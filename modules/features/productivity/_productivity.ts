#!/usr/bin/env bun
/**
 * productivity daemon + CLI
 *
 * Run as daemon:  productivity-daemon  (systemd user service)
 * Run as CLI:     productivity <panel|pomodoro|goals> [subcommand] [args]
 *
 * Socket:     $XDG_RUNTIME_DIR/productivity.sock  (newline-delimited JSON)
 * State file: $HOME/.local/share/daily-goals/<YYYY-MM-DD>.json
 *
 * Tool paths injected by Nix wrapper (env vars):
 *   SWAYMSG      path to swaymsg
 *   FUZZEL       path to fuzzel
 *   NOTIFY_SEND  path to notify-send
 */

import * as fs from "fs";
import * as path from "path";
import * as net from "net";
import * as os from "os";
import { createInterface } from "readline";

// ---------------------------------------------------------------------------
// External tools — full store paths injected by Nix wrapper scripts
// ---------------------------------------------------------------------------

const SWAYMSG = process.env.SWAYMSG;
const FUZZEL = process.env.FUZZEL;
const NOTIFY_SEND = process.env.NOTIFY_SEND;

function spawnTool(bin: string, args: string[], stdin?: string): string {
  const proc = Bun.spawnSync([bin, ...args], {
    stdin: stdin !== undefined ? Buffer.from(stdin) : "ignore",
    stdout: "pipe",
    stderr: "inherit",
  });
  return proc.stdout ? Buffer.from(proc.stdout).toString().trim() : "";
}

/** Switch sway mode — silently ignored if SWAYMSG not set or sway not running */
function setSway(mode: string): void {
  if (!SWAYMSG) return;
  try {
    Bun.spawnSync([SWAYMSG, "mode", mode], {
      stderr: "ignore",
    });
    if (mode === "negative") {
      Bun.spawnSync([SWAYMSG, "workspace", "10"], {
        stderr: "ignore",
      });
    }
    Bun.spawnSync(["printf", `"\a"`]);
  } catch {}
}

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface Goal {
  text: string;
  done: boolean;
}

interface DayFile {
  date: string;
  skipped_ritual: boolean;
  negative_pomodoro_sessions: number;
  goals: Goal[];
  yesterday_review: string;
}

type PomodoroPhase = "negative" | "work";

interface PomodoroState {
  phase: PomodoroPhase;
  endTime: number; // unix ms
  negativeMins: number;
  workMins: number;
  timer: ReturnType<typeof setTimeout> | null;
}

interface DaemonState {
  pomodoro: PomodoroState | null;
}

interface Request {
  cmd: string;
  [key: string]: unknown;
}

interface Response {
  ok: boolean;
  [key: string]: unknown;
}

// ---------------------------------------------------------------------------
// Paths
// ---------------------------------------------------------------------------

const GOALS_DIR = path.join(os.homedir(), ".local/share/daily-goals");
const SOCKET_PATH = path.join(
  process.env.XDG_RUNTIME_DIR ?? `/run/user/${process.getuid!()}`,
  "productivity.sock",
);

function todayStr(): string {
  return new Date().toISOString().slice(0, 10);
}

function todayFile(): string {
  return path.join(GOALS_DIR, `${todayStr()}.json`);
}

// ---------------------------------------------------------------------------
// Day file helpers
// ---------------------------------------------------------------------------

function readDayFile(filePath: string): DayFile | null {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8")) as DayFile;
  } catch {
    return null;
  }
}

function writeDayFile(filePath: string, data: DayFile): void {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  const tmp = `${filePath}.tmp`;
  fs.writeFileSync(tmp, JSON.stringify(data, null, 2));
  fs.renameSync(tmp, filePath);
}

function ensureTodayFile(): DayFile {
  const fp = todayFile();
  const existing = readDayFile(fp);
  if (existing) return existing;
  const fresh: DayFile = {
    date: todayStr(),
    skipped_ritual: false,
    negative_pomodoro_sessions: 0,
    goals: [],
    yesterday_review: "",
  };
  writeDayFile(fp, fresh);
  return fresh;
}

// ---------------------------------------------------------------------------
// Daemon state
// ---------------------------------------------------------------------------

