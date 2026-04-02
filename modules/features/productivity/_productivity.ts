#!/usr/bin/env bun
/**
 * productivity daemon + CLI
 *
 * Run as daemon:  productivity-daemon
 * Run as CLI:     productivity <command> [args]
 *
 * Socket: $XDG_RUNTIME_DIR/productivity.sock (newline-delimited JSON)
 * State file: $HOME/.local/share/daily-goals/<YYYY-MM-DD>.json
 */

import * as fs from "fs";
import * as path from "path";
import * as net from "net";
import * as os from "os";

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

// IPC request/response
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
  "productivity.sock"
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
  if (!state.pomodoro) {
    return { ok: true, running: false };
  }
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
  if (state.pomodoro?.timer) clearTimeout(state.pomodoro.timer);
  state.pomodoro = null;
}

function startPhase(
  phase: PomodoroPhase,
  negativeMins: number,
  workMins: number
): void {
  if (state.pomodoro?.timer) clearTimeout(state.pomodoro.timer);

  const durationMs =
    (phase === "negative" ? negativeMins : workMins) * 60 * 1000;
  const endTime = Date.now() + durationMs;

  const timer = setTimeout(() => {
    const nextPhase: PomodoroPhase =
      state.pomodoro?.phase === "negative" ? "work" : "negative";
    startPhase(nextPhase, negativeMins, workMins);

    if (nextPhase === "negative") {
      incrementSessions();
    }
  }, durationMs);

  // Don't let the timer keep the process alive
  if (timer.unref) timer.unref();

  state.pomodoro = { phase, endTime, negativeMins, workMins, timer };

  if (phase === "negative") {
    incrementSessions();
  }
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

    case "pomodoro.cancel": {
      clearPomodoro();
      return { ok: true };
    }

    case "pomodoro.skip": {
      if (!state.pomodoro) return { ok: false, error: "not running" };
      // Expire immediately — triggers transition on next tick
      state.pomodoro.endTime = Date.now();
      if (state.pomodoro.timer) clearTimeout(state.pomodoro.timer);
      state.pomodoro.timer = setTimeout(() => {
        const nextPhase: PomodoroPhase =
          state.pomodoro?.phase === "negative" ? "work" : "negative";
        const { negativeMins, workMins } = state.pomodoro!;
        startPhase(nextPhase, negativeMins, workMins);
        if (nextPhase === "negative") incrementSessions();
      }, 0);
      if (state.pomodoro.timer.unref) state.pomodoro.timer.unref();
      return { ok: true };
    }

    case "pomodoro.adjust": {
      if (!state.pomodoro) return { ok: false, error: "not running" };
      const deltaMins = Number(req.deltaMins ?? 0);
      const newEnd = state.pomodoro.endTime + deltaMins * 60 * 1000;
      const minEnd = Date.now() + 30_000;
      state.pomodoro.endTime = Math.max(newEnd, minEnd);
      // Reschedule timer
      if (state.pomodoro.timer) clearTimeout(state.pomodoro.timer);
      const remaining = state.pomodoro.endTime - Date.now();
      const { phase, negativeMins, workMins } = state.pomodoro;
      const timer = setTimeout(() => {
        const nextPhase: PomodoroPhase = phase === "negative" ? "work" : "negative";
        startPhase(nextPhase, negativeMins, workMins);
        if (nextPhase === "negative") incrementSessions();
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
      if (!data) return { ok: true, goals: [] };
      return { ok: true, goals: data.goals };
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
      const existing = readDayFile(fp);
      const base = existing ?? {
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
// Daemon entrypoint
// ---------------------------------------------------------------------------

function runDaemon(): void {
  // Clean up stale socket
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
          socket.write(JSON.stringify({ ok: false, error: "invalid JSON" }) + "\n");
          continue;
        }
        const res = dispatch(req);
        socket.write(JSON.stringify(res) + "\n");
      }
    });
    socket.on("error", () => {});
  });

  server.listen(SOCKET_PATH, () => {
    // Restrict socket permissions to owner only
    fs.chmodSync(SOCKET_PATH, 0o600);
    process.stderr.write(`productivity daemon listening on ${SOCKET_PATH}\n`);
  });

  server.on("error", (err) => {
    process.stderr.write(`server error: ${err.message}\n`);
    process.exit(1);
  });

  process.on("SIGTERM", () => {
    server.close();
    fs.unlinkSync(SOCKET_PATH);
    process.exit(0);
  });
  process.on("SIGINT", () => {
    server.close();
    try { fs.unlinkSync(SOCKET_PATH); } catch {}
    process.exit(0);
  });
}

