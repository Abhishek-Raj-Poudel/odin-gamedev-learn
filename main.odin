package game

import "core:math"
// import "core:fmt"
import la "core:math/linalg"
import rl "vendor:raylib"

import "core"
import "graphics"

PLAYER_SPEED :: 400


main :: proc() {

	screen_w: i32 = 600
	screen_h: i32 = 1000

	rl.InitWindow(screen_w, screen_h, "My Odin + Raylib game")

	player := graphics.load_texture("player.png")

	player_pos: [2]f32

	for !rl.WindowShouldClose() {

		input := core.Get_Input()

		direction := [2]f32{input.x, input.y}

		// movement
		if direction.x != 0 || direction.y != 0 {
			move := la.normalize0(direction) * PLAYER_SPEED * rl.GetFrameTime()
			player_pos += move
		}

		// fmt.println(player_pos)

		// ---- BOUNDARY CLAMP ----
		// because player_pos is in f32
		min_x := f32(0 - player.width / 2)
		max_x := f32(rl.GetScreenWidth() - player.width / 2)
		min_y := f32(0 - player.height / 2)
		max_y := f32(rl.GetScreenHeight() - player.height / 2)

		player_pos.x = math.clamp(player_pos.x, min_x, max_x)
		player_pos.y = math.clamp(player_pos.y, min_y, max_y)


		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255}) //background
		rl.DrawTextureV(player, player_pos, rl.WHITE)
		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}
