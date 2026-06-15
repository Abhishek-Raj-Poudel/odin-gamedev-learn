# odin-gamedev-learn

## Architecture

Odin game using Raylib. Package-per-domain layout.

### Package Map

```
main.odin              -- entry point. window init, game loop, bullet pool, temp allocator free
core/                  -- shared infrastructure
  input.odin           -- keyboard polling -> Input_State {x, y, shoot}
game/                  -- entity logic (same package)
  player.odin          -- Player struct + create/update/draw, fire_rate/fire_timer
  enemy.odin           -- Enemy struct + create/update/draw, moves straight down
  bullet.odin          -- Bullet struct + spawn/update/draw, direction-based movement
graphics/              -- rendering utilities
  texture.odin         -- texture cache (load once, reuse by path)
assets/
  texture/             -- PNG sprites
    player.png
```

### Loop (main.odin)

```
Get_Input -> update(player, input, &bullets) -> update(enemy) -> update(bullets) -> BeginDrawing -> draw(player, enemy, bullets) -> EndDrawing -> free_all(temp)
```

### Conventions

| Thing       | Convention        | Example              |
|-------------|-------------------|----------------------|
| Packages    | lowercase dir     | `game`, `graphics`   |
| Types       | PascalCase        | `Player`, `Enemy`    |
| Constants   | UPPER_SNAKE       | `PLAYER_SPEED :: 400`|
| Procs       | verb_entity       | `create_player`      |
|             |                   | `update_player`      |
|             |                   | `spawn_bullet`       |
| Variables   | snake_case        | `screen_w`, `pos`    |

### Entity Pattern

Each entity has:
- Struct with `position [2]f32` and `texture rl.Texture2D`
- `create_TYPE` returns instance (with optional pos arg for enemies)
- `update_TYPE` applies movement, clamps to screen bounds
- `draw_TYPE` renders via `graphics.draw_sprite` (or direct `DrawTextureV`)
- Delete via `alive bool` flag or `maybe(T)` type

### Bullet System

- `Bullet` struct: `position`, `direction`, `texture`, `speed`
- Pool: `[dynamic]Bullet` allocated in `main.odin` via `make`
- `spawn_bullet(pos)` appends to pool, direction `{0, -1}` (upward)
- Fire rate controlled by `fire_rate` / `fire_timer` on `Player` struct
- Shooting bound to SPACE key (`rl.IsKeyDown`)

### Texture Cache (`graphics/texture.odin`)

Package-level `map[string]rl.Texture`. `load_texture` checks cache before loading. Redundant LoadTexture calls avoided.
