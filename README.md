# howmuch

## Quickstart (under 5 minutes)

howmuch answers two questions about your Claude Code or Codex usage, from local
structured telemetry already on your machine:

1. Where did my AI inference budget go?
2. What is one concrete behavior or configuration I would change next?

You need a Mac with Python 3.9 or newer (check with `python3 --version`). No
account, no SnooZELab checkout and no sudo.

Install it (one file, to `~/.local/bin/howmuch`):

```sh
curl -fsSL https://raw.githubusercontent.com/InferGen/howmuch/main/install.sh | sh
```

If it says `~/.local/bin` is not on your PATH, add the line it prints to
`~/.zshrc` and open a new terminal. Then:

```sh
howmuch today      # where today's $ went, what you got, and one thing to try next
howmuch week       # the receipt for the last 7 days, with your top 3 jobs
howmuch record     # optional: save daily figures to ~/.howmuch/history.jsonl
howmuch history    # optional: those saved figures, one line per day
```

### Automatic provider detection

`today` and `week` use Claude Code when it has sessions in the requested
period, otherwise local Codex rollout telemetry. If both are available,
Claude wins deterministically; sources are never merged. No provider flag
or checkout is required. Claude uses `$CLAUDE_CONFIG_DIR/projects` or
`~/.claude/projects`; Codex uses `$HOWMUCH_CODEX_HOME`, then `$CODEX_HOME`,
then `~/.codex`, reading only `sessions/**/rollout-*.jsonl`.

Codex receipts lead with directly observed quota, observed token classes
and ESTIMATED API-equivalent cost. They preserve model, provider, source,
surface and confidence. The originating surface is UNKNOWN for automatic
rollout discovery; a local file alone does not prove CLI versus app origin. Cached input is part of input; reasoning is part
of output, so neither is counted twice. Missing fields and unmapped models
are UNKNOWN, never guessed as zero. Quota is independent of dollar estimates;
actual billed spend is NOT_EXPOSED. Cost uses the pinned API price table.

Periods use local midnight (today) and the last seven local calendar days
(week). Cumulative increments require a baseline inside that period; a
boundary-crossing interval remains UNKNOWN. All rollout files are considered,
not only the newest five used for quota discovery. Malformed files fail
closed and their count is shown. Incomplete or rotated telemetry cannot
fully explain plan limits. Sessions are represented by hashed local identity;
WU/job attribution is NOT_EXPOSED because structured rollouts do not supply
that contract. Activity categories and tool outcomes remain Claude-only.
`record`/`history` currently support Claude only.

Everything is processed locally; nothing is uploaded. No prompt, response,
source code, tool output, credential, account identifier or absolute home
path is included in Codex receipts. No auth/login/config files are read.
`today` and `week` do not persist telemetry or receipts.

### What you'll see

`howmuch today` shows quota for Claude Code and Codex, then a rollup you can read without opening a receipt.
This one is from made-up sessions in the test fixtures, with no quota
evidence on the machine at all:

```text
================================================
                    HOWMUCH
              Claude Code receipt
                     TODAY
                   2026-09-20
            through 15:00 local time
================================================
API-EQUIVALENT                           $0.4000
  price table           ANTHROPIC-API-2026-09-27
  retrieved                           2026-09-27
  API list prices; not what your plan charges
------------------------------------------------
QUOTA
Claude Code                              UNKNOWN
  source                                 UNKNOWN
  seen                           nothing current
  confidence                             UNKNOWN
  why: no quota evidence on this machine
Codex                                    UNKNOWN
  source                                 UNKNOWN
  seen                           nothing current
  confidence                             UNKNOWN
  why: no Codex folder on this machine
howmuch-quota-v0; read locally
------------------------------------------------
WHERE IT WENT
 50% repair loops (ESTIMATE)             $0.2000
 20% writing and editing files           $0.0800
 15% running commands                    $0.0600
 10% reading and searching               $0.0400
  5% replies with no tool call           $0.0200
each turn counted once, by its tool calls
howmuch-rollup-v0; confidence high
------------------------------------------------
WHAT YOU GOT
file edits applied                             3
file edits failed                              0
command runs passed                            3
command runs failed                            2
git commits made                               1
no result recorded                             0
outcome quality                          UNKNOWN
counts of tool results; text is never read
------------------------------------------------
FRICTION
repair loops (ESTIMATE)                  $0.2000
  share of the period's $                  50.0%
  loops still unresolved                       0
failed tool calls                              2
  outside repair loops                         0
of the period's $:
  friction (repair loops)                  50.0%
  productive (not flagged)                 50.0%
  UNKNOWN (not classified)                  0.0%
------------------------------------------------
BIGGEST OPPORTUNITY
repair loops (ESTIMATE)                  $0.2000
  share of the period's $                  50.0%
  loops (unresolved)                       1 (0)
start with alpha @ main
the largest drain measured in this period
howmuch-opportunity-v0
------------------------------------------------
TRY NEXT
In alpha @ main: after a command fails, ask for
  the cause before any edit.
why: repair loops in this job            $0.2000
  loops (unresolved)                       1 (0)
  reruns of the failing command                2
confidence                                   low
howmuch-try-next-v0
```

