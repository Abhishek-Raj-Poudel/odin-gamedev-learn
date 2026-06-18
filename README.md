# odin-gamedev-learn

Top-down shooter. Odin + raylib.

## Features

- [x] Player movement (arrow keys)
- [x] Player shoots (SPACE)
- [x] Bullet off-screen removal
- [x] Enemy pool with off-screen removal
- [ ] Enemy shoots toward player
- [ ] Collision detection
- [ ] Player bullet kills enemy
- [ ] Score tracking
- [ ] Enemy bullet kills player
- [ ] Game states (menu / playing / game over)
- [ ] R to restart on death
- [ ] Enemy spawner (waves)

## Controls

| Key | Action |
|-----|--------|
| Arrow keys | Move player |
| SPACE | Shoot |

## Architecture

### Package Map

```
main.odin              -- entry point. window init, game loop, temp allocator free
core/
  input.odin           -- keyboard polling -> Input_State {x, y, shoot}
game/                  -- entity logic (same package)
  game.odin            -- GameState struct, init/update/draw orchestration
  player.odin          -- Player struct + create/update/draw
  enemy.odin           -- Enemy struct + create/update/draw
  bullet.odin          -- Bullet struct + make/update/draw + off-screen removal
graphics/
  texture.odin         -- texture cache (load once, reuse by path)
assets/
  texture/
    player.png
    bullet.png
```

### Loop

```
Get_Input -> update_game -> BeginDrawing -> draw_game -> EndDrawing -> free_all(temp)
```

### Conventions

| Thing       | Convention        | Example              |
|-------------|-------------------|----------------------|
| Packages    | lowercase dir     | `game`, `graphics`   |
| Types       | PascalCase        | `Player`, `Enemy`    |
| Constants   | UPPER_SNAKE       | `PLAYER_SPEED :: 400`|
| Procs       | verb_entity       | `create_player`      |
|             |                   | `update_player`      |
|             |                   | `make_bullet`        |
| Variables   | snake_case        | `screen_w`, `pos`    |

### Entity Pattern

Each entity has:
- Struct with `pos [2]f32`, texture, state fields (`active`, `fire_timer`, etc.)
- `create_TYPE` factory
- `update_TYPE` per-frame logic
- `draw_TYPE` renders
- Removal: `active=false` + `unordered_remove` in reverse loop

### Texture Cache

Package-level `map[string]rl.Texture`. `load_texture` checks cache before loading.
