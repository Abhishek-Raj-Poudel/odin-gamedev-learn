# odin-gamedev-learn

Top-down shooter. Odin + raylib.

## Features

- [x] Player movement (arrow keys)
- [x] Player shoots (SPACE)
- [x] Enemy shoots toward player (fire timer + direction math)
- [x] Bullet off-screen removal
- [x] Enemy pool with off-screen removal
- [x] Enemy spawner (interval-based, random x)
- [x] Collision detection (raylib circles)
- [x] Player bullet kills enemy
- [x] Enemy bullet kills player
- [x] Score tracking
- [ ] Game states (menu / playing / game over)
- [ ] R to restart on death
- [ ] Asset management (load all at startup)
- [ ] Enemy textures
- [ ] Sound effects
- [ ] Screen shake / background

## Controls

| Key | Action |
|-----|--------|
| Arrow keys | Move player |
| SPACE | Shoot |

## Architecture

### Package Map

```
main.odin              -- entry. window init, game loop, temp allocator free
core/
  input.odin           -- Input_State + Get_Input()
game/                  -- all entity logic, same package
  game.odin            -- GameState, init/update/draw, collision loops
  player.odin          -- Player struct + create/update/draw
  enemy.odin           -- Enemy struct + create/update/draw + shoot-at-player
  bullet.odin          -- Bullet struct + make/update/draw + off-screen
  spawner.odin         -- Spawner struct, timer-based enemy creation
  common.odin          -- shared helpers (off_screen, OFFSCREEN_MARGIN)
graphics/
  texture.odin         -- texture cache (load once, reuse by path)
assets/
  texture/
    player.png
    bullet.png
```

### Entity Pattern

| File | Struct | Pool | Factory | Update | Draw |
|------|--------|------|---------|--------|------|
| player.odin | Player | singleton | create_player | update_player | draw_player |
| enemy.odin | Enemy | `[dynamic]Enemy` | create_enemy | update_enemy | draw_enemy |
| bullet.odin | Bullet | `[dynamic]Bullet` | make_bullet | update_bullet | draw_bullet |

### Bullet Pools

Single `[dynamic]Bullet` pool. `is_player: bool` flag separates player bullets from enemy bullets.

Collision branches on `is_player`:
- `is_player == true` → check vs enemies
- `is_player == false` → check vs player

Alternative: two separate pools `player_bullets` / `enemy_bullets` for cleaner collision loops.

### Game Loop

```
Get_Input → update_player → update_spawner → update_bullets + remove dead →
update_enemies + remove dead → collision (bullets vs enemies, bullets vs player) →
BeginDrawing → draw_player → draw_bullets → draw_enemies → EndDrawing →
free_all(temp_allocator)
```

### Conventions

| Thing | Convention | Example |
|-------|-----------|---------|
| Packages | lowercase dir | `game`, `graphics` |
| Types | PascalCase | `Player`, `Enemy`, `Spawner` |
| Constants | UPPER_SNAKE | `PLAYER_SPEED :: 400` |
| Procs | verb_entity | `create_player`, `update_enemy`, `make_bullet` |
| Variables | snake_case | `screen_w`, `pos`, `fire_rate` |

---

## Cleanup Suggestions

### Immediate (won't compile without)

- `game/common.odin:14` — trailing `\` after `sh + OFFSCREEN_MARGIN`. Delete it.

### Recommended

1. **Two bullet pools instead of `is_player`** — collision loops become straight (no `if` branch). `player_bullets: [dynamic]Bullet`, `enemy_bullets: [dynamic]Bullet`. Remove `is_player` from Bullet struct.
2. **Enemy active guard first** — `update_enemy` shoots before checking `active`. Move `if !e.active {return}` to top.
3. **Player active guard** — `update_player` and `draw_player` need `if !p.active {return}`.
4. **Init fire_interval** — set `fire_interval = fire_rate` in `create_enemy` and `create_player` to prevent instant first shot.
5. **Remove dead code** — commented imports, debug println, unused `move` field in Input_State.

### Architecture notes

- Keep `package game` flat (no sub-packages). Small enough.
- Constants in the file they belong to. OK as-is.
- Texture cache in `graphics/` is fine. Will need unload at game exit.
- Score field not yet in GameState. Add `score: int`.
