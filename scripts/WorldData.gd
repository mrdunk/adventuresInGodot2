extends Node

#const WORLD_SIZE = 0x401  # 1025
#const WORLD_SIZE = 0x201
#const WORLD_SIZE = 0x101
const WORLD_SIZE = 0x81
#const WORLD_SIZE = 0x41
#const WORLD_SIZE = 17

const SEA_LEVEL = 0.3

var coordinates := []
var values_at_recursions := []

func _init():
  for x in WORLD_SIZE:
    var colum = []
    coordinates.push_back(colum)
    for y in WORLD_SIZE:
      colum.push_back(Tile.new(x, y))
  
  _get_values_at_recursions()  
    
  # Seed map heights and population
  var starting_recursion = 3
  var values = get_values_at_recursion(starting_recursion)
  print("recursion: %s %s" % [starting_recursion, values])
  for y in values:
    for x in values:
      coordinates[x][y].height = rand_range(0, 1)
      coordinates[x][y].population = rand_range(0, 1)
      
  # Average map population
  var values_previous = values
  var jitter_base = 0.4
  var jitter_update = -jitter_base
  for recursion in range(starting_recursion + 1, values_at_recursions.size()):
    values = get_values_at_recursion(recursion)
    jitter_base *= jitter_update
    print("recursion: %s" % [recursion,])
    var step = values[1]

    for y in values_previous:
      for x in values_previous:
        average_corners("height", x, y, step, jitter_base)
        average_corners("population", x, y, step, jitter_base)
        
    for x in values_previous:
      for y in values_previous:
        average_surrounding("height", x, y, step, jitter_base)
        average_surrounding("population", x, y, step, jitter_base)
        
    values_previous = values
    #break
  
  #var count = 1
  #var nochange = 0
  #var itterations = 0
  #while count:
  #  itterations += 1
  #  if itterations > 20:
  #    break
  #var recount = close_dips("height", values_at_recursions.size() -1)
  #  if count == recount:
  #    nochange += 1
  #    if nochange > 10:
  #      break
  #  else:
  #    nochange = 0
  #  count = recount

  #find_lowpoints(values_at_recursions.size() - 1)
  close_dips(values_at_recursions.size() - 1)

  flow_downhill()
  
func get_neighbours(tile: Tile, step: int) -> Array:
  var neighbours := []
  if tile.x >= step:
    neighbours.append(coordinates[tile.x - 1][tile.y])
    if tile.y >= step:
      neighbours.append(coordinates[tile.x - 1][tile.y - step])
    if tile.y < WORLD_SIZE - step:
      neighbours.append(coordinates[tile.x - 1][tile.y + step])
  
  if tile.y >= step:
    neighbours.append(coordinates[tile.x][tile.y - step])
  if tile.y < WORLD_SIZE - step:
    neighbours.append(coordinates[tile.x][tile.y + step])
  
  if tile.x < WORLD_SIZE - step:
    neighbours.append(coordinates[tile.x + step][tile.y])
    if tile.y >= step:
      neighbours.append(coordinates[tile.x + 1][tile.y - step])
    if tile.y < WORLD_SIZE - step:
      neighbours.append(coordinates[tile.x + 1][tile.y + step])
  return neighbours

func get_neighbours_of_array(input: Array, step: int) -> Array:
  var neighbours := []
  for tile in input:
    for neighbour in get_neighbours(tile, step):
      if not neighbour in neighbours and not neighbour in input:
        neighbours.append(neighbour)
  return neighbours
  
func get_lowest_neighbour(tile: Tile, step: int, not_in: Array):
  var neighbours := get_neighbours(tile, step)
  neighbours.sort_custom(Static_Methods, "sort_tiles")
  for neighbour in neighbours:
    if not neighbour in not_in:
      return neighbour
  return

func find_lowpoints(recursion: int) -> Array:
  var lowpoints = []
  var values = get_values_at_recursion(recursion)
  var step = values[1]
  for y in range(step, WORLD_SIZE - step, step):
    for x in range(step, WORLD_SIZE - step, step):
      var neighbours = get_neighbours(coordinates[x][y], step)
      neighbours.sort_custom(Static_Methods, "sort_tiles")
      var lowest = neighbours[0]
      if coordinates[x][y].height >= SEA_LEVEL and lowest.height >= coordinates[x][y].height:
        lowpoints.append(coordinates[x][y])
        #coordinates[x][y].highlight = true
  return lowpoints

func close_dips(recursion: int) -> void:
  var values = get_values_at_recursion(recursion)
  var step = values[1]
  var lowpoints: Array = find_lowpoints(recursion)
  lowpoints.sort_custom(Static_Methods, "sort_tiles")
  while lowpoints.size():
    var lowpoint = lowpoints.pop_front()
    var area := [lowpoint]
    var candidates := get_neighbours(lowpoint, step)
    var lowest_candidate = lowpoint.height
    while true:
      #print("%s %s %s %s" % [lowpoints.size(), lowpoint, area.size(), candidates.size()])
      candidates.sort_custom(Static_Methods, "sort_tiles")
      var candidate = candidates.pop_front()
      if candidate.height < lowest_candidate:
        break
      lowest_candidate = candidate.height
      area.append(candidate)
      for neighbour in get_neighbours(candidate, step):
        if not neighbour in candidates and not neighbour in area:
          candidates.append(neighbour)

    for tile in area:
      #tile.highlight2 = true
      tile.height = lowest_candidate