// ---------------------------------------------------------------------------
// CLI entrypoint — sends one request, prints response, exits
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

    socket.on("error", (err) => reject(err));
    socket.setTimeout(2000, () => {
      socket.destroy();
      reject(new Error("daemon not responding"));
    });
  });
}

function formatRemaining(ms: number): string {
  const secs = Math.max(0, Math.floor(ms / 1000));
  const m = Math.floor(secs / 60);
  const s = secs % 60;
  return `${m}:${String(s).padStart(2, "0")}`;
}

async function runCli(): Promise<void> {
  const [, , sub, ...args] = process.argv;

  if (!sub) {
    console.error(
      "Usage: productivity <pomodoro|goals> <subcommand> [args]"
    );
    process.exit(1);
  }

  // --- pomodoro subcommands ---
  if (sub === "pomodoro") {
    const action = args[0];
    if (action === "start") {
      const neg = Number(args[1] ?? 10);
      const work = Number(args[2] ?? 10);
      const res = await sendRequest({
        cmd: "pomodoro.start",
        negativeMins: neg,
        workMins: work,
      });
      if (!res.ok) { console.error(res.error); process.exit(1); }
    } else if (action === "cancel") {
      await sendRequest({ cmd: "pomodoro.cancel" });
    } else if (action === "skip") {
      await sendRequest({ cmd: "pomodoro.skip" });
    } else if (action === "adjust") {
      const delta = Number(args[1] ?? 0);
      await sendRequest({ cmd: "pomodoro.adjust", deltaMins: delta });
    } else if (action === "waybar") {
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
      const text = phase === "negative" ? `NOTHING ${time}` : `WORK ${time}`;
      const cls = phase === "negative" ? "negative" : "work";
      console.log(JSON.stringify({ text, class: cls }));
    } else if (action === "status") {
      const res = await sendRequest({ cmd: "pomodoro.status" });
      console.log(JSON.stringify(res, null, 2));
    } else {
      console.error("Usage: productivity pomodoro {start|cancel|skip|adjust|waybar|status}");
      process.exit(1);
    }
    return;
  }

  // --- goals subcommands ---
  if (sub === "goals") {
    const action = args[0];
    if (action === "list") {
      const res = await sendRequest({ cmd: "goals.list" });
      const goals = res.goals as Goal[];
      if (goals.length === 0) { console.log("No goals set for today."); return; }
      for (const g of goals) {
        console.log(`${g.done ? "✅" : "⬜"} ${g.text}`);
      }
    } else if (action === "add") {
      const text = args.slice(1).join(" ");
      if (!text) { console.error("Usage: productivity goals add <text>"); process.exit(1); }
      await sendRequest({ cmd: "goals.add", text });
    } else if (action === "toggle") {
      const text = args.slice(1).join(" ");
      if (!text) { console.error("Usage: productivity goals toggle <text>"); process.exit(1); }
      await sendRequest({ cmd: "goals.toggle", text });
    } else if (action === "waybar") {
      let res: Response;
      try {
        res = await sendRequest({ cmd: "goals.status" });
      } catch {
        console.log(JSON.stringify({ text: "no goals", tooltip: "Daemon not running", class: "none" }));
        return;
      }
      const total = res.total as number;
      const done = res.done as number;
      const goals = res.goals as Goal[];
      const cls = total === 0 ? "none" : done === total ? "done" : "active";
      const tooltip = goals.map((g) => `${g.done ? "✅" : "⬜"} ${g.text}`).join("\n");
      console.log(JSON.stringify({ text: `[${done}/${total}]`, tooltip, class: cls }));
    } else {
      console.error("Usage: productivity goals {list|add|toggle|waybar}");
      process.exit(1);
    }
    return;
  }

  console.error(`Unknown subcommand: ${sub}`);
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Entrypoint dispatch
// ---------------------------------------------------------------------------

const entrypoint = path.basename(process.argv[1] ?? "");

if (entrypoint === "productivity-daemon") {
  runDaemon();
} else {
  runCli().catch((err: Error) => {
    console.error(`error: ${err.message}`);
    process.exit(1);
  });
}
