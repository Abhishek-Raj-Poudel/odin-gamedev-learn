package game

import rl "vendor:raylib"

import "../core"

import "core:fmt"


Screen :: enum {
	MENU,
	PLAYING,
	GAME_OVER,
}

// Main goal is that the game run's here
GameState :: struct {
	screen:  Screen,
	player:  Player,
	bullets: [dynamic]Bullet,
	enemies: [dynamic]Enemy,
	spawner: Spawner,
	score:   int,
}


init_game :: proc() -> GameState {
	return GameState {
		screen = .PLAYING,
		player = create_player(),
		spawner = create_spawner(),
		score = 0,
	}
}
update_game :: proc(s: ^GameState) {

	if s.screen != .PLAYING {return}
	//score UI
	rl.DrawText(rl.TextFormat("Score: %d", s.score), 10, 10, 20, rl.WHITE)

	inputs := core.Get_Input()

	update_player(&s.player, inputs, &s.bullets)

	update_spawner(&s.spawner, &s.enemies)

	//bullet logic
	for i := len(s.bullets) - 1; i >= 0; i -= 1 {
		update_bullet(&s.bullets[i])
		if !s.bullets[i].active {
			unordered_remove(&s.bullets, i)
		}
	}


	//same logic for enemies i guess
	for i := len(s.enemies) - 1; i >= 0; i -= 1 {
		update_enemy(&s.enemies[i], &s.bullets, s.player.position)
		if !s.enemies[i].active {
			unordered_remove(&s.enemies, i)
		}
	}

	//collision logic
	// bullet and enemy
	for &b in s.bullets {
		if b.active {
			if b.is_player {
				for &e in s.enemies {
					if !e.active {continue}
					if rl.CheckCollisionCircles(b.pos, 8, e.pos, 32) {
						b.active = false
						e.active = false
						s.score += 1
						fmt.println("Total score:", s.score)
						break
					}
				}
			} else {
				if rl.CheckCollisionCircles(b.pos, 8, s.player.position, 32) {
					b.active = false
					s.player.active = false
					break
				}
			}
		}
	}
	//debug
	for &e in s.enemies {
		if !e.active {return}
		rl.DrawCircleLines(i32(e.pos.x + 32), i32(e.pos.y + 32), 32, rl.GREEN)
	}


	if inputs.restart {
		s^ = init_game()
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
