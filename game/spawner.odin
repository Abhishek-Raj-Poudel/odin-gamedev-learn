package game

import rl "vendor:raylib"

import "core:math/rand"

ENEMY_SPEED :: 100
ENEMY_BULLET_SPEED :: 400

ENEMY_BULLET_SPAWN_RATE :: 2

Spawner :: struct {
	spawn_rate:     f32,
	spawn_interval: f32,
}

create_spawner :: proc() -> Spawner {
	return Spawner{spawn_rate = 4}
}

update_spawner :: proc(s: ^Spawner, enemies: ^[dynamic]Enemy) {
	s.spawn_interval -= rl.GetFrameTime()

	if s.spawn_interval <= 0 {
		x := rand.float32_range(0, f32(rl.GetScreenWidth()))
		append(
			enemies,
			create_enemy(
				[2]f32{x, 0},
				[2]f32{0, ENEMY_SPEED},
				ENEMY_BULLET_SPAWN_RATE,
				ENEMY_BULLET_SPEED,
			),
		)
		s.spawn_interval = s.spawn_rate
	}
}
