/// <reference types="node" />
import { execFile } from 'node:child_process';
import { readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { Reporter } from 'e2e';

// Resolves with the command's JSON output, or null when it failed.
const herdr = (...args: string[]) =>
  new Promise<Record<string, string> | null>((resolve) =>
    execFile('herdr-app', ['do', ...args], (error, stdout) => {
      try {
        resolve(error ? null : JSON.parse(stdout));
      } catch {
        resolve(null);
      }
    }),
  );

// Herdr's CLI can't list mod panes, so the pane this reporter opened is remembered here.
const PANE_FILE = join(tmpdir(), 'herdr-sim-pane');

async function showHerdrSim(terminal: string) {
  // A layout with the Simulator panel: select it first, so it never opens on Files or Changes.
  if (await herdr('layout.select', '--stack', 'panel-body', '--child', 'herdr-sim')) {
    await herdr('layout.show', '--id', 'panel');
    return;
  }
  // Any other layout: a pane beside the tests, reused across runs while it stays open.
  const known = await readFile(PANE_FILE, 'utf8').catch(() => '');
  if (known && (await herdr('pane.focus', '--pane', known))) {
    await herdr('pane.focus', '--terminal', terminal);
    return;
  }
  const opened = await herdr('pane.split', '--direction', 'right', '--mod', 'herdr-sim');
  if (opened?.pane) await writeFile(PANE_FILE, opened.pane);
  await herdr('pane.focus', '--terminal', terminal);
}

/** Shows the simulator in Herdr when `e2e run` starts: the Simulator panel, or a pane in other layouts. Does nothing outside Herdr. */
export function herdrSim(): Reporter {
  return {
    name: 'herdr-sim',
    onEvent(event) {
      const terminal = process.env.HC_TERMINAL_ID;
      if (event.type === 'run-started' && terminal) void showHerdrSim(terminal);
    },
  };
}
