package game

import rl "vendor:raylib"

import "core:fmt"

import "../core"


Screen :: enum {
	MENU,
	PLAYING,
	GAME_OVER,
}

// Main goal is that the game run's here
GameState :: struct {
	screen:        Screen,
	player:        Player,
	bullets:       [dynamic]Bullet,
	enemy_bullets: [dynamic]Bullet,
	enemies:       [dynamic]Enemy,
	spawner:       Spawner,
	score:         int,
}


init_game :: proc() -> GameState {
	return GameState {
		screen = .MENU,
		player = create_player(),
		spawner = create_spawner(),
		score = 0,
	}
}
update_game :: proc(s: ^GameState) {

	inputs := core.Get_Input()

	switch s.screen {
	case .MENU:
		if inputs.start {
			s.screen = .PLAYING
		}
	case .PLAYING:
		update_player(&s.player, inputs, &s.bullets)
		update_spawner(&s.spawner, &s.enemies)
		update_bullet(&s.bullets)
		update_bullet(&s.enemy_bullets)

		bullet_collision(s)

		//same logic for enemies i guess
		for i := len(s.enemies) - 1; i >= 0; i -= 1 {
			update_enemy(&s.enemies[i], &s.enemy_bullets, s.player.position)
			if !s.enemies[i].active {
				unordered_remove(&s.enemies, i)
			}
		}

		if !s.player.active {
			s.screen = .GAME_OVER
		}

	case .GAME_OVER:
		if inputs.restart {
			s^ = init_game()
		}
	}

}

draw_game :: proc(s: ^GameState) {
	rl.BeginDrawing()
	rl.ClearBackground({160, 200, 255, 255})

	switch s.screen {
	case .MENU:
		rl.DrawText("press enter to  start game", 0, 0, 16, rl.WHITE)
	case .PLAYING:
		draw_player(s.player)
		draw_bullet(&s.bullets)
		draw_bullet(&s.enemy_bullets)

		for enemy in s.enemies {
			draw_enemy(enemy)
		}
		rl.DrawText(fmt.ctprintf("Score: %d", s.score), 0, 0, 16, rl.WHITE)
	case .GAME_OVER:
		draw_player(s.player)
		draw_bullet(&s.bullets)
		draw_bullet(&s.enemy_bullets)

		for enemy in s.enemies {
			draw_enemy(enemy)
		}

		rl.DrawText("Gave Over press r to restart", 0, 0, 16, rl.WHITE)
	// overlay rect
	// "GAME OVER" centered
	// "Score: N" centered
	// "Press R to restart" centered
	}


	rl.EndDrawing()
}
