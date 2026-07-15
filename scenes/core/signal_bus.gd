extends Node

# Pass the entire enemy instance so listeners can read position, stats, and drop chances
signal enemy_died(enemy: Node2D)
signal enemy_exited_screen(enemy: Node2D)
