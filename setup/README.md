> **Reusable repo scaffolding — `.gitignore`, `.augmentignore`, `CLAUDE.md`, sync workflows, gitexporter config, deploy scripts, and branch protection rulesets.**

---

## What's Included

| File | Purpose |
|------|---------|
| `.gitignore` | Master ignore rules — secrets, OS files, build artifacts, Node, Python, Solidity, React/Vite |
| `.augmentignore` | Controls what Augment Code indexes — includes dependency context, excludes noise |
| `CLAUDE.md` | Stub for Claude Code CLI persistent instructions — fill in per-repo |
| `.github/dependabot.yml` | Grouped Dependabot version updates — npm + GitHub Actions |
| `workflow-templates/sync-public-allowlist.yml` | Sync private → public via **allowlist** (strict — everything private by default) — scaffolded into `.github/workflows/` by `setup/init-public-sync.sh` |
| `workflow-templates/sync-public-excludelist.yml` | Sync private → public via **exclude list** (open — everything public except named paths) — scaffolded into `.github/workflows/` by `setup/init-public-sync.sh` |
| `setup/init-public-sync.sh` | Interactive setup script — prompts for allowlist vs. denylist and scaffolds `.github/workflows/sync-public.yml` for you |
| `gitexporter.config.json` | Local gitexporter config — selective commit-history-preserving public preview |
| `branch-protection/ruleset.json` | GitHub branch protection ruleset — prevents force-push and deletion on `main` |

---

## Workflow Patterns

### Sync to public repo — which model to use?

Run `./setup/init-public-sync.sh` from the repo root. It asks whether you want the allowlist or
denylist model, asks (or detects from `git remote origin`) the target public repo's owner/name, and
writes a filled-in `.github/workflows/sync-public.yml` for you — no manual copy-and-placeholder-edit
needed. It won't touch a `sync-public.yml` that already exists without asking first.

| Model | Use when | File |
|-------|----------|------|
| **Allowlist** | Most content is private; a small set is safe to publish | `sync-public-allowlist.yml` |
| **Exclude list** | Most content is public; a named set must stay private | `sync-public-excludelist.yml` |

Both use `git filter-repo --invert-paths` under the hood. The allowlist model adds a validation step that fails CI if an unclassified root-level path appears — forces an explicit privacy decision on every new file.

The PAT (`PUBLIC_REPO_TOKEN`) itself is never handled by the script or by an agent session — set it
yourself with the `gh secret set` command the script prints at the end.

### gitexporter vs sync-public.yml

| Tool | Mechanism | History |
|------|-----------|---------|
| `sync-public.yml` (GitHub Actions) | Runs on push, rewrites and force-pushes to public repo | Preserved via filter-repo |
| `gitexporter` | Local CLI tool, run manually | Preserved — traverses full commit tree |

Use `sync-public.yml` for automated continuous sync. Use `gitexporter` for a one-time or on-demand local preview before the workflow is set up.

---

## Related How-To Guides

Full setup walkthroughs live in the [`drasticstatic` profile repo](https://github.com/drasticstatic/drasticstatic):

- [`how-to-setup-GITEXPORTER.md`](https://github.com/drasticstatic/drasticstatic/blob/main/how-to-setup-GITEXPORTER.md) — GitExporter + sync-public.yml full pipeline
- [`how-to-publish-react-APPS-to-ghPAGES.md`](https://github.com/drasticstatic/drasticstatic/blob/main/how-to-publish-react-APPS-to-ghPAGES.md) — CRA and Vite apps to GitHub Pages
- [`how-to-setup-BRANCH-PROTECTION-and-TOPICS.md`](https://github.com/drasticstatic/drasticstatic/blob/main/how-to-setup-BRANCH-PROTECTION-and-TOPICS.md) — Branch protection rulesets and GitHub topics via `gh api`

