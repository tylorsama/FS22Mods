# FS22Mods - Farming Simulator 22 Mod Development

This repository contains templates, tools, and examples for building Farming Simulator 22 mods.

## Structure

```
templates/           Starter templates for each mod type
  modDesc_*.xml      modDesc.xml templates (vehicle, placeable, script, production)
  script/            Lua script templates (Specialization, register, main)
  vehicle/           Vehicle XML configuration template
  placeable/         Placeable XML templates (simple, production point)
  l10n_en.xml        Localization template

examples/            Working example mods
  FS22_ExampleScript/  Script mod that displays vehicle speed on the HUD

tools/               Build and packaging utilities
  build.sh           Package a mod directory into a distributable zip

.claude/skills/      Claude Code skills for mod development
  fs22-mod-builder/  Skill for building FS22 mods from scratch
```

## Quick Start

1. Copy a template set for your mod type into a new `FS22_YourModName/` directory
2. Replace `{{PLACEHOLDER}}` values with your mod's specifics
3. Develop and test with the mod folder unzipped in your FS22 mods directory
4. Package with `./tools/build.sh FS22_YourModName`

## Mod Types

- **Vehicle**: Tractors, trucks, combines (needs i3d 3D model)
- **Implement**: Plows, seeders, mowers (needs i3d, attaches to vehicles)
- **Placeable**: Buildings, silos (needs i3d)
- **Production Point**: Factories with input/output processing (needs i3d)
- **Script**: Gameplay modifications via Lua (no 3D model needed)
- **Map**: Custom terrain and world (complex, needs GIANTS Editor)
