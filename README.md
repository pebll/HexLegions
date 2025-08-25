# Godot Strategy MVP - Ultra Simplified Unit System

This is an ultra-simplified and elegant unit system for Godot strategy games.

## What You Get

✅ **Dropdown in Editor** - Select unit type from a dropdown in the inspector  
✅ **Instant Model Updates** - Models change immediately when you change the type  
✅ **Works in Editor & Runtime** - No complex setup or timing issues  
✅ **Clean & Simple** - Just 50 lines of code total  

## How It Works

### The Unit Script (Unit.gd)
```gdscript
@export var unit_type: String = "fox" : set = set_unit_type
@export var unit_config: UnitConfigResource

func set_unit_type(new_type: String):
    unit_type = new_type
    update_model()  # This updates the model immediately

func update_model():
    # Loads and displays the model for the selected unit type
```

### Configuration
- **UnitData.gd** - Defines unit properties (model path, stats, etc.)
- **UnitConfigResource.gd** - Container for all unit configurations
- **data/unit_config.tres** - The actual configuration file

## Usage

### In Editor
1. **Select any Unit node** in the scene tree
2. **In the Inspector**, find "Unit Type" dropdown
3. **Change the selection** - Model updates immediately
4. **Assign Unit Config** - Drag the config resource to the "Unit Config" property

### In Runtime
- Units automatically load their models when the scene starts
- Change unit types programmatically with `unit.unit_type = "stag"`

## Adding New Units

1. **Add unit data** to `data/unit_config.tres`
2. **Place model file** in `models/` directory
3. **Update config** with correct model path
4. **New unit appears** in dropdown automatically

## File Structure

```
├── Unit.gd                    # Main unit script (50 lines)
├── scripts/
│   ├── UnitData.gd           # Unit data resource
│   └── UnitConfigResource.gd # Config container
├── data/
│   └── unit_config.tres      # Unit configurations
├── models/
│   ├── Fox.glb              # Fox unit model
│   └── Stag.glb             # Stag unit model
└── scenes/
    ├── test_main.tscn       # Test scene
    └── unit.tscn            # Unit scene template
```

## That's It!

No complex component systems, no timing issues, no global singletons. Just a simple, elegant solution that does exactly what you need.
