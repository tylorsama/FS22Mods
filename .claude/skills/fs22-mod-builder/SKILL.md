# FS22 Mod Builder

Build Farming Simulator 22 mods from scratch. This skill covers all mod types: vehicles, implements, placeables, production points, script-only mods, and maps.

## Activation

Use this skill when the user wants to:
- Create a new FS22 mod of any type
- Add Lua scripts or specializations to an existing mod
- Create or modify modDesc.xml files
- Build vehicle or placeable XML configurations
- Package a mod for testing or ModHub submission
- Debug common FS22 modding issues

## FS22 Mod Architecture

### Mod Types

| Type | Description | Requires 3D Model |
|------|-------------|--------------------|
| Vehicle | Tractors, trucks, combines | Yes (i3d) |
| Implement | Plows, seeders, mowers | Yes (i3d) |
| Placeable | Buildings, silos, factories | Yes (i3d) |
| Production Point | Factories with input/output | Yes (i3d) |
| Script | Gameplay modifications | No |
| Map | Custom terrain/world | Yes (complex) |

### Required Files (All Mods)

Every FS22 mod needs at minimum:
- `modDesc.xml` at the zip root (descVersion="79")
- `icon.dds` or `icon.png` (256x256 pixels)

### Directory Conventions

```
FS22_ModName/
  modDesc.xml
  icon.dds
  vehicles/          (vehicle/implement mods)
  placeables/        (placeable mods)
  scripts/           (Lua source files)
  l10n/              (localization files)
  store/             (store preview images)
  sounds/            (audio files)
```

Mod zip filenames must use only alphanumeric characters and underscores (no hyphens or dots). Convention: prefix with `FS22_`.

## modDesc.xml Reference

The modDesc.xml is the heart of every mod. descVersion MUST be `79` for FS22.

### Required Fields

```xml
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<modDesc descVersion="79">
    <author>Author Name</author>
    <version>1.0.0.0</version>
    <title>
        <en>Mod Title</en>
    </title>
    <description>
        <en><![CDATA[Mod description text.]]></en>
    </description>
    <iconFilename>icon.dds</iconFilename>
    <multiplayer supported="true" />
</modDesc>
```

### Store Items (vehicles/placeables)

```xml
<storeItems>
    <storeItem xmlFilename="vehicles/myVehicle.xml" />
</storeItems>
```

### Lua Source Files (script mods)

```xml
<extraSourceFiles>
    <sourceFile filename="scripts/main.lua" />
</extraSourceFiles>
```

### Custom Specializations

```xml
<specializations>
    <specialization name="mySpec"
                    className="MySpecialization"
                    filename="scripts/MySpecialization.lua" />
</specializations>
```

### Vehicle Types

```xml
<vehicleTypes>
    <type name="myTractor" parent="baseDrivable"
          filename="$dataS/scripts/vehicles/Vehicle.lua">
        <specialization name="mySpec" />
    </type>
</vehicleTypes>
```

### Input Actions

```xml
<actions>
    <action name="MY_ACTION" category="VEHICLE" />
</actions>
<inputBinding>
    <actionBinding action="MY_ACTION">
        <binding device="KB_MOUSE_DEFAULT" input="KEY_o" />
    </actionBinding>
</inputBinding>
```

### Localization

```xml
<!-- External files (recommended) -->
<l10n filenamePrefix="l10n/l10n" />

<!-- Or inline -->
<l10n>
    <text name="myKey">
        <en>English text</en>
        <de>German text</de>
    </text>
</l10n>
```

### Maps

```xml
<maps>
    <map id="MyMap" className="Mission00"
         configFilename="maps/mapDE.xml"
         defaultVehiclesXMLFilename="maps/defaultVehicles.xml"
         title="My Custom Map" />
</maps>
```

## Lua Scripting Reference

FS22 uses Lua 5.1. The core pattern is the **Specialization**.

### Specialization Template

```lua
MySpec = {}

function MySpec.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Drivable, specializations)
end

function MySpec.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", MySpec)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", MySpec)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", MySpec)
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", MySpec)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", MySpec)
end

function MySpec:onLoad(savegame)
    local spec = self.spec_MySpec
    spec.isActive = false
end

function MySpec:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local spec = self.spec_MySpec
    -- dt is delta time in milliseconds
end

function MySpec:onDelete()
    -- cleanup
end

-- Multiplayer sync (initial join)
function MySpec:onReadStream(streamId, connection)
    local spec = self.spec_MySpec
    spec.isActive = streamReadBool(streamId)
end

function MySpec:onWriteStream(streamId, connection)
    local spec = self.spec_MySpec
    streamWriteBool(streamId, spec.isActive)
end
```

