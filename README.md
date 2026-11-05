# Herdr Sim

A live iOS simulator and Android emulator for the [Herdr](https://herdr.dev)
desktop app, next to your code and terminals. Tap, swipe and type on it right
in Herdr, and watch your mobile tests drive the app while they run. In the
spirit of the device view in Maestro Studio or Flutter's device preview in
VS Code, written as a native Herdr mod (no web view).

![Herdr Sim: a test file, its passing run, and the iPhone simulator showing the result](preview.png)

The mod and its layout are both called `simdock`.

## What it does

- **A live screen.** The picked simulator or emulator streams into a phone
  frame at about 30 frames per second, sized to the panel.
- **Use it in place.** Click to tap, drag to swipe, scroll to scroll, and type
  with your keyboard (shortcuts and Shift included). The toolbar has Home, Lock,
  Volume down, Volume up, Rotate, and, on iOS, show or hide the software
  keyboard.
- **Any device.** The picker at the top lists every iOS simulator and Android
  emulator on the Mac, grouped by platform, with a green dot on the ones
  running. Pick a shut-down one and it boots: iOS through `simctl`, Android
  headless (no emulator window). Images the Mac can't run are shown dimmed.
- **Two ways to show it.** As a panel beside Files and Changes in the `simdock`
  layout, or as a pane in any layout.
- **Opens with your tests.** An optional [e2e](https://e2e.tester.army)
  reporter shows it when `e2e run` starts. See [With e2e](#with-e2e).
- **Repair input.** On Xcode 27, Device Hub can take over simulator touch input
  so taps do nothing. **Repair input** in the picker fixes it (SpringBoard
  restarts, so apps close).

## What it runs

Everything stays on your Mac; the mod opens no remote connections of its own.

- **iOS**: `xcrun simctl` to list and boot simulators, and
  [serve-sim](https://github.com/EvanBacon/serve-sim) 0.1.49 for the screen and
  input. serve-sim runs with `npx`, so the first use downloads it from npm. It
  serves on `127.0.0.1`, and the mod stops the serve-sim it started when you
  switch away.
- **Android**: `adb` (input, screen size) and the emulator binary (to boot), from
  `$ANDROID_HOME`, `$ANDROID_SDK_ROOT` or `~/Library/Android/sdk`. The screen
  comes from the emulator's own gRPC screenshot stream through a small Node
  helper, `mods/simdock/android-stream.mjs` (no dependencies). It reads the
  emulator's discovery file in `~/Library/Caches/TemporaryItems/avd/running/`
  for the gRPC port and token, serves on `127.0.0.1:27000+<console port>`
  (32554 for `emulator-5554`), and exits a few seconds after nothing is
  watching.
- serve-sim and the helper start through your login shell (`$SHELL -lic`), so
  they find the same `node` your terminal does.
- Frames are written to `mods/simdock-screen/` (a ring of 12 files per view),
  because Herdr shows images from files.

## Install

Ask your Herdr agent: *"add the layout at github.com/wobsoriano/herdr-sim"*.
It reads [RECIPE.md](RECIPE.md) and the files, copies the mods and layout into
`~/.config/herdr-app/`, merges `keys.json`, and checks them.

Or by hand:

```sh
git clone https://github.com/wobsoriano/herdr-sim
cd herdr-sim
cp -R mods/simdock mods/simdock-screen mods/tabs-simdock ~/.config/herdr-app/mods/
cp layouts/simdock.json ~/.config/herdr-app/layouts/
herdr-app do layout.switch --name simdock
```

Then add the two keys in [keys.json](keys.json) to `~/.config/herdr-app/keys.json`.
`⌘⇧S` toggles the panel in the `simdock` layout and opens a pane in any other.

Only want the pane? Copy `mods/simdock` and `mods/simdock-screen`; the layout
and `tabs-simdock` are for the panel.

**Needs** macOS, Xcode with at least one simulator, Node on your shell's
`PATH`, and for Android, the Android SDK with an emulator image for your Mac's
architecture.

## Use it

### As a panel

In the `simdock` layout the tab bar has a **Simulator** button after Files and
Changes. It opens the device in the right-hand panel, like Files and Changes,
and remembers per space whether it was open. `⌘⇧S` does the same.

### As a pane

In any layout:

```sh
herdr-app do pane.split --direction right --mod simdock
```

or `⌘⇧S`. Close it like any pane.

### With e2e

[`e2e/herdr-simdock.ts`](e2e/herdr-simdock.ts) is a reporter for
[e2e](https://e2e.tester.army) that shows the device when a run starts: the
panel in the `simdock` layout, otherwise a pane beside the tests (reused across
runs while it stays open). Copy it into your project and add it to your config:

```ts
import { herdrSimdock } from './e2e/herdr-simdock';

export default {
  // ...
  reporters: ['list', herdrSimdock()],
};
```

Outside Herdr it does nothing. It shows the device you last picked; pick the
one your target runs on.

## Limits

- Tested on macOS with Herdr 0.1.13, Xcode 27 (iOS 27.2), and Android emulator
  37.2 (API 36). Linux and Windows aren't supported.
- Every frame shows about 200 ms after it arrives. Herdr takes ~175 ms to show
  a changed image file and has no way for a mod to show image bytes directly,
  so taps feel a little behind the device itself.
- The iOS view keeps 12 full-size frames decoded, about 175 MB of memory while
  it shows.
- Android input goes through `adb shell input` (30 to 40 ms a command).
- The reporter doesn't switch the picker to the device under test.
- `tabs-simdock` is a copy of Herdr 0.1.13's tab bar with the Simulator button
  added. When a Herdr release changes its tab bar, the copy keeps the old one
  until it's updated here (or you clone `tabs` again and add the button).

## License

MIT, see [LICENSE](LICENSE). `mods/tabs-simdock` is derived from Herdr's
`tabs` mod (Apache-2.0, see `mods/tabs-simdock/LICENSE`). The icons are from
[Lucide](https://lucide.dev) (ISC, see `mods/simdock/icons/LICENSE-lucide.txt`),
except `android.svg`.