func find_highpoints(property: String, recursion: int):
  var values = get_values_at_recursion(recursion)
  var step = values[1]
  var highpoints = []   
  for y in range(step, WORLD_SIZE - step, step):
    for x in range(step, WORLD_SIZE - step, step):
      var highest
      for neighbour in get_neighbours(coordinates[x][y], step):
        assert(neighbour)
        #assert(abs(neighbour.x - x) == step or abs(neighbour.y - y) == step)

        if highest == null or neighbour[property] > highest[property]:
          highest = neighbour
        
      if highest[property] < coordinates[x][y][property]:
        #coordinates[x][y].highlight = true
        highpoints.append(coordinates[x][y])

  print("highpoints %s" % [highpoints.size(),])
  return highpoints
  
func flow_downhill():
  var step = 1
  var highpoints = find_highpoints("height", values_at_recursions.size() - 1 - 3)
  highpoints.sort_custom(Static_Methods, "sort_tiles")
  assert(highpoints.front().height < highpoints.back().height)
  while highpoints.size():
    print("--------")
    var count = 10
    var tile = highpoints.pop_back()
    tile.highlight = true
    
    var failed_downhill_tile = false
    while not failed_downhill_tile and count:
      #count -= 1
      var got_downhill_tile = false
        
      var depression := [tile]
      var unflooded_depression := []
      while not got_downhill_tile and not failed_downhill_tile:
        var front := get_neighbours_of_array(depression, step)
        front.sort_custom(Static_Methods, "sort_tiles")
        var grown_depression = false
        for t in front:
          if tile.height >= t.height:
            if not t in depression:
              grown_depression = true
              depression.append(t)
              if not t.highlight:
                unflooded_depression.append(t)
                #break
        if not grown_depression:
          failed_downhill_tile = true
        
        while unflooded_depression.size():
          tile = unflooded_depression.pop_front()
          while tile.highlight:
            tile = unflooded_depression.pop_front()
            print("*")
          if tile:
            tile.highlight = true
            got_downhill_tile = true
            if tile.height <= SEA_LEVEL:
              print("!!!")
            break
        #got_downhill_tile = true
        print("%s %s %s %s %s" % [depression.size(), unflooded_depression.size(), front.size(), got_downhill_tile, failed_downhill_tile])
        
func average_corners(property: String, x: int, y: int, step: int, jitter: float):
  """ For a given (x,y) coordinate, calculate the value of the tile at (x+step,y+step). """
  if x > WORLD_SIZE - 2 * step:
    return
  if y > WORLD_SIZE - 2 * step:
    return
  
  var total = coordinates[x][y][property]
  total += coordinates[x][y + (2 * step)][property]
  total += coordinates[x + (2 * step)][y][property]
  total += coordinates[x + (2 * step)][y + (2 * step)][property]
  total /= 4
  total = clamp(total, 0, 1)
  total += rand_range(jitter, 0)
    
  coordinates[x + step][y + step][property] = total
  
func average_surrounding(property: String, x: int, y: int, step: int, jitter: float):
  """ For a given (x,y) coordinate, calculate the values of the tile at (x + step, y) and (x, y + step)."""
  var target = coordinates[x][y]
  var total_right = target[property]
  var total_below = target[property]
  var count_right = 1
  var count_below = 1
  
  if y < WORLD_SIZE - step:
    if y <= WORLD_SIZE - 2 * step:
      var right = coordinates[x][y + 2 * step]
      total_right += right[property]
      count_right += 1
    if x >= step:
      var above_right = coordinates[x - step][y + step]
      total_right += above_right[property]
      count_right += 1

  if x < WORLD_SIZE - step:
    if y < WORLD_SIZE - step:
      var below_right = coordinates[x + step][y + step]
      total_right += below_right[property]
      count_right += 1
      total_below  += below_right[property]
      count_below += 1
      
    if y >= step:
      var below_left = coordinates[x + step][y - step]
      total_below  += below_left[property]
      count_below += 1

    if x <= WORLD_SIZE - 2 * step:
      var below = coordinates[x + 2 * step][y]
      total_below  += below[property]
      count_below += 1
    
  if y < WORLD_SIZE - step:
    total_right /= count_right
    total_right += rand_range(jitter, 0)
    total_right = clamp(total_right, 0, 1)
    coordinates[x][y + step][property] = total_right
  if x < WORLD_SIZE - step:
    total_below /= count_below
    total_below += rand_range(jitter, 0)
    total_below = clamp(total_below, 0, 1)
    coordinates[x + step][y][property] = total_below  
           
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
    
    
class Static_Methods:
  static func sort_tiles(a, b):
    return a.height < b.height