Read it top to bottom: half of this made-up day went to getting one failing
command to pass, so that is the biggest opportunity, and the one thing to try
next is about that loop, in the job it happened in. When your own files do not
support a suggestion, `TRY NEXT` says `no suggestion` and why. It never falls
back to general advice. The receipt's own figures follow under
`RECEIPT DETAIL`, so you can inspect and verify what the rollup is made from.

`howmuch week` prints the receipt alone, like this one (made-up sessions from
the test fixtures):

```text
================================================
                    HOWMUCH
              Claude Code receipt
                      WEEK
            2026-09-14 to 2026-09-20
            through 15:00 local time
================================================
API-EQUIVALENT                           $0.0109
  price table           ANTHROPIC-API-2026-09-27
  retrieved                           2026-09-27
  API list prices; not what your plan charges
------------------------------------------------
ACTIVITY
sessions                                       2
prompts                                        3
assistant turns                                4
total tokens                               4,540
  input                                    1,035
  output                                     405
  cache write                                100
  cache read                               3,000
------------------------------------------------
5-HOUR WINDOW (ESTIMATE)
no window open at 2026-09-20 15:00
limit ESTIMATE                           UNKNOWN
  no limit hits seen locally
baseline median                          $0.0054
  windows in the last 7 days                   2
confidence                                  none
howmuch-pace-v0, 5h-rolling-approx;
not the provider's own meter
------------------------------------------------
REPAIR TAX (ESTIMATE)
no repair loops detected (howmuch-repair-v0)
how detected: howmuch-repair-v0
  a failed Bash run, edits, then a rerun
------------------------------------------------
TOP JOB
1. beta @ feature-x                      $0.0080
  sessions                                     1
  prompts                                      1
  tokens                                   1,212
2. alpha @ main                          $0.0029
------------------------------------------------
not priced: claude-mystery-9
  tokens left out of the $                    12
Skipped 1 malformed line.
================================================
        Read locally. Nothing uploaded.
                 howmuch 0.1.1
================================================
```

`QUOTA` says where each figure came from: `MACHINE OBSERVED` (the provider's
own figure, seen on this Mac), `HUMAN OBSERVED` (one you typed in with
`howmuch set-quota`), `MACHINE CALCULATED` (an estimate from your own usage)
or `UNKNOWN`. They are tried in that order, and a figure that has gone stale
is never shown as current.

Privacy: howmuch reads only the Claude Code session files on this Mac
(`~/.claude/projects`) and, for the Codex quota figures alone, the Codex
session files (`~/.codex/sessions`). It never prints your prompts or
responses, never makes a network call, and nothing is uploaded.

Uninstall:

```sh
rm ~/.local/bin/howmuch
rm -rf ~/.howmuch    # only if you used `howmuch record`: your local history
```

## What it is

`howmuch` prints a plain-text receipt of your Claude Code usage, and `today`
puts a rollup above it: where the $ went, what you got, the friction, the
biggest opportunity and one thing to try next. It reads only the session
files Claude Code already keeps on your machine, plus the quota figures in
Codex's own session files. It never makes a network call and never prints
prompt or response text. `today` and `week` never write a file; `record`
writes only a local history store, `observe-quota` only the quota snapshot
and `set-quota` only the figure you typed in (all below).

It is standard-library-only Python (3.9+), with no dependencies. It ships as
one file, `dist/howmuch.pyz`, a zip of the package that Python runs directly.

## Install from a checkout (for developers)

```sh
python3 -m pip install ./projects/howmuch_cli
```

