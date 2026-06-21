# Roadmap — Top-Down Shooter

## Current State

- [x] Player movement (arrow keys, clamped)
- [x] Player shoots (SPACE, fire rate 0.25s)
- [x] Enemy shoots toward player (direction math, fire timer)
- [x] Bullet off-screen removal
- [x] Enemy pool: `[dynamic]Enemy` in GameState
- [x] Enemy spawner (interval-based, random x)
- [x] Collision detection (player bullets vs enemy, enemy bullets vs player)
- [x] Player active flag (hit → player frozen)
- No score, no game states, no restart, no UI text, no enemy textures

---

## Phase 1 — Game State + Score Display

**Files:** `game/game.odin`, `game/state.odin` (new), `main.odin`

Goal: Menu → Playing → Game Over → Restart.

```odin
Screen :: enum { MENU, PLAYING, GAME_OVER }
```

- Add `screen: Screen` and `score: int` to GameState
- `update_game` switches on screen. Only update when PLAYING
- `draw_game` switches on screen. Show title, score, game over text
- ENTER to start, R to restart (re-init GameState)
- `rl.DrawText(rl.TextFormat("Score: %d", s.score), 10, 10, 20, rl.WHITE)`

Files: `game/state.odin`, `game/game.odin`, `main.odin`

---

## Phase 2 — Restart + Player Death

- On enemy bullet hit → `screen = .GAME_OVER`
- R key in GAME_OVER → `s^ = init_game()`
- Player doesn't draw/update when dead

---

## Phase 3 — Asset Management

**Files:** `graphics/texture.odin`, `game/game.odin`

Goal: Load all textures at startup, unload at exit.

- Remove lazy-load from `load_texture`
- `load_all_assets :: proc() -> AssetStore` — load every PNG once
- `AssetStore` struct with named fields: `player, bullet, enemy, ...`
- Store in GameState: `assets: AssetStore`
- Pass to create functions or access via `s.assets.player`

Benefit: no `load_texture` per-frame in draw, no duplicate texture field on every entity.

---

## Phase 4 — Enemy Textures + Variants

- Add enemy texture (replace player.png placeholder)
- `EnemyType :: enum { BASIC, FAST, TANK }`
- `create_enemy(type: EnemyType)` — switch on type for speed/hp/fire_rate/texture

---

## Phase 5 — Sound

- Load audio in `AssetStore`
- Play on shoot, enemy death, player hit

---

## Phase 6 — Polish

- Player death animation (flash, particles)
- Screen shake
- Background / parallax
- Difficulty scaling (spawn rate increases over time)

---

## File Reference (current + planned)

```
.
├── main.odin                 -- entry + game loop
├── core/
│   └── input.odin            -- Input_State + Get_Input()
├── game/
│   ├── game.odin             -- GameState, init/update/draw, collision
│   ├── state.odin            -- Screen enum (new)
│   ├── player.odin           -- Player struct + create/update/draw
│   ├── enemy.odin            -- Enemy struct + create/update/draw
│   ├── bullet.odin           -- Bullet struct + make/update/draw
│   ├── spawner.odin          -- Spawner, timer-based enemy creation
│   └── common.odin           -- off_screen, shared helpers
├── graphics/
│   ├── texture.odin          -- texture cache / AssetStore
│   ├── assets.odin           -- load_all_assets, AssetStore (new)
│   └── screen.odin           -- shake, fade effects (new)
├── audio/
│   ├── load.odin             -- load sounds (new)
│   └── play.odin             -- play sounds (new)
└── assets/
    └── texture/
        ├── player.png
        ├── bullet.png
        └── (enemy.png, enemy_fast.png, ...)
```
