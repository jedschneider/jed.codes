---
description: Draft 3 LinkedIn "gap post" variants that tease a blog post
argument-hint: <post-slug> (filename in content/posts/ without .md), or omit for latest
---

# LinkedIn Lead Post — Gap Post Drafter

Draft **3 LinkedIn variants** that drive readers to a blog post on jed.codes.

## Input

Slug: `$ARGUMENTS`

- If a slug was provided, read `content/posts/<slug>.md`.
- If empty, find the most recently modified `content/posts/*.md` (excluding drafts where `draft: true`) and use it.
- Print the resolved post path + title before drafting.

## The gap-post pattern

LinkedIn suppresses posts with external links and rewards standalone value. So:

1. **Give the insight away in the post.** Do not withhold the answer to "earn" the click.
2. **Tease depth, not the answer.** The blog earns clicks by offering a specific artifact, diagram, code, or list the LinkedIn post references but doesn't reproduce.
3. **Link goes in the first comment**, not the post body. End the post with `→ (link in comments)` or similar.

## Structure (each variant)

- **Line 1 — hook.** Concrete claim, counterintuitive result, or specific artifact. No "excited to share," no "I've been thinking about," no throat-clearing.
- **2–5 short lines / lines break for LI readability.** The story or lesson. Standalone valuable — a reader who never clicks still got something.
- **Bridge line.** Names the specific thing the blog goes deeper on (a screenshot, code, list of examples, the how-we-actually-did-it).
- **CTA line.** `→ (link in comments)` or a variant. No hashtag spam. 0–2 hashtags max, only if genuinely relevant.
- **Length.** ~600–1200 chars total. LinkedIn cuts off around 210 chars in the feed before "see more" — the hook must land in the first 2 lines.

## Three angles — draft ONE variant for each

Use different angles so I can pick the strongest hook for this specific post:

- **A. Counterintuitive frame.** Lead with a claim that sounds wrong or surprising, then justify.
- **B. Artifact-forward.** Lead with a concrete thing you built / shipped / measured. Names, numbers, screenshots.
- **C. Personal / secret-sauce.** Softer, more first-person. Good for posts about tools, process, or taste.

## Output format

For each variant, output exactly:

```
### Variant A — <angle name>

<the post copy, ready to paste into LinkedIn, with line breaks preserved>

**First comment:** <url> — <one sentence>
```

Then after all three, add:

```
### Pick

<one sentence recommending A/B/C for this specific post and why>
```

## Rules

- Base URL for the link: `https://jed.codes/posts/<slug>/`
- Do NOT invent facts not in the post. If the post doesn't have a number or artifact, don't fabricate one.
- Do NOT use emojis unless the post itself uses them.
- Do NOT use em-dashes as a stylistic tic. One or two is fine; more reads as AI.
- Match the post's voice — read it first and mirror the register (technical, personal, opinionated, etc.).
- Save nothing to disk. Output only. The user will copy the winner into LinkedIn.
