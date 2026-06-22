# Learn — UI, Asset Management, Animation

## Part 1: Game State Machine (Menu → Playing → Game Over)

### Concept

Game loop switches behavior based on `Screen` enum. Three screens: title menu, actual gameplay, death screen.

Current code already has `Screen` enum and `screen` field in GameState. Uses `.PLAYING` on init. Need to wire the other two.

### Screen flow

```
MENU → (ENTER) → PLAYING → (player dies) → GAME_OVER → (R) → PLAYING (restart)
```

### Step 1 — Change init to start at MENU

In `init_game`, change `screen = .PLAYING` to `screen = .MENU`.

Game starts at menu. Player can see title before playing.

### Step 2 — Add `start` to Input_State (core/input.odin)

```odin
Input_State :: struct {
    move:    [2]f32,
    x:       f32,
    y:       f32,
    shoot:   bool,
    start:   bool,
    restart: bool,
}

Get_Input :: proc() -> Input_State {
    ...
    if rl.IsKeyPressed(.ENTER) {
        state.start = true
    }
    ...
}
```

`shoot` uses `IsKeyDown` (hold to fire). `start` uses `IsKeyPressed` (press once). Different functions, different use cases.

### Step 3 — Update `update_game` to handle all screens

```odin
update_game :: proc(s: ^GameState) {
    inputs := core.Get_Input()

    switch s.screen {
    case .MENU:
        if inputs.start {
            s^ = init_game()
            s.screen = .PLAYING
        }

    case .PLAYING:
        update_player(&s.player, inputs, &s.bullets)
        update_spawner(&s.spawner, &s.enemies)
        update_pool(&s.bullets, update_bullet)
        update_pool(&s.enemy_bullets, update_bullet)
        bullet_collision(s)
        for i := len(s.enemies) - 1; i >= 0; i -= 1 {
            update_enemy(&s.enemies[i], &s.enemy_bullets, s.player.position)
            if !s.enemies[i].active {
                unordered_remove(&s.enemies, i)
            }
        }
        if !s.player.active {
            s.screen = .GAME_OVER
        }

    case .GAME_OVER:
        if inputs.restart {
            s^ = init_game()
            s.screen = .PLAYING
        }
    }
}
```

Key changes:
- Remove `if s.screen != .PLAYING {return}` guard
- Wrap everything in `switch s.screen`
- MENU: ENTER to start — reinit state, set to PLAYING
- PLAYING: at end, check if player died → switch to GAME_OVER
- GAME_OVER: R to restart

### Step 4 — Update `draw_game` to show different screens

```odin
draw_game :: proc(s: ^GameState) {
    rl.BeginDrawing()
    rl.ClearBackground({160, 200, 255, 255})

    switch s.screen {
    case .MENU:
        rl.DrawText("TOP-DOWN SHOOTER", 100, 400, 40, rl.WHITE)
        rl.DrawText("Press ENTER to start", 150, 500, 20, rl.WHITE)

    case .PLAYING:
        draw_player(s.player)
        draw_bullet(&s.bullets)
        draw_bullet(&s.enemy_bullets)
        for enemy in s.enemies {
            draw_enemy(enemy)
        }
        rl.DrawText(
            rl.TextFormat("Score: %d", s.score),
            10, 10, 20, rl.WHITE,
        )

    case .GAME_OVER:
        rl.DrawText("GAME OVER", 180, 400, 40, rl.RED)
        rl.DrawText(
            rl.TextFormat("Final Score: %d", s.score),
            170, 470, 25, rl.WHITE,
        )
        rl.DrawText("Press R to restart", 210, 530, 20, rl.WHITE)
    }

    rl.EndDrawing()
}
```

### Why this works

Each screen draws different content. MENU shows title. PLAYING shows game + score. GAME_OVER shows final score.

`switch` ensures only one screen's draw code runs per frame. No overlap.

### Why `s^ = init_game()` in MENU

