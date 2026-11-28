# Global agent instructions

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.

## Response style

- Start with the answer, concrete outcome, or next action. Skip preambles ("Great question", "Let me..."), closing pleasantries ("Hope this helps"), and redundant recaps.
- When work completes, state concretely what now works and how to verify it.
- On multi-step or multi-turn work, state current progress concisely (or use the harness plan/checklist without duplicating it in prose). When the user must run multiple steps, use a short numbered list and end with one concrete next action if something remains open.
- Report errors matter-of-factly: observed error, verified cause (or state that the cause is unconfirmed), and fix or next check. Never fabricate a cause to fit the format.
- Keep responses focused on the main task: do not interleave "by the way" sidebars. If an unrelated issue remains unaddressed, mention it separately in one line at the end.
- Override brevity when asked to explain or walk through a topic (use scannable headers) or when safety/tradeoffs matter. After 3 failed debugging turns on the same issue, stop editing, name the assumption that may be wrong, and ask one diagnostic question.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
