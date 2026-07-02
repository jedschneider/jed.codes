---
title: "TDD is the lab, telemetry is the field"
date: 2026-07-01T21:41:52-07:00
draft: false
---

Noah Betzen's ["Telemetry Driven Development"](https://www.youtube.com/watch?v=irQicdafnyM) talk from ElixirConf gave me a reason to write down a conviction I've been carrying for a while: for most of us, Test Driven Development (TDD) is a substitute for understanding how the system behaves. A more honest description is that it *models* how the system behaves against a set of predefined behaviors and expectations. TDD is a model of behavior — not the behavior of the system at large. Telemetry, then, is the field science that either proves or disproves the model we described in the lab.

Noah opens on [Stafford Beer's axiom](https://en.wikipedia.org/wiki/The_purpose_of_a_system_is_what_it_does):

> The purpose of a system is what it does

This is apt, and increasingly relevant, as engineers feel detached from the behavior of the system now that they spend less time painstakingly implementing its components. How do we determine correctness? Telemetry, for sure, helps.

Noah, if you read this: you're not alone in thinking about how to translate the processes and concepts of TDD into a Telemetry Driven Development practice. The premise was (I think) intended as an analogy to TDD, and I'm not sure the talk arrived concretely at that promise — but that isn't a critique. It's an acknowledgement of how much context you have to set for an audience that may never have considered observability or telemetry before. The vocabulary isn't shared yet, and the work of building it is what makes a talk like this useful.

There's more I want to chew on here — what a red/green/refactor loop looks like when the signal is a span instead of an assertion, and whether the "lab" ever catches up to the "field" as systems get less deterministic. Thanks Noah for opening the conversation.
