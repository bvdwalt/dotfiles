---
name: deep-review
description: Deep, staff engineer style code review of a change — validates business logic and bugs, security, simplicity and architectural fit, and code quality against the repo's own conventions. Use when the user says "deep review", "do a thorough/deep code review", "review my code like a reviewer would", or invokes /deep-review. For a quick lint-style diff pass, use the built-in /code-review instead.
user-invocable: true
argument-hint: [optional target: paths, commit range, or PR#] [--fix]
---

# Deep Review

Review a change the way a careful staff engineer would: catch business-logic bugs,
security problems, unnecessary complexity, poor architectural fit, and code-quality
issues — not just style. Defer to the repo's own rules (README, CONTRIBUTING, linter
config, any conventions docs it has) so the review never contradicts what the codebase
already documents.

Complexity, architectural fit, and code quality are usually the most common recurring
problems — weight the review accordingly. A change that works but adds an abstraction
nobody needed is a finding, not a pass.

This is the deep review. The built-in `/code-review` is the fast diff pass; do not
duplicate it — this skill reads full files, judges intent, and pauses to ask when
business logic is unclear.

## Step 1 — Determine what to review

Parse the argument, if any:

- **No argument** → review the uncommitted working-tree changes **plus** branch commits
  vs the default branch. Get them with:
  ```bash
  git diff main...HEAD          # committed on this branch (adjust base branch name if needed)
  git diff                      # unstaged working tree
  git diff --staged             # staged
  ```
- **Paths** (files/dirs) → review only those.
- **Commit range** (e.g. `abc123..def456`) → `git diff <range>`.
- **`PR#`** (a number, optionally `#123`) → use `gh pr diff <number>` and `gh pr view <number>` if `gh` is available; otherwise ask the user to provide the diff (or a commit range) and use `git diff`.
- **`--fix`** anywhere in the argument → enable fix mode (see Step 7). Strip it before
  parsing the target.

If there is nothing to review (empty diff), say so and stop.

When reviewing a PR, the description should state the **business problem** the change
solves — not just what the code does. If the description is missing, empty, or only the
unfilled template, ask the author to write one before reviewing. A review without stated
intent can only check style, and that is what `/code-review` is for.

Before starting the review, first ensure you fully understand the feature being reviewed.
Do not begin the review immediately.

1. Read the provided information and write a brief summary (2–5 sentences)
   describing your understanding of the feature, including its purpose, expected
   behavior, and any assumptions you are making.
2. Present this summary to the user and explicitly ask them to confirm whether your
   understanding is correct.
3. If anything is ambiguous, incomplete, or open to interpretation, ask clarifying
   questions instead of making assumptions.
4. Discuss the feature with the user until they explicitly confirm that your summary
   accurately reflects the intended functionality.
5. Only after receiving this confirmation should you begin the actual review.

Your goal is to review the feature that the user intends to build, not the feature you
infer from incomplete information. Never proceed with the review while there is
uncertainty about the expected behavior.

## Step 2 — Read for context, not just hunks

For every changed file, read the **whole file**, plus the definitions of anything it
calls that changed behavior depends on. A diff hunk out of context hides most real bugs.

Then, before judging any new code, **search the codebase for existing helpers or
patterns the change could have reused** (grep/glob for similar function names, similar
utilities, similar logic elsewhere in the same module or a sibling one). The question is
not only "does an exact equivalent already exist?" but "could an existing helper or
abstraction have been **extended or adapted** to cover this case?" A parallel
implementation that could have been a parameter on something that already exists is a
finding.

Judge the shape of the change against the codebase as it is:

- **Readability over abstraction.** An extra layer, wrapper, base class, or indirection
  earns its place only by removing real duplication or complexity. Flag abstractions
  introduced for a single call site, or for a future that has not arrived.
- **Simplest correct solution.** If a shorter, flatter version would be just as correct,
  that is the version that should be in the PR — say so and sketch it.
- **Architectural fit.** New code should look like the code around it and sit in the
  module/layer the architecture implies. Flag a change that invents its own pattern next
  to an established one, or that crosses a module boundary the codebase otherwise
  respects.

Before judging quality or security, skim the repo for its own stated conventions (a
`CONTRIBUTING.md`, `AGENTS.md`/`CLAUDE.md`, a docs/conventions directory, linter/format
config) and defer to those over the general rules below wherever they conflict — a
house rule the repo has already written down beats a generic preference.

## Step 3 — Business-logic and bug pass

