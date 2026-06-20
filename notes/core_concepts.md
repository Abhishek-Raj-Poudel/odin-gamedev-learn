# Core Concepts — Collision, Game Loop, UI

## Collision Detection

### Circle vs Circle

```odin
circle_vs_circle :: proc(pos1, pos2: [2]f32, r1, r2: f32) -> bool {
    return distance(pos1, pos2) < r1 + r2
}
```

Distance between centers less than sum of radii = overlap = hit.

### Rectangle vs Rectangle

raylib has `rl.CheckCollisionRecs(rec1, rec2) -> bool`.

Make `rl.Rectangle` from entity pos + texture size.

### Where in Loop

After all entities move. Before removal.

```odin
// in update_game, after update loops
for &bullet in s.bullets {
    if !bullet.active {continue}
    for &enemy in s.enemies {
        if !enemy.active {continue}
        if circle_vs_circle(bullet.pos, enemy.pos, 16, 16) {
            bullet.active = false
            enemy.active = false
            s.score += 1
        }
    }
}
```

Existing reverse loops automatically clean up next frame.

---

## Game Loop Pattern (current)

```
Get_Input → Update Entities → Remove Dead → Draw → free_all(temp)
```

| Step | What |
|------|------|
| Input | Poll keyboard, fill Input_State |
| Update | Player moves, enemies move, bullets move, timers tick |
| Remove | Reverse loop + unordered_remove for inactive |
| Draw | BeginDrawing → draw everything → EndDrawing |
| Clean | free_all(temp_allocator) |

`rl.GetFrameTime()` gives delta time in seconds. Multiply velocity by dt for frame-rate independent movement.

---

## State Machine (Phase 5)

```odin
Screen :: enum {
    MENU,
    PLAYING,
    GAME_OVER,
}
```

Add `screen: Screen` to GameState. Init as `.MENU`.

```odin
update_game :: proc(s: ^GameState) {
    switch s.screen {
    case .PLAYING:
        inputs := core.Get_Input()
        update_player(&s.player, inputs, &s.bullets)
        // ... update enemies, bullets, collision ...
    case .MENU:
        if rl.IsKeyPressed(.ENTER) { s.screen = .PLAYING }
    case .GAME_OVER:
        if rl.IsKeyPressed(.R) { s^ = init_game() }
    }
}

draw_game :: proc(s: ^GameState) {
    rl.BeginDrawing()
    rl.ClearBackground({...})
    switch s.screen {
    case .MENU:
        rl.DrawText("PRESS ENTER TO START", center_x, center_y, 30, rl.WHITE)
    case .PLAYING:
        draw_player(s.player)
        draw_bullets(s.bullets)
        draw_enemies(s.enemies)
    case .GAME_OVER:
        rl.DrawText("GAME OVER", center_x, center_y, 40, rl.RED)
        rl.DrawText("PRESS R TO RESTART", center_x, center_y + 50, 20, rl.WHITE)
    }
    rl.EndDrawing()
}
```

### Restart: reset everything

```odin
init_game :: proc() -> GameState {
    return GameState {
        player  = create_player(),
        screen  = .MENU,
    }
}
```

Assign `s^ = init_game()` — reinitialize entire state. Simple.

---

## UI (Score + Text)

raylib `DrawText`:

```odin
rl.DrawText("Hello", x: i32, y: i32, font_size: i32, color: rl.Color)
```

Dynamic text:

```odin
text := rl.TextFormat("Score: %d", s.score)
rl.DrawText(text, 10, 10, 20, rl.WHITE)
```

`rl.TextFormat` returns `cstring` from temp allocator. Freed by `free_all(context.temp_allocator)` at end of frame.

### Z-order (draw order)

```
Background → Entities → UI Text
```

Later layers drawn on top. Keep UI last.

---

## Summary

| Concept | Technique |
|---------|-----------|
| Collision | Circle distance check. Mark `active = false` both sides |
| State machine | `Screen` enum, switch on `s.screen` in update + draw |
| Restart | `s^ = init_game()` — full reset |
| Score text | `rl.DrawText(rl.TextFormat(...))` |
| No UI framework | `DrawText` is enough for score, menus, game over |
