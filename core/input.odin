package core

import rl "vendor:raylib"

Input_State :: struct {
	move:  [2]f32,
	x:     f32,
	y:     f32,
	shoot: bool,
}

Get_Input :: proc() -> Input_State {

	state: Input_State

	if rl.IsKeyDown(.UP) {
		state.y -= 1
	}

	if rl.IsKeyDown(.DOWN) {
		state.y += 1
	}

	if rl.IsKeyDown(.LEFT) {
		state.x -= 1
	}

	if rl.IsKeyDown(.RIGHT) {
		state.x += 1
	}

	if rl.IsKeyDown(.SPACE) {
		state.shoot = true
	}

	return state

}
