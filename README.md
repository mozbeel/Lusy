# Lusy

**Lusy** (`.lusy`) — the Lua-inspired language for system-minded developers.  

Lusy is a typed, readable, beginner-friendly dialect of Lua, designed to help programmers **write clean, maintainable code** while gradually learning **systems-level programming concepts**.  

---

## 🌟 Key Features

- **Strong, explicit types**: Learn safe coding practices from day one.
- **Tables as references**: Clear, semantic `tableref` syntax to signal shared, mutable structures.
- **Data-oriented programming friendly**: Ideal for games, simulations, and ECS-style systems.
- **High-level yet systems-conscious**: Easy to pick up, but encourages thinking about memory, ownership, and mutation.
- **Automatic table references**: Tables are always references — no pointer syntax required.
- **Lightweight syntax**: Lua-inspired, readable, and approachable.

---

## 📦 File Extension

- Lusy source files: `.lusy`
- Example: `player.lusy`

---

## ⚡ Quick Syntax Overview

### Types

```tl
local health: integer = 100
local name: string = "Alice"

local position: tableref Vector2 = Vector2 { x = 10, y = 20 }

