package game

import "core:fmt"
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


	for i := len(s.bullets) - 1; i >= 0; i -= 1 {

		update_bullet(&s.bullets[i])

		if !s.bullets[i].active {
			unordered_remove(&s.bullets, i)
		}

		fmt.println("Total bullets:", len(&s.bullets))
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
