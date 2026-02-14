# Bugatti Chiron - 3D Asset Sources

This mod requires a 3D model (`.i3d` format) to work in-game. Below are free,
open-source models you can download and convert.

## Recommended Models (CC-BY 4.0 Licensed)

All models below are free to use with attribution under Creative Commons.

### Best for Game Use (Low Poly)

1. **Bugatti Chiron by -L0Lock-** (Sketchfab)
   - Low-poly, ideal for game engine conversion
   - https://sketchfab.com/3d-models/bugatti-chiron-5e11379a0b7b4014b0ac6003e950a3f8

### High Detail Options

2. **Bugatti Chiron Super Sports 300+ by MdMahib** (Sketchfab)
   - Detailed interior, engine, PBR textures
   - https://sketchfab.com/3d-models/bugatti-chiron-super-sports-300-4e0d187409d6461483f5113cdde9726c

3. **Free Bugatti Chiron by ALIEEEN** (Sketchfab)
   - https://sketchfab.com/3d-models/free-bugatti-chiron-374890e62c5a44e9a739ca638b6e0a18

4. **Bugatti Chiron by WilliamBonk** (Sketchfab)
   - High poly, adjustable color
   - https://sketchfab.com/3d-models/bugatti-chiron-241349162c8a40108f6b9e04410ad6f7

5. **Bugatti Chiron 2017 by HINDU01** (Sketchfab)
   - Modeled in Blender, .obj + .blend available
   - https://sketchfab.com/3d-models/bugatti-chiron-2017-sports-car-d4f9186897fa4341b5f0d2da6b3c6227

### Other Sources

- **Free3D** - Bugatti Chiron 2017 (.blend, .obj):
  https://free3d.com/3d-model/bugatti-chiron-2017-model-31847.html

- **Free3D** - All free Bugatti models:
  https://free3d.com/3d-models/bugatti

## Conversion Workflow

To convert a downloaded model to FS22's `.i3d` format:

### Option A: Blender (Recommended)

1. Install **Blender** (free): https://www.blender.org/download/
2. Install the **GIANTS I3D Exporter Plugin** from:
   https://gdn.giants-software.com/downloads.php
   (Free registration required on the GIANTS Developer Network)
3. Import the downloaded model (.obj, .fbx, .gltf, or .blend)
4. Set up the scene hierarchy to match the `i3dMappings` in `vehicles/bugattiChiron.xml`:
   ```
   bugattiChiron (root TransformGroup)
   ├── body (Shape - car body mesh)
   ├── wheels (TransformGroup)
   │   ├── wheelFrontLeft (TransformGroup)
   │   │   └── wheelDriveFrontLeft (Shape - wheel mesh)
   │   ├── wheelFrontRight (TransformGroup)
   │   │   └── wheelDriveFrontRight (Shape)
   │   ├── wheelRearLeft (TransformGroup)
   │   │   └── wheelDriveRearLeft (Shape)
   │   └── wheelRearRight (TransformGroup)
   │       └── wheelDriveRearRight (Shape)
   ├── interior (TransformGroup)
   │   ├── steeringWheel (Shape)
   │   └── playerSeat (TransformGroup)
   ├── cameras (TransformGroup)
   │   ├── cameraIndoor (Camera)
   │   └── cameraOutdoor (Camera)
   ├── exhaust (TransformGroup)
   │   ├── exhaustLeft (TransformGroup)
   │   ├── exhaustRight (TransformGroup)
   │   └── exhaustParticle1 (TransformGroup)
   ├── sound (TransformGroup)
   │   └── engineSoundNode (TransformGroup)
   └── lights (TransformGroup)
       ├── headlightLeft (Light)
       ├── headlightRight (Light)
       ├── taillightLeft (Light)
       ├── taillightRight (Light)
       ├── reverseLightLeft (Light)
       ├── reverseLightRight (Light)
       ├── turnSignalFrontLeft (Light)
       ├── turnSignalFrontRight (Light)
       ├── turnSignalRearLeft (Light)
       └── turnSignalRearRight (Light)
   ```
5. Ensure physics rigid bodies have scale `1 1 1`
6. Export as `.i3d` via File > Export > GIANTS i3D
7. Place the exported `.i3d` and `.i3d.shapes` files in `vehicles/`

### Option B: GIANTS Editor

1. Download **GIANTS Editor** from:
   https://gdn.giants-software.com/downloads.php
2. Import an OBJ or FBX file
3. Arrange nodes to match the hierarchy above
4. Save as `.i3d`

## Texture Notes

- Convert textures to **DDS format** (BC7 compression) using the GIANTS Texture Tool
- Required texture maps:
  - `_diffuse.dds` - Base color/albedo
  - `_normal.dds` - Normal map
  - `_specular.dds` - Specular/roughness map
- Place all textures in the `textures/` directory

## Attribution

When using CC-BY licensed models, include attribution in your mod description.
Example: "3D model by [Author Name] (CC BY 4.0) - [URL]"
