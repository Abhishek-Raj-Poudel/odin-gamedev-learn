# UI Implementation Guide

## Goal

Three screens:

- MENU → "Press ENTER to start"
- PLAYING → game + score display
- GAME_OVER → frozen game + "Press R to restart"

## Concept

`game/game.odin` already has `Screen` enum (MENU, PLAYING, GAME_OVER). Gate update and draw by current screen. No new files needed.

---

## Step 1 — Start at MENU

In `init_game`, change screen from `.PLAYING` to `.MENU`.

```odin
return GameState {
    screen = .MENU,  // was .PLAYING
    ...
}
```

Game state is initialized but hidden. No game objects drawn on MENU.

---

## Step 2 — Handle all screens in update

Replace current `update_game` body with a switch on screen.

Current code (changes marked):

```odin
update_game :: proc(s: ^GameState) {
    if s.screen != .PLAYING {return}     // ← DELETE this line

    inputs := core.Get_Input()           // ← MOVE above switch

    update_player(...)
    ...

    if inputs.restart {                  // ← DELETE from here
        s^ = init_game()
    }                                    // ← DELETE to here
}
```

Replace with:

```odin
update_game :: proc(s: ^GameState) {
    inputs := core.Get_Input()

    switch s.screen {
    case .MENU:
        if inputs.start {
            s.screen = .PLAYING
        }

    case .PLAYING:
        update_player(&s.player, inputs, &s.bullets)
        update_spawner(&s.spawner, &s.enemies)
        update_bullet(&s.bullets)
        update_bullet(&s.enemy_bullets)
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
        }
    }
}
```

Three changes from current code:
1. Delete `if s.screen != .PLAYING {return}`
2. Move `inputs` declaration before the switch
3. Remove `if inputs.restart` from PLAYING body — put in GAME_OVER case

---

## Step 3 — Draw UI per screen

Same pattern — wrap existing draw in a switch.

```odin
draw_game :: proc(s: ^GameState) {
    rl.BeginDrawing()
    rl.ClearBackground({160, 200, 255, 255})

    switch s.screen {
    case .MENU:
        // title text, "Press ENTER to start"

    case .PLAYING:
        draw_player(s.player)
        draw_bullet(&s.bullets)
        draw_bullet(&s.enemy_bullets)
        for enemy in s.enemies {
            draw_enemy(enemy)
        }
        // score text top-left

    case .GAME_OVER:
        draw_player(s.player)
        draw_bullet(&s.bullets)
        draw_bullet(&s.enemy_bullets)
        for enemy in s.enemies {
            draw_enemy(enemy)
        }
        // overlay rect
        // "GAME OVER" centered
        // "Score: N" centered
        // "Press R to restart" centered
    }

    rl.EndDrawing()
}
```

### Centered text pattern

```odin
text := "Press ENTER to start"
size := 20
w := rl.MeasureText(text, size)
rl.DrawText(text, (f32(rl.GetScreenWidth()) - w) / 2, 500, size, rl.WHITE)
```

### Overlay pattern

```odin
rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), {0, 0, 0, 150})
```

---

## Result after changes

| Screen    | Update      | Draw                         |
|-----------|-------------|------------------------------|
| MENU      | Wait Enter  | Title screen text            |
| PLAYING   | Game logic  | Game + score                 |
| GAME_OVER | Wait R      | Frozen game + overlay + text |

Only file modified: `game/game.odin`.

---

## Endless Scrolling Background

### Idea

2 copies of same texture. Stack vertically. Both scroll down. When one fully off-screen, wrap behind the other. Creates infinite scroll.

### Struct

```odin
Background :: struct {
    tex:   rl.Texture2D,
    pos1:  [2]f32,
    pos2:  [2]f32,
    speed: f32,
}
```

`pos1` = first tile. `pos2` = second tile stacked above it.

### Init

```odin
create_bg :: proc(path: string, speed: f32) -> Background {
    tex := load_texture(path)
    sh := f32(rl.GetScreenHeight())
    return Background {
        tex   = tex,
        pos1  = {0, 0},
        pos2  = {0, -sh},
        speed = speed,
    }
}
```

`pos2` starts at `-screen_height` — directly above `pos1`.

### Update

```odin
update_bg :: proc(bg: ^Background) {
    bg.pos1.y += bg.speed * rl.GetFrameTime()
    bg.pos2.y += bg.speed * rl.GetFrameTime()

    sh := f32(rl.GetScreenHeight())
    if bg.pos1.y >= sh { bg.pos1.y = bg.pos2.y - sh }
    if bg.pos2.y >= sh { bg.pos2.y = bg.pos1.y - sh }
}
```

Each frame add delta. When past bottom, jump to just behind the other.

### Draw

```odin
draw_bg :: proc(bg: Background) {
    rl.DrawTextureV(bg.tex, bg.pos1, rl.WHITE)
    rl.DrawTextureV(bg.tex, bg.pos2, rl.WHITE)
}
```

Draw both. One always on-screen. No gap.

### Where to draw

Draw before game objects. Deepest layer.

```odin
case .PLAYING:
    draw_bg(bg)                      // ← first
    draw_player(s.player)            // ← then game objects
    draw_bullet(&s.bullets)
    ...
```

### Texture note

Load via existing `graphics.load_texture`. Cache works. Same call, no extra work.
