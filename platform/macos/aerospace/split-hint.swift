// aerospace-split-hint — Hyprland-style dwindle layout for AeroSpace.
// Adapted from omacosy (https://github.com/paulsp94/omacosy), MIT.
//
// Hyprland's dwindle splits the focused window along its longer edge,
// so the next window lands beside a wide window and below a tall one.
// AeroSpace has no such layout and no window geometry in its config
// language, so the direction is chosen here and applied with `split`
// while the next window still does not exist. AeroSpace then places
// that window correctly on its first pass.
//
// Driven by aerospace.toml's on-focus-changed hook, which names the
// window in AEROSPACE_WINDOW_ID. The frame comes from the CG window
// list rather than the Accessibility API, so this needs no permission
// grant of its own.
//
// A NEW window fires this hook too (it takes focus on open), and at
// that moment its frame is still wherever the app spawned it —
// AeroSpace has not tiled it yet. Waiting for the frame to settle
// costs ~400ms and loses the race against rapid spawns, so new windows
// are PREDICTED instead: splitting a slot makes both halves' geometry
// known without looking. A state file carries the last hinted window's
// slot and direction; a hook for a NEWER window id (CGWindowIDs are
// issued in increasing order) chains off it instantly. Refocusing an
// EXISTING window reads the frame directly. The slow settle-wait
// survives only as the fallback when there is no fresh state to chain
// from (first window in a burst).
//
// Build: swiftc -O -o ~/.local/bin/aerospace-split-hint split-hint.swift

import CoreGraphics
import Foundation

guard let idStr = ProcessInfo.processInfo.environment["AEROSPACE_WINDOW_ID"],
    let wid = UInt32(idStr) else { exit(0) }

func frame() -> (CGFloat, CGFloat, CGFloat, CGFloat)? {
    guard let list = CGWindowListCopyWindowInfo(.optionIncludingWindow, wid) as? [[String: Any]],
        let b = list.first?[kCGWindowBounds as String] as? [String: CGFloat],
        let x = b["X"], let y = b["Y"],
        let w = b["Width"], let h = b["Height"] else { return nil }
    return (x, y, w, h)
}

// Hyprland's rule is `stack when h * multiplier > w`
// (dwindle:split_width_multiplier, default 1.0). 1.4 makes a wide
// display's half-slot stack first, restoring the left/down/left
// spiral cadence on wide monitors.
let splitWidthMultiplier: CGFloat = 1.4
let statePath = "/tmp/aerospace-split-state-\(getuid())"
let now = Date().timeIntervalSince1970

// State is one line: "wid w h ts". A 3s TTL bounds how stale a chain
// can get (manual resizes, closes, and workspace switches invalidate
// predictions; a burst of opens never lives that long).
var state: (wid: UInt32, w: CGFloat, h: CGFloat)?
if let line = try? String(contentsOfFile: statePath, encoding: .utf8) {
    let f = line.split(separator: " ").compactMap { Double($0) }
    if f.count == 4, now - f[3] < 3 { state = (UInt32(f[0]), CGFloat(f[1]), CGFloat(f[2])) }
}

var w: CGFloat
var h: CGFloat
if let s = state, wid > s.wid {
    // fresh spawn inside a burst: its slot is the half left over
    // from the split we just issued on the previous window
    if s.w >= s.h * splitWidthMultiplier { w = s.w / 2; h = s.h } else { w = s.w; h = s.h / 2 }
} else if state != nil, let f = frame() {
    // an existing window refocused mid-burst: its frame is settled
    (w, h) = (f.2, f.3)
} else {
    // no fresh chain to ride: wait for the frame to stop moving.
    // A new window must MOVE (get tiled) before its frame is trusted,
    // while a hover/keyboard-focused window that never moves is
    // accepted after a short grace. Full bounds, not just size: a
    // spawning terminal inherits the last window's size, so only the
    // position reliably changes on tile.
    var sample = frame()
    var moved = false
    for tick in 1...16 {
        usleep(75_000)
        let next = frame()
        if let a = sample, let b = next, a != b { moved = true }
        if next == nil || (moved && next! == sample!) { sample = next; break }
        sample = next
        if !moved && tick >= 5 { break }
    }
    guard let f = sample else { exit(0) }
    (w, h) = (f.2, f.3)
}

let dir = w >= h * splitWidthMultiplier ? "horizontal" : "vertical"
let aerospaceBin = ["/opt/homebrew/bin/aerospace", "/usr/local/bin/aerospace"]
    .first { FileManager.default.isExecutableFile(atPath: $0) } ?? "aerospace"
let split = Process()
split.executableURL = URL(fileURLWithPath: aerospaceBin)
split.arguments = ["split", "--window-id", idStr, dir]
split.standardError = FileHandle.nullDevice
try? split.run()
split.waitUntilExit()
try? "\(wid) \(w) \(h) \(now)".write(toFile: statePath, atomically: true, encoding: .utf8)