Or run it in place without installing:

```sh
PYTHONPATH=projects/howmuch_cli/src python3 -m howmuch today
```

Or build the single file and install it the way the Quickstart does:

```sh
python3 projects/howmuch_cli/tools/build_pyz.py      # writes dist/howmuch.pyz
sh projects/howmuch_cli/install.sh --from projects/howmuch_cli/dist/howmuch.pyz
```

The build is reproducible: the same sources always give byte-identical
`dist/howmuch.pyz`, and a test checks the committed file is current.
`install.sh` takes the file from `--from PATH`, else `$HOWMUCH_PYZ_URL`, else
the `DEFAULT_PYZ_URL` at its top, and installs to `$HOWMUCH_BIN_DIR`
(default `~/.local/bin`). The download URLs are not live yet; until a release
is published, install with `--from`. `howmuch --version` prints the version.

## Usage

```sh
howmuch today          # local midnight to now
howmuch week           # the last 7 local calendar days, today included
howmuch week --json    # the same figures as JSON
howmuch today --root /path/to/projects
howmuch record         # save today and the 6 days before it to the history store
howmuch history        # daily figures from the history store (--days N, default 14)
howmuch set-quota --provider claude --window five_hour --used 42 --resets 2026-09-20T17:00
```

Sessions are read from `--root`, else `$CLAUDE_CONFIG_DIR/projects`, else
`~/.claude/projects`. `today` and `week` print a till receipt, 48 columns
wide and plain ASCII, with labels on the left and figures right-aligned.
Top to bottom:

- a header: the period, its dates and the end time, in local time
- `API-EQUIVALENT`, the dollar figure from the bundled price table
  (`src/howmuch/prices.json`), with its price table id and retrieval date
- in `today` only: `QUOTA`, a block for Claude Code and a block for Codex
  (see below)
- in `today` only: the rollup (see below), then a `RECEIPT DETAIL` line.
  The receipt's own sections follow under it.
- `ACTIVITY`: sessions, prompts, assistant turns and total tokens, then the
  input, output, cache-write and cache-read tokens
- `5-HOUR WINDOW (ESTIMATE)` (see below): always in `week`; in `today` only
  when Claude Code's quota is `MACHINE CALCULATED` from it
- `REPAIR TAX (ESTIMATE)` (see below)
- `TOP JOB`: the top job by dollars, then tokens, with its sessions, prompts
  and tokens, then jobs 2 and 3 on one line each. A job is a (project
  folder, git branch) pair. Your home folder is shown as `~`.
- models missing from the price table (their tokens are left out of the
  dollar figure) and skipped lines, only if there are any, then
  `Read locally. Nothing uploaded.` and the howmuch version

The dollar figure is what the same tokens would cost at API list prices. It
is not what a subscription plan charges. Long names wrap; nothing is cut.
A character outside plain ASCII is shown as `?`.
`--json` keeps every figure it had and adds a `rollup` object, in both
`today` and `week`. `today --json` also carries `quota_state` (the Claude
Code record) and `quota_environments` (one record per provider: Claude Code,
then Codex).

## The rollup (today)

`howmuch today` answers five things before the receipt. All of them come from
tool names, `is_error` flags, token counts and $ in your session files.
Prompt, response, command and tool output text is never read for them, so
howmuch never judges whether the work was good: that is always `UNKNOWN`.

- `WHERE IT WENT` (`howmuch-rollup-v0`): the period's $ in groups. Each
  assistant turn is counted once, in the first group that fits: inside a
  repair loop (an ESTIMATE, see below); a turn whose content cannot be read
  (`UNKNOWN`); then by its tool calls: writing and editing files (`Edit`,
  `MultiEdit`, `Write`, `NotebookEdit`), running commands (`Bash`), handing
  work to subagents (`Task`, `Agent`), reading and searching (`Read`, `Grep`,
  `Glob`, `LS`, `NotebookRead`, `WebFetch`, `WebSearch`), other tool calls,
  or replies with no tool call. Confidence is `high` when every $ was
  grouped, `medium` when under a tenth was `UNKNOWN`, `low` otherwise, and
  `none` with no priced usage.
- `WHAT YOU GOT` (`howmuch-outcome-v0`): counts of what went through and
  what did not. An edit or a command run failed if its tool result has
  `is_error` true. A commit is a passing `Bash` run whose command has `git`
  followed by `commit`. A tool call with no result in the file is counted
  apart as `no result recorded`. `outcome quality` is always `UNKNOWN`.
