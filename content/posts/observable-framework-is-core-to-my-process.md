---
title: "Observable Framework Is Core to My Process"
date: 2026-07-02T15:39:53-07:00
draft: false
tags: ['observable', 'tooling', 'data']
description: "Why Observable Framework — a static site generator with a first-class DuckDB WASM client — has become a core part of how I explore data."
images: ["/images/observable-framework-core-to-my-process.png"]
---

![Stylized illustration of the Observable Framework at the center of a data workflow — a glowing hub labeled "Observable Framework" with spokes to "Data Exploration", "Static Site Generation", "DuckDB WASM Client", "LLM-Friendly Workflow", and "Analysis"; on the right, sample dashboards for XC ski competitor ranking, S3 lifecycle analysis, CloudTrail structured logs, and impact analysis.](/images/observable-framework-core-to-my-process.png)

One of the first projects I got excited about was [Webby](https://rubygems.org/gems/webby) — a small Ruby gem that generated a static site from markdown. Before the [JAMstack](https://jamstack.org/) 'revolution', static sites were a niche, but one that existed for sure. [Jekyll](https://jekyllrb.com/) won that early market.[^1] Long before NPM supply chain attacks were on anyone's radar, I loved the idea of simple websites with limited upkeep. Yesterday I shipped [search for this blog](/search/) (built on [Hugo](https://gohugo.io/)) powered by a precompiled index. Simple, beautiful, future proof.

As I start blogging more regularly again, I expect I'll keep coming back to the core tooling and base tech that drive my process. [Observable Framework](https://observablehq.com/framework/) is one of those tools. Admittedly, it's a terrible name — terrible to search for — but worth bookmarking.

Observable is co-founded by [Mike Bostock](https://en.wikipedia.org/wiki/Mike_Bostock), the creator of [D3.js](https://d3js.org/). What I've found useful is that Framework is an easy aggregator of data with a simpler execution model than Jupyter, in my estimation.

Critically for me, it ships with a powerful [DuckDB WASM](https://duckdb.org/docs/api/wasm/overview) client as part of the central workflow, which makes it very useful for data exploration and analysis. A few examples I've built with it recently:

1. [An analysis of XC ski competitors](https://jedschneider.github.io/oisran-state-championship-ranking/)
2. S3 bucket analysis — object versions, lifecycle cost modeling, and other storage optimizations.
3. Structured log analysis of AWS CloudTrail logs as a precursor to building data pipelines on top of structured log information — including tracing spans built around structured logs instead of trace data.
4. An impact analysis at my current client, combining code contributions with other data sources to provide a view of the value my work delivered to the business.

![Screenshot of an S3 Version Analysis dashboard built in Observable Framework: header stats for total size, versions total, objects count, and versioning percent; a treemap of storage by prefix; stacked bars of state storage by sub-prefix type; a bulk re-processing events timeline; per-bucket size breakdowns; and a storage cost modeling section showing total savings potential.](/images/observable-framework-s3-analysis.png)

Yes, the labels above read like "S3 Veroin of analysis" and "Rannong azoding called on çloelbat subzroion moales" — turns out image models still can't spell their way out of a bucket, but you get the idea. Framework makes it cheap to point DuckDB at an inventory export, iterate on the treemap and cost model in the same file, and hand the stakeholder a static page instead of a notebook they can't run.

![Screenshot of a Consulting Impact dashboard built in Observable Framework: header stats for 137 Merge Requests, 7 Initiatives, 170 Distinct Tech, and an engagement window of 2025-12 to 2026-07; a horizontal bar chart of work by type (infra, api, observability, data-eng, ci-cd, devex, ui); a monthly merge-requests-over-time histogram; and a grid of initiative cards including Structured Logging, Web Analytics, Point-in-Time Recovery for S3, Audio & Video Pipeline, Observability, and Data Engineering.](/images/observable-framework-impact-analysis.png)

The impact dashboard is the same shape: point Framework at merged-MR history and initiative metadata, let DuckDB do the aggregation, ship a page that becomes a point of conversation, with dynamic data to support the conversation.

In each of these cases, Claude did most of the heavy lifting. For whatever reason the Observable Framework workflow seems reasonably LLM-friendly and consistent in its results.

I count this tech as part of my secret sauce. If you're looking to learn more, [reach out](/contact/) and get in touch.

[^1]: If you're evaluating Jekyll today, consider [Bridgetown](https://www.bridgetownrb.com/) instead — a modern Ruby-powered successor with a healthier build story.