### Injecting Into Existing Vehicle Types

```lua
local modDir = g_currentModDirectory or ""
local modName = g_currentModName or ""

local function addSpecs()
    if g_specializationManager ~= nil then
        g_specializationManager:addSpecialization("mySpec", "MySpec",
            modDir .. "scripts/MySpec.lua", nil)

        for typeName, typeEntry in pairs(g_vehicleTypeManager:getTypes()) do
            if SpecializationUtil.hasSpecialization(Drivable, typeEntry.specializations) then
                g_vehicleTypeManager:addSpecialization(typeName, modName .. ".mySpec")
            end
        end
    end
end

TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, addSpecs)
```

### Hooking Game Events (Script-Only Mods)

```lua
-- Hook into mission load
Mission00.loadMission00Finished = Utils.appendedFunction(
    Mission00.loadMission00Finished, MyMod.onMissionLoaded)

-- Hook into savegame save
FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(
    FSCareerMissionInfo.saveToXMLFile, MyMod.onSave)
```

### Available Event Listeners

Lifecycle: `onLoad`, `onPostLoad`, `onPreDelete`, `onDelete`
Updates: `onUpdate`, `onUpdateTick`, `onDraw`
Multiplayer: `onReadStream`, `onWriteStream`, `onReadUpdateStream`, `onWriteUpdateStream`
Input: `onRegisterActionEvents`
Vehicle: `onEnterVehicle`, `onLeaveVehicle`, `onTurnedOn`, `onTurnedOff`
Implements: `onAttach`, `onDetach`, `onStartWorkAreaProcessing`, `onEndWorkAreaProcessing`

### Stream Read/Write Types

```lua
streamReadBool(streamId)        / streamWriteBool(streamId, val)
streamReadInt8(streamId)        / streamWriteInt8(streamId, val)
streamReadInt16(streamId)       / streamWriteInt16(streamId, val)
streamReadInt32(streamId)       / streamWriteInt32(streamId, val)
streamReadFloat32(streamId)     / streamWriteFloat32(streamId, val)
streamReadString(streamId)      / streamWriteString(streamId, val)
```

## Vehicle XML Reference

### Base Vehicle Types

| Parent | Use Case |
|--------|----------|
| `baseVehicle` | Non-drivable (trailers with no motor) |
| `baseDrivable` | Self-propelled (tractors, trucks, combines) |
| `baseFillable` | Vehicles carrying materials |
| `baseAttachable` | Implements that attach to other vehicles |

### Key Vehicle XML Sections

```xml
<vehicle type="myType">
    <storeData>
        <name>Vehicle Name</name>
        <image>store/image.png</image>
        <price>120000</price>
        <lifetime>600</lifetime>
        <brand>FENDT</brand>
        <category>tractorsL</category>
        <specs>
            <power>250</power>
            <maxSpeed>60</maxSpeed>
        </specs>
        <functions>
            <function>$l10n_function_tractor</function>
        </functions>
    </storeData>

    <base>
        <filename>vehicles/myVehicle.i3d</filename>
        <typeDesc>$l10n_typeDesc_tractor</typeDesc>
        <speedLimit value="60" />
        <components>
            <component centerOfMass="0 0.8 0" mass="8000" />
        </components>
    </base>

    <motorized>
        <motorConfigurations>
            <motorConfiguration name="250 HP">
                <motor torqueScale="1.0" minRpm="800" maxRpm="2200"
                       maxForwardSpeed="60" maxBackwardSpeed="20"
                       brakeForce="5" />
                <transmission name="6+6" />
            </motorConfiguration>
        </motorConfigurations>
        <consumerConfigurations>
            <consumerConfiguration>
                <consumer fillType="DIESEL" usage="5" />
            </consumerConfiguration>
        </consumerConfigurations>
    </motorized>

    <wheels autoRotateBackSpeed="1.0">
        <wheel node="wheelFL" radius="0.55" width="0.4"
               mass="0.2" tireType="normal" />
    </wheels>

    <attacherJoints>
        <attacherJoint node="rearAttacher" jointType="implement" />
    </attacherJoints>

    <i3dMappings>
        <i3dMapping id="wheelFL" node="0>1|0" />
        <i3dMapping id="rearAttacher" node="0>3|0" />
    </i3dMappings>
</vehicle>
```

### Store Categories

