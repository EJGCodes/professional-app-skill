#!/usr/bin/env bash
# app-standards lint (bash fallback for machines without Node.js).
# Hook mode (default): checks the edited file and reports possible violations as non-blocking context.
# Stop mode (--stop): re-checks the files edited this turn for the gate checks, and asks Claude to fix them, at most twice.
# Runs a reduced set of the checks in lint.js. Exceptions in .app-standards.json are honored per rule only:
# any exception for a rule turns that rule off here.
MODE="${1:-hook}"
INPUT="$(cat)"
json_str() {
  printf '%s' "$INPUT" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 \
    | sed "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//; s/\\\\\\\\/\\\\/g"
}
json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr -d '\000-\010\013\014\016-\037' \
    | awk 'BEGIN{ORS=""} NR>1{print "\\n"} {print}'
}

CWD="$(json_str cwd)"
[ -z "$CWD" ] && CWD="$(pwd)"
SESSION="$(json_str session_id | tr -c 'A-Za-z0-9_-' '_' | cut -c1-100)"
[ -z "$SESSION" ] && SESSION="default"
STATE_DIR="${TMPDIR:-/tmp}/app-standards-hooks"
STATE_FILES="$STATE_DIR/$SESSION.files"
STATE_BLOCKS="$STATE_DIR/$SESSION.blocks"

export LC_ALL=C
EM=$'\xe2\x80\x94'
EN=$'\xe2\x80\x93'
SEP="$(printf '\xc2\xb7|\xe2\x80\xa2|\xe2\x8b\x85|\xe2\x88\x99')|&(middot|bull|sdot);|&#(183|8226|8901|x[bB]7|x2022);"
FONTS="(Inter|Geist|Space[ +_-]?Grotesk|DM[ +_-]?Sans|Manrope|Plus[ +_-]?Jakarta|Satoshi|General[ +_-]?Sans|Figtree|Outfit|Onest|Instrument[ +_-]?Sans|Hanken[ +_-]?Grotesk|Albert[ +_-]?Sans|Be[ +_-]?Vietnam|Sora|Urbanist|Lexend|Geologica|Space[ +_-]?Mono|JetBrains[ +_-]?Mono|IBM[ +_-]?Plex[ +_-]?Mono|Roboto[ +_-]?Flex)"
CTX="(font|family|@fontsource|next/font|fonts\.googleapis)"
VAGUE="([Ww]hy (it|this) (matters|helps)|[Tt]he (problem|solution|bottom line|big picture|magic)|[Uu]nder the hood|[Ww]hat makes us different|[Hh]ere.s the thing|[Bb]ehind the scenes|[Ll]et.s dive in)"
HEADING="(^[[:space:]]{0,3}#{1,6}[[:space:]]|<h[1-6][[:space:]>])"

