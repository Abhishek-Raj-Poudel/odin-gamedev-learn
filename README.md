# odin-gamedev-learn

## Architecture

Odin game using Raylib. Package-per-domain layout.

### Package Map

```
main.odin              -- entry point. window init, game loop, temp allocator free
core/                  -- shared infrastructure
  input.odin           -- keyboard polling -> Input_State {x, y, shoot}
game/                  -- entity logic (same package)
  player.odin          -- Player struct + create/update/draw
  enemy.odin           -- Enemy struct + create/update/draw
graphics/              -- rendering utilities
  texture.odin         -- texture cache (load once, reuse by path)
assets/
  texture/             -- PNG sprites
    player.png
```

### Loop (main.odin)

```
Get_Input -> update(player, input) -> update(enemy) -> BeginDrawing -> draw -> EndDrawing
```

### Conventions

| Thing       | Convention        | Example              |
|-------------|-------------------|----------------------|
| Packages    | lowercase dir     | `game`, `graphics`   |
| Types       | PascalCase        | `Player`, `Enemy`    |
| Constants   | UPPER_SNAKE       | `PLAYER_SPEED :: 400`|
| Procs       | snake_case with   | `player_create`      |
|             | entity prefix     | `enemy_update`       |
| Variables   | snake_case        | `screen_w`, `pos`    |

### Entity Pattern

Each entity has:
- Struct with `position [2]f32` and `texture rl.Texture2D`
- `create` returns instance (with optional pos arg for enemies)
- `update` applies movement, clamps to screen bounds
- `draw` renders via `graphics.draw_sprite` (or direct `DrawTextureV`)
- Delete via `alive bool` flag or `maybe(T)` type

### Texture Cache (`graphics/texture.odin`)

Package-level `map[string]rl.Texture`. `load_texture` checks cache before loading. Redundant LoadTexture calls avoided.
