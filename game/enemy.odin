package game

// import "core:math"
// import la "core:math/linalg"
import rl "vendor:raylib"

// import "../core"
import "../graphics"

ENEMY_SPEED :: 300

//TODO: Replace this texture later
ENEMY_TEXTURE :: "assets/texture/player.png"

Enemy :: struct {
	pos:          [2]f32,
	texture:      rl.Texture2D,
	vel:          [2]f32,
	active:       bool,
	bullet_speed: f32,
	fire_rate:    f32,
}

create_enemy :: proc(pos, vel: [2]f32, fire_rate: f32) -> Enemy {
	return Enemy {
		texture = graphics.load_texture(ENEMY_TEXTURE),
		pos = pos,
		vel = vel,
		active = true,
		fire_rate = fire_rate,
	}
}

update_enemy :: proc(e: ^Enemy) {

	if !e.active {return}
	// direction := [2]f32{0, 1}
	e.pos += e.vel * rl.GetFrameTime()
	// move := la.normalize0(direction) * ENEMY_SPEED * rl.GetFrameTime()
	if off_screen(e.pos) {
		e.active = false
	}
}

draw_enemy :: proc(e: Enemy) {
	if !e.active {return}
	rl.DrawTextureV(e.texture, e.pos, rl.WHITE)
}
