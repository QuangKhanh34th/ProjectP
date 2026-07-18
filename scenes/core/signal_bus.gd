extends Node

# Pass the entire enemy instance so listeners can read position, stats, and drop chances
signal enemy_died(enemy: Node2D)
signal enemy_exited_screen(enemy: Node2D)

signal stage_time_updated(time_in_seconds: int)
signal kill_count_updated(total_kills: int)

# --- INVENTORY SIGNAL ---
signal upgrade_collected(upgrade: UpgradeData)
