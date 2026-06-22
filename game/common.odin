package game

import rl "vendor:raylib"

OFFSCREEN_MARGIN :: 100

off_screen :: proc(pos: [2]f32) -> bool {
	sw := f32(rl.GetScreenWidth())
	sh := f32(rl.GetScreenHeight())
	return(
		pos.x < -OFFSCREEN_MARGIN ||
		pos.x > sw + OFFSCREEN_MARGIN ||
		pos.y < -OFFSCREEN_MARGIN ||
		pos.y > sh + OFFSCREEN_MARGIN
	)
}


update_pool :: proc(pool: ^[dynamic]$T, fn: proc(_: ^T)) {

	for i := len(pool) - 1; i >= 0; i -= 1 {
		fn(&pool[i])
		if !pool[i].active {
			unordered_remove(pool, i)
		}
	}

}
