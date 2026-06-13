package graphics

import "core:strings"
import rl "vendor:raylib"


textures: map[string]rl.Texture

load_texture :: proc(path: string) -> rl.Texture {
	if t, t_ok := textures[path]; t_ok {
		return t
	}

	t := rl.LoadTexture(strings.clone_to_cstring(path, context.temp_allocator))

	if t.id != 0 {
		textures[path] = t
	}

	return t
}

draw_sprite :: proc(tex: rl.Texture2D, pos: [2]f32) {
	rl.DrawTextureV(tex, pos, rl.WHITE)
}
