/**
 * Spawn Mesh Agent Tool
 *
 * Allows an agent to spawn a new pi session in a split pane that automatically
 * joins the mesh. Use this when you need more help - just spawn another agent
 * and send it a task description.
 *
 * Requirements:
 * - WezTerm terminal
 * - pi-mesh installed (`pi install npm:pi-mesh`)
 * - WEZTERM_PANE environment variable set (automatic in WezTerm)
 *
 * Usage:
 * 1. Copy this file to ~/.pi/agent/extensions/
 * 2. Use the spawn_mesh_agent tool to create new helper agents
 * 3. The new agent will join the mesh and can be communicated with via mesh_send
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";

export default function spawnMeshAgentExtension(pi: ExtensionAPI) {
  // Track spawned panes for cleanup
  const spawnedPanes: number[] = [];

  pi.registerTool({
    name: "spawn_mesh_agent",
    label: "Spawn Mesh Agent",
    description: `Spawn a new pi agent in a split pane that joins the mesh.

Use this when you need additional help with a task. The new agent will:
- Run in a split pane (horizontal by default, or vertical)
- Automatically join the pi-mesh
- Be reachable via mesh_send for coordination

The task parameter is sent as the initial prompt to the new agent.

Example:
- spawn_mesh_agent({ task: "Help me refactor the auth module - focus on the login flow" })
- spawn_mesh_agent({ task: "Review the test coverage for src/utils/", split: "vertical" })
- spawn_mesh_agent({ task: "Fix the TypeScript errors in the API layer", cwd: "/path/to/project" })

After spawning, use mesh_peers to see the new agent and mesh_send to coordinate.`,
    parameters: Type.Object({
      task: Type.String({
        description:
          "The task description/prompt to give to the new agent. Be specific about what you need help with.",
      }),
      split: Type.Optional(
        Type.Union([Type.Literal("horizontal"), Type.Literal("vertical")], {
          description:
            "How to split the pane. 'horizontal' splits left/right (default), 'vertical' splits top/bottom.",
        })
      ),
      cwd: Type.Optional(
        Type.String({
          description:
            "Working directory for the new agent. Defaults to current working directory.",
        })
      ),
    }),

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const { task, split = "horizontal", cwd } = params;

      // Check for WEZTERM_PANE
      const currentPane = process.env.WEZTERM_PANE;
      if (!currentPane) {
        return {
          content: [
            {
              type: "text",
              text: "Error: WEZTERM_PANE environment variable not set. This tool requires WezTerm terminal.",
            },
          ],
          details: { error: "WEZTERM_PANE not set" },
          isError: true,
        };
      }

      onUpdate?.({
        content: [{ type: "text", text: "Spawning new pi session in split pane..." }],
      });

      try {
        // Build the split-pane command
        const splitArgs = ["cli", "split-pane", "--pane-id", currentPane];

        // Add split direction
        if (split === "vertical") {
          splitArgs.push("--bottom");
        } else {
          splitArgs.push("--right");
        }

        // Add working directory if specified
        const workDir = cwd || ctx.cwd;
        if (workDir) {
          splitArgs.push("--cwd", workDir);
        }

        // The command to run: start pi interactively
        // We just spawn pi - it will auto-register with the mesh
        // Then we use wezterm send-text to send the initial task
        splitArgs.push("--", "pi");

        // Execute the split-pane command
        const result = await pi.exec("wezterm", splitArgs, {
          signal,
          timeout: 10000,
        });

        if (result.code !== 0) {
          return {
            content: [
              {
                type: "text",
                text: `Error spawning pane: ${result.stderr || "Unknown error"}`,
              },
            ],
            details: { error: result.stderr, exitCode: result.code },
            isError: true,
          };
        }

        // Parse the pane ID from stdout
        const newPaneId = parseInt(result.stdout.trim(), 10);
        if (isNaN(newPaneId)) {
          return {
            content: [
              {
                type: "text",
                text: `Pane spawned but could not parse pane ID from output: ${result.stdout}`,
              },
            ],
            details: { rawOutput: result.stdout },
          };
        }

        // Track the spawned pane
        spawnedPanes.push(newPaneId);

        // Wait a moment for pi to start
        await new Promise((resolve) => setTimeout(resolve, 2000));

        // First, join the mesh with /mesh command
        const meshResult = await pi.exec(
          "wezterm",
          [
            "cli",
            "send-text",
            "--pane-id",
            String(newPaneId),
            "--no-paste",
            `/mesh\r`,
          ],
          { signal, timeout: 5000 }
        );

        if (meshResult.code !== 0) {
          return {
            content: [
              {
                type: "text",
                text: `Pane ${newPaneId} spawned but failed to join mesh: ${meshResult.stderr}`,
              },
            ],
            details: {
              paneId: newPaneId,
              task,
              meshError: meshResult.stderr,
            },
          };
        }

        // Wait for mesh to initialize, then close the overlay and send the task
        await new Promise((resolve) => setTimeout(resolve, 1000));

        // Press Escape to close the mesh overlay
        await pi.exec(
          "wezterm",
          [
            "cli",
            "send-text",
            "--pane-id",
            String(newPaneId),
            "--no-paste",
            `\x1b`,
          ],
          { signal, timeout: 5000 }
        );

        await new Promise((resolve) => setTimeout(resolve, 500));

        // Now send the task
        const sendResult = await pi.exec(
          "wezterm",
          [
            "cli",
            "send-text",
            "--pane-id",
            String(newPaneId),
            "--no-paste",
            `${task}\r`,
          ],
          { signal, timeout: 5000 }
        );

        if (sendResult.code !== 0) {
          return {
            content: [
              {
                type: "text",
                text: `Pane ${newPaneId} spawned but failed to send task: ${sendResult.stderr}

You can manually send the task or use mesh_send once the agent appears.`,
              },
            ],
            details: {
              paneId: newPaneId,
              task,
              sendError: sendResult.stderr,
            },
          };
        }

        return {
          content: [
            {
              type: "text",
              text: `Successfully spawned new pi agent in pane ${newPaneId}.

The agent is running with the task:
"${task}"

To coordinate:
- Use mesh_peers() to see when the agent appears in the mesh
- Use mesh_send({ to: "<agent-name>", message: "..." }) to communicate
- The agent will work on the task and be available for follow-up instructions

Monitor pane: wezterm cli get-text --pane-id ${newPaneId} --start-line -50
Focus pane: wezterm cli activate-pane --pane-id ${newPaneId}`,
            },
          ],
          details: {
            paneId: newPaneId,
            task,
            split,
            cwd: workDir,
          },
        };
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        return {
          content: [
            {
              type: "text",
              text: `Error spawning mesh agent: ${errorMessage}`,
            },
          ],
          details: { error: errorMessage },
          isError: true,
        };
      }
    },
  });

  // Optional: Clean up spawned panes on shutdown
  pi.on("session_shutdown", async () => {
    // Don't kill panes by default - the spawned agents might still be working
    // Uncomment below if you want automatic cleanup:
    // for (const paneId of spawnedPanes) {
    //   try {
    //     await pi.exec("wezterm", ["cli", "kill-pane", "--pane-id", String(paneId)]);
    //   } catch {
    //     // Pane might already be closed
    //   }
    // }
  });
}
