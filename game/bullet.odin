package game

import rl "vendor:raylib"

import "../graphics"

BULLET_SPEED :: 600

OFFSCREEN_MARGIN :: 100
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

update_bullet :: proc(b: ^Bullet) {
	if !b.active {return}
	b.pos += b.vel * rl.GetFrameTime()
	if off_screen(b.pos) {
		b.active = false
	}

}

off_screen :: proc(pos: [2]f32) -> bool {

	sw := f32(rl.GetScreenWidth())
	sh := f32(rl.GetScreenHeight())

	return(
		pos.x < -OFFSCREEN_MARGIN ||
		pos.x > sw + OFFSCREEN_MARGIN ||
		pos.y < -OFFSCREEN_MARGIN ||
		pos.y > sh + OFFSCREEN_MARGIN \
	)

}

draw_bullet :: proc(b: Bullet) {
	if !b.active {return}
	rl.DrawTextureV(b.texture, b.pos, rl.WHITE)
}
