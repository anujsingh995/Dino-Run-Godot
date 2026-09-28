extends Node

var ground_height: int
var stump_scene = preload("res://stump.tscn")
var baral_scene = preload("res://baral.tscn")
var stone_scene = preload("res://stone.tscn")
var bird_scene = preload("res://bird.tscn")
var obstacles_type = [stump_scene, baral_scene, stone_scene]
var obstacles = []
var bird_heights = [260, 370]

const DINO_START_POS = Vector2(150, 485)
const CAM_START_POS = Vector2(576, 324)
var difficulty
const MAX_DIFFICULTY: int = 2
var score: int
const SCORE_MODIFIER: int = 2
var high_score: int 
var speed: float = 10.0
const START_SPEED: float = 10.0

const SPEED_INCREMENT: float = 0.1
const SPEED_MODIFIER: int = 5000
var screen_size: Vector2
var game_runing: bool
var last_obs

func _ready():
	screen_size = get_viewport().size
	ground_height = $ground.get_node("Sprite").texture.get_height()
	
	new_game()

func new_game():
	print("YOU LOOSE")
	print("Starting new game...")
	score = 0
	show_score()
	game_runing = false
	get_tree().paused = false
	difficulty = 0
	
	# Clear old obstacles
	for obs in obstacles:
		obs.queue_free()
		obstacles.clear()

	# Reset positions
	$dino.position = DINO_START_POS
	$dino.motion = Vector2(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2(0, 0)

	# Reset HUD and speed
	$HUD.get_node("press").show()
	speed = START_SPEED
	

func _process(_delta):
	if game_runing:
		speed = START_SPEED + score / SPEED_MODIFIER
		adjust_difficulty()
		generate_obs()

		# Move dino and camera
		$dino.position.x += speed 
		$Camera2D.position.x += speed 

		score += speed 
		show_score()

		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.5:
			$ground.position.x += screen_size.x

		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_up"):
			game_runing = true
			$HUD.get_node("press").hide()
func generate_obs():
	# Check if it's time to spawn new obstacles
	if obstacles.empty() or (last_obs and last_obs.position.x < $Camera2D.position.x - screen_size.x / 2):
		var obs_type = obstacles_type[randi() % obstacles_type.size()]
		var max_obs = 2  # Limit to a maximum of 2 obstacles in a pair
		var spacing_within_pair = 100  # Reduced spacing between obstacles in a pair

		for i in range(randi() % max_obs + 1):  # Spawn up to `max_obs` obstacles
			var obs = obs_type.instance()
			var obs_height = obs.get_node("Sprite").texture.get_height()
			var obs_scale = obs.get_node("Sprite").scale

			# Reduced spacing between obstacles
			var obs_x = $Camera2D.position.x + screen_size.x + (i * spacing_within_pair)
			var obs_y = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			obs_y = max(obs_y, screen_size.y - ground_height - 20)

			last_obs = obs
			add_obs(obs, obs_x, obs_y)

		# Add a bird obstacle if difficulty is 1
		if difficulty == MAX_DIFFICULTY:
			if randi() % 2 == 0:
				var bird = bird_scene.instance()
				var bird_x = screen_size.x + score + 100
				var bird_y = bird_heights[randi() % bird_heights.size()]
				add_obs(bird, bird_x, bird_y)

				
func add_obs(obs, x, y):
	obs.position = Vector2(x, y)
	if obs.has_signal("body_entered"):
		obs.connect("body_entered", self, "_on_obs_hit")
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func _on_obs_hit(body):
	if body.name == "dino":
		game_over()
func show_score():
	$HUD.get_node("score label").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
	
func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score() 
	get_tree().paused = true
	game_runing = false
	get_tree().reload_current_scene()
	
func _on_Button_pressed():
	get_tree().reload_current_scene()
	
