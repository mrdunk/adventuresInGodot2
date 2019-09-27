extends Node

#const WORLD_SIZE = 0x401  # 1025
#const WORLD_SIZE = 0x201
const WORLD_SIZE = 0x101
#const WORLD_SIZE = 17
var coordinates := []
var values_at_recursions := []

func _init():
  for y in WORLD_SIZE:
    var row = []
    coordinates.push_back(row)
    for x in WORLD_SIZE:
      row.push_back(null)
  
  _get_values_at_recursions()
  
  # Seed map
  var starting_recursion = 3
  var values = get_values_at_recursion(starting_recursion)
  print("recursion: %s %s" % [starting_recursion, values])
  for y in values:
    for x in values:
      #coordinates[y][x] = Tile.new(rand_range(0, 1))
      coordinates[y][x] = Tile.new(rand_range(0, 1))
  
  # Average map points
  var values_previous = values
  var low_jitter_base = 0.5
  var low_jitter_update = -low_jitter_base
  var high_jitter_base = 0.5
  var high_jitter_update = high_jitter_base
  for recursion in range(starting_recursion + 1, values_at_recursions.size()):
    values = get_values_at_recursion(recursion)
    low_jitter_base *= low_jitter_update
    high_jitter_base *= high_jitter_update
    print("recursion: %s" % [recursion,])
    var step = values[1]
    for y in values:
      for x in values:
        var tile = coordinates[y][x]
        if tile == null:
          var height = 0
          var previous_y = -1
          var previous_x = -1
          var next_y = -1
          var next_x = -1
          if !(y in values_previous):
            if y >= step:
              previous_y = y - step
            if y <= WORLD_SIZE:
              next_y = y + step
          if !(x in values_previous):
            if x >= step:
              previous_x = x - step
            if x <= WORLD_SIZE:
              next_x = x + step

          if previous_x >= 0 and previous_y >= 0:
            height = coordinates[previous_y][previous_x].height
            height += coordinates[previous_y][next_x].height
            height += coordinates[next_y][previous_x].height
            height += coordinates[next_y][next_x].height
            height /= 4
            height += rand_range(low_jitter_base, high_jitter_base)
            height = clamp(height, 0, 1)
            coordinates[y][x] = Tile.new(height)
    for y in values:
      for x in values:
        var tile = coordinates[y][x]
        if tile == null:
          var height = 0
          var count = 0
          var previous_y = y - step
          var previous_x = x - step
          var next_y = y + step
          var next_x = x + step
          if previous_y >= 0:
            var above = coordinates[previous_y][x]
            if above:
              height += above.height
              count += 1
          if next_y < WORLD_SIZE:
            var below = coordinates[next_y][x]
            if below:
              height += below.height
              count += 1
          if previous_x >= 0:
            var left = coordinates[y][previous_x]
            if left:
              height += left.height
              count += 1
          if next_x < WORLD_SIZE:
            var right = coordinates[y][next_x]
            if right:
              height += right.height
              count += 1
          if count:
            height /= count
            height += rand_range(low_jitter_base, high_jitter_base)
            height = clamp(height, 0, 1)
                        
          coordinates[y][x] = Tile.new(height)
    
    values_previous = values
    #break = 0.0
    
    close_dips(recursion)
        
func close_dips(recursion: int):
  var values = get_values_at_recursion(recursion)
  var step = values[1]
  for y in range(step, WORLD_SIZE - step, step):
    for x in range(step, WORLD_SIZE - step, step):
      #print("%s %s,%s" % [step, x, y])
      var lowest = 1
      #lowest = min(coordinates[y - step][x - step].height, lowest)
      lowest = min(coordinates[y - step][x].height, lowest)
      #lowest = min(coordinates[y - step][x + step].height, lowest)
      lowest = min(coordinates[y][x - step].height, lowest)
      lowest = min(coordinates[y][x + step].height, lowest)
      #lowest = min(coordinates[y + step][x - step].height, lowest)
      lowest = min(coordinates[y + step][x].height, lowest)
      #lowest = min(coordinates[y + step][x + step].height, lowest)
      
      coordinates[y][x].height = max(coordinates[y][x].height, lowest)
           
func get_closest_value_at_recursion(value: int, recursion: int):
  var values = values_at_recursions[recursion]
  assert(values.size() > 0)
  
  var half_step = values[1] / 2
  var head = values.size()
  var tail = 0
  var mid
  while true:
    mid = (head + tail) / 2
    var proposed_value = values[mid]
    if proposed_value > value - half_step  and proposed_value <= value + half_step:
      return proposed_value
    if proposed_value > value + half_step:
      head = mid
    else:
      tail = mid
  
func get_values_at_recursion(recursion: int):
  if recursion <= 0:
    recursion = values_at_recursions.size() - 1
  if recursion >= values_at_recursions.size():
    return []
  return values_at_recursions[recursion]

func _get_values_at_recursions():
  for recursion in WORLD_SIZE:
    var step = WORLD_SIZE - 1
    for i in recursion:
      step /= 2
    if step <= 0:
      return
    var values = []
    var sum = 0
    while sum < WORLD_SIZE:
      values.push_back(sum)
      sum += step
    values_at_recursions.push_back(values)
    
    