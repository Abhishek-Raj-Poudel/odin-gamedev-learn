package main

import rl "vendor:raylib"

import "core"
import "game"


main :: proc() {

	screen_w: i32 = 600
	screen_h: i32 = 1000

	rl.InitWindow(screen_w, screen_h, "My Odin + Raylib game")

	player := game.create_player()
	enemy := game.create_enemy()

	//update
	player_pos: [2]f32

	for !rl.WindowShouldClose() {

		input := core.Get_Input()

		game.update_player(&player, input)
		game.update_enemy(&enemy)

		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})
		game.draw_player(player)
		game.draw_enemy(enemy)

		rl.EndDrawing()
		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}
