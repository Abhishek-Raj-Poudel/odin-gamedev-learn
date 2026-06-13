# Roadmap — Top-Down Shooter

## Current State

- Player moves with arrow keys, clamped to screen
- Enemy moves straight down
- Texture cache exists
- No bullets, no collision, no wave system yet

---

## Step 1 — Bullet System

**Files:** `game/bullet.odin`

Goal: Player presses SPACE → bullet spawns at player position → moves upward → remove when off-screen.

```
Bullet :: struct {
    position: [2]f32
    velocity: [2]f32
    active:   bool
}
```

- Use `[dynamic]Bullet` as pool in main.odin
- `spawn_bullet( pos: [2]f32, dir: [2]f32 )` append to pool
- `update_bullets( bullets: ^[dynamic]Bullet )` move + deactivate off-screen
- `draw_bullets( bullets: ^[dynamic]Bullet )` draw each active bullet
- Bind shoot to SPACE key in `Input_State.shoot`

Check: run game, press SPACE, see rectangle fly upward.

---

## Step 2 — Input Improvements

**Files:** `core/input.odin`

- Add `shoot` bool
- Add `start` (ENTER / SPACE for menus later)
- Add mouse position if needed later
- Clean unused fields (`move`)

---

## Step 3 — Enemy Faces Player

**Files:** `core/math.odin` (new), `game/enemy.odin`

Goal: Enemy moves toward player position every frame.

```
direction_to :: proc(from, to: [2]f32) -> [2]f32 {
    return math.linalg.normalize0(to - from)
}
```

- `update_enemy(e: ^Enemy, player_pos: [2]f32)` — set direction toward player
- Apply `direction * e.speed * dt`
- Add clamp to screen bounds

Check: enemy follows player around.

---

## Step 4 — Collision Detection

**Files:** `game/collision.odin` (new)

Goal: Bullet hits enemy → both disappear.

```
check_collision_circle :: proc(pos1, pos2: [2]f32, r1, r2: f32) -> bool {
    return math.linalg.distance(pos1, pos2) < r1 + r2
}
```

- In main loop: for each active bullet, check vs each active enemy
- On hit: bullet.active = false, enemy alive = false (or hp--)

Check: shoot enemy, it disappears.

---

## Step 5 — Enemy Variants

**Files:** `game/enemy.odin`

Goal: Different enemy types from same struct.

```odin
EnemyType :: enum {
    BASIC,
    FAST,
    TANK,
}

Enemy :: struct {
    position: [2]f32
    texture:  rl.Texture2D
    type:     EnemyType
    speed:    f32
    hp:       f32
}
```

- `create_enemy(type: EnemyType, pos: [2]f32)` — switch on type to set speed/hp/texture
- In `update_enemy`: switch on type for behavior (different movement patterns)

Check: spawn 3 types, see different speeds and health.

---

## Step 6 — Wave Spawner

**Files:** `game/wave.odin` (new)

Goal: Waves of enemies spawn automatically.

```odin
Wave_Entry :: struct {
    enemy_type: EnemyType
    count:      int
    delay:      f32    // seconds between spawns
}

Wave_Spawner :: struct {
    entries:       []Wave_Entry
    current_entry: int
    spawned:       int
    timer:         f32
    active:        bool
}
```

- `init_wave(entries: []Wave_Entry)` — setup spawner
- `update_wave(sw: ^Wave_Spawner) -> []Enemy` or callback — spawn enemies on timer
- When all entries done, wave complete
- After wave, brief pause, then next wave

Check: run game, enemies spawn in waves with pauses between.

---

## Step 7 — Game State

**Files:** `game/state.odin` (new) or in main

Goal: Manage screens (menu, playing, game over).

```odin
Game_State :: enum {
    MENU,
    PLAYING,
    GAME_OVER,
}
```

- Main loop switches on state
- MENU: show title, press ENTER to start
- PLAYING: run game logic
- GAME_OVER: show score, press ENTER to restart

---

## Step 8 — Polish

- Score display
- Player death animation
- Sound effects (raylib audio)
- Screen shake
- Background
- More enemy patterns (zigzag, orbit, charge)

---

## File Reference

### Full structure after all steps:

```
.
├── main.odin                 -- entry, game loop, state machine
├── core/
│   ├── input.odin            -- Input_State + Get_Input()
│   └── math.odin             -- direction_to, distance, helpers
├── game/
│   ├── player.odin           -- Player struct + create/update/draw
│   ├── enemy.odin            -- Enemy struct + EnemyType + create/update/draw
│   ├── bullet.odin           -- Bullet struct + pool + create/update/draw
│   ├── collision.odin        -- collision check functions
│   ├── wave.odin             -- Wave_Spawner + configs
│   └── state.odin            -- Game_State enum
├── graphics/
│   ├── texture.odin          -- texture cache + draw_sprite
│   └── camera.odin           -- screen effects (optional)
└── assets/
    └── texture/
        ├── player.png
        ├── bullet.png
        └── enemy_*.png        -- one per enemy type
```
