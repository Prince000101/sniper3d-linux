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
Delete the `.godot` folder in project directory:
```bash
rm -rf sniper_3d_linux/.godot
```

---

## 🎮 Controls

| Action | Input |
|--------|-------|
| Aim | Mouse Move |
| Shoot | Left Click |
| Toggle Scope | Right Click |
| Zoom In | Scroll Up |
| Zoom Out | Scroll Down |
| Back to Menu | Esc |

---

## 📁 Project Structure

```
sniper3d-linux/
├── project.godot          # Project configuration
├── scenes/
│   ├── Main.tscn          # Main game level (City)
│   ├── MainMenu.tscn      # Main menu + Settings
│   ├── Level2.tscn        # Level 2 (Warehouse)
│   └── Bullet.tscn       # Bullet projectile
├── scripts/
│   ├── Player.gd         # Player controls & shooting
│   ├── Target.gd         # Enemy AI
│   ├── Bullet.gd         # Bullet physics
│   ├── GameManager.gd     # Game state & save
│   ├── MainMenu.gd       # Menu + Settings logic
│   └── WeaponModels.gd   # Weapon models
└── docs/
    └── README.md         # This file
```

---

## ⚙️ Technical Details

### Godot Version
- **Godot 4.1+** (uses GL Compatibility renderer)

### Mouse Sensitivity
- **Default: 0.0003** (very slow)
- Adjustable in Settings menu (0.1 - 2.0)
- Multiplier: x15 for smooth movement

### Key Variables (Player.gd)
```gdscript
var mouse_sensitivity = 0.0003
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

### Controls too fast/slow
- Adjust `mouse_sensitivity` in Player.gd (line 3)
- Or use Settings slider in main menu

### Scope too dark
- Scope overlay now has 50% opacity (brighter)
- Green crosshairs for visibility

---

## 🎯 Game Features (v1.0.2)

- [x] Main Menu
- [x] Settings Panel (mouse sensitivity)
- [x] Day environment (blue sky, fog)
- [x] City rooftop level
- [x] Warehouse level (Level 2)
- [x] 5 Targets per level
- [x] Sniper rifle model (barrel, stock, scope)
- [x] Scope with zoom (4x, 6x, 8x, 10x, 12x)
- [x] Green scope crosshair with circle border
- [x] Wind indicator (E/W direction)
- [x] Distance indicator (meters when scoped)
- [x] Zoom level indicator
- [x] Kill counter
- [x] Target counter
- [x] Reload bar
- [x] Bullet physics with gravity
- [x] Target death animation (fall backward)
- [x] ESC returns to menu

---

## 📋 TODO / Coming Soon

- [ ] Save/Load game progress
- [ ] Weapon shop/Armory
- [ ] Sound effects
- [ ] High-poly 3D models (Blender)
- [ ] More levels (3+)
- [ ] Multiplayer/PvP

---

## 👤 Author
**Prince000101**  
Email: kumar.prince7428@gmail.com