package main

import rl "vendor:raylib"

import "game"

WINDOW_WIDTH :: 600
WINDOW_HEIGHT :: 1000


main :: proc() {

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "My Odin + Raylib game")

	state := game.init_game()

	// so this is my update function
	for !rl.WindowShouldClose() {

		game.update_game(&state)

		game.draw_game(&state)

		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}
