# Friday Newsletter — Claude Code Routine

A scheduled, cloud-hosted Claude Code session that drafts your newsletter every Friday morning. Laptop can be closed.

## Why a Remote Routine (not a local task)

| Option | Runs when laptop closed? | Best for |
|---|---|---|
| `/loop` (in-session) | No — dies on exit | Watching a deploy for an hour |
| Desktop scheduled task | No — needs app open & machine awake | Local file work, repo edits on your box |
| **Remote Routine** ✅ | **Yes — Anthropic cloud** | **Recurring deliverables like a newsletter** |

Remote Routine is the right pick. Each run is a fresh Claude Code session on Anthropic-managed infrastructure with a clean clone of your repo, your MCP connectors, and any skills you've committed.

---

## The Four Configurable Parts

1. **Prompt** — standing instructions (the most important field; runs autonomously, no approval prompts mid-run)
2. **Schedule** — preset (Hourly / Daily / Weekdays / Weekly) or custom cron
3. **Tools & connectors** — repos, MCP servers (Gmail, Drive, Slack, GitHub), network access, env vars, setup script
4. **Output destination** — where the draft lands (PR to a `claude/` branch, Gmail draft, Slack message, etc.)

---

## Setup

**Path:** Claude Code Desktop → **Schedule** in sidebar → **New task** → **New remote task**

> Use the **web UI** (claude.com) instead if you need API-call or GitHub-event triggers — those aren't exposed in Desktop or CLI.

### Required fields

```
Name:          Friday Newsletter Draft
Repository:    <your newsletter repo>            # fresh clone each run from default branch
Schedule:      0 8 * * 5                         # Fridays at 8:00 AM (adjust to your TZ — America/Chicago for Omaha)
Environment:   newsletter                        # holds ANTHROPIC_API_KEY, PERPLEXITY_API_KEY, etc.
Setup script:  ./.routine/setup.sh               # installs Feynman + materializes its config
Connectors:    Gmail, Google Drive, GitHub       # whatever sources the newsletter pulls from
Branch policy: default (claude/* only)           # safe — won't touch main
```

### Environment variables

Configure these in the Routine's environment (web UI → Environments → newsletter):

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Feynman's default model provider |
| `PERPLEXITY_API_KEY` | Feynman's web search provider |
| `FEYNMAN_DEFAULT_MODEL` | e.g. `anthropic:claude-sonnet-4-5` (optional) |

These never leave Anthropic's environment — don't commit them, don't echo them.

---

## Bootstrapping Feynman in the routine

Feynman is a local CLI with config at `~/.feynman/settings.json`. Since each run is a fresh clone with no persisted home, you regenerate the config on every run from a template committed to the repo.

### `.routine/setup.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. Install Feynman (bundled Node runtime, no system deps needed)
curl -fsSL https://feynman.is/install | bash
export PATH="$HOME/.local/bin:$PATH"

# 2. Materialize settings.json from template + env vars
mkdir -p "$HOME/.feynman"
envsubst < .routine/feynman.settings.template.json > "$HOME/.feynman/settings.json"

# 3. Smoke test
feynman --version
```

### `.routine/feynman.settings.template.json`

Commit this; it has no secrets, just placeholders that `envsubst` fills in:

```json
{
  "defaultModel": "${FEYNMAN_DEFAULT_MODEL:-anthropic:claude-sonnet-4-5}",
  "providers": {
    "anthropic": { "apiKey": "${ANTHROPIC_API_KEY}" },
    "perplexity": { "apiKey": "${PERPLEXITY_API_KEY}" }
  },
  "webSearch": { "provider": "perplexity" }
}
```

Verify the exact schema against your current `~/.feynman/settings.json` on your laptop — Feynman's config shape can shift between versions and your local one is the source of truth.

### Network egress

The routine's cloud environment needs to allow outbound HTTPS to:
- `api.anthropic.com`
- `api.perplexity.ai`
- `feynman.is` and any CDN it pulls the bundle from (installer time only)

Configure under Environment → Network access. If your org has tight egress rules, allowlist these explicitly.

### Prompt template

```markdown
You are drafting this week's newsletter. Today is {{date}}.

INPUTS (gather first, in this order):
1. Read NEWSLETTER.md in the repo root for tone, structure, and section headers.
2. Pull this week's curated items from:
   - Gmail: messages labeled `newsletter/source` since last Friday
   - Drive: any docs added to `/Newsletters/Inbox/` since last Friday
3. Run the research phase via Feynman. For each topic surfaced in step 2,
   shell out to: `feynman research "<topic>" --output research/<slug>.md`
   Read the resulting briefs and incorporate cited findings into the draft.
   Do NOT use your own web tools for research — Feynman is the source of truth.
4. Skim the prior issue at `issues/latest.md` so the new draft doesn't repeat items.

OUTPUT:
- Create a new file at `issues/{{YYYY-MM-DD}}.md` using the standard template.
- Open a PR on branch `claude/newsletter-{{YYYY-MM-DD}}` titled "Draft: Newsletter {{YYYY-MM-DD}}".
- PR description should list each section, the source link for each item, and any
  questions or judgment calls flagged with "REVIEW:" so I can scan quickly.

CONSTRAINTS:
- Do not publish or send. Draft only.
- Skip any item you can't verify with a source link.
- Keep section word counts within ±15% of the prior issue.
```

Save the prompt as a committed `SKILL.md` in the repo so it's versioned alongside the newsletter template — that way edits go through the same review you'd give any other change.

---

## Friday Morning Loop

1. **08:00 CT** — Routine fires; cloud session clones the repo, hits connectors, drafts the issue.
2. **08:15ish** — PR notification lands (configure failure alerts in the Routines dashboard while you're at it).
3. **You** — open the PR on your phone over coffee, review the `REVIEW:` flags, edit if needed, merge, and trigger publish.

---

## Things to know before you ship it

- **Pro plan or higher** is required for Routines.
- **Feynman config is regenerated every run** from env vars — that's the design. If you change the local schema, update the template in the repo or runs will silently use stale defaults.
- **Stateless by default** — if you need memory between runs (e.g. "what did we cover last week"), persist it explicitly. Reading `issues/latest.md` from the repo is the simplest version of this.
- **No mid-run approvals** — the prompt is the only steering you get. Be specific about what *not* to do.
- **Branch safety** — Claude can only push to `claude/*` prefixed branches unless you flip "Allow unrestricted branch pushes." Leave it off.
- **Cost scales with frequency × complexity.** Weekly + scoped prompt = cheap. Don't bolt on hourly debug runs and forget about them.
- **Failures** don't auto-retry. Set up failure notifications and manually re-trigger after diagnosing.

---

## Quick CLI alternative

If you'd rather skip the UI, in any Claude Code session:

```
/schedule Draft my newsletter every Friday at 8am CT by pulling Gmail label
newsletter/source and Drive folder /Newsletters/Inbox, write to
issues/{date}.md, and open a PR on a claude/newsletter-* branch.
```

Claude walks the same fields conversationally and saves the routine. For GitHub-event or API triggers, edit it on the web after.
