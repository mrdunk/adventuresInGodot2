extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  print(WorldData.values_at_recursions.size())

func _draw():
  print("draw")
  draw_tiles()
  
func draw_tiles():
  var values = WorldData.get_values_at_recursion(0)
  var step = values[1]
  var multiplier = 4
  for y in values:
    for x in values:
      var tile = WorldData.coordinates[y][x]
      var height := 0.0
      if tile:
        height = tile.height
        if height > 0.5:
          draw_rect(Rect2(Vector2(x * multiplier, y * multiplier),
                          Vector2(step * multiplier - 1, step * multiplier - 1)), Color(0.6 * height, 1.4 - height, 0))
        else:
          draw_rect(Rect2(Vector2(x * multiplier, y * multiplier),
                          Vector2(step * multiplier - 1, step * multiplier - 1)), Color(0, 0.2, 1))
      #draw_rect(Rect2(x * multiplier, y * multiplier, (step) * multiplier, (step) * multiplier),
      #          Color(1,0,0), false)
