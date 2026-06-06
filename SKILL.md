# Friday Newsletter Routine

You are producing this week's "This Week in AI" newsletter. Today is {{date}}.
The ISO week number is {{iso_week}} (e.g., 2026-22 for week 22 of 2026).

Audience: Secure Digital Core (SDC) team, Accenture Security.
Distribution: Outlook email. Do not publish or send — draft and PR only.

---

## Step 1 — Read context

1. Read `NEWSLETTER.md` in the repo root. This is the section template and style guide. Follow it exactly.
2. Read `issues/latest.md` (the previous edition) so you know what was already covered. Do not repeat items or "What to Watch" callouts that have already resolved.

---

## Step 2 — Research brief

Run a deep research pass using Feynman. This produces the raw brief that grounds the newsletter.

```bash
feynman deepresearch "AI industry news week of {{YYYY-MM-DD}}: frontier model releases (Anthropic, OpenAI, Google DeepMind, Meta AI, Mistral, xAI), AI safety and alignment research, AI policy and regulation (EU AI Act, NIST, US federal), enterprise AI adoption, AI security risks (prompt injection, model supply chain, agentic AI)"
```

Save the full output to `issues/brief-{{iso_week}}.md`. This is a working artifact — raw notes, not the newsletter.

---

## Step 3 — Draft the newsletter

Run the Feynman draft workflow, which synthesizes the brief into structured prose:

```bash
feynman draft "This Week in AI newsletter for week of {{YYYY-MM-DD}}"
```

Use the output as your starting material. Apply the section structure and callout conventions from `NEWSLETTER.md`. Then write the final newsletter to `issues/{{iso_week}}.md`.

Rules:
- Header: `# This Week in AI — Week of <MONTH DD, YYYY>`
- Add `*ISO Week {{iso_week}} · Distributed to: Secure Digital Core, Accenture Security*` and `*Prepared by: Jacob Nosal | jacob.nosal@accenture.com*` under the title.
- Every item needs at least one inline source link in `([Publication](URL))` format.
- Hedge all vendor-reported metrics inline: "reportedly", "vendor-reported", "claims".
- Unverified rumors: include as a blockquote labeled "Unverified rumor flagged for tracking" — never presented as fact.
- Use the correct callout emoji variant per section (💡 general, 🛡️ SDC, 🎯 Accenture).
- Remove any section header where there is genuinely nothing to report this week — include a `*(No notable X this week.)*` note only for sections where something is expected but absent.
- Flag any item needing human judgment with `REVIEW:` so it is easy to scan in the PR.

---

## Step 4 — Render HTML for Outlook

```bash
pandoc issues/{{iso_week}}.md \
  -o issues/{{iso_week}}.html \
  --standalone \
  --css email.css \
  --embed-resources \
  --metadata pagetitle="This Week in AI"
```

Confirm the HTML file is created at `issues/{{iso_week}}.html`.

---

## Step 5 — Open a PR

Open a pull request:
- Branch: `claude/newsletter-{{iso_week}}`
- Title: `Draft: This Week in AI {{iso_week}}`
- PR body:
  - Section-by-section list of items covered, each with its source link
  - Any `REVIEW:` flags extracted and listed at the top
  - Confirmation that HTML was generated

Do not merge. Leave for Jacob to review, edit if needed, and merge.