`init_game()` returns a fresh GameState with all pools empty. `s^ =` assigns that fresh state to wherever `s` points (the state in main.odin). Old pools get garbage collected.

Then immediately override `screen = .PLAYING` so game starts playing right after init.

---

## Part 2: Asset Store

### Problem

Each entity calls `graphics.load_texture(path)` in its `create` function. Texture loaded lazily into a map. Unload happens implicitly when program exits. No control.

### Solution

Single `AssetStore` struct. Load all PNGs at startup. Pass store to create functions. Unload explicitly at exit.

### Step 1 — Create `graphics/asset.odin`

```odin
package graphics

import rl "vendor:raylib"
import "core:strings"

AssetStore :: struct {
    player:    rl.Texture2D,
    bullet:    rl.Texture2D,
    enemy:     rl.Texture2D,
    explosion: rl.Texture2D,
}

load_all :: proc() -> AssetStore {
    return AssetStore {
        player    = rl.LoadTexture("assets/texture/player.png"),
        bullet    = rl.LoadTexture("assets/texture/bullet.png"),
        enemy     = rl.LoadTexture("assets/texture/enemy.png"),
        explosion = rl.LoadTexture("assets/texture/explosion.png"),
    }
}

unload_all :: proc(a: AssetStore) {
    rl.UnloadTexture(a.player)
    rl.UnloadTexture(a.bullet)
    rl.UnloadTexture(a.enemy)
    rl.UnloadTexture(a.explosion)
}
```

### Why separate from texture.odin

`texture.odin` holds the lazy cache (map). `asset.odin` holds the eager load (struct). They have different lifecycle patterns. Keep separate.

But you could also just extend `texture.odin` with an `AssetStore` struct. Either works.

### Step 2 — Add to GameState + init

```odin
import "../graphics"

GameState :: struct {
    ...
    assets: graphics.AssetStore,
}

init_game :: proc() -> GameState {
    return GameState {
        screen  = .MENU,
        player  = create_player(),
        spawner = create_spawner(),
        assets  = graphics.load_all(),
    }
}
```

### Step 3 — Entity create functions take assets

```odin
create_player :: proc(assets: graphics.AssetStore) -> Player {
    return Player {
        texture  = assets.player,
        position = {f32(rl.GetScreenWidth()) / 2, f32(rl.GetScreenHeight() / 2)},
        fire_rate    = .25,
        bullet_speed = 600,
        active  = true,
    }
}
```

Same for `create_enemy`, `make_bullet` — replace `graphics.load_texture(PATH)` with `assets.PATH_FIELD`.

### Step 4 — Unload in main.odin

```odin
main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "...")
    state := game.init_game()
    for !rl.WindowShouldClose() {
        game.update_game(&state)
        game.draw_game(&state)
        free_all(context.temp_allocator)
    }
    game.shutdown_game(state)   // new proc
    rl.CloseWindow()
}
```

```odin
// game/game.odin
shutdown_game :: proc(s: GameState) {
    graphics.unload_all(s.assets)
}
```

### Why struct over map

- Named fields — no string lookups at runtime
- Compile error if typo field name
- Deterministic unload — one call per texture
- No lazy loading in draw loop

---

## Part 3: Explosion Animation

### Concept

When enemy dies, spawn an animation that plays through spritesheet frames, then self-destructs.

### Spritesheet

A single PNG with grid of frames. Example: `explosion.png` (256x256) with 4x4 grid = 16 frames of 64x64 each.

```
Frame 0  | Frame 1  | Frame 2  | Frame 3
Frame 4  | Frame 5  | Frame 6  | Frame 7
...       | ...      | ...      | ...
```

Each frame drawn as a rectangle crop of the spritesheet at current position.

### Step 1 — Animation struct

`game/animation.odin`:

