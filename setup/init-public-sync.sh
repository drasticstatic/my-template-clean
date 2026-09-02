#!/usr/bin/env bash
# init-public-sync.sh — scaffold .github/workflows/sync-public.yml from this repo's
# workflow-templates/, after asking whether the repo should use the allowlist or
# denylist (excludelist) sync model.
#
# Run this from the root of a repo created from the my-template-clean GitHub template.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/workflow-templates"
DEST_DIR="$REPO_ROOT/.github/workflows"
DEST_FILE="$DEST_DIR/sync-public.yml"

echo "🌐 Public-preview sync setup"
echo ""

if [ -f "$DEST_FILE" ]; then
  read -r -p "⚠️  $DEST_FILE already exists. Overwrite it? [y/N] " overwrite
  case "$overwrite" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted — leaving existing file untouched."; exit 0 ;;
  esac
fi

echo "Which sync model does this repo need?"
echo ""
echo "  1) Allowlist  — strict. Most content stays private; only paths you name"
echo "                  explicitly get synced. CI fails if a new root path isn't"
echo "                  classified yet. Use when most of the repo is private."
echo "  2) Denylist   — open. Most content is public by default; only paths you"
echo "                  name explicitly are stripped before syncing. Use when"
echo "                  most of the repo is meant to be public."
echo ""
read -r -p "Choose [1/2]: " model_choice

case "$model_choice" in
  1)
    SOURCE_FILE="$TEMPLATES_DIR/sync-public-allowlist.yml"
    MODEL_NAME="allowlist"
    ;;
  2)
    SOURCE_FILE="$TEMPLATES_DIR/sync-public-excludelist.yml"
    MODEL_NAME="denylist"
    ;;
  *)
    echo "Not a valid choice (expected 1 or 2). Aborting." >&2
    exit 1
    ;;
esac

if [ ! -f "$SOURCE_FILE" ]; then
  echo "Expected template not found at $SOURCE_FILE" >&2
  exit 1
fi

# Try to default the owner/repo from the git remote; fall back to prompting.
default_owner=""
default_repo=""
if remote_url="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null)"; then
  # Handles both git@github.com:owner/repo.git and https://github.com/owner/repo.git
  stripped="${remote_url#*github.com[:/]}"
  stripped="${stripped%.git}"
  default_owner="${stripped%%/*}"
  default_repo="${stripped##*/}"
fi

read -r -p "GitHub owner/org for the PUBLIC repo [${default_owner:-none detected}]: " owner_input
owner="${owner_input:-$default_owner}"

read -r -p "PUBLIC repo name (e.g. my-repo-public-preview) [${default_repo:+${default_repo}-public-preview}]: " repo_input
if [ -n "$repo_input" ]; then
  public_repo="$repo_input"
elif [ -n "$default_repo" ]; then
  public_repo="${default_repo}-public-preview"
else
  public_repo=""
fi

if [ -z "$owner" ] || [ -z "$public_repo" ]; then
  echo "Owner and public repo name are both required. Aborting." >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
sed -e "s/YOUR_USERNAME/${owner}/g" -e "s/YOUR_PUBLIC_REPO/${public_repo}/g" \
  "$SOURCE_FILE" > "$DEST_FILE"

echo ""
echo "✅ Wrote $DEST_FILE (${MODEL_NAME} model), targeting ${owner}/${public_repo}"
echo ""
echo "Next steps:"
echo "  1. If using the allowlist model, edit the public_allowlist/private_allowlist"
echo "     lists in $DEST_FILE for this repo's actual root paths."
echo "     If using the denylist model, edit the --path strip list instead."
echo "  2. Create the public repo on GitHub if it doesn't exist yet:"
echo "       gh repo create ${owner}/${public_repo} --public"
echo "  3. Create a classic PAT with 'repo' + 'workflow' scopes at"
echo "     github.com/settings/tokens, then set it as a secret on THIS (private) repo"
echo "     yourself — do not paste the token into an agent session:"
echo "       gh secret set PUBLIC_REPO_TOKEN --repo ${owner}/$(basename "$REPO_ROOT")"
echo "  4. Commit and push $DEST_FILE to trigger the first sync run."