- `FRICTION` (`howmuch-friction-v0`): the repair loop $ and its share, the
  loops still unresolved, and a count of failed tool calls of any tool
  (failed calls carry no $ of their own). Then the period's $ in three
  shares that never mix: friction, productive and `UNKNOWN`. Productive
  means only "grouped and not flagged as friction".
- `BIGGEST OPPORTUNITY` (`howmuch-opportunity-v0`): the larger of two
  measured drains. One is repair loops. The other is long context: priced
  turns outside any repair loop that re-read 150,000 or more cached tokens,
  counted at their cache-read $. A drain wins only if it is 10% or more of
  the period's $ and the period has 3 or more assistant turns. Otherwise the
  section says `INSUFFICIENT_EVIDENCE` with the reason, or `TIED` when the
  two largest measure the same. It never picks a winner it cannot show.
- `TRY NEXT` (`howmuch-try-next-v0`): at most one suggestion, only for the
  drain that won, naming the job with the most of it and showing the figures
  that triggered it. Confidence is `medium` when the drain is 25% or more of
  the period's $ and rests on 2 or more loops (or 5 or more long-context
  turns), else `low`. With no winner it prints `no suggestion` and the
  reason.

`--json` carries all of this as `rollup` (`howmuch-rollup/v0`):
`where_it_went` (every group with its `class`, `kind`, `confidence`,
`provenance`, turns, tokens, $ and share), `split`, `what_you_got`,
`friction`, `biggest_opportunity` (the `status`, the winning `drain`, every
measured candidate and the thresholds) and `try_next` (the `status` and the
one `suggestion` with its `evidence`, or `null`). Each part names its
`rule_id`. `week --json` carries the same object; the `week` text is the
receipt alone. A sample is in `samples/fixture_today_rollup.txt`.

These are estimates from what the files show. A turn is put in one group
even if it did several things. A turn inside a repair loop is counted as
friction in full. Long context is not always avoidable, which is why the
suggestion says how confident it is and shows its figures.

## 5-hour window (ESTIMATE)

This section is the fallback, not the quota itself. `week` always prints it.
`today` prints it only when Claude Code's quota is `MACHINE CALCULATED`: when
the provider's own figure or one you typed in is in force, that figure is
shown under `QUOTA` and this estimate is left out. `--json` carries
`quota_window` either way.

Claude Code plans are metered in rolling 5-hour windows. The session files
record neither the windows nor your limit, so the `5-HOUR WINDOW (ESTIMATE)`
section estimates both from your own usage over the last 7 days:

- **Windows are an approximation** (`5h-rolling-approx`). A window starts at
  the first assistant reply not inside an open window and lasts exactly 5
  hours. The provider's own meter may start and reset windows differently.
- **Current window**: the window open now, if any: its API-equivalent $,
  when it started, minutes elapsed, the pace in $/hour and a straight-line
  projection of the $ at the window's end. If no window is open, it says so.
- **Baseline**: the median $ of the windows you completed in the last 7
  days, and how many there were.
- **Inferred limit**: Claude Code writes a `<synthetic>` (API error) line when
  you hit a usage limit. Lines whose text mentions a limit are counted as
  limit hits; only their timestamps are kept, never their text. If any
  completed window had a hit, the inferred limit is the median $ and tokens
  of those windows. It is an **empirical estimate, never exact**: confidence
  is `low` from 1-2 such windows and `medium` from 3 or more, never higher.
  With no hits the limit reads `UNKNOWN`, with the reason.
- **% used** is the current window's $ divided by the inferred limit $,
  rounded to a whole percent, with a 20-cell bar (`#` per 5%, at most 20).
  It is a display ratio worked out only when the receipt is printed. With no
  inferred limit there is no % used and no bar.

The limit, % used, bar and projection appear only under the
`5-HOUR WINDOW (ESTIMATE)` heading, and that section always shows the
confidence (`none` with no inferred limit).

