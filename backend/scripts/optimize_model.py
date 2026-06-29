import bpy
import sys
import os

# Blender headless AR model optimizer
# Run: blender --background --python this.py -- input.fbx output.glb

argv = sys.argv[sys.argv.index("--") + 1:]
input_file = argv[0]
output_file = argv[1]

print(f"Loading {input_file}...")

# Clear default scene
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

# Import model based on file extension
ext = os.path.splitext(input_file)[1].lower()
if ext == '.fbx':
    bpy.ops.import_scene.fbx(filepath=input_file)
elif ext == '.obj':
    bpy.ops.wm.obj_import(filepath=input_file)
elif ext in ('.gltf', '.glb'):
    bpy.ops.import_scene.gltf(filepath=input_file)
else:
    raise Exception(f"Unsupported format: {ext}")

# Get imported mesh objects
objs = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
if not objs:
    raise Exception("No mesh objects found after import")

print(f"Optimizing {len(objs)} mesh(es)...")

for obj in objs:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)

    # Add Decimate modifier to reduce polygon count
    decimate = obj.modifiers.new(name="Decimate", type='DECIMATE')
    decimate.ratio = 0.1

    # Apply modifier
    bpy.ops.object.modifier_apply(modifier=decimate.name)

    bpy.ops.object.shade_smooth()

# Select all for export
bpy.ops.object.select_all(action='SELECT')

# Export as GLB (AR-ready)
print(f"Exporting {output_file}...")
bpy.ops.export_scene.gltf(
    filepath=output_file,
    export_format='GLB',
    export_apply=True,
    export_animations=False,
    export_lights=False,
    export_cameras=False,
    export_yup=False
)

print("Processing complete!")
