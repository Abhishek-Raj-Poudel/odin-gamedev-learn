package game

import rl "vendor:raylib"

import "../core"

// import "core:fmt"

// Main goal is that the game run's here
GameState :: struct {
	player:  Player,
	bullets: [dynamic]Bullet,
	enemies: [dynamic]Enemy,
	spawner: Spawner,
}

init_game :: proc() -> GameState {
	return GameState{player = create_player(), spawner = create_spawner()}
}
update_game :: proc(s: ^GameState) {

	inputs := core.Get_Input()

	update_player(&s.player, inputs, &s.bullets)

	update_spawner(&s.spawner, &s.enemies)

	for i := len(s.bullets) - 1; i >= 0; i -= 1 {
		update_bullet(&s.bullets[i])
		if !s.bullets[i].active {
			unordered_remove(&s.bullets, i)
		}
	}

	// fmt.println("Total bullets:", len(s.bullets))

	//same logic for enemies i guess
	for i := len(s.enemies) - 1; i >= 0; i -= 1 {
		update_enemy(&s.enemies[i], &s.bullets, s.player.position)
		if !s.enemies[i].active {
			unordered_remove(&s.enemies, i)
		}
	}


}

draw_game :: proc(s: ^GameState) {
	rl.BeginDrawing()
	rl.ClearBackground({160, 200, 255, 255})

	draw_player(s.player)

	for bullet in s.bullets {
		draw_bullet(bullet)
	}

	for enemy in s.enemies {
		draw_enemy(enemy)
	}

	rl.EndDrawing()
}