const state: DaemonState = { pomodoro: null };

function pomodoroStatus(): Response {
  if (!state.pomodoro) return { ok: true, running: false };
  const remaining = Math.max(0, state.pomodoro.endTime - Date.now());
  return {
    ok: true,
    running: true,
    phase: state.pomodoro.phase,
    remainingMs: remaining,
    negativeMins: state.pomodoro.negativeMins,
    workMins: state.pomodoro.workMins,
    endTime: state.pomodoro.endTime,
  };
}

function clearPomodoro(): void {
  const wasRunning = state.pomodoro !== null;
  if (state.pomodoro?.timer) clearTimeout(state.pomodoro.timer);
  state.pomodoro = null;
  if (wasRunning) setSway("default");
}

/** startPhase is the single place that owns phase transitions and sway mode. */
function startPhase(
  phase: PomodoroPhase,
  negativeMins: number,
  workMins: number,
): void {
  if (state.pomodoro?.timer) clearTimeout(state.pomodoro.timer);

  const durationMs =
    (phase === "negative" ? negativeMins : workMins) * 60 * 1000;
  const endTime = Date.now() + durationMs;

  const timer = setTimeout(() => {
    const nextPhase: PomodoroPhase = phase === "negative" ? "work" : "negative";
    startPhase(nextPhase, negativeMins, workMins);
  }, durationMs);

  if (timer.unref) timer.unref();
  state.pomodoro = { phase, endTime, negativeMins, workMins, timer };
  setSway(phase === "negative" ? "negative" : "default");
  if (phase === "negative") incrementSessions();
}

function incrementSessions(): void {
  const fp = todayFile();
  const data = readDayFile(fp);
  if (data) {
    data.negative_pomodoro_sessions += 1;
    writeDayFile(fp, data);
  }
}

// ---------------------------------------------------------------------------
// Command handlers
// ---------------------------------------------------------------------------

function handlePomodoro(req: Request): Response {
  switch (req.cmd) {
    case "pomodoro.start": {
      const negativeMins = Number(req.negativeMins ?? 10);
      const workMins = Number(req.workMins ?? 10);
      const phase = (req.phase as PomodoroPhase) ?? "negative";
      clearPomodoro();
      startPhase(phase, negativeMins, workMins);
      return { ok: true, phase, negativeMins, workMins };
    }
    case "pomodoro.cancel":
      clearPomodoro();
      return { ok: true };

    case "pomodoro.skip": {
      if (!state.pomodoro) return { ok: false, error: "not running" };
      const { negativeMins, workMins, phase } = state.pomodoro;
      startPhase(
        phase === "negative" ? "work" : "negative",
        negativeMins,
        workMins,
      );
      return { ok: true };
    }
    case "pomodoro.adjust": {
      if (!state.pomodoro) return { ok: false, error: "not running" };
      const deltaMins = Number(req.deltaMins ?? 0);
      const newEnd = state.pomodoro.endTime + deltaMins * 60 * 1000;
      state.pomodoro.endTime = Math.max(newEnd, Date.now() + 30_000);
      if (state.pomodoro.timer) clearTimeout(state.pomodoro.timer);
      const remaining = state.pomodoro.endTime - Date.now();
      const { phase, negativeMins, workMins } = state.pomodoro;
      const timer = setTimeout(() => {
        startPhase(
          phase === "negative" ? "work" : "negative",
          negativeMins,
          workMins,
        );
      }, remaining);
      if (timer.unref) timer.unref();
      state.pomodoro.timer = timer;
      return { ok: true, endTime: state.pomodoro.endTime };
    }
    case "pomodoro.status":
      return pomodoroStatus();

    default:
      return { ok: false, error: `unknown command: ${req.cmd}` };
  }
}