Read the change as if you have to maintain it. Look for:

- Incorrect logic, wrong conditions, off-by-one, inverted checks.
- Unhandled edge cases: empty/None, zero, large inputs, missing keys, partial failure.
- Error handling: swallowed exceptions, wrong exception type, exceptions re-raised
  without preserving the original cause/traceback, overly broad `except`/`catch`.
- Concurrency/state: shared resources (locks, semaphores, connection pools, caches)
  used inconsistently across code paths that are supposed to share them.
- Data correctness: values built or transformed in a way that drops fields, loses
  precision, or diverges between a cached/replayed path and the fresh-computation path.
- Data reaching the wrong layer or module (e.g. domain logic leaking into a
  presentation/API layer, or vice versa).

**When you cannot tell what the code is *supposed* to do — pause and ask the user.**
Use a question, wait for the answer, then fold it into the finding. Only pause for
genuine business-logic ambiguity; never pause for style — just flag it.

## Step 4 — Security pass

Work through this OWASP-aligned checklist, adapted to what the change actually touches.
Report a security finding with `file:line`, the concrete failure scenario (inputs → bad
outcome), and the fix. Prefer allowlists over denylists in any fix you suggest.

- **Injection — command/subprocess.** Arguments built from untrusted or dynamic input
  must be passed as an argument list to the process, never through a shell that
  interpolates a string (e.g. Python `subprocess` with `shell=True`, C#
  `ProcessStartInfo` with `UseShellExecute` and a concatenated command string, Go
  `exec.Command("sh", "-c", ...)`). Flag any shell-invoking call that concatenates
  external input into the command string.
- **Injection — SQL.** Every query is parameterized. Flag string-formatted SQL and
  f-string/concatenated queries.
