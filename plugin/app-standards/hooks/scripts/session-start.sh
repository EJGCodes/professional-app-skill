#!/usr/bin/env bash
# app-standards session start (bash fallback for machines without Node.js).
INPUT="$(cat)"
DIR="$(printf '%s' "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"cwd"[[:space:]]*:[[:space:]]*"//; s/"$//; s/\\\\/\\/g')"
[ -z "$DIR" ] && DIR="$(pwd)"
[ -d "$DIR" ] || exit 0

# In-game UIs are out of scope, so engine projects get no note.
for m in ProjectSettings project.godot default.project.json; do
  [ -e "$DIR/$m" ] && exit 0
done
ls "$DIR"/*.uproject >/dev/null 2>&1 && exit 0

APP=0
for m in package.json index.html vercel.json netlify.toml .app-standards.json astro.config.mjs astro.config.ts \
  next.config.js next.config.mjs next.config.ts nuxt.config.ts nuxt.config.js svelte.config.js vite.config.ts \
  vite.config.js remix.config.js angular.json pubspec.yaml build.gradle build.gradle.kts src-tauri supabase; do
  if [ -e "$DIR/$m" ]; then APP=1; break; fi
done
ls -d "$DIR"/*.xcodeproj >/dev/null 2>&1 && APP=1
[ "$APP" -eq 1 ] || exit 0

NOTE="This folder is an application project. The app-standards plugin's standards skill applies to building, editing or reviewing it, and is loaded before that work begins."
if [ -e "$DIR/.app-standards.json" ]; then
  NOTE="$NOTE Project settings and approved rule exceptions are recorded in .app-standards.json."
else
  NOTE="$NOTE No .app-standards.json exists yet; /app-standards:new-app creates one."
fi
printf '%s\n' "$NOTE"
exit 0
