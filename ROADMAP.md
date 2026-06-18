# Roadmap — Top-Down Shooter

## Current State

- [x] Player moves arrow keys, clamped to screen
- [x] Player shoots SPACE, fire rate 0.25s
- [x] Bullet off-screen removal
- [x] Enemy struct with `active`, `vel`, `fire_rate`
- [x] Enemy pool: `[dynamic]Enemy` in GameState
- [x] Enemy update/draw loops in game.odin
- [x] Enemy off-screen removal
- [x] Texture cache
- No enemy shooting, no collision, no game states, no spawner

---

## ~~Phase 0 — Bullet System~~ [DONE]

- `Bullet` struct with `pos`, `vel`, `active`
- `make_bullet(pos, vel)` factory
- Off-screen removal with `off_screen` check
- `unordered_remove` in reverse loop

---

## ~~Phase 0.5 — Enemy Pool~~ [DONE]

- Enemy struct: `pos`, `vel`, `active`, `fire_rate`, `texture`
- `create_enemy(pos, vel, fire_rate)` factory
- `[dynamic]Enemy` in GameState
- Update/draw loops with reverse-iterate + unordered_remove

---

## Phase 1 — Enemy Shoots at Player

**Files:** `game/enemy.odin`, `game/game.odin`

Goal: Enemy fires bullets toward player.

- Pass `player_pos` + enemy bullet pool to `update_enemy`
- Add `fire_timer` to Enemy, decrement each frame
- On timer <= 0: calculate direction `normalize(player_pos - e.pos)` , spawn bullet, reset timer
- Add `enemy_bullets: [dynamic]Bullet` to GameState
- Update + draw enemy bullets in game.odin

Check: enemy fires bullets that track toward player position.

---

## Phase 2 — Collision Detection

**Files:** `game/collision.odin` (new)

Goal: Detect bullet-entity hits.

```odin
circle_vs_circle :: proc(pos1, pos2: [2]f32, r1, r2: f32) -> bool
```

- Player bullets vs enemy
- Enemy bullets vs player

---

## Phase 3 — Player Bullet Kills Enemy + Score

**Files:** `game/game.odin`

Goal: Shooting enemy destroys it, score increases.

- On collision: `enemy.active = false`, `bullet.active = false`, `score += 1`
- Add `score: int` to GameState

---

## Phase 4 — Enemy Bullet Kills Player + Restart

**Files:** `game/game.odin`, `game/player.odin`

Goal: Getting hit = death. R to restart.

- Add `alive: bool` to Player
- On collision: `player.alive = false`
- R key resets GameState

---

## Phase 5 — Game State Machine

**Files:** `game/state.odin` (new), `game/game.odin`, `main.odin`

Goal: Menu → Playing → Game Over.

```odin
Screen :: enum { MENU, PLAYING, GAME_OVER }
```

- MENU: title, ENTER to start
- PLAYING: game runs
- GAME_OVER: final score, R to restart

---

## Phase 6 — Enemy Spawner

**Files:** `game/wave.odin` (new), `game/game.odin`

Goal: Continuous enemy spawning.

```odin
Spawner :: struct {
    timer:          f32,
    spawn_interval: f32,
}
```

- `init_spawner(interval) -> Spawner`
- `update_spawner(s: ^Spawner, enemies: ^[dynamic]Enemy)` — timer ticks, spawns enemy at random x above screen
- Add `spawner: Spawner` to GameState

---

## Phase 7 — Polish

- Score display on screen
- Sound effects (raylib audio)
- Player death animation
- Screen shake
- Background / parallax
- Enemy variants (fast, tank, zigzag)

---

## File Reference (planned)

```
.
├── main.odin                 -- entry, game loop
├── core/
│   ├── input.odin            -- Input_State + Get_Input()
│   └── math.odin             -- direction_to, distance helpers (new)
├── game/
│   ├── game.odin             -- GameState, init/update/draw orchestration
│   ├── player.odin           -- Player struct + create/update/draw
│   ├── enemy.odin            -- Enemy struct + create/update/draw
│   ├── bullet.odin           -- Bullet struct + make/update/draw + off-screen
│   ├── collision.odin        -- collision checks (new)
│   ├── wave.odin             -- spawner (new)
│   └── state.odin            -- Screen enum (new)
├── graphics/
│   └── texture.odin          -- texture cache
└── assets/
    └── texture/
        ├── player.png
        ├── bullet.png
        └── enemy.png
```
