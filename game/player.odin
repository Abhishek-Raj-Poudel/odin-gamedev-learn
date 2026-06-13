package game

import "core:math"
import la "core:math/linalg"
import rl "vendor:raylib"

import "../core"
import "../graphics"


PLAYER_SPEED :: 400
PLAYER_TEXTURE :: "assets/texture/player.png"

Player :: struct {
	position: [2]f32,
	texture:  rl.Texture2D,
	speed:    f32,
}


create_player :: proc() -> Player {
	return Player {
		texture = graphics.load_texture(PLAYER_TEXTURE),
		position = [2]f32{f32(rl.GetScreenWidth()) / 2, f32(rl.GetScreenHeight() / 2)},
		speed = PLAYER_SPEED,
	}
}

update_player :: proc(p: ^Player, input: core.Input_State) {

	direction := [2]f32{input.x, input.y}

	if direction.x != 0 || direction.y != 0 {
		move := la.normalize0(direction) * p.speed * rl.GetFrameTime()
		p.position += move
	}

	// because player_position is in f32
	min_x := f32(0 - p.texture.width / 2)
	max_x := f32(rl.GetScreenWidth() - p.texture.width / 2)
	min_y := f32(0 - p.texture.height / 2)
	max_y := f32(rl.GetScreenHeight() - p.texture.height / 2)

	p.position.x = math.clamp(p.position.x, min_x, max_x)
	p.position.y = math.clamp(p.position.y, min_y, max_y)
}

draw_player :: proc(p: Player) {
	rl.DrawTextureV(p.texture, p.position, rl.WHITE)

}
