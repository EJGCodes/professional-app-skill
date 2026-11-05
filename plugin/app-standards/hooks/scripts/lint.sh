#!/usr/bin/env bash
# app-standards lint (bash fallback for machines without Node.js).
# Runs a reduced set of the checks in lint.js and reports them as non-blocking context. Exceptions in .app-standards.json
# are honored per rule only: any exception for a rule turns that rule off here.
INPUT="$(cat)"
json_str() {
  printf '%s' "$INPUT" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 \
    | sed "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//; s/\\\\\\\\/\\\\/g"
}
FILE="$(json_str file_path)"
[ -z "$FILE" ] && exit 0
CWD="$(json_str cwd)"
[ -z "$CWD" ] && CWD="$(pwd)"
case "$FILE" in /*|[A-Za-z]:*) ;; *) FILE="$CWD/$FILE" ;; esac
[ -f "$FILE" ] || exit 0

case "$FILE" in
  */node_modules/*|*/.git/*|*/dist/*|*/build/*|*/out/*|*/.next/*|*/.nuxt/*|*/.svelte-kit/*|*/.output/*|*/.vercel/*|*/coverage/*|*/vendor/*|*/.claude/*) exit 0 ;;
  *.min.js|*.min.css|*.map|*/package-lock.json|*/yarn.lock|*/pnpm-lock.yaml|*/.app-standards.json) exit 0 ;;