The $ figures are API-equivalent, so the inferred limit is a limit in
API-equivalent dollars of your own usage mix, not a published plan number.
`--json` carries these figures and more (tokens, tokens/hour, the baseline
max and the limit's provenance: windows used, hit count and date range) in a
`quota_window` object with `estimator_id` `howmuch-pace-v0`, `window_model`
`5h-rolling-approx` and `confidence` (`none`, `low` or `medium`). A sample
fixture receipt that shows it is `samples/fixture_today_quota_calculated.txt`.

## Quota (MACHINE OBSERVED, HUMAN OBSERVED, MACHINE CALCULATED or UNKNOWN)

`howmuch today` prints one `QUOTA` section directly under the API-equivalent
total, with a block for Claude Code and a block for Codex: is the plan quota
available, low, used up, due to reset, or unknown? Each block gives the
state, the share left (or the estimated burn), the reset time, the source,
when it was seen and the confidence. `week` has no such section: the state
is about now. This is the sample with both providers observed
(`samples/fixture_today_quota_receipt.txt`):

```text
QUOTA
Claude Code                            AVAILABLE
  remaining                                  34%
  resets                        2026-09-20 17:00
    in                                    2h 00m
  source                        MACHINE OBSERVED
  seen                          2026-09-20 14:55
  confidence                                HIGH
  from a provider value saved on this machine
Codex                                  AVAILABLE
  remaining                                  42%
  resets                        2026-09-24 09:00
    in                                    3d 18h
  source                        MACHINE OBSERVED
  seen                          2026-09-20 14:50
  confidence                                HIGH
  from Codex session files on this machine
howmuch-quota-v0; read locally
```

Quota is what the provider says is used, not how much time has passed. For
each provider the sources are tried in this order, and the first one still
in force is shown (`source_rank` in `--json`):

1. **MACHINE OBSERVED**: the provider's own figure, seen on this machine.
   - Claude Code: `~/.howmuch/claude_rate_limits.json`
     (`howmuch-quota-snapshot/v0`: `captured_at` and `windows`, each with
     `window`, `used_fraction` and `resets_at`), which `howmuch observe-quota`
     saves from Claude Code's status line (see below); or the cap notice
     Claude Code writes in a session file when a usage cap is hit (only its
     time, the kind of cap and the reset time are kept, never its text).
   - Codex: the newest `rate_limits` figures in Codex's own session files
     (see below).
   A value older than 15 minutes is stale unless it says the quota is used
   up and its reset is still ahead. Used-up evidence still in force is
   cleared only by a real reply, never by another figure.
2. **HUMAN OBSERVED**: a figure you typed in with `howmuch set-quota` (see
   below). It is in force until its reset time, or for 1 hour when you gave
   none, and its confidence is never above `MEDIUM`.
3. **MACHINE CALCULATED**: Claude Code only. The 5-hour window's $ over the
   inferred limit above (`burn ESTIMATE`). It never says `EXHAUSTED` and
   never gives a remaining share: the inferred limit is not the provider's
   number. Only then does `today` print the `5-HOUR WINDOW (ESTIMATE)`
   section. There is no estimate for Codex.

A source that is stale or cannot be read is skipped, never shown as the
current value. With nothing in force the state is **UNKNOWN**, with the
reason (`INSUFFICIENT_EVIDENCE`, `STALE_EVIDENCE` or `INVALID_SNAPSHOT`) and
a `why:` line. One provider's evidence never fills the other's block.

States: `AVAILABLE`, `LOW_REMAINING` (20% or less left, or an estimated burn
of 80% or more), `EXHAUSTED`, `RESET_PENDING` (the reset time has passed and
no reply since proves the quota is back) and `UNKNOWN`. A real reply more
than 5 minutes after a cap notice supersedes it. Confidence follows the
fixed rules `howmuch-quota-confidence-v0`: `HIGH` for a provider value at
most 15 minutes old or used-up evidence whose reset is still ahead; `MEDIUM`
for used-up evidence with no reset time (at most 1 hour old), a passed reset,
a typed-in figure at most 1 hour old, or an estimate from 3 or more windows;
`LOW` for an older typed-in figure or an estimate from 1 or 2 windows;
`UNKNOWN` otherwise.

`--json` carries the Claude Code record as `quota_state`
(`howmuch-quota-state/v0`, detector `howmuch-quota-v0`) and one record per
provider in `quota_environments`: Claude Code (provider `Anthropic`), then
Codex (provider `OpenAI`, surface `Codex`). `source_rank` is
`MACHINE_OBSERVED`, `HUMAN_OBSERVED`, `MACHINE_CALCULATED` or `null` when the
state is `UNKNOWN`. Every field the record had before is still there with
the same meaning. More samples: `samples/fixture_today_quota_human.txt`
(typed-in figures), `samples/fixture_today_quota_calculated.txt` (the
fallback), `samples/fixture_today_quota_state_observed.txt` (a cap notice)
and `samples/fixture_today_quota_state_estimate.txt`.

### Codex (ChatGPT plan)

On a ChatGPT plan, Codex writes the provider's own meter into its session
files as it runs. `howmuch today` reads the newest one from
`$HOWMUCH_CODEX_HOME`, else `$CODEX_HOME`, else `~/.codex`, under
`sessions/**/rollout-*.jsonl`: a `token_count` event whose `rate_limits` has
`primary` and `secondary`, each with `used_percent` (0 to 100),
`window_minutes` and a reset time (`resets_at`, or `resets_in_seconds`
counted from the event's time).

- Only those numbers and the event's timestamp are read. A line is not
  parsed at all unless it names `rate_limits`; no prompt, reply, path,
  session id, account or token is looked at or kept.
- Only the 5 most recently changed session files are read. Nothing is
  written, and no Codex file is changed.
- Nothing is guessed. With no Codex folder, no session file or no such event,
  the block is `UNKNOWN` and says which. If the newest event's figure cannot
  be read, or is shaped differently, the block is `UNKNOWN`
  (`INVALID_SNAPSHOT`); an older event is not used in its place.
- The figure is as old as your last Codex turn, so it goes stale 15 minutes
  after you stop using Codex.

### A figure you read yourself (`howmuch set-quota`)

When this machine has not observed the provider's figure, you can type in
the one on the provider's own usage page:

```sh
howmuch set-quota --provider claude --window five_hour --used 42 --resets 2026-09-20T17:00
howmuch set-quota --provider codex --window seven_day --used 35
```

`--provider` is `claude` or `codex`, `--window` is a short name of your
choosing, `--used` is the used share from 0 to 100, and `--resets` is an
optional ISO 8601 time (local time if it has no zone). It writes one small
file per provider, `~/.howmuch/human_quota_claude.json` or
`~/.howmuch/human_quota_codex.json`, holding only the provider, the window,
the used share, the reset time and when you entered it; a new figure
replaces the old one. A used value outside 0-100, or a reset time that
cannot be read or has already passed, exits non-zero and writes nothing.

The figure is shown as `HUMAN OBSERVED` only while no machine-observed figure
is in force, and it goes stale at its reset time, or 1 hour after you
entered it when you gave none.

### The provider's own figures (`howmuch observe-quota`)

On a claude.ai Pro or Max plan, Claude Code hands its status line command a
JSON object on stdin that carries the provider's own meter:
`rate_limits.five_hour` and `rate_limits.seven_day`, each with
`used_percentage` (0 to 100) and `resets_at` (Unix epoch seconds).
`howmuch observe-quota` is a status line command that saves those four
values to `~/.howmuch/claude_rate_limits.json` and prints a short status
line such as `5h 66% | 7d 41%`. While that file is at most 15 minutes old,
`howmuch today` shows it under `QUOTA` as `MACHINE OBSERVED` with confidence
`HIGH`, in place of a typed-in figure or the estimate. A sample is in
`samples/fixture_today_quota_state_direct.txt`.

- 66% is saved as `used_fraction` 0.66. A window Claude Code leaves out, or
  whose percentage is not a number, is left out of the file. A reset time
  that is missing or unreadable is saved as `null`. Nothing is estimated.
- Nothing else in the object is read or kept: no session id, path, model,
  cost, account or spend figure. The command makes no network call.
- With no `rate_limits` in the object (an API key, or before the session's
  first reply) the file is left as it was, and goes stale on its own.
- The status line does not run in non-interactive (`claude -p`) sessions, so
  the file is fresh only while an interactive session is in use.
- Do not set the status line's `refreshInterval`: a timer would hand over
  the same old figures and stamp them as new.

To set it up from a checkout, without replacing a status line you already
have (it only prints what it would do until you add `--apply`):

```sh
python3 projects/howmuch_cli/tools/install_statusline.py           # dry run
python3 projects/howmuch_cli/tools/install_statusline.py --apply   # writes ~/.claude/settings.json
```

It adds one `statusLine` entry, keeps a copy of the old file as
`settings.json.before-howmuch`, and changes nothing if a different status
line is already set.

## Repair tax (ESTIMATE)

A repair loop is a stretch of a session spent getting a failing command to
pass: it fails, Claude edits files, and the command is run again. The session
files do not mark these loops, so this section estimates them with the rule
`howmuch-repair-v0`, applied to each session file on its own, in timestamp
order:

- A **run** is a `Bash` tool call paired with its tool result. It failed if
  the result has `is_error` true; otherwise it is ok. An **edit** is an
  `Edit`, `MultiEdit`, `Write` or `NotebookEdit` tool call. Two runs are the
  same command if their command text matches once whitespace is collapsed;
  only a sha256 of it is kept, in memory.
- A loop **opens** at a failed run. It counts only once an edit is followed
  by another run of the same command. It **closes** at the first passing run
  of that command after that (resolved), or else at the session's last run of
  it (unresolved). A failure fixed by a plain rerun, with no edit in between,
  is not a loop. A failure in one session and a rerun in another are not
  linked.
- **Retries** are the runs of the command after the opening failure.
- A loop's **cost** is the tokens and API-equivalent $ of every assistant turn
  from the one that opened it to the one that closed it. Loops on different
  commands can overlap; a turn inside several loops is counted once.

The `REPAIR TAX (ESTIMATE)` section shows the repair $ and that $ as a
percent of the period's $, loops (and how many resolved) and retries, then a
short `how detected` line naming `howmuch-repair-v0`. With no loops it prints
`no repair loops detected (howmuch-repair-v0)`. `--json` carries the same
figures, plus repair tokens and the top 3 jobs by repair $, in a
`repair_loops` object with `estimator` `howmuch-repair-v0` and the full rule
as `method` text.

It is an **estimate, not a measurement**. The rule only sees Bash commands, so
failures in other tools are missed. A turn inside a loop is counted in full
even if part of it was about something else. A command that fails for reasons
no edit could fix (a flaky network, say) still counts if files were edited in
between. Commands, their output and message text are never printed or kept.
A sample fixture receipt is in `samples/fixture_today_repair_receipt.txt`.

## History (record and history)

`howmuch record` saves one row per local calendar day, for today and the 6
days before it, to a history store on your machine:

- **Where**: `$HOWMUCH_HOME/history.jsonl`; `HOWMUCH_HOME` defaults to
  `~/.howmuch`. Nothing is uploaded; `howmuch` never makes a network call.
- **What**: one JSON object per line, `schema_version` `howmuch-history/v0`,
  with only these keys: `schema_version`, `date` (YYYY-MM-DD), `recorded_at`,
  `sessions`, `prompts`, `input_tokens`, `output_tokens`,
  `cache_write_tokens`, `cache_read_tokens`, `total_tokens`, `usd`,
  `rl_loops`, `rl_retries` and `rl_usd` (the repair loop figures). A day is
  local midnight to midnight (midnight to now for today), counted by the same
  rules as `today`. A row never holds a project or branch name, a path, a
  username, a hash of text, or any prompt, response, command or tool output.
- **How**: rows are upserted by date. Recording a day again replaces its row,
  never duplicates it, and rows for other days are kept. The file is written
  whole to a temporary file in the same folder and then renamed into place.
  A line that is not a valid `howmuch-history/v0` row is kept as it is,
  counted and reported, never dropped.

`record` prints how many days it wrote and the store path (your home folder
shown as `~`). Run it daily, by hand or from a scheduler, to build up history
beyond 7 days.

`howmuch history` reads only the store, never the session files, and writes
nothing. For each of the last N stored days (`--days N`, default 14) it shows
the date, sessions, tokens, $ and repair-loop $, and that day's $ as a percent
of the median $ of up to 14 earlier stored days, or `no baseline yet` for the
first. With no store it prints ``no history yet: run `howmuch record` ``.
`--json` carries the same figures. A sample fixture output is in
`samples/fixture_history.txt`.

To delete your history, delete the file (or the whole folder):

```sh
rm ~/.howmuch/history.jsonl
```

## Counting rules

- A streamed reply is written as several lines that share one message id.
  Its usage is counted once, taking the largest value seen for each field.
- `<synthetic>` messages are client-side placeholders and are not counted.
- A prompt is a user line that is not marked `isMeta` and has text in it.
  Tool results are not prompts.
- Lines that are not valid JSON are skipped and counted.
- Only lines timestamped inside the period count. Files last modified
  before the period starts are not opened.

## Tests

```sh
python3 -m pytest projects/howmuch_cli -q
```

`tests/test_real_smoke.py` runs `today` and `week` against this machine's
real Claude Code sessions. It fails if there are none, if any real prompt or
response text, the home path or the username shows up in the output, or if
any figure is impossible, including a quota window figure (negative or
non-finite, more than 300 minutes elapsed, a current window costing more than
the week, a projection below the current $, or an unknown confidence), or a
repair loop figure (negative or non-finite, repair $ above the period's $, a
percent outside 0-100, more resolved loops than loops, or fewer retries than
loops). It then writes numbers-only results, including the quota window
figures, the limit-marker count, the `rl_*` repair loop figures and counts of
Bash tool results by `is_error` (true, false, absent), to
`smoke/real_today.numbers.json` and `smoke/real_week.numbers.json`.

It also runs `record` then `history` against the real sessions, with
`HOWMUCH_HOME` set to a temporary folder, never your real `~/.howmuch`. It
fails if a stored row has a key outside the allowlist, a negative or
non-finite number, repair $ above the day's $, or a date twice, or if real
text, the home path or the username shows up in the store or in either
command's output. It writes the days recorded, days with sessions, total $
and median $ to `smoke/real_history.numbers.json`.

Last, it builds a fresh `howmuch.pyz`, installs it with `install.sh --from`
into a temporary bin folder and runs the installed `howmuch today` against the
real sessions, from outside the repo with `PYTHONPATH` unset. It fails on the
same leak and impossible-value checks, and writes sessions, prompts, total
tokens, $ and the pyz size to `smoke/real_installed_today.numbers.json`.
Every real `today` and `week` receipt, installed or not, must also keep the
layout: no line wider than 48 columns, plain ASCII only, and the section
headings in order.

`tests/test_quota_sources.py` checks the source order (machine observed,
then typed in, then calculated; a stale figure is never shown), the Codex
reader on made-up session files, `howmuch set-quota`, and that the built
`dist/howmuch.pyz` runs both. Its last test reads this machine's real Codex
home and writes numbers and field names only to
`smoke/real_codex_quota.numbers.json`; it records what it finds and does not
fail when Codex is absent.

`tests/test_receipt.py` renders every fixture root, for `today` and `week`,
and checks the layout (width, ASCII, `API-EQUIVALENT` first, every $ figure
ending at column 48, `QUOTA` directly under the total in `today`, the limit,
% used, bar and projection only under the `(ESTIMATE)` window heading, and
that heading in `today` only when the quota is calculated) and each figure
against `--json`. It also checks
that the Quickstart's "What you'll see" block is the fixture `week` receipt.

`tests/test_rollup.py` checks the rollup against hand-computed fixtures:
productive, friction and `UNKNOWN` $ stay apart; weak or tied evidence gives
no winner and no suggestion; a suggestion names the job and carries the
figures that triggered it, and there is never more than one; the receipt
figures and the sections under `RECEIPT DETAIL` are what they were; no text
from a prompt, response, command, tool name or tool result reaches the
output; and the Quickstart's `today` block is the top of the fixture output.

`tests/test_install.py` checks the build (two builds and the committed
`dist/howmuch.pyz` are byte-identical), `--version`, and `install.sh` with
`HOME` and `HOWMUCH_BIN_DIR` in a temporary folder: mode 755, one identical
file after a second run, no change to `HOME` outside the bin folder, the
PATH line, and a refusal with Python older than 3.9. No test downloads
anything. If a `dist/REBUILD` marker exists (left by a session that could not
run `tools/build_pyz.py`), that test rebuilds `dist/howmuch.pyz` once and
deletes the marker.

## Codex / ChatGPT API-equivalent cost (development)

`howmuch codex-cost` reads privacy-safe cumulative usage snapshots on stdin
and prints usage plus ESTIMATED/API-EQUIV cost. `--json` includes session and
UTC-day rollups, exact model/rate provenance, partial known subtotals and
UNKNOWN portions. It never derives provider quota from dollar cost.
Use the repository adapter and commands in
`projects/howmuch_codex_adapter_v0/README.md`; the existing public pyz is
unchanged. The synthetic sample is `samples/fixture_codex_cost_receipt.txt`.
