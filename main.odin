package game

import la "core:math/linalg"
import rl "vendor:raylib"

PLAYER_SPEED :: 300

main :: proc() {
	SPEED :: 10

	rl.InitWindow(1280, 720, "My Odin + Raylib game")

	player := rl.LoadTexture("player.png")


	player_pos: [2]f32

	for !rl.WindowShouldClose() {

		input: [2]f32

		if rl.IsKeyDown(.UP) {
			input.y -= SPEED
		}

		if rl.IsKeyDown(.DOWN) {
			input.y += SPEED
		}

		if rl.IsKeyDown(.LEFT) {
			input.x -= SPEED
		}

		if rl.IsKeyDown(.RIGHT) {
			input.x += SPEED
		}

		player_pos += la.normalize0(input) * PLAYER_SPEED * rl.GetFrameTime()

		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255}) //background
		rl.DrawTextureV(player, player_pos, rl.WHITE)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