function handleGoals(req: Request): Response {
  switch (req.cmd) {
    case "goals.list": {
      const data = readDayFile(todayFile());
      return { ok: true, goals: data?.goals ?? [] };
    }
    case "goals.add": {
      const text = String(req.text ?? "").trim();
      if (!text) return { ok: false, error: "empty text" };
      const data = ensureTodayFile();
      data.goals.push({ text, done: false });
      writeDayFile(todayFile(), data);
      return { ok: true, goals: data.goals };
    }
    case "goals.toggle": {
      const text = String(req.text ?? "").trim();
      if (!text) return { ok: false, error: "empty text" };
      const fp = todayFile();
      const data = readDayFile(fp);
      if (!data) return { ok: false, error: "no goals file" };
      const goal = data.goals.find((g) => g.text === text);
      if (!goal) return { ok: false, error: "goal not found" };
      goal.done = !goal.done;
      writeDayFile(fp, data);
      return { ok: true, goals: data.goals };
    }
    case "goals.status": {
      const data = readDayFile(todayFile());
      if (!data) return { ok: true, total: 0, done: 0, goals: [] };
      const done = data.goals.filter((g) => g.done).length;
      return { ok: true, total: data.goals.length, done, goals: data.goals };
    }
    case "ritual.save": {
      const fp = todayFile();
      const base = readDayFile(fp) ?? {
        date: todayStr(),
        skipped_ritual: false,
        negative_pomodoro_sessions: 0,
        goals: [],
        yesterday_review: "",
      };
      if (req.goals !== undefined) base.goals = req.goals as Goal[];
      if (req.yesterday_review !== undefined)
        base.yesterday_review = String(req.yesterday_review);
      if (req.skipped_ritual !== undefined)
        base.skipped_ritual = Boolean(req.skipped_ritual);
      writeDayFile(fp, base);
      return { ok: true };
    }
    default:
      return { ok: false, error: `unknown command: ${req.cmd}` };
  }
}

function dispatch(req: Request): Response {
  if (req.cmd.startsWith("pomodoro.")) return handlePomodoro(req);
  if (req.cmd.startsWith("goals.") || req.cmd === "ritual.save")
    return handleGoals(req);
  if (req.cmd === "ping") return { ok: true, pong: true };
  return { ok: false, error: `unknown command: ${req.cmd}` };
}

// ---------------------------------------------------------------------------
// Daemon server
// ---------------------------------------------------------------------------

function runDaemon(): void {
  if (fs.existsSync(SOCKET_PATH)) {
    try {
      fs.unlinkSync(SOCKET_PATH);
    } catch {}
  }

  const server = net.createServer((socket) => {
    let buf = "";
    socket.on("data", (chunk) => {
      buf += chunk.toString();
      const lines = buf.split("\n");
      buf = lines.pop() ?? "";
      for (const line of lines) {
        if (!line.trim()) continue;
        let req: Request;
        try {
          req = JSON.parse(line) as Request;
        } catch {
          socket.write(
            JSON.stringify({ ok: false, error: "invalid JSON" }) + "\n",
          );
          continue;
        }
        socket.write(JSON.stringify(dispatch(req)) + "\n");
      }
    });
    socket.on("error", () => {});
  });

  server.listen(SOCKET_PATH, () => {
    fs.chmodSync(SOCKET_PATH, 0o600);
    process.stderr.write(`productivity daemon listening on ${SOCKET_PATH}\n`);
  });

  server.on("error", (err) => {
    process.stderr.write(`server error: ${err.message}\n`);
    process.exit(1);
  });

  const shutdown = () => {
    clearPomodoro(); // resets sway mode if a session was active
    server.close();
    try {
      fs.unlinkSync(SOCKET_PATH);
    } catch {}
    process.exit(0);
  };
  process.on("SIGTERM", shutdown);
  process.on("SIGINT", shutdown);
}

// ---------------------------------------------------------------------------
// IPC client
// ---------------------------------------------------------------------------

async function sendRequest(req: Request): Promise<Response> {
  return new Promise((resolve, reject) => {
    const socket = net.createConnection(SOCKET_PATH, () => {
      socket.write(JSON.stringify(req) + "\n");
    });
    let buf = "";
    socket.on("data", (chunk) => {
      buf += chunk.toString();
      const nl = buf.indexOf("\n");
      if (nl !== -1) {
        socket.destroy();
        try {
          resolve(JSON.parse(buf.slice(0, nl)) as Response);
        } catch (e) {
          reject(e);
        }
      }
    });
    socket.on("error", reject);
    socket.setTimeout(2000, () => {
      socket.destroy();
      reject(new Error("daemon not responding"));
    });
  });
}

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

