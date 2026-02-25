/**
 * Pi Chime Extension
 *
 * Plays an audio chime notification when Pi agent is done and waiting for input.
 * Works on macOS, Linux, and Windows.
 *
 * Configuration via environment variables:
 * - PI_CHIME_SOUND: Path to custom sound file (optional)
 * - PI_CHIME_DISABLED: Set to "1" to disable chime
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { platform } from "node:os";

function playChime(): void {
    if (process.env.PI_CHIME_DISABLED === "1") return;

    const customSound = process.env.PI_CHIME_SOUND?.trim();

    try {
        const os = platform();

        if (os === "darwin") {
            // macOS: use afplay
            const sound =
                customSound ||
                "/System/Library/Sounds/Funk.aiff"; // Default macOS system sound

            if (!existsSync(sound)) {
                // Fallback to simple beep if sound file doesn't exist
                spawn("osascript", ["-e", "beep"], {
                    detached: true,
                    stdio: "ignore",
                }).unref();
                return;
            }

            const child = spawn("afplay", [sound], {
                detached: true,
                stdio: "ignore",
            });
            child.unref();
        } else if (os === "linux") {
            // Linux: try paplay (PulseAudio), then aplay (ALSA), then speaker-test
            const sound = customSound;

            if (sound && existsSync(sound)) {
                // Try paplay first (PulseAudio)
                const child = spawn("paplay", [sound], {
                    detached: true,
                    stdio: "ignore",
                });
                child.on("error", () => {
                    // Fallback to aplay (ALSA)
                    const fallback = spawn("aplay", [sound], {
                        detached: true,
                        stdio: "ignore",
                    });
                    fallback.unref();
                });
                child.unref();
            } else {
                // No custom sound: try to play a system sound or beep
                const systemSounds = [
                    "/usr/share/sounds/freedesktop/stereo/complete.oga",
                    "/usr/share/sounds/freedesktop/stereo/bell.oga",
                    "/usr/share/sounds/sound-icons/glass-water-1.wav",
                ];

                const foundSound = systemSounds.find((s) => existsSync(s));
                if (foundSound) {
                    const child = spawn("paplay", [foundSound], {
                        detached: true,
                        stdio: "ignore",
                    });
                    child.on("error", () => {
                        const fallback = spawn("aplay", [foundSound], {
                            detached: true,
                            stdio: "ignore",
                        });
                        fallback.unref();
                    });
                    child.unref();
                } else {
                    // Last resort: terminal bell
                    process.stdout.write("\x07");
                }
            }
        } else if (os === "win32") {
            // Windows: use PowerShell to play sound
            const sound = customSound;

            if (sound && existsSync(sound)) {
                const child = spawn(
                    "powershell.exe",
                    [
                        "-NoProfile",
                        "-Command",
                        `(New-Object Media.SoundPlayer '${sound}').PlaySync()`,
                    ],
                    {
                        detached: true,
                        stdio: "ignore",
                    }
                );
                child.unref();
            } else {
                // Play default Windows notification sound
                const child = spawn(
                    "powershell.exe",
                    [
                        "-NoProfile",
                        "-Command",
                        "[System.Media.SystemSounds]::Asterisk.Play()",
                    ],
                    {
                        detached: true,
                        stdio: "ignore",
                    }
                );
                child.unref();
            }
        } else {
            // Unknown OS: try terminal bell
            process.stdout.write("\x07");
        }
    } catch {
        // Silently fail - don't break the agent for a notification sound
    }
}

export default function (pi: ExtensionAPI) {
    pi.on("agent_end", async () => {
        playChime();
    });
}
