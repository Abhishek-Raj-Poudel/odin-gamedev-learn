package main

import "core:math"
// import "core:fmt"
import la "core:math/linalg"
import rl "vendor:raylib"

// import "core"
import "core"
import "game"
import "graphics"

// PLAYER_SPEED :: 400


main :: proc() {

	screen_w: i32 = 600
	screen_h: i32 = 1000

	rl.InitWindow(screen_w, screen_h, "My Odin + Raylib game")
	//create
	// player := graphics.load_texture("player.png")

	player := game.create()

	//update
	player_pos: [2]f32

	for !rl.WindowShouldClose() {

		input := core.Get_Input()

		game.update(&player, input)

		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})
		game.draw(player)

		rl.EndDrawing()
		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}
