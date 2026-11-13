#!/usr/bin/env bash
# Fails if this PUBLIC repo tracks AI-assistant files or anything secret-shaped.
# Run locally (scripts/install-hooks.sh wires it into pre-commit) and in CI.
set -u
fail=0
files=$(git ls-files)

bad=$(echo "$files" | grep -iE '(^|/)(CLAUDE(\.local)?\.md|AGENTS\.md|GEMINI\.md|MEMORY\.md|\.mcp\.json|\.cursorrules|copilot-instructions\.md)$|(^|/)\.(claude|cursor|codex|windsurf|continue)/|(^|/)\.env($|\.)|\.(pem|p12|pfx|jks|keystore)$|service-account.*\.json$' | grep -v '\.env\.example$')
if [ -n "$bad" ]; then echo "Private/assistant/secret files are tracked:"; echo "$bad"; fail=1; fi

pat='-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|[sr]k_(live|test)_[A-Za-z0-9]{16,}|sk-(ant-)?[A-Za-z0-9_-]{32,}|xox[baprs]-[A-Za-z0-9-]{10,}|npg_[A-Za-z0-9]{8,}|sb_secret_[A-Za-z0-9_-]{16,}|eyJ[A-Za-z0-9_-]{15,}\.eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{10,}|(postgres(ql)?|mysql|mongodb)://[^:/[:space:]]+:[^@[:space:]$]{4,}@|x-api-key[\"'"'"']?[:=][ ]*[\"'"'"'][A-Za-z0-9_-]{16,}'
hits=$(echo "$files" | grep -v '^scripts/check-public-safety.sh$' | xargs grep -InE "$pat" 2>/dev/null | sed -E 's/(.{60}).*/\1…/')
if [ -n "$hits" ]; then echo "Secret-shaped strings found (values truncated):"; echo "$hits"; fail=1; fi

[ $fail -eq 0 ] && echo "public-safety check passed"
exit $fail
