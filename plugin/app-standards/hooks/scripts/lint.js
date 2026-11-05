#!/usr/bin/env node
// app-standards lint
// Hook mode (default): reads a PostToolUse event on stdin, checks the edited file,
// and reports possible violations to Claude as non-blocking context (JSON on stdout).
// Scan mode: `node lint.js --scan <folder>` checks every file and prints a report.
// It only flags. It never blocks or changes files.
'use strict';

const fs = require('fs');
const path = require('path');

const MAX_FILE_BYTES = 1024 * 1024;
const MAX_HITS_PER_CHECK = 5;
const MAX_MESSAGE_CHARS = 4000;

const SKIP_DIRS = new Set([
  'node_modules', '.git', 'dist', 'build', 'out', '.next', '.nuxt', '.svelte-kit',
  '.output', '.vercel', '.netlify', '.astro', 'coverage', 'vendor', '.turbo', '.cache',
  '.claude', '.claude-plugin', 'public/vendor'
]);
const SKIP_FILES = new Set([
  'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock',
  '.app-standards.json'
]);

const CODE_EXT = new Set(['.html', '.htm', '.css', '.scss', '.sass', '.less', '.js', '.jsx', '.ts', '.tsx', '.mjs', '.cjs', '.vue', '.svelte', '.astro', '.mdx']);
const TEXT_EXT = new Set([...CODE_EXT, '.md', '.txt', '.json']);
const MARKUP_EXT = new Set(['.html', '.htm', '.jsx', '.tsx', '.vue', '.svelte', '.astro', '.mdx', '.js', '.ts', '.mjs', '.cjs']);

const BANNED_FONTS = [
  'Inter', 'Geist', 'Space Grotesk', 'Inter Tight', 'Inter Display', 'Roboto Flex', 'DM Sans',
  'Manrope', 'Plus Jakarta Sans', 'Satoshi', 'General Sans', 'Figtree', 'Outfit', 'Onest',
  'Instrument Sans', 'Hanken Grotesk', 'Albert Sans', 'Be Vietnam Pro', 'Sora', 'Urbanist',
  'Lexend', 'Geologica', 'Space Mono', 'JetBrains Mono', 'Geist Mono', 'IBM Plex Mono'
];
const fontPattern = (name) => name.split(' ').map(escapeRe).join('[\\s+_-]?');
const FONT_RE = new RegExp('(?<![A-Za-z])(' + BANNED_FONTS.slice().sort((a, b) => b.length - a.length).map(fontPattern).join('|') + ')(?![A-Za-z])', 'gi');
const FONT_CONTEXT_RE = /font|family|typeface|@fontsource|next\/font|fonts\.googleapis|fonts\.bunny|fontshare/i;

const ICON_PKG = '(?:lucide(?:-react|-vue(?:-next)?|-svelte|-solid|-angular|-static)?|@lucide\\/[\\w-]+|@heroicons\\/[\\w-]+|heroicons|react-feather|feather-icons|vue-feather|@tabler\\/icons[\\w-]*|@phosphor-icons\\/[\\w-]+|phosphor-react|@radix-ui\\/react-icons|ionicons|@ionic\\/icons|react-icons\\/(?:lu|hi2?|fi|tb|pi|io5?|ri|bs|go|ci|rx))';
const ICON_IMPORT_RE = new RegExp('(?:from\\s*|require\\(\\s*|import\\(\\s*|import\\s+)["\']' + ICON_PKG + '(?=["\'\\/])');
const ICON_DEP_RE = new RegExp('"' + ICON_PKG + '"\\s*:');
const ICON_CDN_RE = new RegExp('(?:src|href)\\s*=\\s*["\'][^"\']*(?:unpkg|jsdelivr|cdnjs)[^"\']*' + '(?:lucide|heroicons|feather|tabler|phosphor|ionicons)', 'i');

