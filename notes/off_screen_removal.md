# Off-Screen Entity Removal

## Problem

Bullets (and later enemies) leave visible area. Their position still updates every frame. Pool grows forever. Memory leak + wasted CPU.

## Solution: `off_screen` check + `unordered_remove`

Two parts: **detect** off-screen, **remove** from dynamic array.

---

## Detect

```odin
OFFSCREEN_MARGIN :: 100

off_screen :: proc(pos: [2]f32) -> bool {
    sw := f32(rl.GetScreenWidth())
    sh := f32(rl.GetScreenHeight())
    return pos.x < -OFFSCREEN_MARGIN ||
           pos.x > sw + OFFSCREEN_MARGIN ||
           pos.y < -OFFSCREEN_MARGIN ||
           pos.y > sh + OFFSCREEN_MARGIN
}
```

Margin prevents pop-at-edge. Entity disappears fully before removal.

No raylib equivalent. `GetScreenWidth/Height` + manual check.

---

## Remove

```odin
import "core:slice"

update_bullet :: proc(b: ^[dynamic]Bullet) {
    i := 0
    for i < len(b) {
        move := la.normalize0(b[i].direction) * b[i].speed * rl.GetFrameTime()
        b[i].position += move

        if off_screen(b[i].position) {
            slice.unordered_remove(b, i)
        } else {
            i += 1
        }
    }
}
```

| Detail | Reason |
|--------|--------|
| `^[dynamic]Bullet` pointer | Caller pool must see deletion |
| `unordered_remove` | Swaps last element into hole. O(1). Order irrelevant for bullets |
| Manual `i` (not `for _, v in`) | Index shifts on delete. Must `i += 1` only when no removal |
| `la.normalize0` return zero on zero vector | Safe if direction is `{0, 0}` |

---

## Why NOT `ordered_remove`

```odin
// Slower. Every delete shifts remaining elements.
ordered_remove(&arr, i)  // O(n) per delete
unordered_remove(&arr, i) // O(1) per delete
```

Bullets and particles: `unordered_remove`. Priority queues / z-ordered lists: `ordered_remove`.

---

## Caller Also Changes

`main.odin` pass pointer:

```odin
game.update_bullet(&bullets)  // was: update_bullet(bullets)
```

---

## Patterns for Other Entities

| Entity | Pool type | Remove when |
|--------|-----------|-------------|
| Bullets | `[dynamic]Bullet` | off-screen OR hit enemy |
| Enemies | `[dynamic]Enemy` | off-screen (bottom) OR health <= 0 |
| Particles | `[dynamic]Particle` | lifetime <= 0 |

All follow same pattern: `unordered_remove` + manual index.