# Sets FILE, ROOT, CONFIG, EXT, CODE, BASE for a path. Returns 1 when the file is skipped.
prepare() {
  FILE="$1"
  case "$FILE" in /*|[A-Za-z]:*) ;; *) FILE="$CWD/$FILE" ;; esac
  [ -f "$FILE" ] || return 1
  case "$FILE" in
    */node_modules/*|*/.git/*|*/dist/*|*/build/*|*/out/*|*/.next/*|*/.nuxt/*|*/.svelte-kit/*|*/.output/*|*/.vercel/*|*/coverage/*|*/vendor/*|*/.claude/*) return 1 ;;
    *.min.js|*.min.css|*.map|*/package-lock.json|*/yarn.lock|*/pnpm-lock.yaml|*/.app-standards.json) return 1 ;;
  esac
  if [ -n "$CLAUDE_PLUGIN_ROOT" ]; then
    case "$FILE" in "$CLAUDE_PLUGIN_ROOT"/*) return 1 ;; esac
  fi
  EXT=".${FILE##*.}"
  EXT="$(printf '%s' "$EXT" | tr 'A-Z' 'a-z')"
  case "$EXT" in
    .html|.htm|.css|.scss|.sass|.less|.js|.jsx|.ts|.tsx|.mjs|.cjs|.vue|.svelte|.astro|.mdx) CODE=1 ;;
    .md|.txt|.json) CODE=0 ;;
    *) return 1 ;;
  esac
  [ "$(wc -c < "$FILE")" -gt 1048576 ] && return 1
  BASE="$(basename "$FILE")"
  ROOT="$(dirname "$FILE")"
  CONFIG=""
  while [ -n "$ROOT" ] && [ "$ROOT" != "/" ]; do
    if [ -f "$ROOT/.app-standards.json" ]; then CONFIG="$ROOT/.app-standards.json"; break; fi
    ROOT="$(dirname "$ROOT")"
  done
  [ -z "$CONFIG" ] && ROOT="$CWD"
  return 0
}

excepted() {
  [ -n "$CONFIG" ] && grep -q "\"rule\"[[:space:]]*:[[:space:]]*\"$1\"" "$CONFIG"
}

REPORT=""
add() { # id label pattern
  excepted "$1" && return
  local hits
  hits="$(grep -nE -- "$3" "$FILE" 2>/dev/null | head -5 | cut -c1-130)"
  [ -n "$hits" ] && REPORT="$REPORT
  [$1] $2
$(printf '%s\n' "$hits" | sed 's/^/    line /')"
}
add_heading() { # id label pattern (only on heading lines)
  excepted "$1" && return
  local hits
  hits="$(grep -nE -- "$HEADING" "$FILE" 2>/dev/null | grep -E -- "$3" | head -5 | cut -c1-130)"
  [ -n "$hits" ] && REPORT="$REPORT
  [$1] $2
$(printf '%s\n' "$hits" | sed 's/^/    line /')"
}

gate_checks() {
  if [ "$BASE" != "package.json" ]; then
    add dash "Em or en dash used as a dash (Section 7)" "$EM|[[:space:]]$EN[[:space:]]"
    add separator "Separator character between inline items (Section 7)" "$SEP"
  fi
  if [ "$CODE" -eq 1 ]; then
    add banned-font "Banned font (Section 2, see fonts.md)" "$CTX.*(^|[^A-Za-z])$FONTS([^A-Za-z]|$)|(^|[^A-Za-z])$FONTS([^A-Za-z]|$).*$CTX"
    add encoded-asset "Encoded image or font, or pasted icon drawing data (Section 4)" "data:(image|font|audio|video|application/(font|x-font|octet-stream))[^,[:space:]\"')]*[;,]|<path[^>]*[[:space:]]d[[:space:]]*=[[:space:]]*[{]?[[:space:]]*[\"'][^\"']{60,}"
  fi
  case "$EXT" in
    .md|.html|.htm|.jsx|.tsx|.vue|.svelte|.astro|.mdx|.js|.ts|.mjs|.cjs)
      add_heading vague-title "Vague or dramatic section title (Section 7, see writing.md)" "$VAGUE" ;;
  esac
}

flag_checks() {
  if [ "$CODE" -eq 1 ]; then
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
  if [ "$BASE" = "vercel.json" ] && ! excepted vercel-config; then
    local v=""
    grep -q '"\$schema"' "$FILE" || v="$v
    line 1: Add \"\$schema\": \"https://openapi.vercel.sh/vercel.json\""
    local legacy
    legacy="$(grep -nE '^[[:space:]]{0,4}"(name|version|alias|builds)"[[:space:]]*:' "$FILE" | head -4)"
    [ -n "$legacy" ] && v="$v
$(printf '%s\n' "$legacy" | sed 's/^/    line /;s/$/ (legacy property)/')"
    [ -n "$v" ] && REPORT="$REPORT
  [vercel-config] vercel.json problem that can stop deployment (Section 13)$v"
  fi
}

if [ "$MODE" = "--stop" ]; then
  [ -f "$STATE_FILES" ] || exit 0
  ALL=""
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    prepare "$f" || continue
    REPORT=""
    gate_checks
    [ -n "$REPORT" ] && ALL="$ALL
${FILE#$ROOT/}$REPORT"
  done < "$STATE_FILES"
  BLOCKS="$(cat "$STATE_BLOCKS" 2>/dev/null || echo 0)"
  if [ -z "$ALL" ] || [ "$BLOCKS" -ge 2 ]; then
    rm -f "$STATE_FILES" "$STATE_BLOCKS"
    exit 0
  fi
  BLOCKS=$((BLOCKS + 1))
  printf '%s' "$BLOCKS" > "$STATE_BLOCKS"
  if [ "$BLOCKS" -ge 2 ]; then
    TAIL='This is the final check for this turn. Fix what you can; anything left open goes under "Notes" in the delivery summary, or is recorded as an exception in .app-standards.json if the user explicitly approved it.'
  else
    TAIL='Fix each one, or record it as an exception in .app-standards.json if the user explicitly approved it.'
  fi
  MSG="app-standards end-of-turn check: files changed in this turn still break rules that must be fixed before finishing (dashes, separator characters, banned fonts, encoded images or pasted icon drawings, and vague section titles).$ALL
$TAIL"
  printf '{"decision":"block","reason":"%s"}\n' "$(json_escape "$MSG")"
  exit 0
fi

# Hook mode
TARGET="$(json_str file_path)"
[ -z "$TARGET" ] && exit 0
prepare "$TARGET" || exit 0
mkdir -p "$STATE_DIR" 2>/dev/null && { grep -qxF "$FILE" "$STATE_FILES" 2>/dev/null || printf '%s\n' "$FILE" >> "$STATE_FILES"; }
gate_checks
flag_checks
[ -z "$REPORT" ] && exit 0
MSG="app-standards lint found possible rule violations in the file just edited.
${FILE#$ROOT/}$REPORT
These are flags, not blocks. Each one is either fixed, or recorded as an exception in .app-standards.json if the user explicitly approved it."
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$(json_escape "$MSG")"
exit 0