const CLASS_CONTEXT_RE = /class(?:Name)?\s*=|:class\s*=|class:|@apply|\bcn\(|\bclsx\(|\bcva\(|\btw`|\btwMerge\(/;

const CHECKS = [
  {
    id: 'banned-font',
    label: 'Banned font (Section 2, see fonts.md)',
    ext: CODE_EXT,
    extraFiles: ['tailwind.config.js', 'tailwind.config.ts', 'tailwind.config.cjs', 'tailwind.config.mjs'],
    test(line) {
      if (!FONT_CONTEXT_RE.test(line)) return [];
      const hits = [];
      let m;
      FONT_RE.lastIndex = 0;
      while ((m = FONT_RE.exec(line)) !== null) hits.push(m[1]);
      return hits;
    }
  },
  {
    id: 'shadow',
    label: 'Shadow (Section 1 bans all shadows)',
    ext: CODE_EXT,
    test(line, ext) {
      const hits = [];
      if (/\b(?:box|text)-shadow\s*:\s*(?!\s*(?:none|unset|initial|inherit)\b)/i.test(line)) hits.push('shadow property');
      if (/\bdrop-shadow\(/i.test(line)) hits.push('drop-shadow()');
      if (/\b(?:boxShadow|textShadow)\s*:\s*(?!\s*["'`]?\s*none\b)/.test(line)) hits.push('shadow style');
      if (MARKUP_EXT.has(ext) || ext === '.css' || ext === '.scss') {
        if (CLASS_CONTEXT_RE.test(line) && /(?:^|[\s"'`{])(?:[\w-]+:)*(?:shadow|drop-shadow|text-shadow)(?:-(?!none\b)[\w[\]/.#-]+)?(?=$|[\s"'`}])/.test(line)) hits.push('shadow class');
      }
      return hits;
    }
  },
  {
    id: 'gradient',
    label: 'Gradient (Section 1 bans gradients)',
    ext: CODE_EXT,
    test(line) {
      const hits = [];
      if (/(?:repeating-)?(?:linear|radial|conic)-gradient\(/i.test(line)) hits.push('CSS gradient');
      if (CLASS_CONTEXT_RE.test(line) && /(?:^|[\s"'`{])(?:[\w-]+:)*bg-(?:gradient|linear|radial|conic)-/.test(line)) hits.push('gradient class');
      return hits;
    }
  },
  {
    id: 'icon-set',
    label: 'Non-approved icon set (Section 4 allows only Material Symbols or Font Awesome)',
    ext: new Set([...CODE_EXT, '.json']),
    test(line, ext, file) {
      if (ext === '.json' && path.basename(file) !== 'package.json') return [];
      const hits = [];
      if (ICON_IMPORT_RE.test(line) || ICON_CDN_RE.test(line)) hits.push('icon import');
      if (ext === '.json' && ICON_DEP_RE.test(line)) hits.push('icon dependency');
      return hits;
    }
  },
  {
    id: 'dash',
    label: 'Em or en dash used as a dash (Section 7)',
    ext: TEXT_EXT,
    test(line, ext, file) {
      if (ext === '.json' && path.basename(file) === 'package.json') return [];
      const hits = [];
      if (line.includes('\u2014')) hits.push('em dash');
      if (/\s\u2013\s/.test(line)) hits.push('spaced en dash');
      return hits;
    }
  },
  {
    id: 'zoom-disabled',
    label: 'Zoom disabled (Section 13 never disables zoom)',
    ext: CODE_EXT,
    test(line) {
      const hits = [];
      if (/user-scalable\s*=\s*(?:no|0)\b/i.test(line) || /userScalable\s*:\s*false/.test(line)) hits.push('user-scalable');
      if (/maximum-scale\s*=\s*1(?:\.0+)?(?![\d.])/i.test(line) || /maximumScale\s*:\s*1(?:\.0+)?(?![\d.])/.test(line)) hits.push('maximum-scale=1');
      return hits;
    }
  },
  {
    id: 'unsafe-html',
    label: 'Raw HTML or eval without visible sanitization (Section 11)',
    ext: CODE_EXT,
    test(line) {
      if (/DOMPurify|sanitize\s*\(/.test(line)) return [];
      const patterns = [
        [/dangerouslySetInnerHTML/, 'dangerouslySetInnerHTML'],
        [/\.(?:inner|outer)HTML\s*\+?=(?!=)/, 'innerHTML assignment'],
        [/\binsertAdjacentHTML\s*\(/, 'insertAdjacentHTML'],
        [/\bv-html\s*=/, 'v-html'],
        [/\{@html\s/, '{@html}'],
        [/\bset:html\s*=/, 'set:html'],
        [/(?<![\w.$])eval\s*\(/, 'eval()'],
        [/\bnew\s+Function\s*\(/, 'new Function()'],
        [/\bdocument\.write(?:ln)?\s*\(/, 'document.write()']
      ];
      return patterns.filter(([re]) => re.test(line)).map(([, name]) => name);
    }
  },
  {
    id: 'sensitive-storage',
    label: 'Sensitive data in browser storage (Section 11)',
    ext: CODE_EXT,
    test(line) {
      const hits = [];
      const keyWords = '(?:token|auth|session|jwt|bearer|user|email|password|passwd|secret|credential|api[-_]?key|refresh|profile|account)';
      if (new RegExp('\\b(?:localStorage|sessionStorage)\\s*\\.\\s*setItem\\s*\\(\\s*["\'`][^"\'`]*' + keyWords, 'i').test(line)) hits.push('setItem with sensitive key');
      if (new RegExp('\\b(?:localStorage|sessionStorage)\\s*\\[\\s*["\'`][^"\'`]*' + keyWords + '[^"\'`]*["\'`]\\s*\\]\\s*=(?!=)', 'i').test(line)) hits.push('assignment with sensitive key');
      if (/\bstorage\s*:\s*(?:window\.)?localStorage\b/.test(line)) hits.push('auth storage set to localStorage');
      return hits;
    }
  },
  {
    id: 'csp-unsafe',
    label: "'unsafe-inline' or 'unsafe-eval' for scripts (Section 11)",
    ext: new Set([...CODE_EXT, '.json', '.toml']),
    test(line) {
      return /script-src(?:-elem|-attr)?[^;]*?'unsafe-(?:inline|eval)'/i.test(line) ? ['script-src unsafe source'] : [];
    }
  },
  {
    id: 'number-input',
    label: 'type="number" on a digit-only field that is not a quantity (Section 6)',
    ext: MARKUP_EXT,
    test(line) {
      if (!/type\s*=\s*\{?\s*["'`]number["'`]/i.test(line)) return [];
      return /(?:zip|postal|phone|tel\b|mobile|card|cc-|cvc|cvv|otp|one-time-code|\bpin\b|verification|code)/i.test(line) ? ['number type'] : [];
    }
  }
];

function escapeRe(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }
function norm(s) { return String(s).toLowerCase().replace(/[\s+_-]/g, ''); }

function findProjectRoot(startDir, fallback) {
  let dir = startDir;
  for (let i = 0; i < 40; i++) {
    if (fs.existsSync(path.join(dir, '.app-standards.json'))) return dir;
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return fallback || startDir;
}

function loadExceptions(root) {
  try {
    const cfg = JSON.parse(fs.readFileSync(path.join(root, '.app-standards.json'), 'utf8'));
    return Array.isArray(cfg.exceptions) ? cfg.exceptions.filter((e) => e && typeof e.rule === 'string') : [];
  } catch (e) {
    return [];
  }
}

function isExcepted(exceptions, checkId, hit, relPath) {
  const rel = relPath.split(path.sep).join('/');
  return exceptions.some((e) => {
    if (e.rule !== checkId) return false;
    if (Array.isArray(e.paths) && e.paths.length && !e.paths.some((p) => rel.startsWith(String(p).replace(/^\.?\//, '')))) return false;
    if (e.value !== undefined && e.value !== null && e.value !== '' && norm(e.value) !== norm(hit)) return false;
    return true;
  });
}

function shouldSkip(file, root) {
  const rel = path.relative(root, file);
  const parts = rel.split(path.sep);
  if (parts.some((p, i) => SKIP_DIRS.has(p) || SKIP_DIRS.has(parts.slice(0, i + 1).join('/')))) return true;
  const base = path.basename(file);
  if (SKIP_FILES.has(base)) return true;
  if (/\.min\.(?:js|css)$/i.test(base) || /\.map$/i.test(base)) return true;
  const pluginRoot = process.env.CLAUDE_PLUGIN_ROOT;
  if (pluginRoot && path.resolve(file).startsWith(path.resolve(pluginRoot))) return true;
  return !TEXT_EXT.has(path.extname(file).toLowerCase()) && !base.startsWith('tailwind.config');
}

function lintFile(file, root, exceptions) {
  let stat;
  try { stat = fs.statSync(file); } catch (e) { return []; }
  if (!stat.isFile() || stat.size > MAX_FILE_BYTES) return [];
  let text;
  try { text = fs.readFileSync(file, 'utf8'); } catch (e) { return []; }
  const ext = path.extname(file).toLowerCase();
  const base = path.basename(file);
  const rel = path.relative(root, file) || base;
  const lines = text.split(/\r?\n/);
  const results = [];
  for (const check of CHECKS) {
    const applies = check.ext.has(ext) || (check.extraFiles && check.extraFiles.includes(base));
    if (!applies) continue;
    const found = [];
    lines.forEach((line, i) => {
      if (line.length > 2000) return;
      const hits = check.test(line, ext, file).filter((h) => !isExcepted(exceptions, check.id, h, rel));
      if (hits.length) found.push({ line: i + 1, hits, text: line.trim().slice(0, 120) });
    });
    if (found.length) results.push({ check, found });
  }
  return results;
}

function formatFile(rel, results) {
  const out = [rel];
  for (const { check, found } of results) {
    out.push(`  [${check.id}] ${check.label}`);
    for (const f of found.slice(0, MAX_HITS_PER_CHECK)) out.push(`    line ${f.line}: ${f.text}`);
    if (found.length > MAX_HITS_PER_CHECK) out.push(`    and ${found.length - MAX_HITS_PER_CHECK} more`);
  }
  return out.join('\n');
}

function walk(dir, root, files) {
  let entries;
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch (e) { return; }
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (SKIP_DIRS.has(entry.name)) continue;
      walk(full, root, files);
    } else if (entry.isFile() && !shouldSkip(full, root)) {
      files.push(full);
    }
  }
}

function scan(target) {
  const root = findProjectRoot(path.resolve(target), path.resolve(target));
  const exceptions = loadExceptions(root);
  const files = [];
  walk(path.resolve(target), root, files);
  const reports = [];
  let count = 0;
  for (const file of files) {
    const results = lintFile(file, root, exceptions);
    if (results.length) {
      count += results.reduce((n, r) => n + r.found.length, 0);
      reports.push(formatFile(path.relative(root, file), results));
    }
  }
  const header = `app-standards lint scan of ${root}: ${files.length} files checked, ${count} possible violations in ${reports.length} files. ${exceptions.length} approved exceptions applied.`;
  process.stdout.write(header + (reports.length ? '\n\n' + reports.join('\n\n') : '') + '\n');
  process.exit(0);
}

function hook(raw) {
  let input;
  try { input = JSON.parse(raw || '{}'); } catch (e) { process.exit(0); }
  const toolInput = input.tool_input || {};
  let file = toolInput.file_path || toolInput.path;
  if (!file || typeof file !== 'string') process.exit(0);
  const cwd = input.cwd || process.cwd();
  if (!path.isAbsolute(file)) file = path.resolve(cwd, file);
  const root = findProjectRoot(path.dirname(file), cwd);
  if (shouldSkip(file, root)) process.exit(0);
  const results = lintFile(file, root, loadExceptions(root));
  if (!results.length) process.exit(0);
  let message = 'app-standards lint found possible rule violations in the file just edited.\n' +
    formatFile(path.relative(root, file) || path.basename(file), results) +
    '\nThese are flags, not blocks. Each one is either fixed, or recorded as an exception in .app-standards.json if the user explicitly approved it.';
  if (message.length > MAX_MESSAGE_CHARS) message = message.slice(0, MAX_MESSAGE_CHARS) + '\n(truncated)';
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: { hookEventName: 'PostToolUse', additionalContext: message }
  }) + '\n');
  process.exit(0);
}

const args = process.argv.slice(2);
if (args[0] === '--scan') {
  scan(args[1] || process.cwd());
} else {
  let raw = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (c) => { raw += c; });
  process.stdin.on('end', () => {
    try { hook(raw); } catch (e) { process.exit(0); }
  });
}
