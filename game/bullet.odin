package game

import la "core:math/linalg"
import rl "vendor:raylib"

import "../graphics"

BULLET_SPEED :: 600
BULLET_TEXTURE :: "assets/texture/bullet.png"

Bullet :: struct {
	position:  [2]f32,
	direction: [2]f32,
	texture:   rl.Texture2D,
	speed:     f32,
}


spawn_bullet :: proc(pos: [2]f32) -> Bullet {
	return Bullet {
		texture = graphics.load_texture(BULLET_TEXTURE),
		position = pos,
		speed = BULLET_SPEED,
		direction = [2]f32{0, -1},
	}
}

update_bullet :: proc(b: [dynamic]Bullet) {
	for i in 0 ..< len(b) {
		move := la.normalize0(b[i].direction) * b[i].speed * rl.GetFrameTime()
		b[i].position += move
	}
}

draw_bullet :: proc(b: [dynamic]Bullet) {
	for i in 0 ..< len(b) {
		rl.DrawTextureV(b[i].texture, b[i].position, rl.WHITE)
	}
}