```odin
package game

import rl "vendor:raylib"
import "../graphics"

EXPLOSION_FRAMES  :: 16
EXPLOSION_COLS    :: 4
EXPLOSION_FRAME_W :: 64
EXPLOSION_FRAME_H :: 64
EXPLOSION_FRAME_TIME :: 0.05

Animation :: struct {
    spritesheet:  rl.Texture2D,
    frame_w:      i32,
    frame_h:      i32,
    total_frames: i32,
    cols:         i32,
    current:      i32,
    timer:        f32,
    frame_time:   f32,
    pos:          [2]f32,
    active:       bool,
}

create_explosion :: proc(pos: [2]f32, sheet: rl.Texture2D) -> Animation {
    return Animation {
        spritesheet  = sheet,
        frame_w      = EXPLOSION_FRAME_W,
        frame_h      = EXPLOSION_FRAME_H,
        total_frames = EXPLOSION_FRAMES,
        cols         = EXPLOSION_COLS,
        frame_time   = EXPLOSION_FRAME_TIME,
        pos          = pos,
        active       = true,
    }
}

update_animation :: proc(a: ^Animation) {
    if !a.active {return}
    a.timer -= rl.GetFrameTime()
    if a.timer <= 0 {
        a.current += 1
        a.timer = a.frame_time
        if a.current >= a.total_frames {
            a.active = false
        }
    }
}

draw_animation :: proc(a: Animation) {
    if !a.active {return}
    src := rl.Rectangle {
        x      = f32(a.current % a.cols * a.frame_w),
        y      = f32(a.current / a.cols * a.frame_h),
        width  = f32(a.frame_w),
        height = f32(a.frame_h),
    }
    dst := rl.Rectangle {
        x      = a.pos.x,
        y      = a.pos.y,
        width  = f32(a.frame_w),
        height = f32(a.frame_h),
    }
    rl.DrawTexturePro(a.spritesheet, src, dst, {0, 0}, 0, rl.WHITE)
}
```

### Step 2 — Add animation pool to GameState

```odin
GameState :: struct {
    ...
    animations: [dynamic]Animation,
}
```

### Step 3 — Spawn animation on enemy death

In `bullet_collision`, when enemy dies:

```odin
if rl.CheckCollisionCircles(b.pos, 8, e.pos, 32) {
    b.active = false
    e.active = false
    s.score += 1
    append(&s.animations, create_explosion(e.pos, s.assets.explosion))
    break
}
```

### Step 4 — Update and draw animations

In `update_game`:

```odin
update_pool(&s.animations, update_animation)
```

In `draw_game`:

```odin
draw_pool(s.animations, draw_animation)
```

This requires `update_pool` and `draw_pool` in `common.odin`:

```odin
update_pool :: proc(pool: ^[dynamic]$T, fn: proc(_: ^T)) {
    for i := len(pool) - 1; i >= 0; i -= 1 {
        fn(&pool[i])
        if !pool[i].active {
            unordered_remove(pool, i)
        }
    }
}

draw_pool :: proc(pool: $T/[]$E, fn: proc(E)) {
    for e in pool {
        if !e.active {continue}
        fn(e)
    }
}
```

### How animation lifecycle works

```
Frame 1: enemy hit → append animation at e.pos
Frame 2: update_pool → animation.current = 1, timer resets
Frame 3: update_pool → animation.current = 2, timer resets
...
Frame 17: update_pool → animation.current = 16 → active = false → unordered_remove
```

Same pool pattern as bullets. Same `update_pool` function. Zero new infrastructure.

---

## Summary

| Feature | Key insight | Files changed |
|---------|------------|---------------|
| Menu screen | `switch` on `s.screen` in update + draw | `input.odin`, `game.odin` |
| Score display | `DrawText(TextFormat(...))` after entities | `game.odin` |
| Game over | Player dies → `s.screen = .GAME_OVER` | `game.odin` |
| Restart | R key → `s^ = init_game()` | `game.odin` |
| Asset store | Single struct, load at init, unload at exit | `graphics/asset.odin`, `game.odin` |
| Explosion | Animation struct, spritesheet, pool lifecycle | `game/animation.odin`, `game.odin` |
