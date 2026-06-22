package game

import rl "vendor:raylib"

import "../graphics"


BULLET_TEXTURE :: "assets/texture/bullet.png"

Bullet :: struct {
	pos:     [2]f32,
	texture: rl.Texture2D,
	vel:     [2]f32,
	active:  bool,
}


make_bullet :: proc(pos, vel: [2]f32) -> Bullet {
	return Bullet {
		texture = graphics.load_texture(BULLET_TEXTURE),
		pos = pos,
		vel = vel,
		active = true,
	}
}


update_bullet :: proc(bullets: ^[dynamic]Bullet) {
	for i := len(bullets) - 1; i >= 0; i -= 1 {
		if !bullets[i].active {continue}
		bullets[i].pos += bullets[i].vel * rl.GetFrameTime()

		if off_screen(bullets[i].pos) {
			bullets[i].active = false
		}
		if !bullets[i].active {
			unordered_remove(bullets, i)
		}
	}

}


bullet_collision :: proc(s: ^GameState) {
	// user bullets -> enemy
	for &b in s.bullets {
		if !b.active {continue}
		for &e in s.enemies {
			if !e.active {continue}
			if rl.CheckCollisionCircles(b.pos, 8, e.pos, 32) {
				b.active = false
				e.active = false
				s.score += 1
				break
			}
		}
	}

	// enemy bullet -> user
	for &b in s.enemy_bullets {

		if !b.active {continue}
		if rl.CheckCollisionCircles(b.pos, 8, s.player.position, 32) {
			b.active = false
			s.player.active = false
			break
		}
	}
}


draw_bullet :: proc(bullets: ^[dynamic]Bullet) {

	for bullet in bullets {
		if !bullet.active {continue}
		rl.DrawTextureV(bullet.texture, bullet.pos, rl.WHITE)
	}
}
