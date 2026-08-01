# Remote Connection & Automation (Sender)

TargetBridge's Sender can be driven without the GUI — for scripting, SSH, remote
connection from another Mac, or connecting automatically on login/wake. It reuses the
same in-app connect/disconnect paths the GUI uses, so there's no separate control logic
to keep in sync.

There are two equivalent entry points, plus a small CLI wrapper:

## 1. `targetbridge-intel` CLI

A thin wrapper (in [`cli/targetbridge`](../cli/targetbridge)) over the Intel
variant's URL scheme. Install it under a distinct command name so it can coexist
with upstream automation:

```bash
install -m 0755 cli/targetbridge /usr/local/bin/targetbridge-intel
```

```bash
targetbridge-intel connect
targetbridge-intel connect --receiver auto --mode mirror --preset 1440p
targetbridge-intel connect --receiver 169.254.0.2 --mode extended --preset 5k
targetbridge-intel disconnect
```

Options: `--receiver auto|<id|name|ip>`, `--mode mirror|extended`, `--preset <name>`,
`--transport tb|net`, `--session N`, `--local-ip <ip>`.
Presets: `standard1440p`, `smooth1440p60`, `smooth1800p60`, `crisp2160p60`, `native5k`,
`native5k60Experimental` (aliases: `1440p`, `1440p60`, `1800p`, `4k`, `5k`, `5k60`).
`native5k60Experimental` is an opt-in HEVC test profile for 5K at 60 FPS; it does not
replace the stable 5K 48 FPS profile. A receiver of `auto` waits briefly for
Bonjour discovery and uses the first receiver found; a raw IP/hostname bypasses discovery.

It launches the Sender on demand and works whether the app is already running or not.

## 2. URL scheme

The CLI builds and opens a `targetbridge-intel://` URL. The separate scheme is
part of the fork's isolation and prevents automation from launching the original
TargetBridge app:
(in Shortcuts, Raycast, a `.command` file, etc.):

```
targetbridge-intel://connect?receiver=auto&mode=mirror&preset=native5k
targetbridge-intel://connect?receiver=<receiver-ip>&mode=extended&preset=1440p&session=1
targetbridge-intel://disconnect
```

```bash
open "targetbridge-intel://connect?receiver=auto&mode=mirror&preset=1440p"
```

## 3. Launch arguments (connect on launch / login item)

Passing `--connect` (and the same options) to the app at launch connects once it's up —
handy for a Login Item or LaunchAgent:

```bash
open -a "TargetBridge Intel Sender" --args --connect --receiver auto --mode mirror --preset 1440p
```

## Recipes

**Connect from another Mac over SSH** — the Sender must be at a logged-in desktop with
TargetBridge installed.

Start with the simplest form first:

```bash
ssh <sender-user>@<sender-host> \
  "open 'targetbridge-intel://connect?receiver=auto&mode=mirror&preset=1440p'"
```

On some macOS setups, if LaunchServices does not deliver the URL into the active GUI
session from a plain remote shell, fall back to `launchctl asuser`:

```bash
ssh <sender-user>@<sender-host> \
  "launchctl asuser \$(id -u <sender-user>) open 'targetbridge-intel://connect?receiver=auto&mode=mirror&preset=1440p'"
```

If that still fails with an audit-session permission error, try the same command through
`sudo` from an interactive SSH session (`ssh -t ...`), because the GUI handoff can be more
strict on some systems.

**Auto-connect on wake (Hammerspoon, on the sender):**

```lua
hs.caffeinate.watcher.new(function(e)
  local w = hs.caffeinate.watcher
  if e == w.systemDidWake or e == w.screensDidUnlock then
    hs.timer.doAfter(2, function()
      hs.execute("open 'targetbridge-intel://connect?receiver=auto&mode=mirror&preset=1440p'")
    end)
  end
end):start()
```

**Arrange the display after connecting (displayplacer):** TargetBridge restores its saved
extended-desktop arrangement at connect time, so apply your own layout *after* the stream
is up (e.g. poll until the display appears, then run your saved `displayplacer "..."` command).

## Notes

- The Sender's capture pipeline requires a logged-in GUI session; these entry points
  signal the app inside that session — they do not (and cannot) start screen capture from a
  pure headless context.
- `auto` requires the receiver to be discoverable over Bonjour (`_targetbridge._tcp`). On
  first use, grant the Sender Screen Recording permission as usual.
- These commands are fire-and-forget: the CLI / `open` returns as soon as the URL is
  delivered, which is **not** the same as "streaming established." Check the app (or its
  log: `log show --predicate 'eventMessage CONTAINS "[automation]"' --last 2m`) to confirm.
- For remote SSH automation, a plain `open 'targetbridge-intel://...'` is often enough and is the
  least brittle option. Use `launchctl asuser` only when the plain form does not reach the
  active GUI session on the sender.
- `connect` without `--session` targets Display 1 and updates its saved Receiver,
  the same as changing it in the GUI. The query name remains `session` for wire
  and script compatibility.
- On a cold launch, `receiver=auto` waits briefly for Bonjour; if discovery is slow on the
  first run, pass an explicit `--receiver <ip>` to skip the wait.
