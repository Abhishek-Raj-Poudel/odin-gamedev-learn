package core

import rl "vendor:raylib"

Input_State :: struct {
	move:    [2]f32,
	x:       f32,
	y:       f32,
	shoot:   bool,
	start:   bool,
	restart: bool,
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
	if rl.IsKeyPressed(.ENTER) {
		state.start = true
	}
	if rl.IsKeyPressed(.R) {
		state.restart = true
	}
	return state

}
