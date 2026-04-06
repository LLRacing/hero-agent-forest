# Hero Agent — JASON/AgentSpeak Forest Navigation Agent

A BDI (Belief-Desire-Intention) agent developed in AgentSpeak (JASON) as part of the **CSCK504 Multi-Agent Systems** module at Kaplan Open Learning (University of Liverpool). The agent navigates an 8x8 grid environment, systematically collects three items (a coin, a gem, and a vase), and delivers them to a goblin agent — handling edge cases including missing items, duplicate items, and teleporters.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-LarryLee-blue?logo=linkedin)](https://www.linkedin.com/in/llracing/)

---

## Demo

**Full Code Walkthrough & Demonstration (Preset 0–5)**  
[![Watch on YouTube](https://img.shields.io/badge/Watch%20on-YouTube-red?logo=youtube)](https://youtu.be/BoDcPMg67QQ)

The video covers a full explanation of the agent code followed by live demonstrations across all six environment presets.

---

## Agent Overview

The Hero agent (`hero.asl`) is written in AgentSpeak and executed via the JASON multi-agent platform. It operates within a forest environment consisting of an 8x8 grid, interacting with percepts and actions exposed by a Java-based environment (`ForestEnv.java`).

The agent's reasoning follows a BDI architecture:
- **Beliefs** are updated from environment percepts (e.g. `pos(hero,X,Y)`, `coin(hero)`, `hero(coin)`)
- **Desires** are expressed as goals (e.g. `!checkItem`, `!toGoblin`)
- **Intentions** are selected plans that are executed to satisfy those goals

---

## Features

### Core Functionality
- Systematic left-to-right, top-to-bottom grid scan using `next(slot)`
- Picks up coin, gem, and vase if not already held
- Navigates to the goblin using `move_towards(X,Y)` and drops all items upon arrival
- Skips visit to goblin if not all three items are found (rational behaviour for Preset 1)

### Teleporter Handling (Preset 4)
- Detects teleportation by comparing expected vs actual position after each scan step
- Computes a resume slot (one step after the teleporter) and navigates to it while actively avoiding the teleporter coordinate
- Uses an 8-directional `predict_step` plan to anticipate the result of each `move_towards` call
- Falls back to a 4-preference detour planner (`detour_one`) when the direct path is blocked by the teleporter

### Re-Teleport Detection (Post-Submission Improvement)
- During teleport recovery navigation, the agent verifies its actual position after every move
- If a re-teleport is detected (actual position differs from predicted), recovery is restarted from the new position with recomputed targets
- This resolves a corner-case loop where the teleporter and the resume target are adjacent, previously causing the agent to cycle indefinitely

### Additional Preset Handling
- **Preset 1** — Detects and reports missing items at end of scan
- **Preset 2** — Handles goblin in a random position via dynamic position query
- **Preset 3** — Skips duplicate items already held and continues scanning
- **Preset 4** — Handles teleporter presence with avoidance and re-teleport recovery (see Teleporter Handling above)
- **Preset 5** — Random configuration handled robustly by the above combined logic

---

## Environment

The forest environment was provided as part of the CSCK504 module and is not included in this repository pending copyright confirmation. The environment files are:

| File | Description |
|---|---|
| `Forest.mas2j` | JASON main configuration file |
| `ForestEnv.java` | Java-based 8x8 grid environment |
| `goblin.asl` | Goblin agent (provided, not assessed) |

To run this project, the above files from the module materials are required. The environment preset can be selected by modifying the argument on line 3 of `Forest.mas2j` (e.g. `ForestEnv(0)` through `ForestEnv(5)`).

---

## Percepts & Actions Reference

| Percept | Meaning |
|---|---|
| `pos(hero, X, Y)` | Hero's current grid position |
| `pos(goblin, X, Y)` | Goblin's current grid position |
| `coin(hero)` / `gem(hero)` / `vase(hero)` | Item present at hero's current position |
| `hero(coin)` / `hero(gem)` / `hero(vase)` | Hero is currently holding the item |

| Action | Meaning |
|---|---|
| `next(slot)` | Advance to next grid position (left-to-right, top-to-bottom) |
| `move_towards(X,Y)` | Move one step toward target coordinate |
| `pick(item)` | Pick up item at current position |
| `drop(item)` | Drop held item at current position |

---

## Commit History

| Commit | Description |
|---|---|
| Initial submission | Systematic grid scan with teleport recovery |
| Post-submission fix | Added re-teleport detection during recovery to prevent corner-case loops |

---

## Author

**Larry Lee**  
CSCK504 Multi-Agent Systems — Kaplan Open Learning (University of Liverpool)  
[LinkedIn](https://www.linkedin.com/in/llracing/)