esac
if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
  case "$FILE" in "$CLAUDE_PLUGIN_ROOT"/*) exit 0 ;; esac
fi
EXT=".${FILE##*.}"
EXT="$(printf '%s' "$EXT" | tr 'A-Z' 'a-z')"
case "$EXT" in
  .html|.htm|.css|.scss|.sass|.less|.js|.jsx|.ts|.tsx|.mjs|.cjs|.vue|.svelte|.astro|.mdx) CODE=1 ;;
  .md|.txt|.json) CODE=0 ;;
  *) exit 0 ;;
esac
[ "$(wc -c < "$FILE")" -gt 1048576 ] && exit 0

# Find the project file for rule-level exceptions.
ROOT="$(dirname "$FILE")"
CONFIG=""
while [ -n "$ROOT" ] && [ "$ROOT" != "/" ]; do
  if [ -f "$ROOT/.app-standards.json" ]; then CONFIG="$ROOT/.app-standards.json"; break; fi
  ROOT="$(dirname "$ROOT")"
done
[ -z "$CONFIG" ] && ROOT="$CWD"
excepted() {
  [ -n "$CONFIG" ] && grep -q "\"rule\"[[:space:]]*:[[:space:]]*\"$1\"" "$CONFIG"
}

export LC_ALL=C
REPORT=""
add() { # id label pattern
  excepted "$1" && return
  local hits
  hits="$(grep -nE -- "$3" "$FILE" 2>/dev/null | head -5 | cut -c1-130)"
  [ -n "$hits" ] && REPORT="$REPORT
  [$1] $2
$(printf '%s\n' "$hits" | sed 's/^/    line /')"
}

EM=$'\xe2\x80\x94'
EN=$'\xe2\x80\x93'
BASE="$(basename "$FILE")"
if [ "$BASE" != "package.json" ]; then
  add dash "Em or en dash used as a dash (Section 7)" "$EM|[[:space:]]$EN[[:space:]]"
fi
if [ "$CODE" -eq 1 ]; then
  FONTS="(Inter|Geist|Space[ +_-]?Grotesk|DM[ +_-]?Sans|Manrope|Plus[ +_-]?Jakarta|Satoshi|General[ +_-]?Sans|Figtree|Outfit|Onest|Instrument[ +_-]?Sans|Hanken[ +_-]?Grotesk|Albert[ +_-]?Sans|Be[ +_-]?Vietnam|Sora|Urbanist|Lexend|Geologica|Space[ +_-]?Mono|JetBrains[ +_-]?Mono|IBM[ +_-]?Plex[ +_-]?Mono|Roboto[ +_-]?Flex)"
  CTX="(font|family|@fontsource|next/font|fonts\.googleapis)"
  add banned-font "Banned font (Section 2, see fonts.md)" "$CTX.*(^|[^A-Za-z])$FONTS([^A-Za-z]|$)|(^|[^A-Za-z])$FONTS([^A-Za-z]|$).*$CTX"
  add shadow "Shadow (Section 1 bans all shadows)" "(box|text)-shadow[[:space:]]*:[[:space:]]*[^n[:space:]]|drop-shadow\(|(boxShadow|textShadow)[[:space:]]*:|(class|className)[[:space:]]*=.*(^|[[:space:]\"'\`:])(drop-|text-)?shadow(-(sm|md|lg|xl|2xl|inner|xs|2xs)|[[:space:]\"'\`])"
  add gradient "Gradient (Section 1 bans gradients)" "(linear|radial|conic)-gradient\(|bg-(gradient|linear|radial|conic)-"
  add icon-set "Non-approved icon set (Section 4)" "(from|require\(|import)[[:space:]]*['\"](lucide|@lucide/|@heroicons/|react-feather|feather-icons|@tabler/icons|@phosphor-icons/|phosphor-react|@radix-ui/react-icons|ionicons)"
  add zoom-disabled "Zoom disabled (Section 13)" "user-scalable[[:space:]]*=[[:space:]]*(no|0)|maximum-scale[[:space:]]*=[[:space:]]*1([^0-9.]|$)|userScalable[[:space:]]*:[[:space:]]*false"
  add unsafe-html "Raw HTML or eval (Section 11)" "dangerouslySetInnerHTML|\.(inner|outer)HTML[[:space:]]*=[^=]|v-html[[:space:]]*=|\{@html |set:html[[:space:]]*=|(^|[^A-Za-z0-9_.])eval[[:space:]]*\(|new[[:space:]]+Function[[:space:]]*\("
  add sensitive-storage "Sensitive data in browser storage (Section 11)" "(localStorage|sessionStorage)\.setItem\([[:space:]]*['\"\`][^'\"\`]*([Tt]oken|[Aa]uth|[Ss]ession|[Jj]wt|[Uu]ser|[Ee]mail|[Pp]assword|[Ss]ecret|[Rr]efresh)"
  add number-input "type=number on a digit-only field (Section 6)" "type[[:space:]]*=[[:space:]]*[{]?[[:space:]]*['\"\`]number['\"\`].*(zip|postal|phone|tel|mobile|card|cc-|cvc|cvv|otp|one-time-code|pin|code)|(zip|postal|phone|tel|mobile|card|cc-|cvc|cvv|otp|one-time-code|pin|code).*type[[:space:]]*=[[:space:]]*[{]?[[:space:]]*['\"\`]number['\"\`]"
  add csp-unsafe "'unsafe-inline' or 'unsafe-eval' for scripts (Section 11)" "script-src[^;]*'unsafe-(inline|eval)'"
fi
if [ "$BASE" = "package.json" ]; then
  add icon-set "Non-approved icon set (Section 4)" "\"(lucide[a-z-]*|@lucide/[a-z-]+|@heroicons/[a-z-]+|react-feather|feather-icons|@tabler/icons[a-z-]*|@phosphor-icons/[a-z-]+|phosphor-react|@radix-ui/react-icons|ionicons)\"[[:space:]]*:"
fi

[ -z "$REPORT" ] && exit 0
REL="${FILE#$ROOT/}"
MSG="$(printf 'app-standards lint found possible rule violations in the file just edited.\n%s%s\nThese are flags, not blocks. Each one is either fixed, or recorded as an exception in .app-standards.json if the user explicitly approved it.' "$REL" "$REPORT")"
# Escape for JSON: backslashes, quotes, tabs, control characters, then newlines.
ESC="$(printf '%s' "$MSG" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr -d '\000-\010\013\014\016-\037' | awk 'BEGIN{ORS=""} NR>1{print "\\n"} {print}')"
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$ESC"
exit 0