- **Injection — templates.** Templates that render user-influenced content should use
  autoescaping; flag rendering from an untrusted raw string, or prompt/HTML built by
  string concatenation (e.g. Python f-strings, C# interpolated strings, Go `fmt.Sprintf`)
  instead of a template.
- **Injection — NoSQL/operator.** Dicts or objects built from user input can smuggle
  operators (e.g. `{"$gt": ""}`). Flag unfiltered user-controlled objects flowing into a
  query.
- **Secrets and credentials.** No hardcoded secrets, API keys, tokens, or passwords —
  they belong in env vars or a secret store. Flag literals that look like credentials,
  and secrets written to logs, error messages, tracebacks, or telemetry.
- **Input validation and output handling.** Validate and constrain external input at the
  boundary; prefer allowlists. Encode output for its context (HTML/URL/JS) when
  reflecting untrusted data.
- **Unsafe evaluation/deserialization.** Flag `eval`/`exec`-style dynamic code
  execution, and unsafe deserializers on untrusted data (e.g. Python `pickle.load` or
  `yaml.load` without a safe loader, .NET `BinaryFormatter`, Go `encoding/gob` fed
  attacker-controlled bytes).
- **SSRF and outbound requests.** Flag any outbound request whose target host/URL is
  built from untrusted input without an allowlist or scope check.
- **Access control.** Check authz on new endpoints/handlers — is the caller allowed to
  do this to this resource? Flag missing ownership/permission checks.
- **Dependencies (supply chain).** New third-party imports: is the dependency
  maintained, pinned, and actually needed? Flag unpinned or unnecessary new
  dependencies, and prefer the standard library or an existing dependency.
- **Error handling as a security concern.** Fail closed, not open. Flag
  `except: pass`-style handling around security-relevant operations, and broad excepts
  that hide auth/validation failures.
- **New features and integrations.** A new feature's security surface is how it
  *connects* to what already exists, not just its own diff. Trace the data in and out —
  where does input come from, where does output flow — and flag any path that crosses a
  trust boundary without that boundary's existing check. If the feature does something
  the repo already guards (auth, rate limiting, scope/allowlisting, sanitization), it
  must go *through* that existing control, not beside it; a parallel path that
  re-implements or skips an established guard is a security finding. Also ask what the
  change widens for the rest of the system (a raised limit, a new "safe/exempt" list, a
  shared cache/credential) and whether that is intended.

## Step 5 — Code-quality pass

These are general, widely-held preferences — defer to the repo's own conventions
(Step 2) wherever they say something different.

- **Naming.** Function/method names should make the action obvious — check what
  convention the surrounding code already uses (verb-first like `build_x`/`FetchY`,
  or another consistent scheme) and flag names that break it, are misleading, or don't
  convey what the function does. Variables are plain, readable, and intuitive — flag
  cryptic abbreviations and single-letter names outside tight loops/comprehensions. One
  term, one concept: flag a new type/field/variable that reuses an existing term for a
  different concept.
- **Functions.** No one-line functions and no thin wrappers that only call another
  function with the same or trivially transformed arguments — inline them or don't add
  them. Prefer early returns; break complex functions into small helpers rather than
  deep nesting.
- **Doc comments and comments.** Doc comments (docstrings, XML doc comments, Godoc
  comments, Javadoc, or whatever the language's convention is) are short — they say
  *what* the function does in plain language, not *how*, and don't restate the code.
  Comments default to none; keep only a short one-line *why* for a genuine non-obvious
  footgun. Flag redundant or over-long comments and doc comments.
- **Typing.** No `Any`/`interface{}`/`object`-style escape hatches from the type system
  unless there is no practical alternative. Type parameters, return values, and public
  APIs explicitly where the language supports it, rather than relying on inference or
  dynamic typing at a boundary.
- **Enums over magic strings.** Matchers, dispatch keys, and status/kind fields should
  be enums or a closed set of typed constants, not bare strings compared by value. Flag
  string-equality dispatch that should be an enum.
- **Simplicity and architectural fit.** The simplest correct solution wins. Flag
  premature abstraction, speculative generality, and layers introduced for a single call
  site. New code should follow the pattern already established around it — flag a
  change that invents a parallel pattern next to an existing one. Flag unrelated
  refactoring bundled into a feature change.
- **Reuse over reinvention.** If the change reimplements something that already exists
  (a util, a helper, a pattern used elsewhere), flag it and point to the existing code.
  Also flag the near-miss case: an existing helper that could have been extended or
  adapted instead of a parallel implementation.
- **Module/layer boundaries.** Respect whatever layering the codebase already has (e.g.
  domain logic not leaking into a UI/API layer, no imports that skip a layer). Flag a
  change that reaches across a boundary the rest of the codebase respects.
- **Reinventing standard-library functionality.** If equivalent functionality exists in
  the language's standard library, prefer it over reimplementing or overriding it.
- **General baseline.** Consistent indentation, descriptive names, reasonable line
  length. Don't waste review effort on whitespace/import-order issues a formatter/linter
  already enforces — focus on design, correctness, security, and the rules above.

## Step 6 — Report

Produce a **severity-ranked report in chat**. Write it in natural prose that a busy
reviewer can read top to bottom and immediately act on. Use plain, clear language. Do
not use decorative or dramatic words, filler, or jargon for its own sake — say the plain
thing plainly. Explain each finding as sentences, not as a terse template. Reference a
code symbol, file, or line directly only when it is the clearest way to point at the
thing, or when the fix depends on the exact name. Do not turn the report into a wall of
identifiers.

Do not assume the reader already knows the code or has the surrounding context in their
head. Where it helps, briefly explain what the affected code does before explaining what
is wrong with it, so the finding stands on its own.

- Lead with a one-sentence overall verdict (e.g. "One major auth gap, otherwise solid").
- Order findings by severity: **Critical → Major → Minor → Nit**.
- Group them by dimension (Business logic / Security / Simplicity & fit / Quality), and
  say when a dimension has no findings.
- For each finding, explain what the affected code does when the reader would need that
  to follow along, then cover what is wrong, why it matters, and the suggested fix. Point
  to a location when there is a concrete one — but architectural or design findings often
  span several places or none in particular, so a file and line are optional, not required.
- Tag each finding with the action to take:
  - **auto fix** — mechanical and behavior-preserving; safe to apply without asking.
  - **ask user** — changes behavior, or depends on intent you had to ask about in Step 3.
    Never applied without explicit confirmation.
  - **no op** — worth knowing, but deliberately not fixed here (out of scope, pre-existing,
    or a judgement call left to the author).

Do not invent findings to pad the report. If the change is clean, say so.

## Step 7 — Fix mode (only if `--fix` was given, or the user asks)

Apply the fixes to the working tree:

- Apply every auto fix finding, and any Nits the user hasn't objected to.
- For ask user findings, ask first and apply only what the user confirms. Never
  auto-apply a fix that changes business logic you had to ask about in Step 3.
- Leave no op findings alone; list them in the summary so nothing is silently dropped.
- After applying, run whatever check/lint/typecheck commands the repo defines (e.g. from
  its README, CI config, or package scripts) and report their output. Fix any errors the
  fixes introduced before finishing.