Vehicles: `tractorsS`, `tractorsM`, `tractorsL`, `harvesters`, `forageHarvesters`, `trucks`, `cars`
Implements: `plows`, `cultivators`, `sowingMachines`, `mowers`, `balers`, `spreaders`, `sprayers`
Trailers: `trailers`, `lowloaders`, `woodTrailers`, `baleTrailers`

## Placeable XML Reference

### Placeable Types

| Type | Description |
|------|-------------|
| `simplePlaceable` | Static buildings/decorations |
| `productionPoint` | Factories with inputs/outputs |
| `silo` | Crop storage |
| `husbandryAnimal` | Animal pens |
| `sellingStation` | Sell points |

### Production Point Example

```xml
<placeable type="productionPoint">
    <storeData>
        <name>Flour Mill</name>
        <price>80000</price>
        <category>productionPoints</category>
    </storeData>
    <base>
        <filename>placeables/flourMill.i3d</filename>
    </base>
    <productionPoint>
        <productions>
            <production id="flour" name="Flour Production"
                        cyclesPerHour="1" costsPerActiveHour="20">
                <inputs>
                    <input fillType="WHEAT" amount="1000" />
                </inputs>
                <outputs>
                    <output fillType="FLOUR" amount="800" />
                </outputs>
            </production>
        </productions>
        <storage capacityPerFillType="50000">
            <fillType name="WHEAT" />
            <fillType name="FLOUR" />
        </storage>
    </productionPoint>
</placeable>
```

### Placeable Store Categories

`placeablesMisc`, `productionPoints`, `silos`, `animalPens`, `greenhouses`

## Common Fill Types

Crops: `WHEAT`, `BARLEY`, `OAT`, `CANOLA`, `CORN`, `SUNFLOWER`, `SOYBEAN`, `POTATO`, `SUGARBEET`, `COTTON`, `SUGARCANE`, `GRAPE`, `OLIVE`
Products: `FLOUR`, `BREAD`, `BUTTER`, `CHEESE`, `CAKE`, `CHOCOLATE`, `SUGAR`, `RAISIN`, `GRAPEJUICE`, `OLIVEOIL`
Animal: `MILK`, `EGG`, `WOOL`, `HONEY`
Materials: `FERTILIZER`, `SEEDS`, `LIME`, `HERBICIDE`, `WATER`, `DIESEL`, `DEF`, `ELECTRICCHARGE`
Forage: `GRASS_WINDROW`, `DRYGRASS_WINDROW`, `STRAW`, `SILAGE`, `HAY`, `TMR`, `FORAGE`
Other: `WOODCHIPS`, `STONE`, `GRAVEL`, `SAND`, `PIGFOOD`, `CHAFF`

## Packaging and Testing

### Build Script

Use the included `tools/build.sh` script:
```bash
./tools/build.sh FS22_ModName    # Packages the mod directory into a zip
```

Rules:
- `modDesc.xml` MUST be at the zip root (not inside a subfolder)
- Zip filename: only alphanumeric + underscores
- Exclude: `.blend`, `.psd`, `.xcf`, `.git`, `__MACOSX`

### Testing Checklist

1. Place unzipped mod folder in FS22 mods directory during development
2. Start the game and check `log.txt` for errors
3. Verify mod appears in mod selection screen with correct icon/title
4. Test in single player first, then multiplayer if `multiplayer supported="true"`
5. Run GIANTS TestRunner before ModHub submission

### Common Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| Mod not appearing in list | modDesc.xml not at zip root | Re-zip with files at root level |
| `Error: missing icon` | Wrong path in iconFilename | Check icon path is relative to modDesc.xml |
| `Error: descVersion` | Wrong version number | Set descVersion="79" |
| `LUA call stack` in log | Lua runtime error | Check log.txt for file:line details |
| `Duplicate specialization` | Spec already in parent type | Check parent type's specs before adding |
| `i3d file not found` | Wrong filename path | Paths are relative to modDesc.xml location |

## Workflow

When building a new mod:

1. **Ask the user** what type of mod they want (vehicle, placeable, script, etc.)
2. **Create the directory structure** using the conventions above
3. **Generate modDesc.xml** with correct descVersion, metadata, and sections for the mod type
4. **Create type-specific files**: vehicle XML, placeable XML, or Lua scripts as needed
5. **Add localization** files if the mod has user-visible strings
6. **Create the build script** entry for packaging
7. **Validate** the modDesc.xml structure and file references

Use the templates in `/templates/` as starting points for each mod type.
