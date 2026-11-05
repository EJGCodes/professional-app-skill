#!/usr/bin/env node
// app-standards session start
// Prints a one-line note when the session starts in an application project,
// so Claude loads the standards skill before building. Prints nothing elsewhere.
'use strict';

const fs = require('fs');
const path = require('path');

const APP_MARKERS = [
  'package.json', 'index.html', 'vercel.json', 'netlify.toml', '.app-standards.json',
  'astro.config.mjs', 'astro.config.ts', 'next.config.js', 'next.config.mjs', 'next.config.ts',
  'nuxt.config.ts', 'nuxt.config.js', 'svelte.config.js', 'vite.config.ts', 'vite.config.js',
  'remix.config.js', 'angular.json', 'pubspec.yaml', 'build.gradle', 'build.gradle.kts',
  'src-tauri', 'supabase'
];
// In-game UIs are out of scope, so engine projects get no note.
const GAME_MARKERS = ['ProjectSettings', 'project.godot', 'default.project.json'];

function has(dir, name) { return fs.existsSync(path.join(dir, name)); }

function main(raw) {
  let input = {};
  try { input = JSON.parse(raw || '{}'); } catch (e) { input = {}; }
  const dir = input.cwd || process.cwd();
  let entries = [];
  try { entries = fs.readdirSync(dir); } catch (e) { return; }
  if (GAME_MARKERS.some((m) => has(dir, m)) || entries.some((e) => e.endsWith('.uproject'))) return;
  const isApp = APP_MARKERS.some((m) => has(dir, m)) || entries.some((e) => e.endsWith('.xcodeproj'));
  if (!isApp) return;
  let note = 'This folder is an application project. The app-standards plugin\'s standards skill applies to building, editing or reviewing it, and is loaded before that work begins.';
  if (has(dir, '.app-standards.json')) note += ' Project settings and approved rule exceptions are recorded in .app-standards.json.';
  else note += ' No .app-standards.json exists yet; /app-standards:new-app creates one.';
  process.stdout.write(note + '\n');
}

let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (c) => { raw += c; });
process.stdin.on('end', () => {
  try { main(raw); } catch (e) { /* never break a session */ }
  process.exit(0);
});
