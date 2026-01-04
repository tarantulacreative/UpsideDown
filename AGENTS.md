# Agent Guidelines

## Repo scope
This file applies to the entire repository.

## Purpose
UpsideDown is a Verse codebase. Keep documentation and support files aligned with the
Upside Down system philosophy: modular, event-driven gameplay systems with explicit
state transitions and player-safe authority management.

## Non-negotiables
- **Event-driven transitions:** State changes are triggered by explicit events, not
  polling loops or hidden side effects.
- **Clean entry/exit:** Every system must have predictable setup and teardown paths.
- **Reversible overrides:** Temporary overrides must restore previous state safely.
- **Multiplayer-safe authority ownership:** Server/client authority boundaries must
  be respected and explicit.
- **UI stack restoration:** UI transitions must restore prior stack state when closing.

## Contribution expectations
- Document changes alongside implementation changes.
- Prefer small, composable systems and named events.
- Avoid incidental coupling between player, UI, and world systems.

## PR notes
- Summaries should call out how changes honor the non-negotiables.
