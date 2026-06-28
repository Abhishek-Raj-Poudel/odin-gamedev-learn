package game

import "../graphics"
import la "core:math/linalg"
import rl "vendor:raylib"

//ENEMY_SPEED :: 300

//TODO: Replace this texture later
ENEMY_TEXTURE :: "assets/texture/enemy.png"

Enemy :: struct {
	pos:           [2]f32,
	texture:       rl.Texture2D,
	vel:           [2]f32,
	active:        bool,
	bullet_speed:  f32,
	fire_rate:     f32,
	fire_interval: f32,
}

create_enemy :: proc(pos, vel: [2]f32, fire_rate, bullet_speed: f32) -> Enemy {
	return Enemy {
		texture = graphics.load_texture(ENEMY_TEXTURE),
		pos = pos,
		vel = vel,
		active = true,
		fire_rate = fire_rate,
		bullet_speed = bullet_speed,
	}
}

update_enemy :: proc(e: ^Enemy, bullets: ^[dynamic]Bullet, player_pos: [2]f32) {
	if !e.active {return}
	// shoot at user
	e.fire_interval -= rl.GetFrameTime()

	if e.fire_interval <= 0 {
		dir := la.normalize0(player_pos - e.pos)
		append(bullets, make_bullet(e.pos, dir * e.bullet_speed))
		e.fire_interval = e.fire_rate
	}


	e.pos += e.vel * rl.GetFrameTime()


	if off_screen(e.pos) {
		e.active = false
	}
}

draw_enemy :: proc(e: Enemy) {
	if !e.active {return}
	rl.DrawTextureV(e.texture, e.pos, rl.WHITE)
}
