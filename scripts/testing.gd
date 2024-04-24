extends Node

signal controller_hello()

@export var controller: BuildingController

func show_meld_options(options):
	for option in options:
		print(option)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		test_solitaire()
	
func test_solitaire_logic():
	var t1 = Time.get_unix_time_from_system()
	var heights = {}
	for i in 1000:
		controller.reset()
		var dice = 216
		while dice >=6:
			dice -= 6
			var values = roll_dice()
			print("rolled %s" % values)
			var hand = find_biggest_hand(values)
			print("kept %s" % hand)
			for die in hand:
				controller.add_die_wherever(die)
		var height = controller.highest_complete_floor()
		if height not in heights:
			heights[height] = 1
		else:
			heights[height] += 1
	var t2 = Time.get_unix_time_from_system()
	print(heights)
	print("in %s seconds" %(t2-t1))
	
	

func test_solitaire():
	var values = roll_dice()
	print("rolled %s" % [values])
	var hand = find_biggest_hand(values)
	print("kept %s" % [hand])
	for die in hand:
		controller.add_die_wherever(die)
		
func test_melding():
	var values = roll_dice()
	#values = [3, 3, 4, 4, 5, 6]
	values.sort()
	print(values)
	show_meld_options(find_best_melds(values))
	print(find_biggest_hand(values))
		
	controller.test()
	# 2,3,4,5,5,6
	# 1,2,3,2,3,4 => 1,2,3 + 2,3,4. not 1,2,3,4, not 2,2 + 3,3 
	# 1,2,3,3,4,5 => 1,2,3 + 3,4,5 not 1,2,3,4,5

func remove_digit_from_run(run, digit):
	if digit not in run:
		return run
	if len(run) < 4:
		return []
	run = run.duplicate()
	run.erase(digit)
	return find_biggest_run(run)

func find_biggest_hand(values):
	var best_melds = find_best_melds(values)
	# returns an array of sets of melds
	# each meld is an array of dice
	# i.e. we have an array of arrays of arrays
	var best = []
	for melds in best_melds:
		var hand = []
		for meld in melds:
			if not meld is Array:
				print("find_biggest_hand expected Array found:")
				print(values)
				print(melds)
			hand.append_array(meld)
		if len(hand) > len(best):
			best = hand
	return best

func find_best_melds(values:Array):
	## find all the potentially-best meld options
	## others might be possible but it's not obvious why they would ever be better
	values = values.duplicate()
	values.sort()
	var sets = find_sets(values)
	var biggest_run = find_biggest_run(values)
	# check for the special case where we can make two runs
	if len(biggest_run):
		# assume we can make a 3-run, which must start at the lowest digit since we can make 2 3's
		var clone = values.duplicate()
		var smallest = values[0]
		clone.erase(smallest)
		clone.erase(smallest+1)
		clone.erase(smallest+2)
		# test if this run actually exists (i.e. we've actually removed 3 digits)
		if len(clone) == 3:
			# if so see if the remaining 3 digits make a run.
			# could do this more efficiently but this function exists already
			var sub_run = find_biggest_run(clone)
			if len(sub_run):
				return [[[smallest, smallest+1, smallest+2], sub_run]]
			
	# count total number of dice matched up
	var set_size = 0
	for meld in sets:
		set_size += len(meld)
	# if no sets we can skip a bunch of logic
	if set_size > 0:
		# if no run option, this is the best we've got
		if not len(biggest_run):
			return [sets]
		
		# if we've found 6 dice that'll do
		if set_size == 6:
			return [sets]
		
		# for 5 we can take the tiple + pair or split it up into run + pair
		# (a 5-tet wouldn't allow for a run, and a run exists)
		if set_size == 5:
			var digit = sets[0][0]
			if len(sets[0]) == 2:
				digit = sets[1][0]
			return [sets, [biggest_run, [digit, digit]]]
		
		# for a 4-dice set, since a 3-run exists we can make a  3-set + 3-run
		if len(sets[0]) == 4:
			var meld = sets[0]
			var og_meld = meld.duplicate()
			meld.pop_back()
			return [[biggest_run, meld], [og_meld]]
		
		# two pairs
		if set_size == 4:
			# if first pair is not in the run, choose between run + pair and both pairs
			if sets[0][0] not in biggest_run:
				return [[ biggest_run, sets[0]], sets]
			# similarly for the other pair
			if sets[1][0] not in biggest_run:
				return [[biggest_run, sets[1]], sets]
			
			# the run needs both pairs, if it's length 4 we can do 3-run + pair
			# (if both pairs were in the middle of the run, we could make two 3-runs
			# and that case is covered earlier)
			# so find which of the runs is on the edge
			if len(biggest_run) == 4:
				var output = [sets]
				var sub_run = null
				for digit in [sets[0][0], sets[1][0]]:
					sub_run = remove_digit_from_run(biggest_run, digit)
					if len(sub_run):
						output.append([[digit, digit], sub_run])
				return output
			
			# otherwise we can take the run or both pairs
			return [sets, [biggest_run]]
		
		if set_size == 3:
			# if set is outside the run, take them separately
			if sets[0][0] not in biggest_run:
				return [[biggest_run, sets[0]]]
			# otherwise give up one of the set
			sets[0].pop_back()
			return [[biggest_run, sets[0]]]
		
		# just a pair
		if set_size == 2:
			# if it's outside the run we take both
			if sets[0][0] not in biggest_run:
				return [[sets[0], biggest_run]]
			# else we have to choose between the pair, the whole run and the pair + best sub-run 
			# find the best run that can be made once we remove the pair
			var sub_run = biggest_run.duplicate()
			for i in len(sub_run):
				if sub_run[i] == sets[0][0]:
					sub_run.remove_at(i)
					break
			sub_run = find_biggest_run(sub_run)
			
			# if the sub-run is 4-length then we get all 6 dice this way, no contest
			if len(sub_run) == 4:
				return [[sub_run, sets[0]]]
				
			# if there exists a run, combine it with the pair into one solution
			var best_combo = [sets[0]]
			if len(sub_run):
				best_combo.append(sub_run)
			# return the best run alone, plus the pair + best remaining as an option
			return [[biggest_run], best_combo]
				
	# no set, so the run is best
	return [biggest_run]
	
	
func find_sets(values: Array):
	# find the pairs/triples etc in the values array
	var melds = []
	if len(values) < 2:
		return melds
	values = values.duplicate()
	values.sort()
	while len(values):
		var face = values.pop_front()
		var meld = [face]
		var count = values.count(face)
		if count:
			for i in count:
				meld.append(values.pop_front())
			melds.append(meld)
	return melds

func find_biggest_run(values) -> Array:
	if len(values) < 3:
		return []
	# check 1-4 for being the first in the run
	for starting_face in range(1,5):
		# if it's not there, try the next
		if starting_face not in values:
			continue
		# test each face after this one
		for next_face in range(starting_face+1, 8):
			# if it's present, great
			if next_face in values:
				continue
			# otherwise run is finished - next_face isn't present
			# so for a run of 3 it should be 3 higher than the first digit
			# (n, n+1, n+2 are the run, n+3 is not in it)
			if next_face - starting_face <3:
				break
			# no run that doesn't start where this one does can be longer
			# since this is at least 3 faces, a 4-face run would have to include
			# at least one of this run's digits, so it could contain them all
			return range(starting_face, next_face)
	return []	
	
func roll_dice():
	var values = [0, 0, 0, 0, 0, 0]
	for i in 6:
		values[i] = randi_range(1, 6)
	return values
