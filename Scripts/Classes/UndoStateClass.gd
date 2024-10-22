class_name UndoState
extends Resource

var player_snake : Array[Vector2] = [Vector2.ZERO]
var player_powered : bool = false
var player_charge : int = 1
var power_blocks : Array[Vector2] = []
var wires : Array[WireBlockState] = []
var power_orbs : Array[Vector2] = []
var door_power_states : Array[bool] = []
var door_solid_states : Array[bool] = []
