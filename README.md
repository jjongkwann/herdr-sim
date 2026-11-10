# Herdr Sim

Your iOS simulator and Android emulator, live inside [Herdr](https://herdr.dev), next to your code and terminals.

![Herdr Sim: a test file, its passing run, and the iPhone simulator showing the result](preview.png)

Pick any simulator or emulator on your Mac and use it right in Herdr. Run your mobile tests and watch them tap through the app while the results print beside it.

## What you can do

- **See the device live.** The screen updates about 30 times a second.
- **Use it in place.** Click to tap, drag to swipe, scroll with your mouse or trackpad, and type with your keyboard. The buttons above the screen press Home, Lock and the volume keys, rotate the device, and on iOS show or hide the on-screen keyboard.
- **Switch devices.** The picker lists every iOS simulator and Android emulator on your Mac, with the running ones marked green. Pick one that's off and it starts. Android emulators run without a window of their own.
- **Show two at once.** Each panel and pane has its own device, so an iPhone and an Android emulator can run side by side. A new pane starts on the device you picked last.
- **Put it where you want it.** Open it from a Simulator button in the tab bar, next to Files and Changes, or as a pane in any layout.
- **Fix stuck taps.** On Xcode 27, taps on a simulator sometimes stop working. Repair input in the picker fixes them. It restarts SpringBoard, so open apps close.

## Install

Ask your Herdr agent to "add the layout at github.com/wobsoriano/herdr-sim".

Or by hand:

```sh
git clone https://github.com/wobsoriano/herdr-sim
cd herdr-sim
scripts/install-serve-sim.sh
cp -R mods/herdr-sim mods/herdr-sim-screen mods/tabs-herdr-sim ~/.config/herdr-app/mods/
cp layouts/herdr-sim.json ~/.config/herdr-app/layouts/
herdr-app do layout.switch --name herdr-sim
```

Then add the two shortcuts in [keys.json](keys.json) to `~/.config/herdr-app/keys.json`. In Herdr, the layout and the mod are both named `herdr-sim`.

If you only want the pane, copy `mods/herdr-sim` and `mods/herdr-sim-screen` and skip the rest.

You need macOS, Xcode with at least one simulator, and Node 20 or later with npm. For Android you also need the Android SDK and an emulator image built for your Mac's chip.

### serve-sim

For iOS, Herdr Sim runs [serve-sim](https://github.com/EvanBacon/serve-sim) 0.1.49 from `~/.local/share/herdr-sim/serve-sim-0.1.49/`. `scripts/install-serve-sim.sh` puts it there once:

- It downloads `serve-sim-0.1.49.tgz` from the npm registry, or takes a tarball you already have: `scripts/install-serve-sim.sh path/to/serve-sim-0.1.49.tgz`.
- It stops unless the tarball's sha512 matches the hash written in the script, which is npm's `dist.integrity` for serve-sim 0.1.49.
- It unpacks the tarball into `package/` and installs serve-sim's one runtime dependency, `ws`, with `npm ci --ignore-scripts` from the lockfile in `scripts/serve-sim/`, which pins `ws` by its hash too. No package scripts run.

The mod then runs `node ~/.local/share/herdr-sim/serve-sim-0.1.49/package/dist/serve-sim.js` directly. It looks for `node` in `/opt/homebrew/bin`, then `/usr/local/bin`, then on Herdr's `PATH`. It never uses `npx` and never downloads anything at run time; if the folder is missing, the panel tells you to run the script. Running the script again replaces the folder.

## Use it

### From the tab bar

Switch to the `herdr-sim` layout. Click **Simulator** next to Files and Changes, or press ⌘⇧S. Click it again to close the panel. Each space remembers whether the panel was open.

### As a pane

In any other layout, press ⌘⇧S, or run:

```sh
herdr-app do pane.split --direction right --mod herdr-sim
```

Close it like any other pane.

## What it runs on your Mac

Herdr Sim sends nothing over the internet itself.

- For iOS it runs Xcode's simulator tools and the copy of serve-sim that `scripts/install-serve-sim.sh` installed. Only that script downloads anything.
- For Android it runs `adb` and the emulator from your Android SDK, plus a small helper that comes with the mod.
- It saves the latest frames of the screen as image files in its own folder, because Herdr shows pictures from files.

## Limits

- It works on macOS only. It's tested with Herdr 0.1.13, Xcode 27 and Android emulator 37.2.
- The picture is about 0.2 seconds behind the device, because Herdr takes that long to show a changed image. Taps and typing reach the device right away.
- Showing an iPhone takes about 175 MB of memory.
- The Simulator button lives in a copy of Herdr 0.1.13's tab bar. If a Herdr update changes the tab bar, this copy keeps the old one until it's updated here.

## License

MIT, see [LICENSE](LICENSE). The tab bar in `mods/tabs-herdr-sim` is adapted from Herdr's own and keeps Herdr's Apache-2.0 license, in `mods/tabs-herdr-sim/LICENSE`. The icons are from [Lucide](https://lucide.dev) under the ISC license, except the Android icon.
