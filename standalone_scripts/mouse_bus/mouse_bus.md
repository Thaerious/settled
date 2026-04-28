# MouseBus

`mouse_bus.gd` is an autoload singleton that owns all drag-and-drop state for the game. Nothing else tracks what is being dragged, what is hovered, or where the cursor is relative to a target — that responsibility lives here exclusively.

---

## Usage Overview

### Philosophy
The responsibilty for handling drag-drop actions rests with the calling method.  The MouseBus is responsible for checking drop validity and maintaining the ghost image.

### Given
* A valid drop target is a Control node with can_drop == true, or an Area2D on the "mouse" physics layer (not mask).


### Usage Overview
1. caller → start_drag(args: DragArgs)
2. enter valid drop target → signal args.on_enter
3. exit valid drop target → signal args.on_exit
4. release over valid drop target → args.on_success
5. release over no valid drop target → args.on_failure

`drag_handler.gd` handles the typical case where a mouse press starts a drag and the mouse pointer is hidden when there is a texture. To use override the following fields and methods (call super on methods):
* field - texture
* field - texture_size
* method - _on_success
* method - _on_failure
* method - _on_enter
* method - _on_exit


## Core concepts

**DragArgs** is the configuration object a caller passes to `start_drag()`. It carries the texture and size for the ghost image, a cursor offset, and four callbacks: `on_success`, `on_failure`, `on_enter`, and `on_exit`.

**DragRecord** is a snapshot built at the moment a drag ends. It records the draggable node, the resolved drop target (`destination`), and the cursor position in three coordinate spaces. It is passed to `on_success` or `on_failure`.

**HoverRecord** is a snapshot built each frame that the cursor moves between targets during a drag. It records the node that was just left (`exited`) and/or the node that was just entered (`entered`), along with the same positional data as a DragRecord. It is passed to `on_enter` and `on_exit`.

---

## Lifecycle Details

### Startup (`_ready`)

- Sets the cursor to the default arrow shape.
- Creates a `CanvasLayer` at index `DRAG_LAYER` (10) and adds it as a child. This layer hosts the ghost image and renders above all other UI.
- Scans the 2D physics layer names for a layer called `"mouse"` and stores its bitmask. This mask is used later when querying the physics space for world-space drop targets.

### Each frame (`_process`)

Only runs work when a drag is active (i.e. `_draggable` is not null).

1. Moves the ghost `TextureRect` to `mouse_position + args.offset`.
2. Calls `_update_hover()` to check whether the cursor has moved onto or off of a valid drop target.

### Input (`_input`)

Watches for a left mouse button release. When one is detected and a drag is active, calls `_stop_drag()`.

---

## Starting a drag

```
caller → start_drag(args: DragArgs)
```

`start_drag` asserts that no drag is already running, then:

- Stores the `DragArgs`.
- Calls `_generate_rect()` to create a `TextureRect` from the args' texture and size. The rect is configured to ignore mouse input so it never interferes with hit detection.
- Adds the rect to `_drag_layer`, making it visible above everything else.

---

## Hover tracking

`_update_hover()` is called every frame during a drag. It delegates to `_generate_hover_record()`, which:

1. Captures the current screen position and converts it to world space.
2. Stores the current `_hover_target` as `exited`.
3. Calls `_get_drop_target()` to find what is under the cursor right now, stored as `entered`.

Back in `_update_hover`, if `exited == entered` nothing has changed and the function returns early. Otherwise:

- If `entered` is non-null, `on_enter` is called with the record.
- If `exited` is non-null, `on_exit` is called with the record.
- `_hover_target` is updated to `entered`.

---

## Drop target resolution

`_get_drop_target()` checks two sources in priority order:

**1. UI controls (`_get_ui_target`)**  
Asks the viewport for the currently hovered `Control`. A control is only considered a valid drop target if it has a `can_drop` property set to `true`. This is a duck-typed convention — any `Control` that declares `var can_drop: bool = true` opts in automatically.

**2. World Area2Ds (`_get_world_target`)**  
Runs a point query against the 2D physics space at the current world position. The query is restricted to the `"mouse"` physics layer, collides with areas only (not bodies), and returns the first collider found.

UI targets take priority. If a UI target is found, the world query is skipped entirely.

---

## Ending a drag

When the left mouse button is released, `_stop_drag()` runs:

1. Calls `_resolve_target()`, which builds a `DragRecord` with the current cursor positions and the resolved drop target.
2. If `destination` is non-null, calls `on_success(record)`. Otherwise calls `on_failure(record)`.
3. Frees the ghost image via `clear_image()`.
4. Clears `_args` and `_hover_target`.

> **Note:** There is currently a dead code block in `_stop_drag` that constructs a `HoverRecord` for the lingering hover target but never passes it to `on_exit`. If a final exit callback on drop is desired, that call is missing.

---

## Coordinate helpers

| Method | Description |
|---|---|
| `mouse_world_pos()` | Current mouse position in world space. Equivalent to `world_pos(get_viewport().get_mouse_position())`. |
| `world_pos(canvas_pos)` | Converts a screen-space position to world space using the inverse canvas transform. |
| `canvas_pos(global_pos)` | Converts a world-space position to screen space. |
| `get_local(target, world_pos)` | Returns the cursor position in `target`'s local space. Uses `get_local_mouse_position()` for Controls, `to_local()` for everything else. |

---

## Data flow summary

```
caller calls start_drag(DragArgs)
    │
    ▼
ghost TextureRect created and added to drag CanvasLayer
    │
    ▼ (every frame)
ghost follows cursor
_update_hover() → _generate_hover_record()
    ├─ target unchanged → no-op
    └─ target changed   → on_exit(HoverRecord) / on_enter(HoverRecord)
    │
    ▼ (mouse button released)
_stop_drag() → _resolve_target() → DragRecord
    ├─ destination found → on_success(DragRecord)
    └─ no destination   → on_failure(DragRecord)
ghost freed, state reset
```