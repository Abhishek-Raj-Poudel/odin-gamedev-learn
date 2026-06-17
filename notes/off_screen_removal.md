# Off-Screen Bullet Removal

## Problem

Bullets fired never removed. Pool grows forever. Memory leak. Wasted CPU updating/drawing dead bullets.

## Solution

Two-part: mark inactive when off-screen, delete inactive bullets each frame.

---

## Step 1: `off_screen` helper

In `bullet.odin`:

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

MARGIN prevents pop-at-edge. Bullet fully leaves screen before removal.

No raylib equivalent. `GetScreenWidth/Height` + manual bounds check.

---

## Step 2: Mark inactive on off-screen

In `update_bullet` (`bullet.odin`):

```odin
update_bullet :: proc(b: ^Bullet) {
    if !b.active {return}
    b.pos += b.vel * rl.GetFrameTime()
    if off_screen(b.pos) {
        b.active = false
    }
}
```

---

## Step 3: Guard draw by active

In `draw_bullet` (`bullet.odin`):

```odin
draw_bullet :: proc(b: Bullet) {
    if !b.active {return}
    rl.DrawTextureV(b.texture, b.pos, rl.WHITE)
}
```

---

## Step 4: Delete inactive bullets each frame

In `game.odin`, add import:

```odin
import "core:slice"
```

Then in `update_game`:

```odin
update_game :: proc(s: ^GameState) {
    inputs := core.Get_Input()
    update_player(&s.player, inputs, &s.bullets)
    for &bullet in s.bullets {
        update_bullet(&bullet)
    }
    // remove inactive bullets
    i := 0
    for i < len(s.bullets) {
        if !s.bullets[i].active {
            slice.unordered_remove(&s.bullets, i)
        } else {
            i += 1
        }
    }
}
```

---

## Why This Works

| Part | Why |
|------|-----|
| `off_screen` | Single bounds check. Reusable for enemies later |
| `active = false` | Defers deletion. Avoids delete-while-iterating in bullet loop |
| Separate cleanup loop | Delete after all updates. Safe iteration |
| `unordered_remove` | O(1). Swaps last element into hole. Order irrelevant for bullets |
| Manual `i` index | Deletion shifts last element into `i`. Don't skip it |

---

## Verify

1. Run game
2. Hold SPACE
3. Bullets fire upward, disappear past screen top + 100px
4. Bullet count stops growing