function formatRemaining(ms: number): string {
  const secs = Math.max(0, Math.floor(ms / 1000));
  return `${Math.floor(secs / 60)}:${String(secs % 60).padStart(2, "0")}`;
}

// ---------------------------------------------------------------------------
// Terminal helpers (panel TUI)
// ---------------------------------------------------------------------------

const ESC = "\x1b";
const CLR = `${ESC}[2J${ESC}[H`;

const c = {
  bold: (s: string) => `${ESC}[1m${s}${ESC}[0m`,
  dim: (s: string) => `${ESC}[2m${s}${ESC}[0m`,
  red: (s: string) => `${ESC}[31m${s}${ESC}[0m`,
  green: (s: string) => `${ESC}[32m${s}${ESC}[0m`,
  yellow: (s: string) => `${ESC}[33m${s}${ESC}[0m`,
};

function setupRawTerminal(): () => void {
  process.stdin.setRawMode(true);
  process.stdin.resume();
  const restore = () => {
    try {
      process.stdin.setRawMode(false);
    } catch {}
  };
  process.once("exit", restore);
  return restore;
}

async function readKey(timeoutMs: number): Promise<string | null> {
  return new Promise((resolve) => {
    const t = setTimeout(() => {
      process.stdin.removeListener("data", handler);
      resolve(null);
    }, timeoutMs);
    const handler = (buf: Buffer) => {
      clearTimeout(t);
      process.stdin.removeListener("data", handler);
      resolve(buf.toString("utf8")[0] ?? null);
    };
    process.stdin.once("data", handler);
  });
}

async function promptLine(prompt: string, defaultVal = ""): Promise<string> {
  const rl = createInterface({ input: process.stdin, output: process.stdout });
  const label = defaultVal ? `${prompt} [${defaultVal}]: ` : `${prompt}: `;
  return new Promise((resolve) => {
    rl.question(label, (answer) => {
      rl.close();
      resolve(answer.trim() || defaultVal);
    });
  });
}

// ---------------------------------------------------------------------------
// Panel TUI
// ---------------------------------------------------------------------------

const MENU_CHOICES = [
  { neg: 10, work: 10, label: "10 / 10  (10min nothing, 10min work)" },
  { neg: 10, work: 20, label: "10 / 20  (10min nothing, 20min work)" },
  { neg: 20, work: 20, label: "20 / 20  (20min nothing, 20min work)" },
];

function renderMenu(): void {
  process.stdout.write(CLR);
  process.stdout.write(c.bold("  Negative Pomodoro\n\n"));
  MENU_CHOICES.forEach((ch, i) => {
    process.stdout.write(`  ${c.dim(`[${i + 1}]`)}  ${ch.label}\n`);
  });
  process.stdout.write(`  ${c.dim("[c]")}  Custom\n\n`);
  process.stdout.write(c.dim("  1–3, c to start  ·  q to quit\n"));
}

function renderCountdown(
  phase: string,
  remainingMs: number,
  negMins: number,
  workMins: number,
): void {
  const phaseLabel =
    phase === "negative" ? c.red(c.bold("NOTHING")) : c.green(c.bold("WORK"));
  const timeStr = formatRemaining(remainingMs);
  const timeColored =
    remainingMs < 60_000
      ? c.red(c.bold(timeStr))
      : remainingMs < 3 * 60_000
        ? c.yellow(timeStr)
        : c.bold(timeStr);

  process.stdout.write(CLR);
  process.stdout.write(c.bold("  Negative Pomodoro") + "\n");
  process.stdout.write(
    c.dim("  s:skip  c:cancel  +:+5min  -:-5min  q:quit panel") + "\n\n",
  );
  process.stdout.write(`  Phase:     ${phaseLabel}\n`);
  process.stdout.write(`  Remaining: ${timeColored}\n`);
  process.stdout.write(`  Cycle:     ${negMins}min / ${workMins}min\n`);
}

