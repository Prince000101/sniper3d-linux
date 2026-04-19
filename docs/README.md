# Sniper 3D Linux - Project Documentation

## 🔧 How to Run the Project

1. **Clone the project:**
   ```bash
   cd ~/Desktop
   git clone https://github.com/Prince000101/sniper3d-linux.git
   cd sniper_3d_linux
   ```

2. **Open in Godot 4:**
   - Launch Godot 4
   - Click **Import**
   - Navigate to `sniper_3d_linux/project.godot`
   - Click **Import & Edit**

3. **Play:** Press **F5**

### If getting "Missing Project" error:
Delete the `.godot` folder before opening:
```bash
rm -rf ~/.godot
```
Or clone fresh.

---

## 🎮 Controls

| Action | Input |
|--------|-------|
| Aim | Mouse Move |
| Shoot | Left Click |
| Toggle Scope | Right Click |
| Zoom In | Scroll Up |
| Zoom Out | Scroll Down |
| Quit | Esc |

---

## 📁 Project Structure

```
sniper3d-linux/
├── project.godot          # Project configuration
├── scenes/
│   ├── Main.tscn          # Main game level
│   ├── MainMenu.tscn     # Main menu
│   ├── Level2.tscn      # Level 2 (warehouse)
│   └── Bullet.tscn      # Bullet projectile
├── scripts/
│   ├── Player.gd         # Player controls & shooting
│   ├── Target.gd        # Enemy AI
│   ├── Bullet.gd       # Bullet physics
│   ├── GameManager.gd   # Game state & save
│   ├── MainMenu.gd     # Menu logic
│   └── WeaponModels.gd # Weapon models
└── docs/
    └── README.md       # This file
```

---

## ⚙️ Technical Details

### Godot Version
- **Godot 4.1+** (uses GL Compatibility renderer)

### Input System
- Uses **InputEventMouseButton** directly (not mapped actions)
- Mouse sensitivity: `0.002` (adjustable in Player.gd)

### Key Variables (Player.gd)
```gdscript
var mouse_sensitivity = 0.002
var weapon_damage = 100
var reload_time = 2.0
var weapon_zoom = 4
var weapon_stability = 50
```

### Key Variables (Bullet.gd)
```gdscript
var velocity = Vector3.ZERO
var gravity = Vector3(0, -5.0, 0)
var damage = 100
var wind_force = Vector3.ZERO
var lifetime = 3.0
```

---

## 🐛 Common Fixes

### "Missing project" error
- Delete `.godot` folder in project directory

### Bullet error "omni_energy"
- Use `light_energy` instead (Godot 4 syntax)

### Buttons not working
- Use `action_mode = 0` in Button nodes
- Or use direct signal connection in code

### Controls not responding
- Ensure mouse is captured: `Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)`
- Release on exit: `Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)`

---

## 🎯 Game Features (Current)

- [x] Main Menu with buttons
- [x] Day/night environment
- [x] City rooftop level
- [x] 5 Targets per level
- [x] Sniper rifle model
- [x] Scope with zoom (4x-12x)
- [x] Green scope crosshair
- [x] Wind indicator
- [x] Distance indicator
- [x] Kill counter
- [x] Target counter
- [x] Reload bar
- [x] Bullet physics
- [x] Target death animation

---

## 📋 TODO / Coming Soon

- [ ] Settings menu (sensitivity slider)
- [ ] Multiple weapon types
- [ ] Weapon shop/Armory
- [ ] More levels
- [ ] Sound effects
- [ ] High-poly 3D models (Blender)
- [ ] Multiplayer/PvP

---

## 👤 Author
Created by Prince000101
Email: kumar.prince7428@gmail.com