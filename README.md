# Top-down shooter. Odin + raylib.

### What? 
Simple 2D shooter built to learn raylib + Odin.

### Why Odin + Raylib?
Odin for low-level programming practice; raylib because dead simple to use.

### Controls
| Key | Action |
|-----|--------|
| Arrow keys | Move |
| SPACE | Shoot |

```
main.odin
core/input.odin
game/          -- game, player, enemy, bullet, spawner, common
graphics/      -- texture cache
assets/texture/
```

### Roadmap

- [x] Phase 1 — Foundation: movement, boundaries, code structure
- [x] Phase 2 — Combat: enemies, AI, bullets, pools, spawner, collision, score
- [ ] Phase 3 — Game loop: states, restart, UI
- [ ] Phase 4 — Assets: textures, sounds, asset manager

### After Phase 4
- [ ] Phase 5 - Wave spanner
