extends Node

class_name Tile

var height: float
var population: float
var x: int
var y: int
var updated := false
var highlight := false

func _init(_x: int, _y: int):
  x = _x
  y = _y
