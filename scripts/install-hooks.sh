#!/usr/bin/env bash
# Installs a pre-commit hook that blocks assistant files and secrets in this public repo.
set -e
printf '#!/usr/bin/env bash\ngit diff --cached --name-only | grep -iE "(^|/)(CLAUDE(\\.local)?\\.md|AGENTS\\.md|MEMORY\\.md|\\.mcp\\.json)$|(^|/)\\.(claude|cursor)/|(^|/)\\.env($|\\.)" | grep -v "\\.env\\.example$" && { echo "Blocked: assistant/secret file staged"; exit 1; }\nexec scripts/check-public-safety.sh\n' > "$(git rev-parse --git-dir)/hooks/pre-commit"
chmod +x "$(git rev-parse --git-dir)/hooks/pre-commit"
echo "pre-commit hook installed"
