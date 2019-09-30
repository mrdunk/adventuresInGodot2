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
  var multiplier = 8
  for x in values:
    for y in values:
      var tile = WorldData.coordinates[x][y]
      var height = tile.height
                         
      if height > WorldData.SEA_LEVEL:
        draw_rect(Rect2(Vector2(x * multiplier, y * multiplier),
                        Vector2(step * multiplier - 1, step * multiplier - 1)), Color(0.0 * height, 1.4 - height, 0, 1))
      else:
        draw_rect(Rect2(Vector2(x * multiplier, y * multiplier),
                        Vector2(step * multiplier - 1, step * multiplier - 1)), Color(0, 0.2, 2 * height, 1))

      if tile.highlight:
        draw_rect(Rect2(Vector2((x + step / 2.0) * multiplier, (y + step / 2.0) * multiplier),
                        Vector2(4, 4)), Color(1, 0, 0, 1)) 
      #draw_rect(Rect2(x * multiplier, y * multiplier, (step) * multiplier, (step) * multiplier),
      #          Color(1,0,0), false)
    