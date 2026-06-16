package game

import rl "vendor:raylib"

import "../core"

// Main goal is that the game run's here
GameState :: struct {
	player:  Player,
	bullets: [dynamic]Bullet,
	// enemies: [dynamic]Enemy,
}

init_game :: proc() -> GameState {
	return GameState{player = create_player()}
}
update_game :: proc(s: ^GameState) {

	inputs := core.Get_Input()

	update_player(&s.player, inputs, &s.bullets)

	for &bullet in s.bullets {
		update_bullet(&bullet)
	}

}

draw_game :: proc(s: ^GameState) {
	rl.BeginDrawing()
	rl.ClearBackground({160, 200, 255, 255})

	draw_player(s.player)

	for bullet in s.bullets {
		draw_bullet(bullet)
	}

	rl.EndDrawing()
}
