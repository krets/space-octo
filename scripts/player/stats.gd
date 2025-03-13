extends Resource
class_name PlayerStats

@export var thrust_speed : float = 500
@export var brake_speed : float = 250
@export var turn_rate : float = 3.0
@export var max_speed : float = 900 
@export var max_health : float = 200
@export var health : float = 100
@export var weapon_cooldown : float = 0.2
@export var weapon_damage : float = 10.0
@export var max_weapon_damage : float = 100.0


@export var shield_size_empty : float = 14.0
@export var shield_size_min : float = 32.0
@export var shield_display_min : float = 25.0 
@export var shield_grow_size : float = 120.0
@export var shield_grow_threshold : float = max_health/2

@export var fuel : float = 0.0
@export var max_fuel : float = 500.0

@export var points_blue : int = 0
@export var points_orange : int = 0
@export var points_yellow : int = 0