async function showStartMenu(): Promise<boolean> {
  const restore = setupRawTerminal();
  renderMenu();

  while (true) {
    const key = await readKey(60_000);
    if (!key || key === "q" || key === "\x03" || key === "\x1b") {
      restore();
      process.stdout.write(CLR);
      return false;
    }
    if (key >= "1" && key <= "3") {
      const ch = MENU_CHOICES[parseInt(key) - 1];
      restore();
      await sendRequest({
        cmd: "pomodoro.start",
        negativeMins: ch.neg,
        workMins: ch.work,
      });
      return true;
    }
    if (key === "c") {
      restore();
      process.stdout.write(CLR);
      const negStr = await promptLine("  Nothing minutes", "10");
      const workStr = await promptLine("  Work minutes", "20");
      await sendRequest({
        cmd: "pomodoro.start",
        negativeMins: Math.max(1, parseInt(negStr) || 10),
        workMins: Math.max(1, parseInt(workStr) || 20),
      });
      return true;
    }
  }
}

async function showCountdown(): Promise<void> {
  const restore = setupRawTerminal();
  try {
    while (true) {
      let res: Response;
      try {
        res = await sendRequest({ cmd: "pomodoro.status" });
      } catch {
        break;
      }
      if (!res.running) break;

      renderCountdown(
        res.phase as string,
        res.remainingMs as number,
        res.negativeMins as number,
        res.workMins as number,
      );

      const key = await readKey(1000);
      if (!key) continue;

      switch (key) {
        case "s":
          await sendRequest({ cmd: "pomodoro.skip" });
          break;
        case "+":
          await sendRequest({ cmd: "pomodoro.adjust", deltaMins: 5 });
          break;
        case "-":
          await sendRequest({ cmd: "pomodoro.adjust", deltaMins: -5 });
          break;
        case "c":
          await sendRequest({ cmd: "pomodoro.cancel" });
          restore();
          process.stdout.write(CLR + "  Cancelled.\n");
          return;
        case "q":
        case "\x03":
          restore();
          return; // panel closes, timer + sway mode remain active
      }
    }
  } finally {
    restore();
  }

  process.stdout.write(CLR + "  Timer ended.\n");
  await new Promise<void>((r) => setTimeout(r, 1500));
}

async function runPanel(): Promise<void> {
  let status: Response;
  try {
    status = await sendRequest({ cmd: "pomodoro.status" });
  } catch {
    console.error("productivity daemon not responding");
    process.exit(1);
  }

  if (!status.running) {
    const started = await showStartMenu();
    if (!started) return;
  }

  await showCountdown();
}

// ---------------------------------------------------------------------------
// Goals interactive commands
// ---------------------------------------------------------------------------

async function goalsToggleInteractive(): Promise<void> {
  if (!FUZZEL) {
    console.error(
      "FUZZEL env var not set — are you running via the Nix wrapper?",
    );
    process.exit(1);
  }

  let res: Response;
  try {
    res = await sendRequest({ cmd: "goals.status" });
  } catch {
    console.error("daemon not responding");
    process.exit(1);
  }

  const goals = res.goals as Goal[];
  if (goals.length === 0) {
    if (NOTIFY_SEND)
      spawnTool(NOTIFY_SEND, ["No goals", "No goals to toggle today"]);
    return;
  }

  const menu = goals.map((g) => `${g.done ? "✅" : "⬜"} ${g.text}`).join("\n");
  const selected = spawnTool(
    FUZZEL,
    ["--dmenu", "--prompt", "Toggle goal: "],
    menu + "\n",
  );
  if (!selected) return;

  const text = selected.replace(/^[✅⬜]\s*/, "").trim();
  if (text) await sendRequest({ cmd: "goals.toggle", text });
}

