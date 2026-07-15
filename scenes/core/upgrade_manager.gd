# Upgrade Manager
# Holding the master database of all possible weapons and 
# passive items in the game.
# Tracking what the player currently owns and what level those items are.
#
# Checking inventory constraints (e.g., stopping new weapon 
# generation if the player already has 6 weapons).
#
# Running weighted RNG algorithm to generate the 3 upgrade choices.

extends Node

# In the Godot Inspector, drag all upgrade .tres files into this array
@export var all_upgrades: Array[UpgradeData] = []

# This tracks what the player currently owns during the run
var collected_upgrades: Array[UpgradeData] = []

func get_upgrade_options(amount: int = 3) -> Array[UpgradeData]:
	var valid_pool: Array[Dictionary] = []
	var total_weight: int = 0
	
	for upgrade in all_upgrades:
		# 1. Skip if the player already collected this exact level
		if upgrade in collected_upgrades:
			continue
			
		# 2. Check Prerequisites: If it has a prereq, do we own it?
		if upgrade.prerequisite != null and not upgrade.prerequisite in collected_upgrades:
			continue
			
		# 3. Assign weights. Favor upgrades over brand new Level 1 items
		var weight := 10 # Default weight for a brand new item
		if upgrade.prerequisite != null:
			weight = 40 # 4x MORE LIKELY to appear if it's an upgrade to an existing item
			
		valid_pool.append({"resource": upgrade, "weight": weight})
		total_weight += weight
		
	# 4. Draw unique options without replacement (no duplicates on the same screen)
	var chosen_options: Array[UpgradeData] = []
	for i in range(amount):
		if valid_pool.is_empty():
			print("[upgrade_manager] no valid upgrade")
			break
		
		print("[upgrade_manager] upgrades pool", valid_pool)
		var random_num := randi_range(1, total_weight)
		var current_sum := 0
		
		for j in range(valid_pool.size()):
			var item: Dictionary = valid_pool[j]
			current_sum += item["weight"]
			
			if random_num <= current_sum:
				chosen_options.append(item["resource"])
				# Remove from the temporary pool so we don't pick the exact same card twice
				total_weight -= item["weight"]
				valid_pool.remove_at(j)
				break
				
	return chosen_options
