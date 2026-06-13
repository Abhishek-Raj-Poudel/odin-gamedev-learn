package game

// import "core:math"
import la "core:math/linalg"
import rl "vendor:raylib"

// import "../core"
import "../graphics"

ENEMY_SPEED :: 300

//TODO: Replace this texture later
ENEMY_TEXTURE :: "assets/texture/player.png"

Enemy :: struct {
	position: [2]f32,
	texture:  rl.Texture2D,
	speed:    f32,
}

create_enemy :: proc() -> Enemy {
	return Enemy {
		texture = graphics.load_texture(ENEMY_TEXTURE),
		position = [2]f32{500, 0},
		speed = ENEMY_SPEED,
	}
}

update_enemy :: proc(e: ^Enemy) {
	direction := [2]f32{0, 1}
	move := la.normalize0(direction) * ENEMY_SPEED * rl.GetFrameTime()
	e.position += move
}

draw_enemy :: proc(e: Enemy) {
	rl.DrawTextureV(e.texture, e.position, rl.WHITE)
}