async function goalsAddInteractive(): Promise<void> {
  const text = await promptLine("New goal");
  if (text) await sendRequest({ cmd: "goals.add", text });
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

async function handlePomodoroCmd(args: string[]): Promise<void> {
  switch (args[0]) {
    case "start": {
      const res = await sendRequest({
        cmd: "pomodoro.start",
        negativeMins: Number(args[1] ?? 10),
        workMins: Number(args[2] ?? 10),
      });
      if (!res.ok) {
        console.error(res.error);
        process.exit(1);
      }
      break;
    }
    case "cancel":
      await sendRequest({ cmd: "pomodoro.cancel" });
      break;
    case "skip":
      await sendRequest({ cmd: "pomodoro.skip" });
      break;
    case "adjust": {
      await sendRequest({
        cmd: "pomodoro.adjust",
        deltaMins: Number(args[1] ?? 0),
      });
      break;
    }
    case "waybar": {
      let res: Response;
      try {
        res = await sendRequest({ cmd: "pomodoro.status" });
      } catch {
        console.log(JSON.stringify({ text: "", class: "idle" }));
        return;
      }
      if (!res.running) {
        console.log(JSON.stringify({ text: "", class: "idle" }));
        return;
      }
      const time = formatRemaining(res.remainingMs as number);
      const phase = res.phase as string;
      console.log(
        JSON.stringify({
          text: phase === "negative" ? `NOTHING ${time}` : `WORK ${time}`,
          class: phase === "negative" ? "negative" : "work",
        }),
      );
      break;
    }
    case "status": {
      console.log(
        JSON.stringify(await sendRequest({ cmd: "pomodoro.status" }), null, 2),
      );
      break;
    }
    default:
      console.error(
        "Usage: productivity pomodoro {start|cancel|skip|adjust|waybar|status}",
      );
      process.exit(1);
  }
}

async function handleGoalsCmd(args: string[]): Promise<void> {
  switch (args[0]) {
    case "list": {
      const goals = (await sendRequest({ cmd: "goals.list" })).goals as Goal[];
      if (!goals.length) {
        console.log("No goals set for today.");
        return;
      }
      for (const g of goals) console.log(`${g.done ? "✅" : "⬜"} ${g.text}`);
      break;
    }
    case "add": {
      const text = args.slice(1).join(" ");
      if (!text) {
        console.error("Usage: productivity goals add <text>");
        process.exit(1);
      }
      await sendRequest({ cmd: "goals.add", text });
      break;
    }
    case "add-interactive":
      await goalsAddInteractive();
      break;
    case "toggle": {
      const text = args.slice(1).join(" ");
      if (!text) {
        console.error("Usage: productivity goals toggle <text>");
        process.exit(1);
      }
      await sendRequest({ cmd: "goals.toggle", text });
      break;
    }
    case "toggle-interactive":
      await goalsToggleInteractive();
      break;
    case "waybar": {
      let res: Response;
      try {
        res = await sendRequest({ cmd: "goals.status" });
      } catch {
        console.log(
          JSON.stringify({
            text: "no goals",
            tooltip: "Daemon not running",
            class: "none",
          }),
        );
        return;
      }
      const total = res.total as number;
      const done = res.done as number;
      const goals = res.goals as Goal[];
      const tooltip = goals
        .map((g) => `${g.done ? "✅" : "⬜"} ${g.text}`)
        .join("\n");
      console.log(
        JSON.stringify({
          text: `[${done}/${total}]`,
          tooltip,
          class: total === 0 ? "none" : done === total ? "done" : "active",
        }),
      );
      break;
    }
    default:
      console.error(
        "Usage: productivity goals {list|add|add-interactive|toggle|toggle-interactive|waybar}",
      );
      process.exit(1);
  }
}

async function runCli(): Promise<void> {
  const [sub, ...args] = process.argv.slice(2).filter((a) => a !== "--daemon");

  if (!sub) {
    console.error(
      "Usage: productivity <panel|pomodoro|goals> [subcommand] [args]",
    );
    process.exit(1);
  }

  if (sub === "panel") {
    await runPanel();
    return;
  }
  if (sub === "pomodoro") {
    await handlePomodoroCmd(args);
    return;
  }
  if (sub === "goals") {
    await handleGoalsCmd(args);
    return;
  }

  console.error(`Unknown subcommand: ${sub}`);
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Entrypoint
// ---------------------------------------------------------------------------

if (process.argv.includes("--daemon")) {
  runDaemon();
} else {
  runCli().catch((err: Error) => {
    console.error(`error: ${err.message}`);
    process.exit(1);
  });
}
