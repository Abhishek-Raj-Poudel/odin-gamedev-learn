package game

import rl "vendor:raylib"

import "../core"

import "core:fmt"

// Main goal is that the game run's here
GameState :: struct {
	player:  Player,
	bullets: [dynamic]Bullet,
	enemies: [dynamic]Enemy,
	spawner: Spawner,
	score:   int,
}

init_game :: proc() -> GameState {
	return GameState{player = create_player(), spawner = create_spawner(), score = 0}
}
update_game :: proc(s: ^GameState) {

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
					if rl.CheckCollisionCircles(b.pos, 8, e.pos, 16) {
						b.active = false
						e.active = false
						s.score += 1
						fmt.println("Total score:", s.score)
						break
					}
				}
			} else {
				if rl.CheckCollisionCircles(b.pos, 8, s.player.position, 16) {
					b.active = false
					s.player.active = false
					break
				}
			}
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
