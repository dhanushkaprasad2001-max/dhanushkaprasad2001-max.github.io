extends Node3D
const PORT := 27015
const MAX_PLAYERS := 50
const MAP_SIZE := 220.0
var local_player: CharacterBody3D
var players: Dictionary = {}
var hud: CanvasLayer
var status_label: Label
var population_label: Label
var roster_label: Label
var address_input: LineEdit
var match_started := false
var safe_radius := 95.0
var safe_timer := 0.0
var match_time_remaining := 600.0
var match_clock_tick := 0.0
var match_finished := false
var match_hud_label: Label
var spectator_camera: Camera3D
var spectator_target_id := 0
var spectator_label: Label
var match_result_label: Label
var menu_root: Control
var profile_name := "Player"
var selected_language := "English"
var master_volume := 0.8
var music_volume := 0.7
var sfx_volume := 0.8
var graphics_quality := 1
var game_started := false
var selected_mode := "Solo"
var match_type := "Battle Royale"
var selected_game_mode := "Battle Royale"
var selected_submode := "Solo"
var ranked_points := 0
var ranked_tier := "RECRUIT"
var target_players := 50
var custom_room_code := ""
var server_address := ""
var party_members: Array[String] = []
var friend_names: Array[String] = []
var player_level := 1
var player_xp := 0
var player_id := ""
var career_matches := 0
var career_wins := 0
var career_kills := 0
var career_deaths := 0
var career_damage := 0
var career_best_kills := 0
var career_coins := 0
var match_history: Array = []
var unlocked_achievements: Array = []
var daily_login_date := ""
var daily_mission_date := ""
var daily_mission_matches := 0
var daily_mission_kills := 0
var daily_mission_damage := 0
var daily_mission_wins := 0
var daily_mission_loot := 0
var daily_claimed: Array[String] = []
var daily_match_claimed := false
var daily_kill_claimed := false
var career_result_saved := false
var camera_yaw := 0.0
var camera_pitch := -0.12
var look_sensitivity := 0.004
var sprint_enabled := false
var crouch_enabled := false
var normal_speed := 6.0
var sprint_speed := 9.0
var crouch_speed := 3.0
var weapon_names := ["ASSAULT RIFLE", "SMG", "SHOTGUN"]
var weapon_damage := [25.0, 15.0, 65.0]
var weapon_mag_sizes := [30, 40, 8]
var weapon_reserve := [120, 160, 40]
var weapon_fire_delays := [0.12, 0.075, 0.8]
var weapon_ranges := [120.0, 75.0, 35.0]
var weapon_spread := [0.012, 0.025, 0.09]
var current_weapon := 0
var ammo_in_mag := 30
var reserve_ammo := 120
var fire_cooldown := 0.0
var is_reloading := false
var reload_timer := 0.0
var weapon_hud_label: Label
var ammo_hud_label: Label
var crosshair_label: Label
var weapon_visual: Node3D
var last_hit_name := ""
var loot_nodes: Array[Node3D] = []
var training_targets: Array[CharacterBody3D] = []
var training_hits := 0
var training_target_count := 6
var nearby_loot: Node3D
var health := 100.0
var armor := 0.0
var medkit_count := 1
var inventory_label: Label
var pickup_button: Button
var health_bar: ProgressBar
var armor_bar: ProgressBar
var is_dead := false
var respawn_timer := 0.0
var zone_damage_timer := 0.0
var damage_flash_timer := 0.0
var is_dropping := false
var parachute_visual: Node3D
var drop_status_label: Label
var drop_elapsed := 0.0
var network_send_timer := 0.0
var connection_timeout_timer := 0.0
const CONNECTION_TIMEOUT_SECONDS := 15.0
var server_player_states: Dictionary = {}
var server_match_roster: Dictionary = {}
var last_server_position: Dictionary = {}
var server_position_time: Dictionary = {}
var server_position_last_packet_time: Dictionary = {}
var server_last_shot_time: Dictionary = {}
var server_player_health: Dictionary = {}
var server_player_kills: Dictionary = {}
var server_player_deaths: Dictionary = {}
var server_player_damage: Dictionary = {}
var server_player_armor: Dictionary = {}
var server_player_medkits: Dictionary = {}
var server_player_ready: Dictionary = {}
var lobby_countdown := -1.0
var lobby_last_broadcast_second := -1
var lobby_status_label: Label
var ready_button: Button
var local_player_ready := false
var server_zone_damage_timer := 0.0
var server_player_teams: Dictionary = {}
var server_eliminated: Dictionary = {}
var kill_feed_entries: Array[String] = []
var server_match_mode := ""
var server_match_queue := ""
var server_match_had_multiple_players := false
var local_team_id := 0
var team_hud_label: Label
var elimination_count := 0
var server_loot_taken: Dictionary = {}
var kill_feed_label: Label
var vehicle_nodes: Array[CharacterBody3D] = []
var active_vehicle: CharacterBody3D
var in_vehicle := false
var vehicle_speed := 0.0
var vehicle_status_label: Label
var server_vehicle_drivers: Dictionary = {}
var server_vehicle_update_time: Dictionary = {}
var server_vehicle_controls: Dictionary = {}
var server_vehicle_speeds: Dictionary = {}
var server_vehicle_health: Dictionary = {}
var server_vehicle_destroyed: Dictionary = {}
var network_test_target_id := 0
var network_test_damage_received := false
var network_test_spawn_received := false
var capacity_test_spawned := false
var capacity_test_rejected := false
var capacity_test_population := 0
var vehicle_sync_timer := 0.0
# LAST ZONE original character, cosmetics and armory systems
var owned_bundles: Array[String] = ["FIELD OPERATIVE"]
var equipped_bundle := "FIELD OPERATIVE"
var selected_character := "KAIRO"
var owned_characters: Array[String] = ["KAIRO", "NYX"]
var selected_gender := "MALE"
var emote_wheel_open := false
var emote_animation_busy := false
var selected_skill := "BULWARK PULSE"
var equipped_passive_skills: Array[String] = ["QUICK HANDS", "FIELD MEDIC", "SCAVENGER"]
var passive_slot_cursor := 0
var skill_regen_rate := 0.0
var skill_speed_bonus := 0.0
var skill_reload_bonus := 0.0
var owned_emotes: Array[String] = ["SALUTE"]
var equipped_emote := "SALUTE"
var owned_gloo_skins: Array[String] = ["TACTICAL BLUE"]
var equipped_gloo_skin := "TACTICAL BLUE"
var weapon_upgrade_levels: Dictionary = {"ASSAULT RIFLE": 0, "SMG": 0, "SHOTGUN": 0}
var skill_cooldown := 0.0
var skill_duration := 0.0
var skill_active := false
var skill_button: Button
var emote_status_label: Label
var gloo_wall_charges := 2
var gloo_wall_button: Button

func _ready() -> void:
	var user_args := OS.get_cmdline_user_args()
	var engine_args := OS.get_cmdline_args()
	if "--self-test" in user_args:
		_run_project_self_test()
		return
	if "--network-test-client" in user_args:
		_run_network_test_client()
		return
	if "--capacity-test-client" in user_args:
		_run_capacity_test_client()
		return
	# Dedicated-server exports carry this feature tag. Keep explicit CLI flags
	# too, so the editor/headless development server remains easy to launch.
	if OS.has_feature("dedicated_server") or "--server" in user_args or "--server" in engine_args:
		_build_island()
		_build_loot_spawns()
		_start_server()
		return
	_setup_input()
	_load_local_settings()
	_ensure_audio_buses()
	_apply_audio_settings()
	_build_menu()
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _process(delta: float) -> void:
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	if skill_cooldown > 0.0:
		skill_cooldown = maxf(0.0, skill_cooldown - delta)
	if skill_active and skill_duration > 0.0:
		skill_duration = maxf(0.0, skill_duration - delta)
		if skill_regen_rate > 0.0 and health < 100.0 and not is_dead:
			health = minf(100.0, health + skill_regen_rate * delta)
		if skill_duration <= 0.0:
			skill_active = false
			skill_regen_rate = 0.0
			skill_speed_bonus = 0.0
			skill_reload_bonus = 0.0
			sprint_speed = 9.0
	if skill_button:
		skill_button.text = selected_skill + " (" + str(ceili(skill_cooldown)) + "s)"
		skill_button.disabled = skill_cooldown > 0.0 or local_player == null
	if connection_timeout_timer > 0.0:
		connection_timeout_timer = maxf(0.0, connection_timeout_timer - delta)
		if connection_timeout_timer <= 0.0 and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
			multiplayer.multiplayer_peer.close()
			multiplayer.multiplayer_peer = null
			if status_label:
				status_label.text = "Connection timed out after 15 seconds. Check the server IP and UDP port, then press CONNECT to retry."
	if is_dead and respawn_timer > 0.0:
		respawn_timer -= delta
		if status_label:
			status_label.text = "TRAINING  •  RESPAWNING IN " + str(maxi(0, ceili(respawn_timer)))
		if respawn_timer <= 0.0:
			_respawn_player()
	_update_survival(delta)
	_update_spectator_camera()
	if damage_flash_timer > 0.0:
		damage_flash_timer = maxf(0.0, damage_flash_timer - delta)
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0.0:
			_finish_reload()
	if weapon_hud_label:
		weapon_hud_label.text = weapon_names[current_weapon]
	if ammo_hud_label:
		ammo_hud_label.text = str(ammo_in_mag) + " / " + str(reserve_ammo)
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if local_player and not multiplayer.is_server():
			network_send_timer += delta
			if network_send_timer >= 0.1:
				network_send_timer = 0.0
				if in_vehicle and is_instance_valid(active_vehicle):
					var throttle_input := 0.0
					if Input.is_action_pressed("move_forward"):
						throttle_input += 1.0
					if Input.is_action_pressed("move_back"):
						throttle_input -= 0.65
					var steering_input := 0.0
					if Input.is_action_pressed("move_left"):
						steering_input += 1.0
					if Input.is_action_pressed("move_right"):
						steering_input -= 1.0
					rpc_id(1, "request_vehicle_update", vehicle_nodes.find(active_vehicle), throttle_input, steering_input, Input.is_action_pressed("vehicle_brake"))
				else:
					rpc_id(1, "server_update_position", local_player.global_position, wrapf(local_player.rotation.y + camera_yaw, -PI, PI))
	if multiplayer.is_server() and not match_started and lobby_countdown >= 0.0:
		lobby_countdown = maxf(0.0, lobby_countdown - delta)
		var countdown_second := ceili(lobby_countdown)
		if countdown_second != lobby_last_broadcast_second:
			lobby_last_broadcast_second = countdown_second
			_broadcast_lobby_status()
		if lobby_countdown <= 0.0 and _server_all_players_ready():
			match_started = true
			match_finished = false
			lobby_countdown = -1.0
			server_player_ready.clear()
			server_player_kills.clear()
			server_player_deaths.clear()
			server_player_damage.clear()
			server_loot_taken.clear()
			server_eliminated.clear()
			server_last_shot_time.clear()
			server_zone_damage_timer = 0.0
			for peer_variant in server_player_states.keys():
				var stat_peer := int(peer_variant)
				server_player_kills[stat_peer] = 0
				server_player_deaths[stat_peer] = 0
				server_player_damage[stat_peer] = 0.0
			match_time_remaining = 600.0
			match_clock_tick = 0.0
			safe_timer = 0.0
			safe_radius = 95.0
			_broadcast_lobby_status()
		elif lobby_countdown <= 0.0:
			lobby_countdown = -1.0
			lobby_last_broadcast_second = -1
			_broadcast_lobby_status()
	if multiplayer.is_server() and match_started and not match_finished:
		server_zone_damage_timer += delta
		if server_zone_damage_timer >= 1.0:
			server_zone_damage_timer = 0.0
			_server_apply_zone_damage()
		match_time_remaining = maxf(0.0, match_time_remaining - delta)
		match_clock_tick += delta
		safe_timer += delta
		if safe_timer >= 60.0:
			safe_timer = 0.0
			safe_radius = maxf(15.0, safe_radius - 8.0)
		if match_clock_tick >= 1.0:
			match_clock_tick = 0.0
			var alive_count := _server_alive_player_count()
			if match_time_remaining <= 0.0 or (server_match_had_multiple_players and _server_alive_team_count() <= 1):
				match_finished = true
				var winner_id := _server_last_alive_player()
				rpc("update_match_clock", 0 if match_time_remaining <= 0.0 else ceili(match_time_remaining), safe_radius, true, alive_count)
				_server_broadcast_match_result(winner_id, "LAST PLAYER STANDING" if winner_id > 0 else "TIME LIMIT REACHED")
			else:
				rpc("update_match_clock", ceili(match_time_remaining), safe_radius, false, alive_count)

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_server_update_vehicles(delta)
	if local_player and hud:
		var coordinate_label := hud.find_child("MapCoordinates", true, false) as Label
		if coordinate_label:
			coordinate_label.text = "POSITION: " + str(roundi(local_player.global_position.x)) + ", " + str(roundi(local_player.global_position.z))
	if local_player == null or is_dead:
		return
	if is_dropping:
		_update_air_drop(delta)
		return
	_update_nearby_loot()
	if Input.is_action_just_pressed("pickup"):
		_pickup_nearby_loot()
	if Input.is_action_just_pressed("use_medkit"):
		_use_medkit()
	if Input.is_action_just_pressed("vehicle_interact"):
		_toggle_vehicle()
	if in_vehicle:
		_drive_vehicle(delta)
		return
	var direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1.0
	if Input.is_action_pressed("move_back"):
		direction.z += 1.0
	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("move_right"):
		direction.x += 1.0
	direction = direction.normalized()
	var camera := local_player.get_node_or_null("CameraPivot/Camera3D") as Camera3D
	var move := Vector3.ZERO
	if camera:
		var forward := -camera.global_basis.z
		var right := camera.global_basis.x
		move = right * direction.x + forward * -direction.z
		move.y = 0.0
		move = move.normalized()
	else:
		move = direction
	var speed := normal_speed + (0.5 if equipped_passive_skills.has("SPRINTER") else 0.0) + skill_speed_bonus
	if crouch_enabled:
		speed = crouch_speed
	elif sprint_enabled:
		speed = sprint_speed + (0.5 if equipped_passive_skills.has("SPRINTER") else 0.0) + skill_speed_bonus
	local_player.velocity.x = move.x * speed
	local_player.velocity.z = move.z * speed
	if not local_player.is_on_floor():
		local_player.velocity.y -= 22.0 * delta
	else:
		local_player.velocity.y = -0.2
	if Input.is_action_just_pressed("weapon_1"):
		_equip_weapon(0)
	if Input.is_action_just_pressed("weapon_2"):
		_equip_weapon(1)
	if Input.is_action_just_pressed("weapon_3"):
		_equip_weapon(2)
	if Input.is_action_just_pressed("reload"):
		_start_reload()
	if Input.is_action_just_pressed("jump") and local_player.is_on_floor() and not crouch_enabled:
		local_player.velocity.y = 7.0
	local_player.move_and_slide()
	if move.length() > 0.05:
		local_player.rotation.y = atan2(-move.x, -move.z)
	var visual := local_player.get_node_or_null("CharacterVisual") as Node3D
	if visual:
		visual.scale.y = 0.72 if crouch_enabled else 1.0
		_update_operator_motion(visual, move.length() > 0.05, delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		_fire_weapon()
	if local_player == null:
		return
	if event is InputEventScreenDrag:
		_rotate_player_camera(event.relative)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_rotate_player_camera(event.relative)


func _rotate_player_camera(delta_position: Vector2) -> void:
	var pivot := local_player.get_node_or_null("CameraPivot") as Node3D
	if pivot == null:
		return
	pivot.rotation.y -= delta_position.x * look_sensitivity
	pivot.rotation.x = clampf(pivot.rotation.x - delta_position.y * look_sensitivity, -0.85, 0.35)
	camera_yaw = pivot.rotation.y
	camera_pitch = pivot.rotation.x


func _setup_input() -> void:
	_add_action("move_forward", KEY_W)
	_add_action("move_back", KEY_S)
	_add_action("move_left", KEY_A)
	_add_action("move_right", KEY_D)
	_add_action("jump", KEY_SPACE)
	_add_action("fire", KEY_F)
	_add_action("reload", KEY_R)
	_add_action("weapon_1", KEY_1)
	_add_action("weapon_2", KEY_2)
	_add_action("weapon_3", KEY_3)
	_add_action("pickup", KEY_E)
	_add_action("use_medkit", KEY_H)
	_add_action("vehicle_interact", KEY_G)
	_add_action("vehicle_brake", KEY_B)

func _add_action(action: String, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)

func _build_island() -> void:
	# Island terrain and surrounding ocean
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(MAP_SIZE, MAP_SIZE)
	ground.mesh = plane
	ground.position.y = -0.6
	ground.material_override = _material(Color(0.20, 0.31, 0.17))
	add_child(ground)
	var ground_body := StaticBody3D.new()
	ground_body.name = "IslandGroundCollision"
	ground_body.position = Vector3(0, -1.1, 0)
	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(MAP_SIZE, 1.0, MAP_SIZE)
	ground_collision.shape = ground_shape
	ground_body.add_child(ground_collision)
	add_child(ground_body)
	var water := MeshInstance3D.new()
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(650, 650)
	water.mesh = water_mesh
	water.position.y = -1.15
	water.material_override = _material(Color(0.025, 0.19, 0.25))
	add_child(water)
	# Main roads crossing the island
	_add_map_box(Vector3(0, -0.35, 0), Vector3(12, 0.35, 205), Color(0.20, 0.20, 0.18), false)
	_add_map_box(Vector3(0, -0.34, 0), Vector3(205, 0.36, 10), Color(0.22, 0.22, 0.19), false)
	_add_map_box(Vector3(-48, -0.32, 42), Vector3(8, 0.38, 76), Color(0.24, 0.23, 0.20), false)
	_add_map_box(Vector3(48, -0.32, -42), Vector3(8, 0.38, 76), Color(0.24, 0.23, 0.20), false)
	# Creek and crossing bridge
	_add_map_box(Vector3(0, -0.48, 68), Vector3(200, 0.12, 5), Color(0.04, 0.27, 0.39), false)
	_add_map_box(Vector3(0, -0.18, 68), Vector3(16, 0.55, 8), Color(0.40, 0.34, 0.25), false)
	# Named map districts with distinct building clusters
	_add_map_building(Vector3(-58, 0, -52), Vector3(12, 7, 10), Color(0.48, 0.38, 0.29))
	_add_map_building(Vector3(-42, 0, -48), Vector3(10, 6, 12), Color(0.55, 0.48, 0.36))
	_add_map_building(Vector3(-52, 0, -32), Vector3(9, 5, 9), Color(0.38, 0.43, 0.42))
	_add_map_building(Vector3(42, 0, -58), Vector3(16, 9, 13), Color(0.38, 0.42, 0.46))
	_add_map_building(Vector3(62, 0, -42), Vector3(11, 6, 11), Color(0.50, 0.42, 0.34))
	_add_map_building(Vector3(48, 0, -28), Vector3(12, 6, 9), Color(0.43, 0.47, 0.40))
	_add_map_building(Vector3(-65, 0, 42), Vector3(13, 7, 12), Color(0.49, 0.40, 0.31))
	_add_map_building(Vector3(-46, 0, 52), Vector3(10, 5, 10), Color(0.43, 0.45, 0.39))
	_add_map_building(Vector3(48, 0, 42), Vector3(14, 8, 12), Color(0.42, 0.43, 0.47))
	_add_map_building(Vector3(66, 0, 58), Vector3(10, 5, 12), Color(0.53, 0.44, 0.33))
	# Small service buildings and cover around the centre
	for i in range(8):
		var px := -30.0 + float(i % 4) * 20.0
		var pz := -20.0 + float(i / 4) * 40.0
		_add_map_building(Vector3(px, 0, pz), Vector3(7, 4, 7), Color(0.36, 0.39, 0.34))
	# Forests, rocks and low hills
	for i in range(68):
		var x := randf_range(-96, 96)
		var z := randf_range(-96, 96)
		if absf(x) < 13 or absf(z) < 11 or (absf(x) < 24 and absf(z) < 24):
			continue
		_add_map_tree(Vector3(x, 0, z))
	for i in range(18):
		var rock := MeshInstance3D.new()
		var rock_mesh := SphereMesh.new()
		rock_mesh.radius = randf_range(1.0, 2.8)
		rock_mesh.height = rock_mesh.radius * 1.3
		rock.mesh = rock_mesh
		rock.position = Vector3(randf_range(-96, 96), rock_mesh.radius * 0.35, randf_range(-96, 96))
		rock.material_override = _material(Color(0.30, 0.32, 0.31))
		add_child(rock)
	# Landmark towers help players recognise the island
	_add_map_box(Vector3(0, 5, -82), Vector3(5, 10, 5), Color(0.33, 0.36, 0.38), true)
	_add_map_box(Vector3(0, 10.5, -82), Vector3(8, 1, 8), Color(0.72, 0.30, 0.15), false)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.15
	add_child(sun)
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.48, 0.58, 0.66)
	environment.ambient_light_energy = 0.65
	env.environment = environment
	add_child(env)
	_spawn_vehicles()


func _add_map_box(pos: Vector3, dimensions: Vector3, tint: Color, solid: bool) -> void:
	var holder: Node3D
	if solid:
		var body := StaticBody3D.new()
		body.position = pos
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = dimensions
		collision.shape = shape
		body.add_child(collision)
		holder = body
	else:
		holder = Node3D.new()
		holder.position = pos
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	visual.material_override = _material(tint)
	holder.add_child(visual)
	add_child(holder)


func _add_map_building(pos: Vector3, dimensions: Vector3, tint: Color) -> void:
	_add_map_box(pos + Vector3(0, dimensions.y * 0.5, 0), dimensions, tint, true)
	var roof := MeshInstance3D.new()
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(dimensions.x + 0.8, 0.7, dimensions.z + 0.8)
	roof.mesh = roof_mesh
	roof.position = pos + Vector3(0, dimensions.y + 0.35, 0)
	roof.material_override = _material(Color(0.22, 0.24, 0.25))
	add_child(roof)


func _add_map_tree(pos: Vector3) -> void:
	var trunk := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.18
	cylinder.bottom_radius = 0.28
	cylinder.height = 3.2
	trunk.mesh = cylinder
	trunk.position = pos + Vector3(0, 1.0, 0)
	trunk.material_override = _material(Color(0.22, 0.13, 0.07))
	add_child(trunk)
	var crown := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.55
	sphere.height = 3.0
	crown.mesh = sphere
	crown.position = pos + Vector3(0, 3.0, 0)
	crown.material_override = _material(Color(0.08, 0.22 + randf() * 0.12, 0.10))
	add_child(crown)
func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	return material

func _create_player(peer_id: int, is_local: bool) -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.name = "Player_" + str(peer_id)
	body.position = Vector3(randf_range(-12, 12), 2, randf_range(-12, 12))
	var collision := CollisionShape3D.new()
	collision.name = "PlayerCollision"
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	collision.shape = capsule
	body.add_child(collision)
	var character := Node3D.new()
	character.name = "CharacterVisual"
	body.add_child(character)
	_build_operator_visual(character, is_local, selected_gender if is_local else "MALE")
	if is_local:
		var pivot := Node3D.new()
		pivot.name = "CameraPivot"
		pivot.position = Vector3(0, 1.35, 0)
		pivot.rotation.x = camera_pitch
		body.add_child(pivot)
		var camera := Camera3D.new()
		camera.name = "Camera3D"
		camera.position = Vector3(0, 2.4, 6.8)
		camera.current = true
		camera.fov = 75.0
		pivot.add_child(camera)
	if is_local:
		_create_weapon_visual(body)
	add_child(body)
	players[peer_id] = body
	return body


func _add_character_part(parent: Node3D, part_name: String, pos: Vector3, dimensions: Vector3, tint: Color, use_sphere: bool = false) -> void:
	var part := MeshInstance3D.new()
	part.name = part_name
	if use_sphere:
		var sphere := SphereMesh.new()
		sphere.radius = maxf(dimensions.x, maxf(dimensions.y, dimensions.z)) * 0.5
		sphere.height = dimensions.y
		part.mesh = sphere
	else:
		var box := BoxMesh.new()
		box.size = dimensions
		part.mesh = box
	part.position = pos
	part.material_override = _material(tint)
	parent.add_child(part)

func _create_local_player() -> void:
	local_player = _create_player(1, true)
	local_player.position = Vector3(0, 2, 0)
	armor = 10.0 if equipped_passive_skills.has("FORTIFIED") else 0.0
	_apply_equipped_bundle()

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size = Vector2(360, 150)
	hud.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var title := Label.new()
	title.text = "LAST ZONE  //  BATTLE ROYALE"
	title.add_theme_font_size_override("font_size", 20)
	column.add_child(title)
	status_label = Label.new()
	status_label.text = "Not connected"
	column.add_child(status_label)
	population_label = Label.new()
	population_label.text = "PLAYERS: 0 / 50  •  REAL PLAYERS ONLY"
	population_label.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0))
	column.add_child(population_label)
	roster_label = Label.new()
	roster_label.text = "PLAYER ROSTER\nWaiting for real players..."
	roster_label.add_theme_font_size_override("font_size", 12)
	roster_label.add_theme_color_override("font_color", Color(0.78, 0.86, 0.9))
	column.add_child(roster_label)
	team_hud_label = Label.new()
	team_hud_label.text = "TEAM: WAITING FOR SERVER"
	team_hud_label.add_theme_color_override("font_color", Color(0.35, 0.95, 0.83))
	column.add_child(team_hud_label)
	match_result_label = Label.new()
	match_result_label.position = Vector2(420, 190)
	match_result_label.custom_minimum_size = Vector2(430, 150)
	match_result_label.text = ""
	hud.add_child(match_result_label)
	spectator_label = Label.new()
	spectator_label.position = Vector2(420, 235)
	spectator_label.custom_minimum_size = Vector2(300, 36)
	spectator_label.text = ""
	hud.add_child(spectator_label)
	var spectator_button := Button.new()
	spectator_button.text = "NEXT SPECTATOR"
	spectator_button.position = Vector2(420, 275)
	spectator_button.pressed.connect(_cycle_spectator_target)
	hud.add_child(spectator_button)
	match_hud_label = Label.new()
	match_hud_label.text = "MATCH 10:00  •  SAFE ZONE 95m"
	match_hud_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
	column.add_child(match_hud_label)
	kill_feed_label = Label.new()
	kill_feed_label.text = "KILL FEED\nNo eliminations yet"
	kill_feed_label.add_theme_font_size_override("font_size", 12)
	kill_feed_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.58))
	column.add_child(kill_feed_label)
	var row := HBoxContainer.new()
	column.add_child(row)
	address_input = LineEdit.new()
	address_input.placeholder_text = "Dedicated server IP address"
	address_input.text = server_address
	address_input.custom_minimum_size = Vector2(190, 42)
	row.add_child(address_input)
	var connect_button := Button.new()
	connect_button.text = "CONNECT"
	connect_button.pressed.connect(_connect_to_server)
	row.add_child(connect_button)
	var help := Label.new()
	help.text = "WASD: Move   SPACE: Jump   F: Fire"
	column.add_child(help)
	health_bar = ProgressBar.new()
	health_bar.position = Vector2(18, 125)
	health_bar.custom_minimum_size = Vector2(260, 18)
	health_bar.max_value = 100
	health_bar.value = health
	health_bar.show_percentage = false
	hud.add_child(health_bar)
	armor_bar = ProgressBar.new()
	armor_bar.position = Vector2(18, 147)
	armor_bar.custom_minimum_size = Vector2(260, 12)
	armor_bar.max_value = 100
	armor_bar.value = armor
	armor_bar.show_percentage = false
	hud.add_child(armor_bar)
	var map_panel := PanelContainer.new()
	map_panel.position = Vector2(18, 180)
	map_panel.custom_minimum_size = Vector2(220, 150)
	hud.add_child(map_panel)
	var map_column := VBoxContainer.new()
	map_panel.add_child(map_column)
	var map_title := Label.new()
	map_title.text = "ISLAND MAP  /  LOCATIONS"
	map_title.add_theme_font_size_override("font_size", 14)
	map_column.add_child(map_title)
	var map_locations := Label.new()
	map_locations.text = "NORTH: RADIO TOWER\nWEST: OLD TOWN\nEAST: HARBOR\nSOUTH: RIVERSIDE\nCENTRE: CROSSROADS"
	map_locations.add_theme_font_size_override("font_size", 12)
	map_column.add_child(map_locations)
	var map_coords := Label.new()
	map_coords.name = "MapCoordinates"
	map_coords.text = "POSITION: 0, 0"
	map_column.add_child(map_coords)
	var fire_button := Button.new()
	fire_button.text = "FIRE"
	fire_button.position = Vector2(1080, 570)
	fire_button.custom_minimum_size = Vector2(150, 90)
	fire_button.button_down.connect(func(): Input.action_press("fire"))
	fire_button.button_up.connect(func(): Input.action_release("fire"))
	hud.add_child(fire_button)
	var jump_button := Button.new()
	jump_button.text = "JUMP"
	jump_button.position = Vector2(900, 590)
	jump_button.custom_minimum_size = Vector2(130, 70)
	jump_button.button_down.connect(func(): Input.action_press("jump"))
	jump_button.button_up.connect(func(): Input.action_release("jump"))
	hud.add_child(jump_button)
	_add_touch_button("▲", Vector2(100, 520), "move_forward")
	_add_touch_button("▼", Vector2(100, 630), "move_back")
	_add_touch_button("◀", Vector2(25, 575), "move_left")
	_add_touch_button("▶", Vector2(175, 575), "move_right")
	var sprint_button := Button.new()
	sprint_button.text = "SPRINT"
	sprint_button.position = Vector2(900, 500)
	sprint_button.custom_minimum_size = Vector2(130, 58)
	sprint_button.toggle_mode = true
	sprint_button.toggled.connect(func(active: bool): sprint_enabled = active)
	hud.add_child(sprint_button)
	var crouch_button := Button.new()
	crouch_button.text = "CROUCH"
	crouch_button.position = Vector2(1045, 480)
	crouch_button.custom_minimum_size = Vector2(130, 58)
	crouch_button.toggle_mode = true
	crouch_button.toggled.connect(func(active: bool):
		crouch_enabled = active
		if active:
			sprint_enabled = false
	)
	hud.add_child(crouch_button)
	weapon_hud_label = Label.new()
	weapon_hud_label.position = Vector2(900, 680)
	weapon_hud_label.add_theme_font_size_override("font_size", 20)
	hud.add_child(weapon_hud_label)
	ammo_hud_label = Label.new()
	ammo_hud_label.position = Vector2(1080, 680)
	ammo_hud_label.add_theme_font_size_override("font_size", 24)
	hud.add_child(ammo_hud_label)
	crosshair_label = Label.new()
	crosshair_label.text = "+"
	crosshair_label.position = Vector2(635, 335)
	crosshair_label.add_theme_font_size_override("font_size", 30)
	hud.add_child(crosshair_label)
	var reload_button := Button.new()
	reload_button.text = "RELOAD"
	reload_button.position = Vector2(900, 420)
	reload_button.custom_minimum_size = Vector2(125, 52)
	reload_button.pressed.connect(_start_reload)
	hud.add_child(reload_button)
	var weapon_cycle_button := Button.new()
	weapon_cycle_button.text = "NEXT GUN"
	weapon_cycle_button.position = Vector2(1045, 420)
	weapon_cycle_button.custom_minimum_size = Vector2(125, 52)
	weapon_cycle_button.pressed.connect(func(): _equip_weapon((current_weapon + 1) % weapon_names.size()))
	hud.add_child(weapon_cycle_button)
	pickup_button = Button.new()
	pickup_button.text = "NO LOOT"
	pickup_button.position = Vector2(760, 500)
	pickup_button.custom_minimum_size = Vector2(125, 58)
	pickup_button.disabled = true
	pickup_button.pressed.connect(_pickup_nearby_loot)
	hud.add_child(pickup_button)
	var medkit_button := Button.new()
	medkit_button.text = "MEDKIT"
	medkit_button.position = Vector2(760, 570)
	medkit_button.custom_minimum_size = Vector2(125, 58)
	medkit_button.pressed.connect(_use_medkit)
	hud.add_child(medkit_button)
	inventory_label = Label.new()
	inventory_label.position = Vector2(18, 345)
	inventory_label.text = "HP 100  |  ARMOR 0  |  MEDKIT 1"
	inventory_label.add_theme_font_size_override("font_size", 16)
	hud.add_child(inventory_label)
	drop_status_label = Label.new()
	drop_status_label.position = Vector2(420, 52)
	drop_status_label.add_theme_font_size_override("font_size", 20)
	drop_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	drop_status_label.custom_minimum_size = Vector2(420, 35)
	hud.add_child(drop_status_label)
	ready_button = Button.new()
	ready_button.text = "READY UP"
	ready_button.position = Vector2(420, 92)
	ready_button.custom_minimum_size = Vector2(180, 48)
	ready_button.pressed.connect(_toggle_ready)
	hud.add_child(ready_button)
	lobby_status_label = Label.new()
	lobby_status_label.position = Vector2(420, 145)
	lobby_status_label.custom_minimum_size = Vector2(420, 40)
	lobby_status_label.text = "LOBBY • WAITING FOR PLAYERS"
	hud.add_child(lobby_status_label)
	skill_button = Button.new()
	skill_button.text = selected_skill + " (45s)"
	skill_button.position = Vector2(560, 590)
	skill_button.custom_minimum_size = Vector2(170, 60)
	skill_button.pressed.connect(_activate_character_skill)
	hud.add_child(skill_button)
	var emote_button := Button.new()
	emote_button.text = "EMOTE"
	emote_button.position = Vector2(560, 660)
	emote_button.custom_minimum_size = Vector2(120, 48)
	emote_button.pressed.connect(_toggle_emote_wheel)
	hud.add_child(emote_button)
	emote_status_label = Label.new()
	emote_status_label.position = Vector2(560, 710)
	hud.add_child(emote_status_label)
	gloo_wall_button = Button.new()
	gloo_wall_button.text = "GLOO WALL (" + str(gloo_wall_charges) + ")"
	gloo_wall_button.position = Vector2(700, 590)
	gloo_wall_button.custom_minimum_size = Vector2(150, 60)
	gloo_wall_button.pressed.connect(_deploy_gloo_wall)
	hud.add_child(gloo_wall_button)
	var vehicle_button := Button.new()
	vehicle_button.text = "ENTER / EXIT VEHICLE"
	vehicle_button.position = Vector2(760, 650)
	vehicle_button.custom_minimum_size = Vector2(180, 52)
	vehicle_button.pressed.connect(_toggle_vehicle)
	hud.add_child(vehicle_button)
	vehicle_status_label = Label.new()
	vehicle_status_label.position = Vector2(760, 710)
	vehicle_status_label.text = "VEHICLE: ON FOOT (G)"
	hud.add_child(vehicle_status_label)
	var look_hint := Label.new()
	look_hint.text = "DRAG SCREEN TO LOOK AROUND"
	look_hint.position = Vector2(420, 24)
	look_hint.add_theme_font_size_override("font_size", 16)
	hud.add_child(look_hint)

func _add_touch_button(label_text: String, pos: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = label_text
	button.position = pos
	button.custom_minimum_size = Vector2(65, 65)
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))
	hud.add_child(button)

func _connect_to_server() -> void:
	if address_input == null or address_input.text.strip_edges().is_empty():
		if status_label:
			status_label.text = "ENTER A REAL DEDICATED SERVER IP ADDRESS"
		return
	var server_port := PORT
	var configured_port := OS.get_environment("LAST_ZONE_PORT").strip_edges()
	if not configured_port.is_empty():
		var parsed_port := configured_port.to_int()
		if parsed_port >= 1 and parsed_port <= 65535:
			server_port = parsed_port
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		if status_label:
			status_label.text = "A server connection is already active or in progress."
		return
	var peer := ENetMultiplayerPeer.new()
	server_address = address_input.text.strip_edges()
	_save_local_settings()
	var error := peer.create_client(server_address, server_port)
	if error != OK:
		status_label.text = "Could not start connection: " + str(error)
		return
	multiplayer.multiplayer_peer = peer
	connection_timeout_timer = CONNECTION_TIMEOUT_SECONDS
	status_label.text = "Connecting to " + address_input.text + "... (15s timeout)"

func _run_network_test_client() -> void:
	var port := PORT
	var configured_port := OS.get_environment("LAST_ZONE_PORT").strip_edges()
	if not configured_port.is_empty():
		port = clampi(configured_port.to_int(), 1, 65535)
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client("127.0.0.1", port)
	if error != OK:
		push_error("NETWORK TEST: client could not start: " + str(error))
		get_tree().quit(1)
		return
	multiplayer.multiplayer_peer = peer
	var wait_time := 0.0
	while wait_time < 8.0 and peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		await get_tree().create_timer(0.1).timeout
		wait_time += 0.1
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		push_error("NETWORK TEST: client connection timed out")
		get_tree().quit(1)
		return
	rpc_id(1, "request_spawn", "Solo")
	wait_time = 0.0
	while wait_time < 4.0 and not network_test_spawn_received:
		await get_tree().create_timer(0.1).timeout
		wait_time += 0.1
	if not network_test_spawn_received:
		push_error("NETWORK TEST: server did not assign a synchronized air-drop spawn")
		get_tree().quit(1)
		return
	rpc_id(1, "request_set_ready", true)
	wait_time = 0.0
	while wait_time < 22.0 and not match_started:
		await get_tree().create_timer(0.1).timeout
		wait_time += 0.1
	if not match_started:
		push_error("NETWORK TEST: lobby did not start after both clients readied")
		get_tree().quit(1)
		return
	wait_time = 0.0
	while wait_time < 4.0 and network_test_target_id <= 0:
		await get_tree().create_timer(0.1).timeout
		wait_time += 0.1
	if network_test_target_id <= 0:
		push_error("NETWORK TEST: peer roster did not identify the other client")
		get_tree().quit(1)
		return
	rpc_id(1, "request_player_damage", network_test_target_id, 0)
	wait_time = 0.0
	while wait_time < 4.0 and not network_test_damage_received:
		await get_tree().create_timer(0.1).timeout
		wait_time += 0.1
	if network_test_damage_received:
		print("NETWORK TEST: client joined, readied, started match and received server-authoritative damage")
		get_tree().quit(0)
	else:
		push_error("NETWORK TEST: server-authoritative damage was not received")
		get_tree().quit(1)

func _run_capacity_test_client() -> void:
	var port := PORT
	var configured_port := OS.get_environment("LAST_ZONE_PORT").strip_edges()
	if not configured_port.is_empty():
		port = clampi(configured_port.to_int(), 1, 65535)
	var expect_rejection := OS.get_environment("LAST_ZONE_EXPECT_REJECTION") == "1"
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client("127.0.0.1", port)
	if error != OK:
		if expect_rejection:
			print("CAPACITY TEST: overflow client rejected at connection admission")
			get_tree().quit(0)
		else:
			push_error("CAPACITY TEST: client could not start: " + str(error))
			get_tree().quit(1)
		return
	multiplayer.multiplayer_peer = peer
	var elapsed := 0.0
	while elapsed < 8.0 and peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		if expect_rejection:
			print("CAPACITY TEST: overflow client rejected at transport admission")
			get_tree().quit(0)
		else:
			push_error("CAPACITY TEST: expected client connection timed out")
			get_tree().quit(1)
		return
	rpc_id(1, "request_spawn", "Solo")
	elapsed = 0.0
	while elapsed < 8.0 and not capacity_test_spawned and not capacity_test_rejected:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1
	if expect_rejection:
		if capacity_test_rejected or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
			print("CAPACITY TEST: overflow client rejected by server admission limit")
			get_tree().quit(0)
		elif capacity_test_spawned:
			push_error("CAPACITY TEST: server admitted player 51 beyond capacity")
			get_tree().quit(1)
		else:
			push_error("CAPACITY TEST: overflow client was not rejected")
			get_tree().quit(1)
	elif capacity_test_spawned:
		elapsed = 0.0
		while elapsed < 20.0 and capacity_test_population < 50:
			await get_tree().create_timer(0.1).timeout
			elapsed += 0.1
		if capacity_test_population < 50:
			push_error("CAPACITY TEST: all 50 player slots did not become occupied")
			get_tree().quit(1)
			return
		print("CAPACITY TEST: 50/50 connected; holding slots for overflow check")
		await get_tree().create_timer(12.0).timeout
		print("CAPACITY TEST: player admitted")
		get_tree().quit(0)
	else:
		push_error("CAPACITY TEST: player was not admitted")
		get_tree().quit(1)

func _run_project_self_test() -> void:
	var failures: Array[String] = []
	if MAX_PLAYERS != 50:
		failures.append("MAX_PLAYERS must remain 50")
	if weapon_names.size() != weapon_damage.size() or weapon_names.size() != weapon_mag_sizes.size() or weapon_names.size() != weapon_fire_delays.size() or weapon_names.size() != weapon_ranges.size():
		failures.append("Weapon configuration arrays have different lengths")
	for index in range(weapon_names.size()):
		if float(weapon_damage[index]) <= 0.0 or int(weapon_mag_sizes[index]) <= 0 or float(weapon_fire_delays[index]) <= 0.0 or float(weapon_ranges[index]) <= 0.0:
			failures.append("Invalid weapon configuration at index " + str(index))
	if MAP_SIZE < 100.0 or safe_radius <= 0.0 or health <= 0.0:
		failures.append("Invalid world or player survival configuration")
	var saved_teams: Dictionary = server_player_teams.duplicate(true)
	server_player_teams.clear()
	var duo_counts: Dictionary = {}
	for fake_id in range(1, 51):
		var duo_team := _assign_team_id(fake_id, 2)
		server_player_teams[fake_id] = duo_team
		duo_counts[duo_team] = int(duo_counts.get(duo_team, 0)) + 1
	if duo_counts.size() != 25:
		failures.append("Duo mode must distribute 50 players across 25 teams")
	for team_count in duo_counts.values():
		if int(team_count) > 2:
			failures.append("Duo team capacity exceeded")
	server_player_teams.clear()
	var squad_counts: Dictionary = {}
	for fake_id in range(1, 51):
		var squad_team := _assign_team_id(fake_id, 4)
		server_player_teams[fake_id] = squad_team
		squad_counts[squad_team] = int(squad_counts.get(squad_team, 0)) + 1
	if squad_counts.size() != 13:
		failures.append("Squad mode must distribute 50 players across 13 teams")
	for team_count in squad_counts.values():
		if int(team_count) > 4:
			failures.append("Squad team capacity exceeded")
	server_player_teams = saved_teams
	var saved_match_mode := server_match_mode
	server_match_mode = "Solo"
	if _minimum_match_players() != 2:
		failures.append("Solo queue must require at least 2 players")
	server_match_mode = "Duo"
	if _minimum_match_players() != 4:
		failures.append("Duo queue must require two complete teams (4 players)")
	server_match_mode = "Squad"
	if _minimum_match_players() != 8:
		failures.append("Squad queue must require two complete teams (8 players)")
	var saved_local_team := local_team_id
	local_team_id = 7
	if not _is_local_team_winner(7) or _is_local_team_winner(8):
		failures.append("Every member of the winning team must receive a win")
	local_team_id = saved_local_team
	server_match_mode = saved_match_mode
	var ready_test_states: Dictionary = server_player_states.duplicate(true)
	var ready_test_flags: Dictionary = server_player_ready.duplicate(true)
	server_match_mode = "Solo"
	server_player_states = {101: {}, 102: {}}
	server_player_ready = {101: true, 102: true}
	if not _server_all_players_ready():
		failures.append("Lobby must accept a full minimum-size all-ready Solo group")
	server_player_ready[102] = false
	if _server_all_players_ready():
		failures.append("Lobby must not start while any connected player is not ready")
	server_player_ready[102] = true
	server_player_states.erase(102)
	if _server_all_players_ready():
		failures.append("Lobby must not start below the minimum player count")
	server_player_states = ready_test_states
	server_player_ready = ready_test_flags
	server_match_mode = saved_match_mode
	var saved_states: Dictionary = server_player_states.duplicate(true)
	var saved_eliminated: Dictionary = server_eliminated.duplicate(true)
	var saved_team_ids: Dictionary = server_player_teams.duplicate(true)
	server_player_states = {1: {}, 2: {}, 3: {}, 4: {}}
	server_player_teams = {1: 1, 2: 1, 3: 2, 4: 2}
	server_eliminated.clear()
	if _server_alive_team_count() != 2:
		failures.append("Two active squads must count as two surviving teams")
	server_eliminated[3] = true
	server_eliminated[4] = true
	if _server_alive_team_count() != 1:
		failures.append("Eliminating one squad must leave one surviving team")
	server_player_states = saved_states
	server_player_teams = saved_team_ids
	server_eliminated = saved_eliminated
	if failures.is_empty():
		print("LAST ZONE SELF TEST: all project configuration invariants passed")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error("LAST ZONE SELF TEST: " + failure)
		get_tree().quit(1)

func _start_server() -> void:
	var server_port := PORT
	var configured_port := OS.get_environment("LAST_ZONE_PORT").strip_edges()
	if not configured_port.is_empty():
		var parsed_port := configured_port.to_int()
		if parsed_port >= 1 and parsed_port <= 65535:
			server_port = parsed_port
		else:
			push_warning("Invalid LAST_ZONE_PORT; using default UDP port " + str(PORT))
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(server_port, MAX_PLAYERS)
	if error != OK:
		push_error("Server failed to start: " + str(error))
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_server_peer_connected)
	multiplayer.peer_disconnected.connect(_server_peer_disconnected)
	print("LAST ZONE dedicated server listening on UDP ", server_port, " (capacity ", MAX_PLAYERS, ")")

func _on_connected() -> void:
	connection_timeout_timer = 0.0
	status_label.text = "ONLINE  •  Connected to server"
	var queue_type := "RANKED" if selected_game_mode == "Ranked Battle Royale" else "CASUAL"
	rpc_id(1, "request_spawn", selected_mode + "|" + queue_type)

func _on_connection_failed() -> void:
	connection_timeout_timer = 0.0
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	status_label.text = "Connection failed. Check server IP and UDP port 27015, then press CONNECT to retry."

func _on_server_disconnected() -> void:
	connection_timeout_timer = 0.0
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	status_label.text = "Disconnected from server. Press CONNECT to retry."

func _on_peer_connected(id: int) -> void:
	status_label.text = "Player connected: " + str(id)

func _on_peer_disconnected(id: int) -> void:
	if players.has(id):
		players[id].queue_free()
		players.erase(id)

func _server_peer_connected(id: int) -> void:
	print("Player joined: ", id)

func _server_peer_disconnected(id: int) -> void:
	print("Player left: ", id)
	server_player_states.erase(id)
	last_server_position.erase(id)
	server_position_time.erase(id)
	server_position_last_packet_time.erase(id)
	server_last_shot_time.erase(id)
	server_vehicle_update_time.erase(id)
	server_player_health.erase(id)
	server_player_armor.erase(id)
	server_player_medkits.erase(id)
	server_player_ready.erase(id)
	server_player_teams.erase(id)
	server_eliminated.erase(id)
	for vehicle_id_variant in server_vehicle_drivers.keys():
		if int(server_vehicle_drivers[vehicle_id_variant]) == id:
			var abandoned_vehicle_id := int(vehicle_id_variant)
			var abandoned_car := vehicle_nodes[abandoned_vehicle_id] if abandoned_vehicle_id >= 0 and abandoned_vehicle_id < vehicle_nodes.size() else null
			server_vehicle_drivers.erase(vehicle_id_variant)
			server_vehicle_controls.erase(abandoned_vehicle_id)
			server_vehicle_speeds[abandoned_vehicle_id] = 0.0
			if abandoned_car:
				rpc("vehicle_driver_changed", abandoned_vehicle_id, id, false, abandoned_car.global_position + abandoned_car.global_basis.x * 2.2 + Vector3.UP * 0.2, abandoned_car.rotation.y)
	if multiplayer.multiplayer_peer != null and multiplayer.is_server():
		rpc("despawn_remote_player", id)
		if server_match_had_multiple_players and match_started and not match_finished and _server_alive_team_count() <= 1:
			match_finished = true
			var winner_id := _server_last_alive_player()
			rpc("update_match_clock", ceili(match_time_remaining), safe_radius, true, _server_alive_player_count())
			_server_broadcast_match_result(winner_id, "WIN BY DISCONNECT")
		if not match_started and server_player_states.size() >= _minimum_match_players():
			var remaining_all_ready := true
			for remaining_id in server_player_states.keys():
				if not bool(server_player_ready.get(int(remaining_id), false)):
					remaining_all_ready = false
					break
			if remaining_all_ready and lobby_countdown < 0.0:
				lobby_countdown = 15.0
				lobby_last_broadcast_second = 15
			elif not remaining_all_ready:
				lobby_countdown = -1.0
				lobby_last_broadcast_second = -1
		else:
			lobby_countdown = -1.0
			lobby_last_broadcast_second = -1
		_broadcast_server_population()
		_broadcast_server_roster()
		_broadcast_lobby_status()
		if server_player_states.is_empty():
			server_player_kills.clear()
			server_match_roster.clear()
			server_player_deaths.clear()
			server_player_damage.clear()
			server_player_ready.clear()
			server_eliminated.clear()
			server_last_shot_time.clear()
			server_loot_taken.clear()
			server_match_mode = ""
			server_match_queue = ""
			server_zone_damage_timer = 0.0
			server_match_had_multiple_players = false
			elimination_count = 0
			safe_radius = 95.0
			safe_timer = 0.0
			match_started = false
			match_finished = false
			lobby_countdown = -1.0
			lobby_last_broadcast_second = -1
			match_time_remaining = 600.0
			match_clock_tick = 0.0
			# Restore the vehicle fleet as well as loot before the next lobby.
			_build_loot_spawns()
			_reset_vehicle_fleet()

@rpc("any_peer", "call_remote", "reliable")
func request_spawn(requested_mode: String) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0 or server_player_states.has(sender):
		return
	var queue_parts := requested_mode.split("|", false, 1)
	var team_mode := str(queue_parts[0])
	var queue_type := str(queue_parts[1]) if queue_parts.size() > 1 else "CASUAL"
	if team_mode not in ["Solo", "Duo", "Squad"] or queue_type not in ["CASUAL", "RANKED"]:
		rpc_id(sender, "spawn_rejected", "Invalid matchmaking queue.")
		return
	if match_started:
		rpc_id(sender, "spawn_rejected", "This match has already started.")
		return
	if server_player_states.size() >= MAX_PLAYERS:
		rpc_id(sender, "spawn_rejected", "This match is full (50/50).")
		return
	if server_match_mode.is_empty():
		server_match_mode = team_mode
		server_match_queue = queue_type
	elif team_mode != server_match_mode or queue_type != server_match_queue:
		rpc_id(sender, "spawn_rejected", "This server is running " + server_match_queue + " " + server_match_mode + ". Select the same queue.")
		return
	var team_capacity := 1 if team_mode == "Solo" else (2 if team_mode == "Duo" else 4)
	var team_id := _assign_team_id(sender, team_capacity)
	var spawn_position := Vector3(randf_range(-65.0, 65.0), 48.0, randf_range(-65.0, 65.0))
	var spawn_yaw := 0.0
	if OS.get_environment("LAST_ZONE_TEST_MODE") == "1":
		if server_player_states.is_empty():
			spawn_position = Vector3(0.0, 48.0, 20.0)
		else:
			spawn_position = Vector3(0.0, 48.0, 16.0)
			spawn_yaw = PI
	if not server_player_states.is_empty():
		server_match_had_multiple_players = true
	server_player_states[sender] = {"position": spawn_position, "yaw": spawn_yaw}
	server_match_roster[sender] = true
	server_player_ready[sender] = false
	lobby_countdown = -1.0
	lobby_last_broadcast_second = -1
	server_player_health[sender] = 100.0
	server_player_kills[sender] = int(server_player_kills.get(sender, 0))
	server_player_deaths[sender] = int(server_player_deaths.get(sender, 0))
	server_player_damage[sender] = float(server_player_damage.get(sender, 0.0))
	server_player_armor[sender] = 0.0
	server_player_medkits[sender] = 1
	server_player_teams[sender] = team_id
	server_eliminated.erase(sender)
	last_server_position[sender] = spawn_position
	server_position_time[sender] = Time.get_ticks_msec() / 1000.0
	rpc_id(sender, "set_local_team", team_id, team_mode, team_capacity)
	rpc_id(sender, "set_local_spawn", spawn_position, spawn_yaw)
	# Send the already connected players to the newcomer first.
	for existing_id_variant in server_player_states.keys():
		var existing_id := int(existing_id_variant)
		if existing_id == sender:
			continue
		var state: Dictionary = server_player_states[existing_id]
		rpc_id(sender, "spawn_remote_player", existing_id, state["position"], float(state["yaw"]), int(server_player_teams.get(existing_id, existing_id)))
	# Announce the newcomer to every connected client.
	rpc("spawn_remote_player", sender, spawn_position, spawn_yaw, team_id)
	_broadcast_server_population()
	_broadcast_server_roster()
	_broadcast_lobby_status()

func _broadcast_server_roster() -> void:
	if not multiplayer.is_server():
		return
	var peer_ids := PackedInt32Array()
	var team_ids := PackedInt32Array()
	for peer_variant in server_player_states.keys():
		var peer_id := int(peer_variant)
		peer_ids.append(peer_id)
		team_ids.append(int(server_player_teams.get(peer_id, 0)))
	rpc("receive_server_roster", peer_ids, team_ids)

@rpc("authority", "call_remote", "reliable")
func receive_server_roster(peer_ids: PackedInt32Array, team_ids: PackedInt32Array) -> void:
	if peer_ids.size() > MAX_PLAYERS or peer_ids.size() != team_ids.size():
		return
	var seen_peer_ids: Dictionary = {}
	for index in range(peer_ids.size()):
		var peer_id := peer_ids[index]
		var team_id := team_ids[index]
		if peer_id <= 0 or team_id <= 0 or seen_peer_ids.has(peer_id):
			return
		if team_id > MAX_PLAYERS:
			return
		seen_peer_ids[peer_id] = true
	var team_counts: Dictionary = {}
	for team_id in team_ids:
		team_counts[team_id] = int(team_counts.get(team_id, 0)) + 1
		if int(team_counts[team_id]) > 4:
			return
	if OS.get_cmdline_user_args().has("--network-test-client"):
		network_test_target_id = 0
		for peer_id in peer_ids:
			if peer_id != multiplayer.get_unique_id():
				network_test_target_id = peer_id
				break
	if not roster_label:
		return
	var lines := PackedStringArray(["PLAYER ROSTER"])
	var count := mini(peer_ids.size(), MAX_PLAYERS)
	var team_members: Dictionary = {}
	for index in range(count):
		var team_id := team_ids[index] if index < team_ids.size() else 0
		team_members[team_id] = int(team_members.get(team_id, 0)) + 1
	var team_capacity := 1 if selected_mode == "Solo" else (2 if selected_mode == "Duo" else 4)
	var team_keys: Array = team_members.keys()
	team_keys.sort()
	for team_variant in team_keys:
		lines.append("TEAM " + str(team_variant) + "  •  " + str(team_members[team_variant]) + "/" + str(team_capacity))
	for index in range(count):
		var peer_id := peer_ids[index]
		var team_id := team_ids[index] if index < team_ids.size() else 0
		lines.append("  PLAYER " + str(peer_id) + "  •  TEAM " + str(team_id))
	roster_label.text = "\n".join(lines) if count > 0 else "PLAYER ROSTER\nWaiting for real players..."

func _broadcast_server_population() -> void:
	if not multiplayer.is_server():
		return
	var connected_players := server_player_states.size()
	rpc("receive_server_population", connected_players, MAX_PLAYERS)

@rpc("authority", "call_remote", "reliable")
func receive_server_population(connected_players: int, capacity: int) -> void:
	if capacity < 1 or capacity > MAX_PLAYERS or connected_players < 0 or connected_players > capacity:
		return
	if OS.get_cmdline_user_args().has("--capacity-test-client"):
		capacity_test_population = connected_players
	if population_label:
		population_label.text = "PLAYERS: " + str(connected_players) + " / " + str(capacity) + "  •  REAL PLAYERS ONLY"

func _assign_team_id(peer_id: int, team_capacity: int) -> int:
	var team_counts: Dictionary = {}
	for assigned_team_variant in server_player_teams.values():
		var assigned_team := int(assigned_team_variant)
		team_counts[assigned_team] = int(team_counts.get(assigned_team, 0)) + 1
	var candidate := 1
	while int(team_counts.get(candidate, 0)) >= team_capacity:
		candidate += 1
	return candidate

func _toggle_ready() -> void:
	if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		if status_label: status_label.text = "CONNECT TO A MATCH SERVER FIRST"
		return
	if multiplayer.is_server():
		_server_set_ready(1, not local_player_ready)
	else:
		rpc_id(1, "request_set_ready", not local_player_ready)

@rpc("any_peer", "call_remote", "reliable")
func request_set_ready(wants_ready: bool) -> void:
	if multiplayer.is_server():
		_server_set_ready(multiplayer.get_remote_sender_id(), wants_ready)

func _minimum_match_players() -> int:
	match server_match_mode:
		"Duo":
			return 4
		"Squad":
			return 8
		_:
			return 2


func _server_all_players_ready() -> bool:
	if server_player_states.size() < _minimum_match_players():
		return false
	for id_variant in server_player_states.keys():
		if not bool(server_player_ready.get(int(id_variant), false)):
			return false
	return true

func _server_set_ready(peer_id: int, wants_ready: bool) -> void:
	if not server_player_states.has(peer_id) or match_started:
		return
	server_player_ready[peer_id] = wants_ready
	if _server_all_players_ready():
		if lobby_countdown < 0.0:
			lobby_countdown = 15.0
			lobby_last_broadcast_second = 15
	elif lobby_countdown >= 0.0:
		lobby_countdown = -1.0
		lobby_last_broadcast_second = -1
	_broadcast_lobby_status()

func _broadcast_lobby_status() -> void:
	if not multiplayer.is_server():
		return
	var ids := PackedInt32Array()
	var flags := PackedInt32Array()
	for id_variant in server_player_states.keys():
		var peer_id := int(id_variant)
		ids.append(peer_id)
		flags.append(1 if bool(server_player_ready.get(peer_id, false)) else 0)
	rpc("receive_lobby_status", ids, flags, lobby_countdown, match_started)

@rpc("authority", "call_remote", "reliable")
func receive_lobby_status(ids: PackedInt32Array, flags: PackedInt32Array, countdown: float, started: bool) -> void:
	if ids.size() > MAX_PLAYERS or ids.size() != flags.size() or not is_finite(countdown):
		return
	if countdown < -1.0 or countdown > 15.0:
		return
	var seen_peer_ids: Dictionary = {}
	for index in range(ids.size()):
		var peer_id := ids[index]
		if peer_id <= 0 or seen_peer_ids.has(peer_id) or flags[index] not in [0, 1]:
			return
		seen_peer_ids[peer_id] = true
	var my_id := multiplayer.get_unique_id()
	if started and not match_started:
		career_result_saved = false
	match_started = started
	local_player_ready = false
	var ready_count := 0
	for i in range(ids.size()):
		var is_ready := i < flags.size() and flags[i] == 1
		if is_ready:
			ready_count += 1
		if ids[i] == my_id:
			local_player_ready = is_ready
	if ready_button:
		ready_button.text = "CANCEL READY" if local_player_ready else "READY UP"
		ready_button.disabled = started
	if lobby_status_label:
		if started:
			lobby_status_label.text = "MATCH STARTED • GOOD LUCK"
		elif countdown >= 0.0:
			lobby_status_label.text = "ALL READY • STARTING IN " + str(ceili(countdown)) + "s • " + str(ready_count) + "/" + str(ids.size())
		else:
			lobby_status_label.text = "LOBBY • " + str(ready_count) + "/" + str(ids.size()) + " READY"

@rpc("authority", "call_remote", "reliable")
func set_local_team(team_id: int, mode: String, team_capacity: int) -> void:
	local_team_id = team_id
	if local_player:
		local_player.set_meta("team_id", team_id)
	if team_hud_label:
		team_hud_label.text = mode.to_upper() + "  •  TEAM " + str(team_id) + "  •  " + str(team_capacity) + " PLAYERS MAX"

@rpc("authority", "call_remote", "reliable")
func set_local_spawn(spawn_position: Vector3, spawn_yaw: float) -> void:
	if not spawn_position.is_finite() or not is_finite(spawn_yaw):
		return
	if OS.get_cmdline_user_args().has("--network-test-client"):
		network_test_spawn_received = spawn_position.y >= 40.0
	if local_player == null:
		return
	local_player.global_position = spawn_position
	local_player.rotation.y = wrapf(spawn_yaw, -PI, PI)
	local_player.velocity = Vector3.ZERO
	is_dropping = true
	drop_elapsed = 0.0
	_create_parachute_visual()
	if status_label:
		status_label.text = "SERVER ASSIGNED AIR INSERTION POINT"

@rpc("authority", "call_remote", "reliable")
func spawn_rejected(reason: String) -> void:
	if OS.get_cmdline_user_args().has("--capacity-test-client"):
		capacity_test_rejected = true
	if status_label:
		status_label.text = "MATCH JOIN REJECTED: " + reason

@rpc("authority", "call_remote", "reliable")
func spawn_remote_player(id: int, spawn_position: Vector3, yaw: float, team_id: int) -> void:
	if OS.get_cmdline_user_args().has("--capacity-test-client"):
		if id == multiplayer.get_unique_id():
			capacity_test_spawned = true
		else:
			return
	if id == multiplayer.get_unique_id() or players.has(id):
		return
	var body := _create_player(id, false)
	body.global_position = spawn_position
	body.rotation.y = yaw
	body.set_meta("team_id", team_id)

@rpc("authority", "call_remote", "reliable")
func despawn_remote_player(id: int) -> void:
	if players.has(id):
		players[id].queue_free()
		players.erase(id)

@rpc("any_peer", "call_remote", "unreliable")
func server_update_position(pos: Vector3, yaw: float) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if not server_player_states.has(sender) or server_eliminated.has(sender) or match_finished or not pos.is_finite() or not is_finite(yaw):
		return
	# Reject coordinates outside the playable island and implausible teleports.
	if absf(pos.x) > MAP_SIZE * 0.5 + 8.0 or absf(pos.z) > MAP_SIZE * 0.5 + 8.0 or pos.y < -5.0 or pos.y > 90.0:
		return
	yaw = wrapf(yaw, -PI, PI)
	var now := Time.get_ticks_msec() / 1000.0
	var last_packet_time := float(server_position_last_packet_time.get(sender, 0.0))
	if last_packet_time > 0.0 and now - last_packet_time < 0.066:
		return
	server_position_last_packet_time[sender] = now
	var previous: Vector3 = last_server_position.get(sender, pos)
	var previous_time := float(server_position_time.get(sender, now))
	var elapsed := clampf(now - previous_time, 0.05, 1.0)
	# Permit normal running and vehicle movement, but reject implausible speed/teleports.
	var maximum_distance := 24.0 * elapsed + 1.5
	if previous.distance_to(pos) > maximum_distance:
		return
	last_server_position[sender] = pos
	server_position_time[sender] = now
	server_player_states[sender] = {"position": pos, "yaw": yaw}
	rpc("client_update_position", sender, pos, yaw)

@rpc("authority", "call_remote", "unreliable")
func client_update_position(id: int, pos: Vector3, yaw: float) -> void:
	if not players.has(id):
		return
	var remote_player: CharacterBody3D = players[id]
	if remote_player.global_position.distance_to(pos) > 8.0:
		remote_player.global_position = pos
	else:
		remote_player.global_position = remote_player.global_position.lerp(pos, 0.65)
	remote_player.rotation.y = yaw

@rpc("authority", "call_remote", "reliable")
func _server_apply_damage(target_id: int, incoming: float, source: String) -> void:
	if not server_player_states.has(target_id) or server_eliminated.has(target_id) or incoming <= 0.0:
		return
	var target_armor := float(server_player_armor.get(target_id, 0.0))
	var absorbed := minf(target_armor, incoming * 0.60)
	target_armor = maxf(0.0, target_armor - absorbed)
	var target_health := maxf(0.0, float(server_player_health.get(target_id, 100.0)) - (incoming - absorbed))
	var killer_id := 0
	if source.begins_with("PLAYER "):
		killer_id = int(source.trim_prefix("PLAYER "))
		if killer_id > 0 and killer_id != target_id and server_player_states.has(killer_id) and not server_eliminated.has(killer_id):
			server_player_damage[killer_id] = float(server_player_damage.get(killer_id, 0.0)) + (incoming - absorbed)
		else:
			killer_id = 0
	server_player_armor[target_id] = target_armor
	server_player_health[target_id] = target_health
	var eliminated := target_health <= 0.0
	if eliminated:
		server_eliminated[target_id] = true
		server_player_deaths[target_id] = int(server_player_deaths.get(target_id, 0)) + 1
		if killer_id > 0 and server_player_states.has(killer_id) and not server_eliminated.has(killer_id):
			server_player_kills[killer_id] = int(server_player_kills.get(killer_id, 0)) + 1
		rpc("broadcast_elimination", killer_id, target_id, elimination_count + 1)
		elimination_count += 1
	rpc_id(target_id, "receive_authoritative_damage", target_health, target_armor, source, eliminated)
	rpc("broadcast_player_status", target_id, target_health, target_armor)
	if eliminated:
		var alive_count := _server_alive_player_count()
		if server_match_had_multiple_players and _server_alive_team_count() <= 1 and not match_finished:
			match_finished = true
			var winner_id := _server_last_alive_player()
			rpc("update_match_clock", ceili(match_time_remaining), safe_radius, true, alive_count)
			_server_broadcast_match_result(winner_id, "ELIMINATION VICTORY")

func _server_apply_zone_damage() -> void:
	for peer_variant in server_player_states.keys():
		var peer_id := int(peer_variant)
		if server_eliminated.has(peer_id):
			continue
		var state: Dictionary = server_player_states[peer_id]
		var pos: Vector3 = state["position"]
		if Vector2(pos.x, pos.z).length() > safe_radius:
			_server_apply_damage(peer_id, 5.0, "OUTSIDE SAFE ZONE")

@rpc("any_peer", "call_remote", "reliable")
func request_player_damage(target_id: int, weapon_index: int) -> void:
	if not multiplayer.is_server() or match_finished:
		return
	var shooter_id := multiplayer.get_remote_sender_id()
	if not match_started or shooter_id == target_id or not server_player_states.has(shooter_id) or not server_player_states.has(target_id):
		return
	if server_eliminated.has(shooter_id) or server_eliminated.has(target_id):
		return
	if server_match_mode != "Solo" and int(server_player_teams.get(shooter_id, -1)) == int(server_player_teams.get(target_id, -2)):
		return
	if weapon_index < 0 or weapon_index >= weapon_damage.size():
		return
	var now := Time.get_ticks_msec() / 1000.0
	var previous_shot: float = float(server_last_shot_time.get(shooter_id, 0.0))
	if now - previous_shot < float(weapon_fire_delays[weapon_index]) * 0.8:
		return
	var shooter_state: Dictionary = server_player_states[shooter_id]
	var target_state: Dictionary = server_player_states[target_id]
	var shooter_pos: Vector3 = shooter_state["position"]
	var target_pos: Vector3 = target_state["position"]
	var shot_distance := shooter_pos.distance_to(target_pos)
	if shot_distance > float(weapon_ranges[weapon_index]) + 3.0:
		return
	# Require the target to be broadly in front of the shooter; prevents arbitrary remote-target damage RPCs.
	var shooter_yaw := float(shooter_state.get("yaw", 0.0))
	var forward := Vector3(-sin(shooter_yaw), 0.0, -cos(shooter_yaw))
	var to_target := Vector3(target_pos.x - shooter_pos.x, 0.0, target_pos.z - shooter_pos.z).normalized()
	if forward.length_squared() > 0.1 and to_target.length_squared() > 0.1 and forward.dot(to_target) < 0.35:
		return
	# Server checks static world geometry so clients cannot shoot through buildings.
	var ray_from := shooter_pos + Vector3(0.0, 1.4, 0.0)
	var ray_to := target_pos + Vector3(0.0, 1.0, 0.0)
	var ray_query := PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	var world := get_world_3d()
	if world == null:
		return
	var obstruction := world.direct_space_state.intersect_ray(ray_query)
	if not obstruction.is_empty():
		var hit_position: Vector3 = obstruction["position"]
		if ray_from.distance_to(hit_position) < ray_from.distance_to(ray_to) - 1.25:
			return
	server_last_shot_time[shooter_id] = now
	_server_apply_damage(target_id, float(weapon_damage[weapon_index]), "PLAYER " + str(shooter_id))

@rpc("authority", "call_remote", "reliable")
func receive_authoritative_damage(new_health: float, new_armor: float, source: String, eliminated: bool) -> void:
	if OS.get_cmdline_user_args().has("--network-test-client"):
		network_test_damage_received = new_health < 100.0
	if local_player == null or is_dead:
		return
	health = clampf(new_health, 0.0, 100.0)
	armor = clampf(new_armor, 0.0, 100.0)
	damage_flash_timer = 0.25
	if status_label:
		status_label.text = "UNDER ATTACK: " + source
	if health_bar:
		health_bar.value = health
	if armor_bar:
		armor_bar.value = armor
	if eliminated or health <= 0.0:
		_die()

func broadcast_player_status(peer_id: int, current_health: float, current_armor: float) -> void:
	if status_label:
		status_label.text = "PLAYER " + str(peer_id) + "  HP " + str(roundi(current_health)) + "  ARMOR " + str(roundi(current_armor))

@rpc("authority", "call_remote", "reliable")
func broadcast_elimination(killer_id: int, victim_id: int, total_eliminations: int) -> void:
	var entry := ("PLAYER " + str(killer_id) + " ELIMINATED PLAYER " + str(victim_id)) if killer_id > 0 else ("ZONE ELIMINATED PLAYER " + str(victim_id))
	kill_feed_entries.push_front(entry)
	while kill_feed_entries.size() > 4:
		kill_feed_entries.pop_back()
	if kill_feed_label:
		kill_feed_label.text = "KILL FEED\n" + "\n".join(kill_feed_entries)
	if status_label:
		status_label.text = entry + "  •  TOTAL " + str(total_eliminations)

@rpc("authority", "call_remote", "reliable")
func update_safe_zone(radius: float) -> void:
	safe_radius = radius
	if status_label:
		status_label.text = "SAFE ZONE RADIUS: " + str(roundi(radius)) + "m"

func _server_broadcast_match_result(winner_id: int, result_text: String) -> void:
	if not multiplayer.is_server():
		return
	var ranking: Array[Dictionary] = []
	var ranked_participants: Dictionary = server_match_roster if not server_match_roster.is_empty() else server_player_states
	for peer_variant in ranked_participants.keys():
		var ranked_id := int(peer_variant)
		ranking.append({"id": ranked_id, "kills": int(server_player_kills.get(ranked_id, 0)), "deaths": int(server_player_deaths.get(ranked_id, 0)), "damage": roundi(float(server_player_damage.get(ranked_id, 0.0)))})
	ranking.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["kills"]) != int(b["kills"]):
			return int(a["kills"]) > int(b["kills"])
		if int(a["damage"]) != int(b["damage"]):
			return int(a["damage"]) > int(b["damage"])
		return int(a["deaths"]) < int(b["deaths"])
	)
	var board := PackedStringArray(["FINAL TOP PLAYERS"])
	for index in range(mini(5, ranking.size())):
		var row: Dictionary = ranking[index]
		board.append(str(index + 1) + ". PLAYER " + str(row["id"]) + "  K " + str(row["kills"]) + "  D " + str(row["deaths"]) + "  DMG " + str(row["damage"]))
	for peer_variant in server_player_states.keys():
		var peer_id := int(peer_variant)
		rpc_id(peer_id, "receive_match_result", winner_id, int(server_player_teams.get(winner_id, 0)), result_text, int(server_player_kills.get(peer_id, 0)), int(server_player_deaths.get(peer_id, 0)), roundi(float(server_player_damage.get(peer_id, 0.0))))
		rpc_id(peer_id, "receive_match_leaderboard", board)

func _server_last_alive_player() -> int:
	for peer_variant in server_player_states.keys():
		var peer_id := int(peer_variant)
		if not server_eliminated.has(peer_id):
			return peer_id
	return 0

@rpc("authority", "call_remote", "reliable")
func receive_match_leaderboard(lines: PackedStringArray) -> void:
	if match_result_label:
		match_result_label.text += "\n" + "\n".join(lines)

@rpc("authority", "call_remote", "reliable")
func receive_match_result(winner_id: int, winner_team_id: int, result_text: String, local_kills: int, local_deaths: int, local_damage: int) -> void:
	if career_result_saved:
		return
	career_result_saved = true
	_record_career_match(winner_team_id, result_text, local_kills, local_deaths, local_damage)
	if match_result_label:
		var winner_line := "WINNER: PLAYER " + str(winner_id) if winner_id > 0 else "MATCH DRAW"
		match_result_label.text = winner_line + "\n" + result_text + "\nYOUR STATS  •  KILLS " + str(local_kills) + "  DEATHS " + str(local_deaths) + "  DAMAGE " + str(local_damage)
	if status_label:
		status_label.text = "MATCH FINISHED"

func _server_alive_team_count() -> int:
	var alive_teams: Dictionary = {}
	for peer_variant in server_player_states.keys():
		var peer_id := int(peer_variant)
		if server_eliminated.has(peer_id):
			continue
		var team_id := int(server_player_teams.get(peer_id, peer_id))
		alive_teams[team_id] = true
	return alive_teams.size()


func _server_alive_player_count() -> int:
	var alive := 0
	for peer_id_variant in server_player_states.keys():
		var peer_id := int(peer_id_variant)
		if not server_eliminated.has(peer_id):
			alive += 1
	return alive

@rpc("authority", "call_remote", "reliable")
func update_match_clock(seconds_left: int, radius: float, finished: bool, alive_count: int) -> void:
	match_time_remaining = float(maxi(0, seconds_left))
	safe_radius = radius
	match_finished = finished
	if match_hud_label:
		var minutes := int(seconds_left / 60)
		var seconds := seconds_left % 60
		match_hud_label.text = "MATCH " + ("%02d:%02d" % [minutes, seconds]) + "  •  ALIVE " + str(alive_count) + "  •  ZONE " + str(roundi(radius)) + "m"
		if finished:
			match_hud_label.text = "MATCH FINISHED  •  " + str(alive_count) + " ALIVE"

func _fire_weapon() -> void:
	if local_player == null or fire_cooldown > 0.0 or is_reloading:
		return
	if ammo_in_mag <= 0:
		if status_label:
			status_label.text = "MAGAZINE EMPTY - RELOAD"
		_start_reload()
		return
	ammo_in_mag -= 1
	fire_cooldown = weapon_fire_delays[current_weapon]
	_update_weapon_hud()
	var camera := local_player.get_node_or_null("CameraPivot/Camera3D") as Camera3D
	if camera == null:
		return
	var spread: float = float(weapon_spread[current_weapon]) * (0.85 if equipped_passive_skills.has("SHARP EYE") else 1.0)
	var aim_direction := -camera.global_basis.z
	aim_direction += camera.global_basis.x * randf_range(-spread, spread)
	aim_direction += camera.global_basis.y * randf_range(-spread, spread)
	aim_direction = aim_direction.normalized()
	var from := camera.global_position
	var to: Vector3 = from + aim_direction * float(weapon_ranges[current_weapon])
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [local_player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit:
		var target := hit.collider as Node
		if target and target is CharacterBody3D:
			last_hit_name = target.name
			var vehicle_hit_id := vehicle_nodes.find(target as CharacterBody3D)
			if vehicle_hit_id >= 0:
				if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server():
					rpc_id(1, "request_vehicle_damage", vehicle_hit_id, current_weapon)
				else:
					_server_damage_vehicle(vehicle_hit_id, current_weapon)
				if status_label:
					status_label.text = "VEHICLE HIT  •  " + target.name
				_show_muzzle_flash()
				return
			if status_label:
				status_label.text = "HIT: " + target.name + "  (" + str(roundi(weapon_damage[current_weapon])) + " DMG)"
			if target.has_meta("training_target"):
				_damage_training_target(target as CharacterBody3D, weapon_damage[current_weapon])
			elif target.has_method("apply_damage"):
				target.apply_damage(weapon_damage[current_weapon])
			elif target.name.begins_with("Player_") and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server():
				var target_id := int(target.name.trim_prefix("Player_"))
				rpc_id(1, "request_player_damage", target_id, current_weapon)
		else:
			if status_label:
				status_label.text = "SHOT FIRED - IMPACT"
	else:
		if status_label:
			status_label.text = "SHOT FIRED"
	_show_muzzle_flash()
	if weapon_visual:
		weapon_visual.rotation.x = -0.08


func _equip_weapon(index: int) -> void:
	if index < 0 or index >= weapon_names.size() or is_reloading:
		return
	current_weapon = index
	ammo_in_mag = weapon_mag_sizes[index]
	reserve_ammo = weapon_reserve[index]
	_update_weapon_visual()
	_update_weapon_hud()
	if status_label:
		status_label.text = "EQUIPPED: " + weapon_names[index]


func _start_reload() -> void:
	if is_reloading or ammo_in_mag >= weapon_mag_sizes[current_weapon] or reserve_ammo <= 0:
		return
	is_reloading = true
	reload_timer = (1.8 if current_weapon != 2 else 2.4) * (0.82 if equipped_passive_skills.has("QUICK HANDS") else 1.0) * (1.0 - skill_reload_bonus)
	if status_label:
		status_label.text = "RELOADING " + weapon_names[current_weapon] + "..."


func _finish_reload() -> void:
	var needed: int = int(weapon_mag_sizes[current_weapon]) - ammo_in_mag
	var loaded := mini(needed, reserve_ammo)
	ammo_in_mag += loaded
	reserve_ammo -= loaded
	is_reloading = false
	reload_timer = 0.0
	_update_weapon_hud()
	if status_label:
		status_label.text = "RELOAD COMPLETE"


func _update_weapon_hud() -> void:
	if weapon_hud_label:
		weapon_hud_label.text = weapon_names[current_weapon]
	if ammo_hud_label:
		ammo_hud_label.text = str(ammo_in_mag) + " / " + str(reserve_ammo)


func _create_weapon_visual(owner: Node3D) -> void:
	weapon_visual = Node3D.new()
	weapon_visual.name = "WeaponVisual"
	weapon_visual.position = Vector3(0.42, 1.12, -0.42)
	owner.add_child(weapon_visual)
	_update_weapon_visual()


func _update_weapon_visual() -> void:
	if weapon_visual == null:
		return
	for child in weapon_visual.get_children():
		child.queue_free()
	var body_mesh := MeshInstance3D.new()
	var body_box := BoxMesh.new()
	body_box.size = Vector3(0.18, 0.16, 0.78)
	body_mesh.mesh = body_box
	body_mesh.material_override = _material(Color(0.12, 0.14, 0.13))
	weapon_visual.add_child(body_mesh)
	var barrel := MeshInstance3D.new()
	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = 0.035
	barrel_mesh.bottom_radius = 0.045
	barrel_mesh.height = 0.52 if current_weapon != 2 else 0.32
	barrel.mesh = barrel_mesh
	barrel.rotation.x = PI * 0.5
	barrel.position.z = -0.55
	barrel.material_override = _material(Color(0.07, 0.08, 0.08))
	weapon_visual.add_child(barrel)
	var stock := MeshInstance3D.new()
	var stock_mesh := BoxMesh.new()
	stock_mesh.size = Vector3(0.14, 0.14, 0.28)
	stock.mesh = stock_mesh
	stock.position.z = 0.42
	stock.material_override = _material(Color(0.28, 0.20, 0.13))
	weapon_visual.add_child(stock)


func _show_muzzle_flash() -> void:
	if weapon_visual == null:
		return
	var flash := MeshInstance3D.new()
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = 0.12
	flash_mesh.height = 0.24
	flash.mesh = flash_mesh
	flash.position = Vector3(0, 0, -0.88)
	flash.material_override = _material(Color(1.0, 0.72, 0.18))
	weapon_visual.add_child(flash)
	get_tree().create_timer(0.07).timeout.connect(func():
		if is_instance_valid(flash):
			flash.queue_free()
	)

# ------------------------------------------------------------
# FIRST EIGHT FOUNDATION SYSTEMS: splash, menu, loading, settings,
# language selection and a locally saved player profile.
# Online account authentication is intentionally left for backend work.
# ------------------------------------------------------------

func _load_local_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://last_zone.cfg") == OK:
		profile_name = str(cfg.get_value("profile", "name", "Player"))
		player_id = str(cfg.get_value("profile", "player_id", ""))
		player_level = int(cfg.get_value("profile", "level", 1))
		player_xp = int(cfg.get_value("profile", "xp", 0))
		career_matches = int(cfg.get_value("career", "matches", 0))
		career_wins = int(cfg.get_value("career", "wins", 0))
		career_kills = int(cfg.get_value("career", "kills", 0))
		career_deaths = int(cfg.get_value("career", "deaths", 0))
		career_damage = int(cfg.get_value("career", "damage", 0))
		career_best_kills = int(cfg.get_value("career", "best_kills", 0))
		career_coins = int(cfg.get_value("career", "coins", 0))
		match_history = cfg.get_value("career", "history", [])
		unlocked_achievements = cfg.get_value("career", "achievements", [])
		daily_login_date = str(cfg.get_value("career", "daily_login_date", ""))
		daily_mission_date = str(cfg.get_value("career", "daily_mission_date", ""))
		daily_mission_matches = int(cfg.get_value("career", "daily_mission_matches", 0))
		daily_mission_kills = int(cfg.get_value("career", "daily_mission_kills", 0))
		daily_mission_damage = int(cfg.get_value("career", "daily_mission_damage", 0))
		daily_mission_wins = int(cfg.get_value("career", "daily_mission_wins", 0))
		daily_mission_loot = int(cfg.get_value("career", "daily_mission_loot", 0))
		daily_claimed = cfg.get_value("career", "daily_claimed", [])
		daily_match_claimed = bool(cfg.get_value("career", "daily_match_claimed", false))
		daily_kill_claimed = bool(cfg.get_value("career", "daily_kill_claimed", false))
		selected_mode = str(cfg.get_value("profile", "mode", "Solo"))
		match_type = str(cfg.get_value("profile", "match_type", "Battle Royale"))
		selected_game_mode = str(cfg.get_value("profile", "game_mode", "Battle Royale"))
		selected_submode = str(cfg.get_value("profile", "submode", "Solo"))
		ranked_points = int(cfg.get_value("ranked", "points", 0))
		ranked_tier = str(cfg.get_value("ranked", "tier", "RECRUIT"))
		target_players = clampi(int(cfg.get_value("profile", "target_players", 50)), 2, MAX_PLAYERS)
		custom_room_code = str(cfg.get_value("profile", "custom_room_code", ""))
		server_address = str(cfg.get_value("profile", "server_address", ""))
		var saved_friends: Variant = cfg.get_value("profile", "friends", [])
		for friend in saved_friends:
			friend_names.append(str(friend))
		selected_language = str(cfg.get_value("settings", "language", "English"))
		master_volume = float(cfg.get_value("settings", "master_volume", 0.8))
		music_volume = float(cfg.get_value("settings", "music_volume", 0.7))
		sfx_volume = float(cfg.get_value("settings", "sfx_volume", 0.8))
		graphics_quality = int(cfg.get_value("settings", "graphics_quality", 1))
		owned_bundles = cfg.get_value("collection", "bundles", ["FIELD OPERATIVE"])
		equipped_bundle = str(cfg.get_value("collection", "equipped_bundle", "FIELD OPERATIVE"))
		selected_character = str(cfg.get_value("collection", "character", "KAIRO"))
		var saved_characters: Array = cfg.get_value("collection", "owned_characters", ["KAIRO", "NYX"])
		owned_characters.clear()
		for character_name in saved_characters:
			owned_characters.append(str(character_name))
		if not owned_characters.has("KAIRO"): owned_characters.append("KAIRO")
		if not owned_characters.has("NYX"): owned_characters.append("NYX")
		selected_gender = str(cfg.get_value("collection", "gender", "MALE"))
		selected_skill = str(cfg.get_value("collection", "skill", "BULWARK PULSE"))
		var saved_passives: Array = cfg.get_value("collection", "passive_skills", ["QUICK HANDS", "FIELD MEDIC", "SCAVENGER"])
		equipped_passive_skills.clear()
		for passive_name in saved_passives:
			if not equipped_passive_skills.has(str(passive_name)) and equipped_passive_skills.size() < 3:
				equipped_passive_skills.append(str(passive_name))
		while equipped_passive_skills.size() < 3:
			equipped_passive_skills.append(["QUICK HANDS", "FIELD MEDIC", "SCAVENGER"][equipped_passive_skills.size()])
		if not owned_characters.has(selected_character): selected_character = "KAIRO"
		selected_skill = _character_active_skill(selected_character)
		owned_emotes = cfg.get_value("collection", "emotes", ["SALUTE"])
		equipped_emote = str(cfg.get_value("collection", "equipped_emote", "SALUTE"))
		owned_gloo_skins = cfg.get_value("collection", "gloo_skins", ["TACTICAL BLUE"])
		equipped_gloo_skin = str(cfg.get_value("collection", "equipped_gloo_skin", "TACTICAL BLUE"))
		weapon_upgrade_levels = cfg.get_value("collection", "weapon_upgrades", {"ASSAULT RIFLE": 0, "SMG": 0, "SHOTGUN": 0})
	if player_id.is_empty():
		player_id = "LZ-" + str(abs(hash(profile_name + str(Time.get_unix_time_from_system())))).pad_zeros(8)
	_save_local_settings()
	_apply_audio_settings()
	_reset_daily_missions_if_needed()
	_claim_daily_login_reward()

func _save_local_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("profile", "name", profile_name)
	cfg.set_value("profile", "player_id", player_id)
	cfg.set_value("profile", "level", player_level)
	cfg.set_value("profile", "xp", player_xp)
	cfg.set_value("career", "matches", career_matches)
	cfg.set_value("career", "wins", career_wins)
	cfg.set_value("career", "kills", career_kills)
	cfg.set_value("career", "deaths", career_deaths)
	cfg.set_value("career", "damage", career_damage)
	cfg.set_value("career", "best_kills", career_best_kills)
	cfg.set_value("career", "coins", career_coins)
	cfg.set_value("career", "history", match_history)
	cfg.set_value("career", "achievements", unlocked_achievements)
	cfg.set_value("career", "daily_login_date", daily_login_date)
	cfg.set_value("career", "daily_mission_date", daily_mission_date)
	cfg.set_value("career", "daily_mission_matches", daily_mission_matches)
	cfg.set_value("career", "daily_mission_kills", daily_mission_kills)
	cfg.set_value("career", "daily_mission_damage", daily_mission_damage)
	cfg.set_value("career", "daily_mission_wins", daily_mission_wins)
	cfg.set_value("career", "daily_mission_loot", daily_mission_loot)
	cfg.set_value("career", "daily_claimed", daily_claimed)
	cfg.set_value("career", "daily_match_claimed", daily_match_claimed)
	cfg.set_value("career", "daily_kill_claimed", daily_kill_claimed)
	cfg.set_value("profile", "mode", selected_mode)
	cfg.set_value("profile", "match_type", match_type)
	cfg.set_value("profile", "game_mode", selected_game_mode)
	cfg.set_value("profile", "submode", selected_submode)
	cfg.set_value("ranked", "points", ranked_points)
	cfg.set_value("ranked", "tier", ranked_tier)
	cfg.set_value("profile", "target_players", target_players)
	cfg.set_value("profile", "custom_room_code", custom_room_code)
	cfg.set_value("profile", "server_address", server_address)
	cfg.set_value("profile", "friends", friend_names)
	cfg.set_value("settings", "language", selected_language)
	cfg.set_value("settings", "master_volume", master_volume)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.set_value("settings", "graphics_quality", graphics_quality)
	cfg.set_value("collection", "bundles", owned_bundles)
	cfg.set_value("collection", "equipped_bundle", equipped_bundle)
	cfg.set_value("collection", "character", selected_character)
	cfg.set_value("collection", "owned_characters", owned_characters)
	cfg.set_value("collection", "gender", selected_gender)
	cfg.set_value("collection", "skill", selected_skill)
	cfg.set_value("collection", "passive_skills", equipped_passive_skills)
	cfg.set_value("collection", "emotes", owned_emotes)
	cfg.set_value("collection", "equipped_emote", equipped_emote)
	cfg.set_value("collection", "gloo_skins", owned_gloo_skins)
	cfg.set_value("collection", "equipped_gloo_skin", equipped_gloo_skin)
	cfg.set_value("collection", "weapon_upgrades", weapon_upgrade_levels)
	cfg.save("user://last_zone.cfg")

func _ensure_audio_buses() -> void:
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var new_index := AudioServer.get_bus_count() - 1
			AudioServer.set_bus_name(new_index, bus_name)
			AudioServer.set_bus_send(new_index, "Master")

func _apply_audio_settings() -> void:
	if AudioServer.get_bus_count() > 0:
		AudioServer.set_bus_volume_db(0, linear_to_db(maxf(master_volume, 0.001)))
	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(maxf(music_volume, 0.001)))
	var sfx_bus := AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(maxf(sfx_volume, 0.001)))


func _reset_daily_missions_if_needed() -> void:
	var today := Time.get_date_string_from_system()
	if daily_mission_date != today:
		daily_mission_date = today
		daily_mission_matches = 0
		daily_mission_kills = 0
		daily_mission_damage = 0
		daily_mission_wins = 0
		daily_mission_loot = 0
		daily_claimed.clear()
		daily_match_claimed = false
		daily_kill_claimed = false
		_save_local_settings()

func _claim_daily_login_reward() -> void:
	var today := Time.get_date_string_from_system()
	if daily_login_date == today:
		return
	daily_login_date = today
	career_coins += 25
	player_xp += 25
	_process_level_ups()
	_save_local_settings()

func _process_level_ups() -> void:
	while player_xp >= player_level * 100:
		player_xp -= player_level * 100
		player_level += 1
		career_coins += 50
		_unlock_level_cosmetics()
	_save_local_settings()

func _unlock_level_cosmetics() -> void:
	var level_bundles := {3: "RECRUIT FIELD KIT", 8: "URBAN SCOUT SET", 20: "SHADOW STRIKE BUNDLE", 35: "SAMURAI GUARD BUNDLE", 45: "GOLDEN FRONTIER BUNDLE", 60: "DRAGON WARDEN BUNDLE", 80: "LEGENDARY PHANTOM BUNDLE"}
	for threshold in level_bundles:
		if player_level >= int(threshold):
			var bundle_name := str(level_bundles[threshold])
			if not owned_bundles.has(bundle_name): owned_bundles.append(bundle_name)
	var weapon_skin_levels := {12: "M4A1 ARCTIC", 25: "MP5 NEON", 40: "M1014 EMBER", 55: "M4A1 PHANTOM", 70: "GOLDEN ARMORY"}
	for threshold in weapon_skin_levels:
		if player_level >= int(threshold):
			var skin_name := str(weapon_skin_levels[threshold])
			var reward_id := "WEAPON SKIN: " + skin_name
			if not unlocked_achievements.has(reward_id): unlocked_achievements.append(reward_id)

func _unlock_achievement(achievement: String) -> void:
	if unlocked_achievements.has(achievement):
		return
	unlocked_achievements.append(achievement)
	career_coins += 100
	player_xp += 50
	_process_level_ups()

func _is_local_team_winner(winner_team_id: int) -> bool:
	return winner_team_id > 0 and local_team_id == winner_team_id


func _record_career_match(winner_team_id: int, result_text: String, kills: int, deaths: int, damage: int) -> void:
	var won := _is_local_team_winner(winner_team_id)
	var reward_xp := 50 + maxi(0, kills) * 25 + (200 if won else 0)
	var reward_coins := 25 + maxi(0, kills) * 10 + (100 if won else 0)
	career_matches += 1
	career_wins += 1 if won else 0
	if selected_game_mode == "Ranked Battle Royale":
		ranked_points = maxi(0, ranked_points + (35 if won else 8) + maxi(0, kills) * 4 - maxi(0, deaths) * 3)
		_update_ranked_tier()

	career_kills += maxi(0, kills)
	career_deaths += maxi(0, deaths)
	career_damage += maxi(0, damage)
	career_best_kills = maxi(career_best_kills, kills)
	daily_mission_damage += maxi(0, damage)
	daily_mission_wins += 1 if won else 0
	player_xp += reward_xp
	career_coins += reward_coins
	_process_level_ups()
	daily_mission_matches += 1
	daily_mission_kills += maxi(0, kills)
	_process_level_ups()
	_claim_completed_daily_tasks()
	if career_matches >= 1: _unlock_achievement("FIRST MATCH")
	if career_matches >= 10: _unlock_achievement("VETERAN • 10 MATCHES")
	if career_wins >= 1: _unlock_achievement("FIRST VICTORY")
	if career_kills >= 10: _unlock_achievement("ELIMINATOR • 10 KILLS")
	if career_kills >= 50: _unlock_achievement("ELITE • 50 KILLS")
	if career_damage >= 1000: _unlock_achievement("DAMAGE DEALER • 1000")
	if career_best_kills >= 5: _unlock_achievement("FIVE KILL GAME")
	var record := {"date": Time.get_datetime_string_from_system(false, true), "mode": selected_mode, "result": result_text, "won": won, "kills": kills, "deaths": deaths, "damage": damage, "xp": reward_xp, "coins": reward_coins}
	match_history.push_front(record)
	while match_history.size() > 20:
		match_history.pop_back()
	_save_local_settings()
	if status_label:
		status_label.text = "REWARDS: +" + str(reward_xp) + " XP  •  +" + str(reward_coins) + " COINS"

func _update_ranked_tier() -> void:
	if ranked_points >= 5000:
		ranked_tier = "LAST ZONE CHAMPION"
	elif ranked_points >= 3500:
		ranked_tier = "LEGEND"
	elif ranked_points >= 2400:
		ranked_tier = "WARLORD"
	elif ranked_points >= 1500:
		ranked_tier = "MASTER"
	elif ranked_points >= 900:
		ranked_tier = "ELITE"
	elif ranked_points >= 450:
		ranked_tier = "VETERAN"
	elif ranked_points >= 150:
		ranked_tier = "SOLDIER"
	else:
		ranked_tier = "RECRUIT"
	_save_local_settings()


func _show_ranked_screen() -> void:
	var panel := _show_simple_screen("RANKED • SEASON 01")
	var info := Label.new()
	info.text = "TIER: " + ranked_tier + "\nRANK POINTS: " + str(ranked_points) + "\n\nRecruit 0 • Soldier 150 • Veteran 450 • Elite 900\nMaster 1500 • Warlord 2400 • Legend 3500\nLast Zone Champion 5000\n\nPoints are awarded only when a match result is recorded."
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(info)
	var back := Button.new()
	back.text = "BACK"
	back.pressed.connect(_show_lobby_screen)
	panel.add_child(back)


func _show_career_screen() -> void:
	var panel := _show_simple_screen("CAREER • PLAYER STATISTICS")
	var stats := Label.new()
	stats.text = "LEVEL " + str(player_level) + "  •  XP " + str(player_xp) + " / " + str(player_level * 100) + "\nCOINS: " + str(career_coins) + "\nMATCHES: " + str(career_matches) + "   WINS: " + str(career_wins) + "\nKILLS: " + str(career_kills) + "   DEATHS: " + str(career_deaths) + "\nDAMAGE: " + str(career_damage) + "   BEST KILLS: " + str(career_best_kills)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(stats)
	var history_button := Button.new()
	history_button.text = "VIEW MATCH HISTORY"
	history_button.pressed.connect(_show_match_history_screen)
	panel.add_child(history_button)
	var back := Button.new()
	back.text = "BACK"
	back.pressed.connect(_build_menu)
	panel.add_child(back)

func _show_match_history_screen() -> void:
	var panel := _show_simple_screen("MATCH HISTORY • LAST 20")
	if match_history.is_empty():
		var empty := Label.new()
		empty.text = "No completed online matches saved yet."
		panel.add_child(empty)
	else:
		for record_variant in match_history:
			var record: Dictionary = record_variant
			var line := Label.new()
			line.text = str(record.get("date", "")) + "  •  " + ("WIN" if bool(record.get("won", false)) else "PLAYED") + "\n" + str(record.get("mode", "")) + "  K " + str(record.get("kills", 0)) + "  D " + str(record.get("deaths", 0)) + "  DMG " + str(record.get("damage", 0)) + "  +" + str(record.get("xp", 0)) + " XP"
			line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			panel.add_child(line)
			panel.add_child(HSeparator.new())
	var back := Button.new()
	back.text = "BACK"
	back.pressed.connect(_show_career_screen)
	panel.add_child(back)


func _character_unlock_level(character: String) -> int:
	match character:
		"KAIRO", "NYX": return 1
		"MIRA": return 5
		"ROOK": return 15
		"VEX": return 30
		"SABLE": return 50
		"ORION": return 70
	return 999

func _character_coin_price(character: String) -> int:
	match character:
		"KAIRO", "NYX": return 0
		"MIRA": return 600
		"ROOK": return 1200
		"VEX": return 2500
		"SABLE": return 4000
		"ORION": return 6000
	return 999999

func _daily_mission_summary() -> String:
	return "1. PLAY 2 MATCHES: " + str(mini(daily_mission_matches, 2)) + "/2  •  75 COINS + 50 XP\n2. GET 3 KILLS: " + str(mini(daily_mission_kills, 3)) + "/3  •  100 COINS + 75 XP\n3. DEAL 500 DAMAGE: " + str(mini(daily_mission_damage, 500)) + "/500  •  100 COINS + 75 XP\n4. WIN 1 MATCH: " + str(mini(daily_mission_wins, 1)) + "/1  •  150 COINS + 100 XP\n5. COLLECT 5 SUPPLIES: " + str(mini(daily_mission_loot, 5)) + "/5  •  75 COINS + 50 XP\nComplete each task to claim its reward once per day."

func _claim_completed_daily_tasks() -> void:
	var tasks := [["PLAY_2", daily_mission_matches >= 2, 75, 50], ["KILL_3", daily_mission_kills >= 3, 100, 75], ["DAMAGE_500", daily_mission_damage >= 500, 100, 75], ["WIN_1", daily_mission_wins >= 1, 150, 100], ["LOOT_5", daily_mission_loot >= 5, 75, 50]]
	for task in tasks:
		var task_id := str(task[0])
		if bool(task[1]) and not daily_claimed.has(task_id):
			daily_claimed.append(task_id)
			career_coins += int(task[2])
			player_xp += int(task[3])
	_process_level_ups()
	_save_local_settings()

func _show_rewards_screen() -> void:
	_reset_daily_missions_if_needed()
	var panel := _show_simple_screen("DAILY REWARDS • MISSIONS")
	var login := Label.new()
	login.text = "DAILY LOGIN: +25 COINS • +25 XP\nTODAY'S LOGIN: " + ("CLAIMED" if daily_login_date == Time.get_date_string_from_system() else "AVAILABLE")
	login.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(login)
	var missions := Label.new()
	missions.text = _daily_mission_summary()
	missions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(missions)
	var reward_info := Label.new()
	reward_info.text = "MATCH REWARD: +50 XP +25 COINS\nEACH KILL: +25 XP +10 COINS\nWIN BONUS: +200 XP +100 COINS\nLEVEL UP: BONUS +50 COINS"
	panel.add_child(reward_info)
	var back := Button.new()
	back.text = "BACK"
	back.pressed.connect(_build_menu)
	panel.add_child(back)

func _show_achievements_screen() -> void:
	var panel := _show_simple_screen("ACHIEVEMENTS")
	var achievements := ["FIRST MATCH", "VETERAN • 10 MATCHES", "FIRST VICTORY", "ELIMINATOR • 10 KILLS", "ELITE • 50 KILLS", "DAMAGE DEALER • 1000", "FIVE KILL GAME"]
	for achievement in achievements:
		var item := Label.new()
		item.text = ("UNLOCKED  ✓  " if unlocked_achievements.has(achievement) else "LOCKED  •  ") + achievement
		panel.add_child(item)
	var back := Button.new()
	back.text = "BACK"
	back.pressed.connect(_build_menu)
	panel.add_child(back)


# ------------------------------------------------------------
# LAST ZONE ORIGINAL CONTENT SYSTEMS (local prototype, saved per device)
# ------------------------------------------------------------
func _content_button(parent: VBoxContainer, caption: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 44
	button.pressed.connect(callback)
	parent.add_child(button)

func _content_label(parent: VBoxContainer, caption: String) -> Label:
	var label := Label.new()
	label.text = caption
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func _content_back(panel: VBoxContainer, callback: Callable = Callable()) -> void:
	var back := Button.new()
	back.text = "BACK"
	back.custom_minimum_size.y = 44
	back.pressed.connect(callback if callback.is_valid() else Callable(self, "_build_menu"))
	panel.add_child(back)

func _show_character_screen() -> void:
	var panel := _show_simple_screen("OPERATORS • CHARACTER SKILLS")
	_content_label(panel, "Choose an owned operator. Each operator has one unique Active Skill. Equip three different Passive Skills.")
	for data in [
		["KAIRO", "BULWARK PULSE", "Adds 35 armor instantly"],
		["NYX", "VOLT DASH", "Boosts movement speed for 8 seconds"],
		["MIRA", "FIELD MEDIC", "Restores health and regenerates health"],
		["ROOK", "SCAVENGER INSTINCT", "Restores 45 reserve rounds"],
		["VEX", "PHASE RUN", "High-speed movement for 7 seconds"],
		["SABLE", "ECHO SCAN", "Reveals nearby supply locations"],
		["ORION", "LAST STAND", "Adds 50 armor and regenerates health"]
	]:
		var character_name := str(data[0])
		var skill_name := str(data[1])
		var row := HBoxContainer.new()
		panel.add_child(row)
		var description := Label.new()
		description.text = character_name + " • " + skill_name + "\n" + str(data[2])
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(description)
		var action := Button.new()
		var required_level := _character_unlock_level(character_name)
		var price := _character_coin_price(character_name)
		var is_owned := owned_characters.has(character_name)
		action.text = ("ACTIVE" if selected_character == character_name else "SELECT") if is_owned else ("LEVEL " + str(required_level) if player_level < required_level else "UNLOCK • " + str(price))
		action.disabled = not is_owned and (player_level < required_level or career_coins < price)
		action.pressed.connect(func():
			if not owned_characters.has(character_name):
				if player_level < required_level or career_coins < price: return
				career_coins -= price
				owned_characters.append(character_name)
			selected_character = character_name
			selected_skill = _character_active_skill(character_name)
			_save_local_settings()
			_show_character_screen()
		)
		row.add_child(action)
		panel.add_child(HSeparator.new())
	_content_label(panel, "ACTIVE SKILL • " + selected_skill + "\n" + _active_skill_description(selected_skill) + "\nCooldown: " + str(_active_skill_cooldown(selected_skill)) + " seconds")
	_content_label(panel, "PASSIVE SKILL LOADOUT • THREE SLOTS")
	for slot_index in range(3):
		var row := HBoxContainer.new()
		panel.add_child(row)
		var label := Label.new()
		label.text = "SLOT " + str(slot_index + 1) + " • " + equipped_passive_skills[slot_index]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var prev := Button.new()
		prev.text = "PREV"
		prev.pressed.connect(func():
			passive_slot_cursor = slot_index
			_cycle_passive_skill(-1)
			_show_character_screen()
		)
		row.add_child(prev)
		var next := Button.new()
		next.text = "NEXT"
		next.pressed.connect(func():
			passive_slot_cursor = slot_index
			_cycle_passive_skill(1)
			_show_character_screen()
		)
		row.add_child(next)
	_content_label(panel, "PASSIVES • UNLOCK BY LEVEL")
	for passive in _passive_skill_catalog():
		var info := Label.new()
		info.text = str(passive[0]) + " • " + str(passive[2]) + (" [UNLOCKED]" if player_level >= int(passive[1]) else " [LEVEL " + str(passive[1]) + "]")
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(info)
	_content_label(panel, "LEVEL " + str(player_level) + " • COINS " + str(career_coins) + "\nOwned: " + ", ".join(owned_characters))
	_content_back(panel)

func _character_active_skill(character: String) -> String:
	match character:
		"KAIRO": return "BULWARK PULSE"
		"NYX": return "VOLT DASH"
		"MIRA": return "FIELD MEDIC"
		"ROOK": return "SCAVENGER INSTINCT"
		"VEX": return "PHASE RUN"
		"SABLE": return "ECHO SCAN"
		"ORION": return "LAST STAND"
	return "BULWARK PULSE"

func _active_skill_description(skill: String) -> String:
	match skill:
		"BULWARK PULSE": return "Instantly grants 35 armor."
		"VOLT DASH": return "Increases sprint speed for 8 seconds."
		"FIELD MEDIC": return "Restores 25 health and regenerates up to 24 more."
		"SCAVENGER INSTINCT": return "Restores 45 reserve ammunition."
		"PHASE RUN": return "Increases movement speed for 7 seconds."
		"ECHO SCAN": return "Highlights nearby supplies with a scan pulse."
		"LAST STAND": return "Grants 50 armor and temporary health regeneration."
	return "Operator combat ability."

func _active_skill_cooldown(skill: String) -> int:
	match skill:
		"VOLT DASH", "PHASE RUN": return 50
		"FIELD MEDIC", "ECHO SCAN": return 55
		"LAST STAND": return 65
		"SCAVENGER INSTINCT": return 50
	return 45

func _passive_skill_catalog() -> Array:
	return [
		["QUICK HANDS", 1, "Reload 18% faster"],
		["FIELD MEDIC", 1, "Medkits restore 15 extra health"],
		["SCAVENGER", 1, "Ammo pickups grant 20% more"],
		["SPRINTER", 15, "Movement speed +0.5"],
		["SHARP EYE", 25, "Weapon spread reduced by 15%"],
		["FORTIFIED", 35, "Start each local match with 10 armor"],
		["TACTICAL FOCUS", 45, "Active skill cooldowns reduced by 5 seconds"],
		["FIELD SURVIVOR", 60, "Skill regeneration increased by 1 health per second"]
	]

func _cycle_passive_skill(direction: int) -> void:
	var catalog := _passive_skill_catalog()
	var current_index := 0
	for i in range(catalog.size()):
		if str(catalog[i][0]) == equipped_passive_skills[passive_slot_cursor]:
			current_index = i
	for attempt in range(catalog.size()):
		current_index = posmod(current_index + direction, catalog.size())
		var candidate := str(catalog[current_index][0])
		var duplicate := false
		for slot in range(3):
			if slot != passive_slot_cursor and equipped_passive_skills[slot] == candidate:
				duplicate = true
		if player_level >= int(catalog[current_index][1]) and not duplicate:
			equipped_passive_skills[passive_slot_cursor] = candidate
			break
	_save_local_settings()

func _show_bundle_screen() -> void:
	var panel := _show_simple_screen("OUTFIT VAULT • BUNDLES")
	_content_label(panel, "Original cosmetic bundles. Purchases use earned in-game coins and are saved on this device.")
	var bundles := [
		["FIELD OPERATIVE", "STARTER", 0, "KAIRO • standard tactical field uniform", 1],
		["EMBER PHANTOM", "RARE", 650, "NYX • ember-accented combat uniform", 4],
		["NEON WRAITH", "EPIC", 950, "MIRA • reactive neon urban outfit", 10],
		["IRON SENTINEL", "LEGENDARY", 1400, "ROOK • heavy armored elite suit", 18],
		["RECRUIT FIELD KIT", "COMMON", 0, "KAIRO • recruit uniform reward", 3],
		["URBAN SCOUT SET", "RARE", 0, "NYX • urban scout reward", 8],
		["SHADOW STRIKE BUNDLE", "EPIC", 0, "MIRA • masked stealth outfit", 20],
		["SAMURAI GUARD BUNDLE", "EPIC", 0, "ROOK • original masked samurai armour", 35],
		["GOLDEN FRONTIER BUNDLE", "LEGENDARY", 0, "VEX • golden elite battle suit", 45],
		["DRAGON WARDEN BUNDLE", "MYTHIC", 0, "SABLE • dragon-inspired armoured outfit", 60],
		["LEGENDARY PHANTOM BUNDLE", "MYTHIC", 0, "ORION • endgame phantom armour", 80]
	]
	for entry in bundles:
		var item_name := str(entry[0])
		var price := int(entry[2])
		var required_level := int(entry[4])
		var row := HBoxContainer.new()
		panel.add_child(row)
		var info := Label.new()
		info.text = item_name + "  •  " + str(entry[1]) + "\n" + str(entry[3]) + "\n" + ("OWNED" if owned_bundles.has(item_name) else ("LOCKED • LEVEL " + str(required_level) if player_level < required_level else str(price) + " COINS"))
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(info)
		var action := Button.new()
		action.text = "EQUIP" if owned_bundles.has(item_name) else ("LOCKED" if player_level < required_level else "BUY")
		action.disabled = not owned_bundles.has(item_name) and player_level < required_level
		action.pressed.connect(func():
			if player_level < required_level: return
			if owned_bundles.has(item_name):
				equipped_bundle = item_name
				_apply_equipped_bundle()
				_save_local_settings()
				_show_bundle_screen()
			elif price == 0 or career_coins >= price:
				career_coins -= price
				owned_bundles.append(item_name)
				equipped_bundle = item_name
				_apply_equipped_bundle()
				_save_local_settings()
				_show_bundle_screen()
			else:
				info.text = item_name + "\nNOT ENOUGH COINS. Earn coins by playing matches."
		)
		row.add_child(action)
		panel.add_child(HSeparator.new())
	_content_label(panel, "COINS: " + str(career_coins) + "  •  EQUIPPED: " + equipped_bundle)
	_content_back(panel)

func _apply_equipped_bundle() -> void:
	if local_player == null:
		return
	var visual := local_player.get_node_or_null("CharacterVisual")
	if visual == null:
		return
	var tint := Color(0.12, 0.34, 0.48)
	match equipped_bundle:
		"EMBER PHANTOM": tint = Color(0.48, 0.12, 0.08)
		"NEON WRAITH": tint = Color(0.12, 0.42, 0.48)
		"IRON SENTINEL": tint = Color(0.32, 0.34, 0.38)
	for part_name in ["Torso", "LeftArmPivot/UpperArm", "RightArmPivot/UpperArm"]:
		var part := visual.get_node_or_null(part_name) as MeshInstance3D
		if part:
			var material := StandardMaterial3D.new()
			material.albedo_color = tint
			material.roughness = 0.75
			part.material_override = material

func _show_emote_screen() -> void:
	var panel := _show_simple_screen("EMOTE COLLECTION")
	_content_label(panel, "Equip and preview original character emotes. Select an emote below, then use the match emote wheel.")
	var emotes := [["SALUTE", 0], ["VICTORY POSE", 250], ["HYPE DANCE", 400], ["ROBOT GROOVE", 600], ["SQUAD CELEBRATION", 800]]
	for entry in emotes:
		var emote_name := str(entry[0])
		var price := int(entry[1])
		var row := HBoxContainer.new()
		panel.add_child(row)
		var info := Label.new()
		info.text = emote_name + "  •  " + ("OWNED" if owned_emotes.has(emote_name) else str(price) + " COINS")
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var action := Button.new()
		action.text = "EQUIP" if owned_emotes.has(emote_name) else "BUY"
		action.pressed.connect(func():
			if owned_emotes.has(emote_name):
				equipped_emote = emote_name
				_save_local_settings()
				_show_emote_screen()
			elif career_coins >= price:
				career_coins -= price
				owned_emotes.append(emote_name)
				equipped_emote = emote_name
				_save_local_settings()
				_show_emote_screen()
			else:
				info.text = emote_name + " • NOT ENOUGH COINS"
		)
		row.add_child(action)
		var preview := Button.new()
		preview.text = "PREVIEW"
		preview.pressed.connect(func():
			equipped_emote = emote_name
			_play_equipped_emote()
		)
		row.add_child(preview)
	_content_label(panel, "EQUIPPED EMOTE: " + equipped_emote + "  •  COINS: " + str(career_coins))
	_content_back(panel)

func _play_equipped_emote() -> void:
	if local_player == null or is_dead:
		return
	if emote_status_label:
		emote_status_label.text = "EMOTE: " + equipped_emote
	var visual := local_player.get_node_or_null("CharacterVisual") as Node3D
	if visual and not emote_animation_busy:
		_play_emote_animation(visual, equipped_emote)

func _show_armory_screen() -> void:
	var panel := _show_simple_screen("ARMORY • WEAPON COLLECTION")
	_content_label(panel, "Real-world weapon designations are used where applicable. Upgrade levels are saved locally. Premium upgrades are not yet synced to an online account.")
	var guns := [
		["ASSAULT RIFLE", "M4A1 PLATFORM", 25.0],
		["SMG", "MP5 PLATFORM", 15.0],
		["SHOTGUN", "M1014 PLATFORM", 65.0]
	]
	for gun in guns:
		var key := str(gun[0])
		var level := int(weapon_upgrade_levels.get(key, 0))
		var damage_value := float(gun[2]) + float(level) * 2.0
		var info := _content_label(panel, str(gun[1]) + "  •  " + key + "\nDAMAGE: " + str(snappedf(damage_value, 0.1)) + "  •  UPGRADE LEVEL: " + str(level) + "/5")
		var upgrade := Button.new()
		upgrade.text = "UPGRADE • " + str(250 + level * 150) + " COINS" if level < 5 else "MAX LEVEL"
		upgrade.disabled = level >= 5
		upgrade.pressed.connect(func():
			var cost := 250 + level * 150
			if career_coins < cost:
				info.text = "NOT ENOUGH COINS • PLAY MATCHES TO EARN MORE"
				return
			career_coins -= cost
			weapon_upgrade_levels[key] = level + 1
			var index := weapon_names.find(key)
			if index >= 0:
				weapon_damage[index] = float(gun[2]) + float(level + 1) * 2.0
			_save_local_settings()
			_show_armory_screen()
		)
		panel.add_child(upgrade)
		panel.add_child(HSeparator.new())
	_content_label(panel, "COINS: " + str(career_coins) + "\nWeapon damage upgrades are capped at +10 base damage per gun.")
	_content_back(panel)

func _show_gloo_screen() -> void:
	var panel := _show_simple_screen("GLOO WALL COLLECTION")
	_content_label(panel, "Deployable temporary cover. Choose an original wall finish; wall skins are cosmetic in this prototype.")
	for entry in [["TACTICAL BLUE", 0], ["CRIMSON GRID", 300], ["ARCTIC SHIELD", 450], ["GOLD CIRCUIT", 700]]:
		var skin := str(entry[0])
		var price := int(entry[1])
		var row := HBoxContainer.new()
		panel.add_child(row)
		var info := Label.new()
		info.text = skin + "  •  " + ("OWNED" if owned_gloo_skins.has(skin) else str(price) + " COINS")
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var action := Button.new()
		action.text = "EQUIP" if owned_gloo_skins.has(skin) else "BUY"
		action.pressed.connect(func():
			if owned_gloo_skins.has(skin):
				equipped_gloo_skin = skin
			elif career_coins >= price:
				career_coins -= price
				owned_gloo_skins.append(skin)
				equipped_gloo_skin = skin
			else:
				info.text = skin + " • NOT ENOUGH COINS"
			_save_local_settings()
			_show_gloo_screen()
		)
		row.add_child(action)
	_content_label(panel, "EQUIPPED WALL: " + equipped_gloo_skin + "  •  COINS: " + str(career_coins))
	_content_back(panel)

func _activate_character_skill() -> void:
	if local_player == null or is_dead or skill_cooldown > 0.0:
		if status_label: status_label.text = "SKILL COOLDOWN: " + str(ceili(skill_cooldown)) + "s"
		return
	var cooldown := _active_skill_cooldown(selected_skill)
	if equipped_passive_skills.has("TACTICAL FOCUS"):
		cooldown = maxi(25, cooldown - 5)
	skill_cooldown = float(cooldown)
	skill_active = true
	skill_duration = 8.0
	skill_regen_rate = 0.0
	skill_speed_bonus = 0.0
	skill_reload_bonus = 0.0
	match selected_skill:
		"BULWARK PULSE":
			armor = minf(100.0, armor + 35.0)
			status_label.text = "BULWARK PULSE • +35 ARMOR"
		"VOLT DASH":
			skill_speed_bonus = 3.0
			status_label.text = "VOLT DASH • SPEED BOOST"
		"FIELD MEDIC":
			health = minf(100.0, health + 25.0)
			skill_regen_rate = 3.0 + (1.0 if equipped_passive_skills.has("FIELD SURVIVOR") else 0.0)
			status_label.text = "FIELD MEDIC • HEAL + REGEN"
		"SCAVENGER INSTINCT":
			reserve_ammo += 45
			status_label.text = "SCAVENGER INSTINCT • +45 AMMO"
		"PHASE RUN":
			skill_speed_bonus = 4.5
			skill_duration = 7.0
			status_label.text = "PHASE RUN • HIGH MOBILITY"
		"ECHO SCAN":
			_update_nearby_loot()
			status_label.text = "ECHO SCAN • SUPPLIES REVEALED"
		"LAST STAND":
			armor = minf(100.0, armor + 50.0)
			skill_regen_rate = 2.0 + (1.0 if equipped_passive_skills.has("FIELD SURVIVOR") else 0.0)
			skill_duration = 8.0
			status_label.text = "LAST STAND • DEFENCE ACTIVE"
	_spawn_skill_pulse()
	_update_nearby_loot()
	_update_weapon_hud()


# Procedural original operator rig: articulated limbs, body-type proportions and cosmetic attachments.
func _build_operator_visual(parent: Node3D, is_local: bool, gender: String) -> void:
	var uniform := Color(0.12, 0.34, 0.48) if is_local else Color(0.48, 0.20, 0.12)
	var body_width := 0.68 if gender == "FEMALE" else 0.74
	_add_character_part(parent, "Torso", Vector3(0, 1.13, 0), Vector3(body_width, 0.78, 0.38), uniform)
	_add_character_part(parent, "Vest", Vector3(0, 1.18, -0.015), Vector3(body_width + 0.08, 0.48, 0.41), Color(0.16, 0.19, 0.18))
	_add_character_part(parent, "Head", Vector3(0, 1.82, 0), Vector3(0.40, 0.46, 0.40), Color(0.72, 0.53, 0.39), true)
	_add_character_part(parent, "Helmet", Vector3(0, 2.03, 0), Vector3(0.50, 0.22, 0.48), Color(0.18, 0.25, 0.19), true)
	_add_character_part(parent, "ChestPlate", Vector3(0, 1.22, -0.225), Vector3(0.34, 0.32, 0.035), Color(0.28, 0.32, 0.30))
	_add_character_part(parent, "Backpack", Vector3(0, 1.12, 0.27), Vector3(0.48, 0.56, 0.20), Color(0.10, 0.14, 0.13))
	for side in [-1.0, 1.0]:
		var arm := Node3D.new()
		arm.name = "LeftArmPivot" if side < 0.0 else "RightArmPivot"
		arm.position = Vector3(side * 0.43, 1.48, 0)
		parent.add_child(arm)
		_add_character_part(arm, "UpperArm", Vector3(0, -0.22, 0), Vector3(0.21, 0.50, 0.23), uniform, true)
		_add_character_part(arm, "Forearm", Vector3(0, -0.52, -0.015), Vector3(0.19, 0.34, 0.20), Color(0.20, 0.23, 0.22), true)
		_add_character_part(parent, "ShoulderPad" + str(int(side)), Vector3(side * 0.46, 1.49, 0), Vector3(0.30, 0.20, 0.30), Color(0.25, 0.29, 0.27), true)
		var leg := Node3D.new()
		leg.name = "LeftLegPivot" if side < 0.0 else "RightLegPivot"
		leg.position = Vector3(side * 0.19, 0.78, 0)
		parent.add_child(leg)
		_add_character_part(leg, "Thigh", Vector3(0, -0.18, 0), Vector3(0.27, 0.46, 0.30), Color(0.12, 0.14, 0.16), true)
		_add_character_part(leg, "Shin", Vector3(0, -0.48, 0), Vector3(0.23, 0.34, 0.25), Color(0.16, 0.18, 0.19), true)
		_add_character_part(leg, "Boot", Vector3(0, -0.67, -0.07), Vector3(0.30, 0.18, 0.40), Color(0.07, 0.08, 0.07))
	_add_character_part(parent, "UtilityBelt", Vector3(0, 0.83, 0), Vector3(0.70, 0.12, 0.40), Color(0.08, 0.10, 0.09))
	_add_character_part(parent, "LeftPouch", Vector3(-0.30, 0.86, -0.22), Vector3(0.16, 0.20, 0.12), Color(0.22, 0.24, 0.20))
	_add_character_part(parent, "RightPouch", Vector3(0.30, 0.86, -0.22), Vector3(0.16, 0.20, 0.12), Color(0.22, 0.24, 0.20))

func _rebuild_local_character_visual() -> void:
	if local_player == null:
		return
	var old := local_player.get_node_or_null("CharacterVisual")
	if old:
		old.queue_free()
	var visual := Node3D.new()
	visual.name = "CharacterVisual"
	local_player.add_child(visual)
	_build_operator_visual(visual, true, selected_gender)
	_apply_equipped_bundle()

func _update_operator_motion(visual: Node3D, moving: bool, delta: float) -> void:
	var phase := float(Time.get_ticks_msec()) * (0.012 if sprint_enabled else 0.008)
	var amount := 0.62 if sprint_enabled else 0.38
	for side in [-1.0, 1.0]:
		var arm := visual.get_node_or_null("LeftArmPivot" if side < 0.0 else "RightArmPivot") as Node3D
		var leg := visual.get_node_or_null("LeftLegPivot" if side < 0.0 else "RightLegPivot") as Node3D
		var swing := sin(phase + (PI if side < 0.0 else 0.0)) * amount if moving else 0.0
		if arm and not emote_animation_busy:
			arm.rotation.x = lerpf(arm.rotation.x, swing * 0.75, minf(1.0, delta * 10.0))
		if leg and not emote_animation_busy:
			leg.rotation.x = lerpf(leg.rotation.x, -swing, minf(1.0, delta * 10.0))

func _play_emote_animation(visual: Node3D, emote_name: String) -> void:
	emote_animation_busy = true
	var left := visual.get_node_or_null("LeftArmPivot") as Node3D
	var right := visual.get_node_or_null("RightArmPivot") as Node3D
	var l_leg := visual.get_node_or_null("LeftLegPivot") as Node3D
	var r_leg := visual.get_node_or_null("RightLegPivot") as Node3D
	var tween := create_tween()
	tween.set_parallel(true)
	if emote_name == "SALUTE":
		if right: tween.tween_property(right, "rotation:z", -1.9, 0.28)
	elif emote_name == "VICTORY POSE":
		if left: tween.tween_property(left, "rotation:z", 2.4, 0.25)
		if right: tween.tween_property(right, "rotation:z", -2.4, 0.25)
	elif emote_name == "HYPE DANCE" or emote_name == "SQUAD CELEBRATION":
		if left: tween.tween_property(left, "rotation:z", 2.2, 0.22)
		if right: tween.tween_property(right, "rotation:z", -2.2, 0.22)
		if l_leg: tween.tween_property(l_leg, "rotation:x", -0.65, 0.22)
		if r_leg: tween.tween_property(r_leg, "rotation:x", 0.65, 0.22)
	else:
		if left: tween.tween_property(left, "rotation:z", 1.4, 0.18)
		if right: tween.tween_property(right, "rotation:z", -1.4, 0.18)
	tween.set_parallel(false)
	tween.tween_interval(0.55)
	tween.tween_callback(func():
		var reset := create_tween()
		reset.set_parallel(true)
		for node in [left, right, l_leg, r_leg]:
			if node and is_instance_valid(node):
				reset.tween_property(node, "rotation", Vector3.ZERO, 0.28)
		reset.set_parallel(false)
		reset.tween_callback(func(): emote_animation_busy = false)
	)

func _toggle_emote_wheel() -> void:
	if hud == null:
		return
	var existing := hud.get_node_or_null("EmoteWheel")
	if existing:
		existing.queue_free()
		emote_wheel_open = false
		return
	emote_wheel_open = true
	var wheel := PanelContainer.new()
	wheel.name = "EmoteWheel"
	wheel.position = Vector2(390, 230)
	wheel.custom_minimum_size = Vector2(340, 300)
	hud.add_child(wheel)
	var list := VBoxContainer.new()
	wheel.add_child(list)
	var title := Label.new()
	title.text = "EMOTE WHEEL  •  SELECT"
	list.add_child(title)
	for emote_name in ["SALUTE", "VICTORY POSE", "HYPE DANCE", "ROBOT GROOVE", "SQUAD CELEBRATION"]:
		var button := Button.new()
		button.text = emote_name + ("  ✓" if equipped_emote == emote_name else "")
		button.pressed.connect(func():
			equipped_emote = emote_name
			_play_equipped_emote()
			_save_local_settings()
			wheel.queue_free()
			emote_wheel_open = false
		)
		list.add_child(button)
	var close := Button.new()
	close.text = "CLOSE"
	close.pressed.connect(func(): wheel.queue_free(); emote_wheel_open = false)
	list.add_child(close)

func _spawn_skill_pulse() -> void:
	if local_player == null:
		return
	var pulse := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 0.12
	mesh.radial_segments = 24
	mesh.rings = 6
	pulse.mesh = mesh
	pulse.position = local_player.global_position + Vector3(0, 0.12, 0)
	pulse.scale = Vector3(0.5, 0.08, 0.5)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.15, 0.72, 1.0, 0.55)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pulse.material_override = material
	add_child(pulse)
	var tween := create_tween()
	tween.tween_property(pulse, "scale", Vector3(5.0, 0.08, 5.0), 0.55)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, 0.55)
	tween.tween_callback(pulse.queue_free)

func _deploy_gloo_wall() -> void:
	if local_player == null or is_dead or gloo_wall_charges <= 0:
		if status_label: status_label.text = "NO GLOO WALL CHARGES"
		return
	var forward := -local_player.global_basis.z
	var wall_position := local_player.global_position + forward * 2.4
	var wall := StaticBody3D.new()
	wall.name = "GlooWall_" + str(Time.get_ticks_msec())
	wall.global_position = wall_position + Vector3(0, 1.35, 0)
	wall.rotation.y = local_player.rotation.y
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4.2, 2.7, 0.45)
	collision.shape = shape
	wall.add_child(collision)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = shape.size
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	match equipped_gloo_skin:
		"CRIMSON GRID": material.albedo_color = Color(0.65, 0.12, 0.16, 0.88)
		"ARCTIC SHIELD": material.albedo_color = Color(0.25, 0.75, 0.9, 0.88)
		"GOLD CIRCUIT": material.albedo_color = Color(0.78, 0.58, 0.16, 0.88)
		_: material.albedo_color = Color(0.12, 0.48, 0.78, 0.88)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.35
	visual.material_override = material
	wall.add_child(visual)
	add_child(wall)
	gloo_wall_charges -= 1
	if gloo_wall_button: gloo_wall_button.text = "GLOO WALL (" + str(gloo_wall_charges) + ")"
	if status_label: status_label.text = "GLOO WALL DEPLOYED • " + equipped_gloo_skin

func _build_menu() -> void:
	menu_root = Control.new()
	menu_root.name = "MainMenu"
	menu_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_root)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.018, 0.045, 0.065, 1.0)
	menu_root.add_child(background)
	var glow := ColorRect.new()
	glow.position = Vector2(0, 0)
	glow.size = Vector2(1280, 8)
	glow.color = Color(0.12, 0.72, 0.66, 1.0)
	menu_root.add_child(glow)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_root.add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(420, 0)
	column.add_theme_constant_override("separation", 14)
	center.add_child(column)
	var logo := Label.new()
	logo.text = "LAST ZONE"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_font_size_override("font_size", 52)
	logo.add_theme_color_override("font_color", Color(0.35, 0.95, 0.83))
	column.add_child(logo)
	var subtitle := Label.new()
	subtitle.text = "BATTLE ROYALE  •  SURVIVE THE ZONE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color(0.72, 0.82, 0.85))
	column.add_child(subtitle)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 20
	column.add_child(spacer)
	_add_menu_button(column, _tr("PLAY"), _on_play_pressed)
	_add_menu_button(column, _tr("PLAYER PROFILE"), _show_profile_screen)
	_add_menu_button(column, "CAREER & MATCH HISTORY", _show_career_screen)
	_add_menu_button(column, "DAILY REWARDS & MISSIONS", _show_rewards_screen)
	_add_menu_button(column, "CHARACTERS & SKILLS", _show_character_screen)
	_add_menu_button(column, "OUTFIT BUNDLES & VAULT", _show_bundle_screen)
	_add_menu_button(column, "EMOTE COLLECTION", _show_emote_screen)
	_add_menu_button(column, "WEAPON ARMORY", _show_armory_screen)
	_add_menu_button(column, "GLOO WALL COLLECTION", _show_gloo_screen)
	_add_menu_button(column, "ACHIEVEMENTS", _show_achievements_screen)
	_add_menu_button(column, _tr("SETTINGS"), _show_settings_screen)
	_add_menu_button(column, _tr("LANGUAGE"), _show_language_screen)
	var footer := Label.new()
	footer.text = "VERSION 0.1.1  •  EARLY ACCESS PROTOTYPE"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 11)
	footer.add_theme_color_override("font_color", Color(0.45, 0.58, 0.62))
	column.add_child(footer)

func _add_menu_button(parent: VBoxContainer, caption: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 54)
	button.add_theme_font_size_override("font_size", 19)
	button.pressed.connect(callback)
	parent.add_child(button)

func _clear_menu() -> void:
	if menu_root:
		menu_root.queue_free()
	menu_root = null

func _show_simple_screen(screen_title: String) -> VBoxContainer:
	_clear_menu()
	menu_root = Control.new()
	menu_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_root)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.018, 0.045, 0.065, 1.0)
	menu_root.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_root.add_child(center)
	var panel := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(430, 0)
	panel.add_theme_constant_override("separation", 14)
	center.add_child(panel)
	var title := Label.new()
	title.text = screen_title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.35, 0.95, 0.83))
	panel.add_child(title)
	return panel

func _show_profile_screen() -> void:
	var panel := _show_simple_screen(_tr("PLAYER PROFILE"))
	var info := Label.new()
	info.text = _tr("LOCAL PROFILE — ONLINE SIGN-IN COMING LATER")
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(info)
	var name_edit := LineEdit.new()
	name_edit.placeholder_text = _tr("Enter player name")
	name_edit.text = profile_name
	name_edit.custom_minimum_size.y = 48
	panel.add_child(name_edit)
	var save_button := Button.new()
	save_button.text = _tr("SAVE PROFILE")
	save_button.custom_minimum_size.y = 48
	save_button.pressed.connect(func():
		var new_name := name_edit.text.strip_edges()
		if new_name.length() >= 3:
			profile_name = new_name.left(16)
			_save_local_settings()
			_show_profile_screen()
		else:
			info.text = _tr("NAME MUST BE 3–16 CHARACTERS")
	)
	panel.add_child(save_button)
	var back := Button.new()
	back.text = _tr("BACK")
	back.pressed.connect(_build_menu)
	panel.add_child(back)

func _show_settings_screen() -> void:
	var panel := _show_simple_screen(_tr("SETTINGS"))
	var volume_label := Label.new()
	volume_label.text = _tr("MASTER VOLUME") + ": " + str(roundi(master_volume * 100)) + "%"
	panel.add_child(volume_label)
	var volume := HSlider.new()
	volume.min_value = 0.0
	volume.max_value = 1.0
	volume.step = 0.05
	volume.value = master_volume
	volume.value_changed.connect(func(value: float):
		master_volume = value
		volume_label.text = _tr("MASTER VOLUME") + ": " + str(roundi(value * 100)) + "%"
		_apply_audio_settings()
		_save_local_settings()
	)
	panel.add_child(volume)
	var music_label := Label.new()
	music_label.text = "MUSIC VOLUME: " + str(roundi(music_volume * 100)) + "%"
	panel.add_child(music_label)
	var music_slider := HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.value = music_volume
	music_slider.value_changed.connect(func(value: float):
		music_volume = value
		music_label.text = "MUSIC VOLUME: " + str(roundi(value * 100)) + "%"
		_apply_audio_settings()
		_save_local_settings()
	)
	panel.add_child(music_slider)
	var sfx_label := Label.new()
	sfx_label.text = "SOUND EFFECTS: " + str(roundi(sfx_volume * 100)) + "%"
	panel.add_child(sfx_label)
	var sfx_slider := HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = sfx_volume
	sfx_slider.value_changed.connect(func(value: float):
		sfx_volume = value
		sfx_label.text = "SOUND EFFECTS: " + str(roundi(value * 100)) + "%"
		_apply_audio_settings()
		_save_local_settings()
	)
	panel.add_child(sfx_slider)
	var quality_label := Label.new()
	quality_label.text = _tr("GRAPHICS QUALITY")
	panel.add_child(quality_label)
	var quality := OptionButton.new()
	quality.add_item(_tr("LOW"))
	quality.add_item(_tr("MEDIUM"))
	quality.add_item(_tr("HIGH"))
	quality.select(clampi(graphics_quality, 0, 2))
	quality.item_selected.connect(func(index: int):
		graphics_quality = index
		_apply_graphics_settings()
		_save_local_settings()
	)
	panel.add_child(quality)
	var back := Button.new()
	back.text = _tr("BACK")
	back.pressed.connect(_build_menu)
	panel.add_child(back)
	_apply_graphics_settings()

func _apply_graphics_settings() -> void:
	var viewport := get_viewport()
	if graphics_quality == 0:
		viewport.scaling_3d_scale = 0.65
	elif graphics_quality == 1:
		viewport.scaling_3d_scale = 0.85
	else:
		viewport.scaling_3d_scale = 1.0

func _show_language_screen() -> void:
	var panel := _show_simple_screen(_tr("LANGUAGE"))
	var language := OptionButton.new()
	language.add_item("English")
	language.add_item("සිංහල")
	language.select(0 if selected_language == "English" else 1)
	panel.add_child(language)
	var apply := Button.new()
	apply.text = _tr("SAVE LANGUAGE")
	apply.pressed.connect(func():
		selected_language = "English" if language.selected == 0 else "Sinhala"
		_save_local_settings()
		_build_menu()
	)
	panel.add_child(apply)
	var back := Button.new()
	back.text = _tr("BACK")
	back.pressed.connect(_build_menu)
	panel.add_child(back)

func _tr(key: String) -> String:
	if selected_language != "Sinhala":
		return key
	var translations := {
		"PLAY": "ක්‍රීඩා කරන්න",
		"PLAYER PROFILE": "ක්‍රීඩක පැතිකඩ",
		"SETTINGS": "සැකසුම්",
		"LANGUAGE": "භාෂාව",
		"BACK": "ආපසු",
		"MASTER VOLUME": "ප්‍රධාන ශබ්දය",
		"GRAPHICS QUALITY": "ග්‍රැෆික් ගුණාත්මකභාවය",
		"LOW": "අඩු",
		"MEDIUM": "මධ්‍යම",
		"HIGH": "ඉහළ",
		"SAVE LANGUAGE": "භාෂාව සුරකින්න",
		"SAVE PROFILE": "පැතිකඩ සුරකින්න",
		"Enter player name": "ක්‍රීඩක නම ඇතුළත් කරන්න",
		"LOCAL PROFILE — ONLINE SIGN-IN COMING LATER": "දේශීය පැතිකඩ — Online පිවිසුම පසුව",
		"NAME MUST BE 3–16 CHARACTERS": "නම අකුරු 3–16 අතර විය යුතුයි"
	}
	return str(translations.get(key, key))

func _on_play_pressed() -> void:
	_show_lobby_screen()

# ------------------------------------------------------------
# SYSTEMS 9–19: lobby, player card, progression display,
# friends/invites, party lobby, mode selection and match launch.
# Friends and party are local prototype UI until online services exist.
# ------------------------------------------------------------

func _show_lobby_screen() -> void:
	var panel := _show_simple_screen("LAST ZONE  /  MAIN LOBBY")
	panel.custom_minimum_size = Vector2(540, 0)

	var welcome := Label.new()
	welcome.text = "WELCOME BACK, " + profile_name.to_upper()
	welcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	welcome.add_theme_font_size_override("font_size", 23)
	panel.add_child(welcome)

	var avatar := Label.new()
	avatar.text = "◉"
	avatar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar.add_theme_font_size_override("font_size", 58)
	avatar.add_theme_color_override("font_color", Color(0.35, 0.95, 0.83))
	panel.add_child(avatar)

	var id_label := Label.new()
	id_label.text = "PLAYER ID: " + player_id
	id_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(id_label)

	var level_label := Label.new()
	level_label.text = "LEVEL " + str(player_level) + "     XP " + str(player_xp) + " / " + str(player_level * 100)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(level_label)

	var xp_bar := ProgressBar.new()
	xp_bar.max_value = player_level * 100
	xp_bar.value = player_xp
	xp_bar.custom_minimum_size.y = 14
	panel.add_child(xp_bar)

	var ranked_button := Button.new()
	ranked_button.text = "RANKED PROFILE • " + ranked_tier + " • " + str(ranked_points) + " RP"
	ranked_button.pressed.connect(_show_ranked_screen)
	panel.add_child(ranked_button)

	var profile_button := Button.new()
	profile_button.text = "EDIT PLAYER PROFILE"
	profile_button.pressed.connect(_show_profile_screen)
	panel.add_child(profile_button)

	var divider := HSeparator.new()
	panel.add_child(divider)

	var mode_title := Label.new()
	mode_title.text = "SELECT GAME MODE"
	mode_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(mode_title)

	var modes := OptionButton.new()
	for mode in ["Solo", "Duo", "Squad"]:
		modes.add_item(mode)
	modes.select(maxi(0, ["Solo", "Duo", "Squad"].find(selected_mode)))
	modes.item_selected.connect(func(index: int):
		selected_mode = ["Solo", "Duo", "Squad"][index]
		_save_local_settings()
		_show_lobby_screen()
	)
	panel.add_child(modes)

	var match_type_title := Label.new()
	match_type_title.text = "SELECT ONE OF 8 GAME MODES"
	match_type_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(match_type_title)

	var game_modes := ["Battle Royale", "Ranked Battle Royale", "Squad Strike", "Duel Zone", "Combat Academy", "World Forge", "Survival Events", "Private Operations"]
	var mode_picker := OptionButton.new()
	for mode_name in game_modes:
		mode_picker.add_item(mode_name)
	mode_picker.select(maxi(0, game_modes.find(selected_game_mode)))
	mode_picker.item_selected.connect(func(index: int):
		selected_game_mode = game_modes[index]
		match_type = _legacy_match_type_for_mode(selected_game_mode)
		_save_local_settings()
		_show_lobby_screen()
	)
	panel.add_child(mode_picker)

	var submode_title := Label.new()
	submode_title.text = "MODE VARIANT"
	submode_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(submode_title)
	var submode_picker := OptionButton.new()
	var submodes := _available_submodes(selected_game_mode)
	for variant in submodes:
		submode_picker.add_item(variant)
	submode_picker.select(maxi(0, submodes.find(selected_submode)))
	submode_picker.item_selected.connect(func(index: int):
		selected_submode = submodes[index]
		selected_mode = selected_submode if selected_game_mode == "Battle Royale" or selected_game_mode == "Ranked Battle Royale" else selected_mode
		_save_local_settings()
		_show_lobby_screen()
	)
	panel.add_child(submode_picker)

	var mode_description := Label.new()
	mode_description.text = _game_mode_description(selected_game_mode)
	mode_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mode_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mode_description.add_theme_font_size_override("font_size", 12)
	panel.add_child(mode_description)

	var capacity_title := Label.new()
	capacity_title.text = "BATTLE ROOM CAPACITY  •  UP TO " + str(MAX_PLAYERS) + " PLAYERS"
	capacity_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(capacity_title)

	var capacity_note := Label.new()
	capacity_note.text = "Target players per match: " + str(target_players) + " (server capacity setting)"
	capacity_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	capacity_note.add_theme_font_size_override("font_size", 12)
	panel.add_child(capacity_note)

	var team_limit := 1 if selected_mode == "Solo" else (2 if selected_mode == "Duo" else 4)
	var party_title := Label.new()
	party_title.text = "TEAM LOBBY  •  " + str(mini(team_limit, party_members.size() + 1)) + " / " + str(team_limit)
	party_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(party_title)

	var party_list := Label.new()
	var party_text := profile_name + "  (YOU)"
	for member in party_members:
		party_text += "\n" + member
	for slot in range(team_limit - mini(team_limit, party_members.size() + 1)):
		party_text += "\nOPEN TEAM SLOT"
	party_list.text = party_text
	party_list.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(party_list)

	var team_note := Label.new()
	team_note.text = "Team invitations require the online friends service."
	team_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	team_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	team_note.add_theme_color_override("font_color", Color(0.72, 0.82, 0.85))
	panel.add_child(team_note)

	var invite := Button.new()
	invite.text = "INVITE TEAMMATE  •  ONLINE SERVICE NOT READY"
	invite.disabled = true
	panel.add_child(invite)

	var friends_title := Label.new()
	friends_title.text = "FRIENDS LIST"
	friends_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(friends_title)

	var friend_entry := LineEdit.new()
	friend_entry.placeholder_text = "Add a friend's display name"
	panel.add_child(friend_entry)

	var add_friend := Button.new()
	add_friend.text = "SAVE FRIEND LOCALLY"
	add_friend.pressed.connect(func():
		var friend_name := friend_entry.text.strip_edges()
		if friend_name.length() < 3:
			team_note.text = "Friend name must contain at least 3 characters."
		elif friend_name == profile_name:
			team_note.text = "You cannot add your own player name."
		elif friend_names.has(friend_name):
			team_note.text = "This friend is already saved."
		else:
			friend_names.append(friend_name.left(20))
			_save_local_settings()
			_show_lobby_screen()
	)
	panel.add_child(add_friend)

	var friends_info := Label.new()
	if friend_names.is_empty():
		friends_info.text = "No saved friends yet."
	else:
		var saved_friend_text := "SAVED FRIENDS  •  OFFLINE"
		for friend_name in friend_names:
			saved_friend_text += "\n" + friend_name
		friends_info.text = saved_friend_text
	friends_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	friends_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(friends_info)

	var online_note := Label.new()
	online_note.text = "Online status and real invitations will activate after backend matchmaking is connected."
	online_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_note.add_theme_font_size_override("font_size", 12)
	panel.add_child(online_note)

	var match_info := Label.new()
	if match_type == "Training Ground":
		match_info.text = "Practice movement and aim alone. No online opponents."
	elif match_type == "Custom Match":
		match_info.text = "Private room setup preview. Online room hosting is not connected yet."
	else:
		match_info.text = "Battle Royale • " + selected_mode + " • Up to " + str(target_players) + " players"
	match_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	match_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match_info.add_theme_font_size_override("font_size", 12)
	panel.add_child(match_info)

	if selected_game_mode in ["Battle Royale", "Ranked Battle Royale"]:
		var server_title := Label.new()
		server_title.text = "ONLINE SERVER ADDRESS"
		server_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(server_title)
		var server_input := LineEdit.new()
		server_input.placeholder_text = "Enter public server IP or hostname"
		server_input.text = server_address
		server_input.clear_button_enabled = true
		panel.add_child(server_input)
		var server_hint := Label.new()
		server_hint.text = "This is a direct server connection, not global matchmaking. Do not use 127.0.0.1 for internet matches."
		server_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		server_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		server_hint.add_theme_font_size_override("font_size", 11)
		panel.add_child(server_hint)
		var save_server := Button.new()
		save_server.text = "SAVE SERVER ADDRESS"
		save_server.pressed.connect(func():
			server_address = server_input.text.strip_edges()
			_save_local_settings()
			if server_address.is_empty():
				server_hint.text = "No server address saved. Enter a public dedicated server address."
				save_server.text = "SAVE SERVER ADDRESS"
			else:
				server_hint.text = "SERVER SAVED: " + server_address + "  •  UDP " + str(PORT)
				save_server.text = "SERVER ADDRESS SAVED"
		)
		panel.add_child(save_server)

	var start := Button.new()
	start.text = "START " + match_type.to_upper()
	start.custom_minimum_size.y = 58
	start.add_theme_font_size_override("font_size", 20)
	start.pressed.connect(_on_start_selected_match)
	panel.add_child(start)

	var back := Button.new()
	back.text = "BACK TO MAIN MENU"
	back.pressed.connect(_build_menu)
	panel.add_child(back)

func _legacy_match_type_for_mode(mode_name: String) -> String:
	match mode_name:
		"Combat Academy":
			return "Training Ground"
		"Private Operations":
			return "Custom Match"
		_:
			return "Battle Royale"


func _available_submodes(mode_name: String) -> Array[String]:
	match mode_name:
		"Battle Royale", "Ranked Battle Royale":
			return ["Solo", "Duo", "Squad"]
		"Squad Strike":
			return ["4v4 Casual", "4v4 Ranked"]
		"Duel Zone":
			return ["1v1", "2v2"]
		"Combat Academy":
			return ["Aim & Recoil", "Movement Training", "Combat Practice"]
		"World Forge":
			return ["Create Map", "Test My Map"]
		"Survival Events":
			return ["Undead Outbreak", "Night Survival", "Explosive Arena", "Melee Trial"]
		"Private Operations":
			return ["Private Battle Royale", "Private Squad Strike", "Private Duel"]
	return ["Standard"]


func _game_mode_description(mode_name: String) -> String:
	match mode_name:
		"Battle Royale":
			return "SOLO / DUO / SQUAD • 50-player target • last team standing. Online matchmaking still needs a live backend."
		"Ranked Battle Royale":
			return "Ranked ladder: Recruit → Soldier → Veteran → Elite → Master → Warlord → Legend → Last Zone Champion. Ranked online seasons are not active yet."
		"Squad Strike":
			return "4v4 round-based combat with an in-match weapon economy. Online teams and ranked rounds need server implementation."
		"Duel Zone":
			return "Choose 1v1 or 2v2 elimination duels. Online opponent matchmaking is not connected yet."
		"Combat Academy":
			return "OFFLINE PRACTICE • movement, aiming, recoil and weapon handling. This mode can launch locally."
		"World Forge":
			return "Design and test custom battle maps. Community publishing and sharing need an online service."
		"Survival Events":
			return "Choose original event rules: Undead Outbreak, Night Survival, Explosive Arena or Melee Trial."
		"Private Operations":
			return "Configure private match rules and room details. Real invites and internet room hosting are not connected yet."
	return ""


func _on_start_selected_match() -> void:
	match_type = _legacy_match_type_for_mode(selected_game_mode)
	if selected_game_mode == "Private Operations":
		_show_custom_match_notice()
		return
	if selected_game_mode == "World Forge":
		_show_world_forge_notice()
		return
	if selected_game_mode == "Combat Academy":
		match_type = "Training Ground"
		_show_loading_screen()
		return
	# All active combat queues are human-online only. No local enemy fallback.
	# The current public prototype supports Battle Royale Solo/Duo/Squad on ENet.
	if selected_game_mode in ["Battle Royale", "Ranked Battle Royale"]:
		if server_address.strip_edges().is_empty():
			_show_server_address_required_notice()
			return
		selected_mode = selected_submode if selected_submode in ["Solo", "Duo", "Squad"] else "Solo"
		match_type = "Battle Royale"
		_save_local_settings()
		_show_loading_screen()
		return
	_show_mode_availability_notice()


func _show_server_address_required_notice() -> void:
	var panel := _show_simple_screen("ONLINE SERVER REQUIRED")
	var info := Label.new()
	info.text = "Enter and save a reachable public dedicated-server IP address in the lobby before starting an online Battle Royale match. Global matchmaking is not deployed yet."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(info)
	var back := Button.new()
	back.text = "BACK TO LOBBY"
	back.pressed.connect(_show_lobby_screen)
	panel.add_child(back)


func _show_mode_availability_notice() -> void:
	var panel := _show_simple_screen(selected_game_mode.to_upper())
	var info := Label.new()
	info.text = _game_mode_description(selected_game_mode) + "\n\nThis mode is registered in the mode selector, but full gameplay and online matchmaking are not yet implemented. I will not label it as playable until it passes tests."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(info)
	var back := Button.new()
	back.text = "BACK TO LOBBY"
	back.pressed.connect(_show_lobby_screen)
	panel.add_child(back)


func _show_world_forge_notice() -> void:
	var panel := _show_simple_screen("WORLD FORGE")
	var info := Label.new()
	info.text = "WORLD FORGE • CREATE MAP / TEST MAP\n\nMap editing, saving and publishing are not implemented yet. This screen is a development placeholder, not a working map editor."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(info)
	var back := Button.new()
	back.text = "BACK TO LOBBY"
	back.pressed.connect(_show_lobby_screen)
	panel.add_child(back)


func _show_custom_match_notice() -> void:
	var panel := _show_simple_screen("CUSTOM MATCH")
	var room_label := Label.new()
	room_label.text = "PRIVATE ROOM"
	room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(room_label)
	var room_input := LineEdit.new()
	room_input.placeholder_text = "Enter room code (when online rooms are available)"
	room_input.text = custom_room_code
	panel.add_child(room_input)
	var save_room := Button.new()
	save_room.text = "SAVE ROOM CODE"
	save_room.pressed.connect(func():
		custom_room_code = room_input.text.strip_edges().to_upper().left(12)
		_save_local_settings()
		room_label.text = "Room code saved on this device. Hosting is not online yet."
	)
	panel.add_child(save_room)
	var info := Label.new()
	info.text = "Custom room creation and joining need the dedicated online room service. This screen does not create an internet room yet."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(info)
	var back := Button.new()
	back.text = "BACK TO LOBBY"
	back.pressed.connect(_show_lobby_screen)
	panel.add_child(back)

func _show_loading_screen() -> void:
	var panel := _show_simple_screen(_tr("LOADING LAST ZONE"))
	var message := Label.new()
	message.text = _tr("PREPARING BATTLEFIELD...")
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(message)
	var progress := ProgressBar.new()
	progress.custom_minimum_size = Vector2(360, 24)
	progress.max_value = 100
	progress.value = 5
	panel.add_child(progress)
	for step in range(1, 11):
		await get_tree().create_timer(0.12).timeout
		if not is_instance_valid(progress):
			return
		progress.value = step * 10
	await get_tree().create_timer(0.2).timeout
	_enter_game()

func _enter_game() -> void:
	if game_started:
		return
	game_started = true
	_clear_menu()
	_build_island()
	_create_local_player()
	_build_hud()
	_build_loot_spawns()
	if match_type == "Training Ground":
		_build_training_targets()
		_start_air_drop()
		status_label.text = "COMBAT ACADEMY • OFFLINE AIM & RECOIL PRACTICE"
	else:
		_start_air_drop()
		status_label.text = "BATTLE ROYALE  •  " + selected_mode + "  •  Target " + str(target_players) + " players"
		if not server_address.strip_edges().is_empty():
			_connect_to_server()
		else:
			status_label.text += " • Enter a server address in the lobby"

func _build_training_targets() -> void:
	for target in training_targets:
		if is_instance_valid(target):
			target.queue_free()
	training_targets.clear()
	training_hits = 0
	var positions := [
		Vector3(-8, 0, -18), Vector3(-4, 0, -24), Vector3(0, 0, -20),
		Vector3(4, 0, -26), Vector3(8, 0, -18), Vector3(0, 0, -32)
	]
	for i in range(training_target_count):
		var dummy := CharacterBody3D.new()
		dummy.name = "Academy_Target_" + str(i + 1)
		dummy.position = positions[i % positions.size()]
		dummy.set_meta("training_target", true)
		dummy.set_meta("target_health", 100.0)
		var body := MeshInstance3D.new()
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.55
		capsule.height = 1.8
		body.mesh = capsule
		body.position.y = 0.9
		body.material_override = _material(Color(0.82, 0.24, 0.16))
		dummy.add_child(body)
		var collision := CollisionShape3D.new()
		var shape := CapsuleShape3D.new()
		shape.radius = 0.55
		shape.height = 1.8
		collision.shape = shape
		collision.position.y = 0.9
		dummy.add_child(collision)
		add_child(dummy)
		training_targets.append(dummy)
	if status_label:
		status_label.text = "AIM ACADEMY • Targets: " + str(training_targets.size()) + " • Shoot to score"


func _damage_training_target(target: CharacterBody3D, damage: float) -> void:
	var remaining := float(target.get_meta("target_health", 100.0)) - damage
	target.set_meta("target_health", remaining)
	if remaining <= 0.0:
		training_hits += 1
		if status_label:
			status_label.text = "TARGET DOWN • Score " + str(training_hits) + " / " + str(training_target_count)
		target.queue_free()
		training_targets.erase(target)
		if training_targets.is_empty():
			if status_label:
				status_label.text = "ACADEMY COMPLETE • " + str(training_hits) + " targets cleared"
			_build_training_targets()
	else:
		if status_label:
			status_label.text = "TARGET HIT • " + str(roundi(remaining)) + " HP LEFT"


func _build_loot_spawns() -> void:
	for item in loot_nodes:
		if is_instance_valid(item):
			item.queue_free()
	loot_nodes.clear()
	var spawn_data := [
		["ammo_rifle", 30, Vector3(-55, 0.8, -48)],
		["ammo_smg", 45, Vector3(48, 0.8, -55)],
		["ammo_shotgun", 8, Vector3(-62, 0.8, 45)],
		["medkit", 1, Vector3(50, 0.8, 45)],
		["armor", 50, Vector3(4, 0.8, -12)],
		["weapon_smg", 1, Vector3(30, 0.8, 12)],
		["weapon_shotgun", 1, Vector3(-30, 0.8, 14)],
		["ammo_rifle", 30, Vector3(0, 0.8, -80)],
		["medkit", 1, Vector3(72, 0.8, -32)],
		["armor", 50, Vector3(-72, 0.8, -28)]
	]
	for data in spawn_data:
		_create_loot_item(str(data[0]), int(data[1]), data[2] as Vector3)

func _create_loot_item(item_type: String, amount: int, spawn_position: Vector3) -> void:
	var item := Node3D.new()
	item.name = "Loot_" + item_type
	item.position = spawn_position
	item.set_meta("loot_type", item_type)
	item.set_meta("loot_amount", amount)
	item.set_meta("loot_id", loot_nodes.size())
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.8, 0.65, 0.8)
	visual.mesh = mesh
	var tint := Color(0.15, 0.55, 0.95)
	match item_type:
		"medkit": tint = Color(0.15, 0.9, 0.35)
		"armor": tint = Color(0.15, 0.8, 0.85)
		"weapon_smg", "weapon_shotgun": tint = Color(0.95, 0.65, 0.12)
	visual.material_override = _material(tint)
	item.add_child(visual)
	add_child(item)
	loot_nodes.append(item)

func _update_nearby_loot() -> void:
	nearby_loot = null
	var best_distance := 3.2
	if local_player:
		for item in loot_nodes:
			if not is_instance_valid(item):
				continue
			var distance := local_player.global_position.distance_to(item.global_position)
			if distance < best_distance:
				best_distance = distance
				nearby_loot = item
	if pickup_button:
		pickup_button.disabled = nearby_loot == null
		pickup_button.text = "PICK UP" if nearby_loot else "NO LOOT"
	if inventory_label:
		inventory_label.text = "HP " + str(roundi(health)) + "  |  ARMOR " + str(roundi(armor)) + "  |  MEDKIT " + str(medkit_count)
	if health_bar:
		health_bar.value = health
	if armor_bar:
		armor_bar.value = armor

func _pickup_nearby_loot() -> void:
	if nearby_loot == null or not is_instance_valid(nearby_loot):
		return
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server():
		rpc_id(1, "request_loot_pickup", int(nearby_loot.get_meta("loot_id", -1)))
		return
	var item_type := str(nearby_loot.get_meta("loot_type", ""))
	var amount := int(nearby_loot.get_meta("loot_amount", 0))
	if equipped_passive_skills.has("SCAVENGER") and item_type.begins_with("ammo_"):
		amount = ceili(float(amount) * 1.2)
	_apply_loot_reward(item_type, amount)
	var loot_id := int(nearby_loot.get_meta("loot_id", -1))
	loot_nodes.erase(nearby_loot)
	nearby_loot.queue_free()
	nearby_loot = null
	_update_weapon_hud()
	_update_nearby_loot()

func _apply_loot_reward(item_type: String, amount: int) -> void:
	match item_type:
		"ammo_rifle":
			weapon_reserve[0] = int(weapon_reserve[0]) + amount
			if current_weapon == 0: reserve_ammo += amount
			status_label.text = "RIFLE AMMO +" + str(amount)
		"ammo_smg":
			weapon_reserve[1] = int(weapon_reserve[1]) + amount
			if current_weapon == 1: reserve_ammo += amount
			status_label.text = "SMG AMMO +" + str(amount)
		"ammo_shotgun":
			weapon_reserve[2] = int(weapon_reserve[2]) + amount
			if current_weapon == 2: reserve_ammo += amount
			status_label.text = "SHOTGUN AMMO +" + str(amount)
		"medkit":
			medkit_count += amount
			status_label.text = "MEDKIT COLLECTED"
		"armor":
			armor = minf(100.0, armor + float(amount))
			status_label.text = "ARMOR +" + str(amount)
		"weapon_smg":
			_equip_weapon(1)
			status_label.text = "SMG PICKED UP"
		"weapon_shotgun":
			_equip_weapon(2)
			status_label.text = "SHOTGUN PICKED UP"
	daily_mission_loot += 1
	_claim_completed_daily_tasks()

@rpc("any_peer", "call_remote", "reliable")
func request_loot_pickup(loot_id: int) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if not server_player_states.has(sender) or server_eliminated.has(sender) or match_finished or loot_id < 0 or loot_id >= loot_nodes.size() or server_loot_taken.has(loot_id):
		return
	var item: Node3D = loot_nodes[loot_id]
	if not is_instance_valid(item):
		return
	var player_state: Dictionary = server_player_states[sender]
	var player_position: Vector3 = player_state["position"]
	if player_position.distance_to(item.position) > 4.5:
		return
	var item_type := str(item.get_meta("loot_type", ""))
	var item_amount := int(item.get_meta("loot_amount", 0))
	if item_amount <= 0:
		return
	if item_type == "armor":
		server_player_armor[sender] = minf(100.0, float(server_player_armor.get(sender, 0.0)) + float(item_amount))
	elif item_type == "medkit":
		server_player_medkits[sender] = mini(10, int(server_player_medkits.get(sender, 0)) + item_amount)
	server_loot_taken[loot_id] = sender
	rpc("remove_loot_item", loot_id, sender)
	if item_type == "armor" or item_type == "medkit":
		rpc_id(sender, "receive_authoritative_inventory", float(server_player_armor.get(sender, 0.0)), int(server_player_medkits.get(sender, 0)))

@rpc("authority", "call_remote", "reliable")
func receive_authoritative_inventory(new_armor: float, new_medkits: int) -> void:
	armor = clampf(new_armor, 0.0, 100.0)
	medkit_count = maxi(0, new_medkits)
	if armor_bar: armor_bar.value = armor
	_update_nearby_loot()

@rpc("authority", "call_remote", "reliable")
func remove_loot_item(loot_id: int, collector_id: int) -> void:
	for item in loot_nodes:
		if is_instance_valid(item) and int(item.get_meta("loot_id", -1)) == loot_id:
			if collector_id == multiplayer.get_unique_id():
				_apply_loot_reward(str(item.get_meta("loot_type", "")), int(item.get_meta("loot_amount", 0)))
			loot_nodes.erase(item)
			item.queue_free()
			break
	if nearby_loot and int(nearby_loot.get_meta("loot_id", -1)) == loot_id:
		nearby_loot = null
	_update_weapon_hud()
	_update_nearby_loot()

func _use_medkit() -> void:
	if is_dead:
		return
	var online_client := multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server()
	if online_client:
		rpc_id(1, "request_use_medkit")
		return
	if medkit_count <= 0:
		if status_label: status_label.text = "NO MEDKITS"
		return
	if health >= 100.0:
		if status_label: status_label.text = "HEALTH IS ALREADY FULL"
		return
	medkit_count -= 1
	health = minf(100.0, health + (65.0 if equipped_passive_skills.has("FIELD MEDIC") else 50.0))
	if status_label: status_label.text = "MEDKIT USED  •  HEALTH " + str(roundi(health))
	_update_nearby_loot()

@rpc("any_peer", "call_remote", "reliable")
func request_use_medkit() -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if not server_player_states.has(sender) or server_eliminated.has(sender):
		return
	var count := int(server_player_medkits.get(sender, 0))
	var current_health := float(server_player_health.get(sender, 100.0))
	if count <= 0 or current_health >= 100.0:
		return
	count -= 1
	current_health = minf(100.0, current_health + 50.0)
	server_player_medkits[sender] = count
	server_player_health[sender] = current_health
	rpc_id(sender, "receive_authoritative_heal", current_health, float(server_player_armor.get(sender, 0.0)), count)

@rpc("authority", "call_remote", "reliable")
func receive_authoritative_heal(new_health: float, new_armor: float, remaining_medkits: int) -> void:
	if is_dead:
		return
	health = clampf(new_health, 0.0, 100.0)
	armor = clampf(new_armor, 0.0, 100.0)
	medkit_count = maxi(0, remaining_medkits)
	if health_bar: health_bar.value = health
	if armor_bar: armor_bar.value = armor
	if status_label: status_label.text = "MEDKIT USED  •  HEALTH " + str(roundi(health))
	_update_nearby_loot()

# STAGES 79-88: health, damage, armor, elimination and respawn
func apply_damage(amount: float) -> void:
	_take_damage(amount, "COMBAT")

func _take_damage(amount: float, source: String) -> void:
	if is_dead or amount <= 0.0:
		return
	var incoming: float = amount
	var absorbed: float = minf(armor, incoming * 0.60)
	armor = maxf(0.0, armor - absorbed)
	var health_damage: float = incoming - absorbed
	health = maxf(0.0, health - health_damage)
	damage_flash_timer = 0.25
	if status_label:
		status_label.text = "UNDER ATTACK: " + source + "  -" + str(roundi(health_damage)) + " HP"
	_update_nearby_loot()
	if health <= 0.0:
		_die()

func _update_survival(delta: float) -> void:
	if local_player == null or is_dead:
		return
	var distance_from_centre := Vector2(local_player.global_position.x, local_player.global_position.z).length()
	if distance_from_centre > safe_radius:
		zone_damage_timer += delta
		if zone_damage_timer >= 1.0:
			zone_damage_timer = 0.0
			var online_client := multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server()
			if not online_client:
				_take_damage(5.0, "OUTSIDE SAFE ZONE")
	else:
		zone_damage_timer = 0.0
	if damage_flash_timer > 0.0 and status_label and damage_flash_timer > 0.15:
		status_label.modulate = Color(1.0, 0.35, 0.35)
	else:
		if status_label:
			status_label.modulate = Color.WHITE

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	# Battle Royale eliminations are permanent for this round; only Training Ground respawns.
	respawn_timer = 8.0 if match_type == "Training Ground" else -1.0
	if local_player:
		local_player.velocity = Vector3.ZERO
		local_player.visible = false
	if status_label:
		if match_type == "Training Ground":
			status_label.text = "TRAINING  •  RESPAWNING IN 8"
		else:
			status_label.text = "ELIMINATED  •  SPECTATING"
	if pickup_button:
		pickup_button.disabled = true
	if match_type == "Battle Royale":
		var camera := local_player.get_node_or_null("CameraPivot/Camera3D") as Camera3D if local_player else null
		if camera:
			spectator_camera = camera
			spectator_camera.set_as_top_level(true)
			spectator_camera.current = true
			spectator_camera.global_position = local_player.global_position + Vector3(0, 3, 7)
		_cycle_spectator_target()

func _cycle_spectator_target() -> void:
	var ids: Array[int] = []
	for id_variant in players.keys():
		var id := int(id_variant)
		if id != multiplayer.get_unique_id() and is_instance_valid(players[id]) and players[id].visible:
			ids.append(id)
	ids.sort()
	if ids.is_empty():
		spectator_target_id = 0
		if spectator_label: spectator_label.text = "SPECTATING • NO LIVE PLAYERS"
		return
	var current_index := ids.find(spectator_target_id)
	spectator_target_id = ids[(current_index + 1) % ids.size()]
	if spectator_label: spectator_label.text = "SPECTATING PLAYER " + str(spectator_target_id)

func _update_spectator_camera() -> void:
	if not is_dead or spectator_camera == null or not is_instance_valid(spectator_camera):
		return
	if spectator_target_id == 0 or not players.has(spectator_target_id):
		_cycle_spectator_target()
		return
	var target: Node3D = players[spectator_target_id]
	if not is_instance_valid(target) or not target.visible:
		_cycle_spectator_target()
		return
	var desired := target.global_position + Vector3(0, 3.0, 6.0)
	spectator_camera.global_position = spectator_camera.global_position.lerp(desired, 0.12)
	spectator_camera.look_at(target.global_position + Vector3(0, 1.2, 0), Vector3.UP)

func _respawn_player() -> void:
	if spectator_camera:
		spectator_camera.set_as_top_level(false)
		spectator_camera.current = true
	spectator_target_id = 0
	is_dead = false
	respawn_timer = 0.0
	health = 100.0
	armor = 10.0 if equipped_passive_skills.has("FORTIFIED") else 0.0
	zone_damage_timer = 0.0
	if local_player:
		local_player.global_position = Vector3(0, 2, 0)
		local_player.velocity = Vector3.ZERO
		local_player.visible = true
	if status_label:
		status_label.modulate = Color.WHITE
		status_label.text = "RESPAWNED  •  FULL HEALTH"
	if pickup_button:
		pickup_button.disabled = false
	_update_nearby_loot()

# STAGES 89-98: aircraft insertion and parachute landing prototype
func _start_air_drop() -> void:
	if local_player == null:
		return
	is_dropping = true
	drop_elapsed = 0.0
	local_player.global_position = Vector3(randf_range(-65.0, 65.0), 48.0, randf_range(-65.0, 65.0))
	local_player.velocity = Vector3.ZERO
	_create_parachute_visual()
	if status_label:
		status_label.text = "AIR INSERTION  •  STEER TO CHOOSE YOUR LANDING"
	if drop_status_label:
		drop_status_label.text = "AIR DROP  •  MOVE TO STEER"

func _create_parachute_visual() -> void:
	if parachute_visual and is_instance_valid(parachute_visual):
		parachute_visual.queue_free()
	parachute_visual = Node3D.new()
	parachute_visual.name = "ParachuteCanopy"
	parachute_visual.position = Vector3(0, 3.2, 0)
	var canopy := MeshInstance3D.new()
	var canopy_mesh := SphereMesh.new()
	canopy_mesh.radius = 2.6
	canopy_mesh.height = 1.0
	canopy_mesh.radial_segments = 16
	canopy_mesh.rings = 6
	canopy.mesh = canopy_mesh
	canopy.scale = Vector3(1.0, 0.28, 0.8)
	canopy.material_override = _material(Color(0.88, 0.18, 0.12))
	parachute_visual.add_child(canopy)
	for x in [-1.5, 1.5]:
		var line := MeshInstance3D.new()
		var line_mesh := CylinderMesh.new()
		line_mesh.top_radius = 0.025
		line_mesh.bottom_radius = 0.025
		line_mesh.height = 3.0
		line.mesh = line_mesh
		line.position = Vector3(x, -1.5, 0)
		line.material_override = _material(Color(0.92, 0.92, 0.86))
		parachute_visual.add_child(line)
	local_player.add_child(parachute_visual)

func _update_air_drop(delta: float) -> void:
	if local_player == null:
		return
	drop_elapsed += delta
	var steering := Vector2.ZERO
	if Input.is_action_pressed("move_left"): steering.x -= 1.0
	if Input.is_action_pressed("move_right"): steering.x += 1.0
	if Input.is_action_pressed("move_forward"): steering.y -= 1.0
	if Input.is_action_pressed("move_back"): steering.y += 1.0
	steering = steering.normalized()
	local_player.global_position.x = clampf(local_player.global_position.x + steering.x * 9.0 * delta, -MAP_SIZE * 0.44, MAP_SIZE * 0.44)
	local_player.global_position.z = clampf(local_player.global_position.z + steering.y * 9.0 * delta, -MAP_SIZE * 0.44, MAP_SIZE * 0.44)
	local_player.velocity = Vector3(0, -5.0, 0)
	local_player.move_and_slide()
	if drop_status_label:
		drop_status_label.text = "PARACHUTE DESCENT  •  ALT " + str(roundi(maxf(0.0, local_player.global_position.y))) + "m"
	if local_player.global_position.y <= 2.2 or drop_elapsed >= 12.0:
		_finish_air_drop()

func _finish_air_drop() -> void:
	if not is_dropping:
		return
	is_dropping = false
	if local_player:
		local_player.global_position.y = 2.0
		local_player.velocity = Vector3.ZERO
		if parachute_visual and is_instance_valid(parachute_visual):
			parachute_visual.queue_free()
		parachute_visual = null
	if drop_status_label:
		drop_status_label.text = "LANDED  •  LOOT AND SURVIVE"
	if status_label:
		status_label.text = "LANDED SAFELY  •  FIND WEAPONS AND SUPPLIES"


func _spawn_vehicles() -> void:
	# Two simple drivable vehicles placed on open roads.
	_create_vehicle(Vector3(-24, 0.15, 0), 0.0, Color(0.10, 0.34, 0.62))
	_create_vehicle(Vector3(28, 0.15, 0), PI, Color(0.66, 0.20, 0.12))

func _reset_vehicle_fleet() -> void:
	if not multiplayer.is_server():
		return
	server_vehicle_drivers.clear()
	server_vehicle_update_time.clear()
	server_vehicle_controls.clear()
	server_vehicle_speeds.clear()
	for vehicle_id in range(vehicle_nodes.size()):
		var car := vehicle_nodes[vehicle_id]
		if not is_instance_valid(car):
			continue
		var spawn_position := Vector3(-24, 0.15, 0) if vehicle_id == 0 else Vector3(28, 0.15, 0)
		var spawn_yaw := 0.0 if vehicle_id == 0 else PI
		server_vehicle_health[vehicle_id] = 300.0
		server_vehicle_destroyed[vehicle_id] = false
		car.global_position = spawn_position
		car.rotation = Vector3(0, spawn_yaw, 0)
		car.velocity = Vector3.ZERO
		car.visible = true
		for child in car.get_children():
			if child is CollisionShape3D:
				child.set_deferred("disabled", false)
		rpc("vehicle_fleet_reset", vehicle_id, spawn_position, spawn_yaw)

@rpc("authority", "call_remote", "reliable")
func vehicle_fleet_reset(vehicle_id: int, spawn_position: Vector3, spawn_yaw: float) -> void:
	if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size():
		return
	if not spawn_position.is_finite() or not is_finite(spawn_yaw):
		return
	var car := vehicle_nodes[vehicle_id]
	server_vehicle_health[vehicle_id] = 300.0
	server_vehicle_destroyed[vehicle_id] = false
	car.global_position = spawn_position
	car.rotation = Vector3(0, wrapf(spawn_yaw, -PI, PI), 0)
	car.velocity = Vector3.ZERO
	car.visible = true
	for child in car.get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", false)
	if vehicle_status_label:
		vehicle_status_label.text = "VEHICLE FLEET RESTORED"


func _create_vehicle(pos: Vector3, yaw: float, tint: Color) -> void:
	var car := CharacterBody3D.new()
	car.name = "DriveableVehicle_" + str(vehicle_nodes.size() + 1)
	car.position = pos
	car.rotation.y = yaw
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 1.15, 3.6)
	collision.shape = shape
	collision.position.y = 0.65
	car.add_child(collision)
	var chassis := MeshInstance3D.new()
	var chassis_mesh := BoxMesh.new()
	chassis_mesh.size = Vector3(2.0, 0.65, 3.6)
	chassis.mesh = chassis_mesh
	chassis.position.y = 0.65
	chassis.material_override = _material(tint)
	car.add_child(chassis)
	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.55, 0.72, 1.75)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0, 1.28, -0.15)
	cabin.material_override = _material(Color(0.12, 0.19, 0.22))
	car.add_child(cabin)
	for side in [-1.0, 1.0]:
		for axle in [-1.0, 1.0]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.38
			wheel_mesh.bottom_radius = 0.38
			wheel_mesh.height = 0.22
			wheel.mesh = wheel_mesh
			wheel.rotation.z = PI * 0.5
			wheel.position = Vector3(side * 1.02, 0.38, axle * 1.18)
			wheel.material_override = _material(Color(0.035, 0.04, 0.045))
			car.add_child(wheel)
	add_child(car)
	vehicle_nodes.append(car)
	server_vehicle_health[vehicle_nodes.size() - 1] = 300.0
	server_vehicle_destroyed[vehicle_nodes.size() - 1] = false


func _toggle_vehicle() -> void:
	if local_player == null:
		return
	if in_vehicle:
		var vehicle_id := vehicle_nodes.find(active_vehicle)
		if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server():
			rpc_id(1, "request_vehicle_exit", vehicle_id)
		else:
			_finish_vehicle_exit(vehicle_id)
		return
	var nearest_id := -1
	var nearest_distance := 4.5
	for i in range(vehicle_nodes.size()):
		var car := vehicle_nodes[i]
		if not is_instance_valid(car):
			continue
		var distance := local_player.global_position.distance_to(car.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = i
	if nearest_id < 0:
		if vehicle_status_label:
			vehicle_status_label.text = "NO VEHICLE NEARBY"
		return
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server():
		rpc_id(1, "request_vehicle_enter", nearest_id)
	else:
		_set_local_vehicle_driver(nearest_id, true)


func _set_local_vehicle_driver(vehicle_id: int, entering: bool) -> void:
	if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size():
		return
	if entering:
		if bool(server_vehicle_destroyed.get(vehicle_id, false)):
			if vehicle_status_label:
				vehicle_status_label.text = "VEHICLE DESTROYED"
			return
		active_vehicle = vehicle_nodes[vehicle_id]
		in_vehicle = true
		vehicle_speed = 0.0
		local_player.global_position = active_vehicle.global_position
		local_player.rotation.y = active_vehicle.rotation.y
		var visual := local_player.get_node_or_null("CharacterVisual") as Node3D
		if visual:
			visual.visible = false
		if vehicle_status_label:
			vehicle_status_label.text = "DRIVING  •  G TO EXIT"
	else:
		_finish_vehicle_exit(vehicle_id)


func _finish_vehicle_exit(vehicle_id: int) -> void:
	if is_instance_valid(active_vehicle) and local_player:
		local_player.global_position = active_vehicle.global_position + active_vehicle.global_basis.x * 2.2 + Vector3.UP * 0.2
		local_player.rotation.y = active_vehicle.rotation.y
	active_vehicle = null
	in_vehicle = false
	vehicle_speed = 0.0
	var visual := local_player.get_node_or_null("CharacterVisual") as Node3D if local_player else null
	if visual:
		visual.visible = true
	if vehicle_status_label:
		vehicle_status_label.text = "VEHICLE: ON FOOT (G)"


@rpc("any_peer", "call_remote", "reliable")
func request_vehicle_enter(vehicle_id: int) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if not server_player_states.has(sender) or server_eliminated.has(sender) or match_finished or vehicle_id < 0 or vehicle_id >= vehicle_nodes.size():
		return
	if bool(server_vehicle_destroyed.get(vehicle_id, false)):
		rpc_id(sender, "vehicle_request_denied", "VEHICLE DESTROYED")
		return
	if server_vehicle_drivers.has(vehicle_id):
		rpc_id(sender, "vehicle_request_denied", "VEHICLE ALREADY OCCUPIED")
		return
	var state: Dictionary = server_player_states[sender]
	var pos: Vector3 = state["position"]
	var car := vehicle_nodes[vehicle_id]
	if pos.distance_to(car.global_position) > 5.0:
		rpc_id(sender, "vehicle_request_denied", "MOVE CLOSER TO VEHICLE")
		return
	server_vehicle_drivers[vehicle_id] = sender
	server_vehicle_controls[vehicle_id] = {"driver": sender, "throttle": 0.0, "steering": 0.0, "braking": false}
	server_vehicle_speeds[vehicle_id] = 0.0
	server_vehicle_update_time[sender] = Time.get_ticks_msec() / 1000.0
	rpc("vehicle_driver_changed", vehicle_id, sender, true, car.global_position, car.rotation.y)


@rpc("any_peer", "call_remote", "reliable")
func request_vehicle_exit(vehicle_id: int) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size() or not server_player_states.has(sender) or int(server_vehicle_drivers.get(vehicle_id, 0)) != sender:
		return
	var car := vehicle_nodes[vehicle_id]
	if bool(server_vehicle_destroyed.get(vehicle_id, false)):
		rpc_id(sender, "vehicle_request_denied", "VEHICLE DESTROYED")
		return
	server_vehicle_drivers.erase(vehicle_id)
	server_vehicle_controls.erase(vehicle_id)
	server_vehicle_speeds[vehicle_id] = 0.0
	server_vehicle_update_time.erase(sender)
	var exit_pos := car.global_position + car.global_basis.x * 2.2 + Vector3.UP * 0.2
	server_player_states[sender] = {"position": exit_pos, "yaw": car.rotation.y}
	rpc("vehicle_driver_changed", vehicle_id, sender, false, exit_pos, car.rotation.y)


@rpc("any_peer", "call_remote", "unreliable")
func request_vehicle_update(vehicle_id: int, throttle: float, steering: float, braking: bool) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size() or not server_player_states.has(sender) or server_eliminated.has(sender) or int(server_vehicle_drivers.get(vehicle_id, 0)) != sender or bool(server_vehicle_destroyed.get(vehicle_id, false)):
		return
	if not is_finite(throttle) or not is_finite(steering):
		return
	server_vehicle_controls[vehicle_id] = {"driver": sender, "throttle": clampf(throttle, -0.65, 1.0), "steering": clampf(steering, -1.0, 1.0), "braking": braking}
	server_vehicle_update_time[sender] = Time.get_ticks_msec() / 1000.0


func _server_update_vehicles(delta: float) -> void:
	if not multiplayer.is_server():
		return
	vehicle_sync_timer += delta
	for vehicle_id in range(vehicle_nodes.size()):
		var car := vehicle_nodes[vehicle_id]
		if not is_instance_valid(car) or bool(server_vehicle_destroyed.get(vehicle_id, false)):
			continue
		var driver_id := int(server_vehicle_drivers.get(vehicle_id, 0))
		if driver_id <= 0:
			server_vehicle_speeds[vehicle_id] = move_toward(float(server_vehicle_speeds.get(vehicle_id, 0.0)), 0.0, 3.5 * delta)
			continue
		var control: Dictionary = server_vehicle_controls.get(vehicle_id, {})
		var last_input := float(server_vehicle_update_time.get(driver_id, 0.0))
		if Time.get_ticks_msec() / 1000.0 - last_input > 0.5:
			control = {}
		var throttle := float(control.get("throttle", 0.0))
		var steering := float(control.get("steering", 0.0))
		var braking := bool(control.get("braking", false))
		var speed := float(server_vehicle_speeds.get(vehicle_id, 0.0))
		if braking:
			speed = move_toward(speed, 0.0, 24.0 * delta)
		else:
			speed = move_toward(speed, throttle * 20.0, (9.0 if absf(throttle) > 0.0 else 3.5) * delta)
		server_vehicle_speeds[vehicle_id] = speed
		if absf(speed) > 0.8:
			var steering_factor := clampf(absf(speed) / 8.0, 0.25, 1.0)
			car.rotation.y += steering * 1.35 * steering_factor * delta * signf(speed)
		var forward := -car.global_basis.z
		car.velocity.x = forward.x * speed
		car.velocity.z = forward.z * speed
		car.velocity.y -= 18.0 * delta
		if car.is_on_floor():
			car.velocity.y = -0.15
		car.move_and_slide()
		if car.get_slide_collision_count() > 0:
			server_vehicle_speeds[vehicle_id] = speed * 0.88
		if absf(car.global_position.x) > MAP_SIZE * 0.5 or absf(car.global_position.z) > MAP_SIZE * 0.5:
			car.global_position.x = clampf(car.global_position.x, -MAP_SIZE * 0.5, MAP_SIZE * 0.5)
			car.global_position.z = clampf(car.global_position.z, -MAP_SIZE * 0.5, MAP_SIZE * 0.5)
		server_player_states[driver_id] = {"position": car.global_position, "yaw": car.rotation.y}
	if vehicle_sync_timer >= 0.1:
		vehicle_sync_timer = 0.0
		for vehicle_id in range(vehicle_nodes.size()):
			var car := vehicle_nodes[vehicle_id]
			if is_instance_valid(car) and not bool(server_vehicle_destroyed.get(vehicle_id, false)):
				rpc("vehicle_state_update", vehicle_id, car.global_position, car.rotation.y)


@rpc("authority", "call_remote", "reliable")
func vehicle_driver_changed(vehicle_id: int, driver_id: int, entering: bool, position: Vector3, yaw: float) -> void:
	if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size():
		return
	if entering:
		if driver_id == multiplayer.get_unique_id():
			_set_local_vehicle_driver(vehicle_id, true)
		elif players.has(driver_id) and is_instance_valid(players[driver_id]):
			var remote_visual := players[driver_id].get_node_or_null("CharacterVisual") as Node3D
			if remote_visual:
				remote_visual.visible = false
			players[driver_id].global_position = position
	else:
		if driver_id == multiplayer.get_unique_id():
			_finish_vehicle_exit(vehicle_id)
		elif players.has(driver_id) and is_instance_valid(players[driver_id]):
			var remote_visual := players[driver_id].get_node_or_null("CharacterVisual") as Node3D
			if remote_visual:
				remote_visual.visible = true
			players[driver_id].global_position = position
		vehicle_nodes[vehicle_id].global_position = position
		vehicle_nodes[vehicle_id].rotation.y = yaw


@rpc("authority", "call_remote", "reliable")
func vehicle_request_denied(message: String) -> void:
	if vehicle_status_label:
		vehicle_status_label.text = message


@rpc("authority", "call_remote", "unreliable")
func vehicle_state_update(vehicle_id: int, pos: Vector3, yaw: float) -> void:
	if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size() or not pos.is_finite() or not is_finite(yaw):
		return
	var car := vehicle_nodes[vehicle_id]
	car.global_position = car.global_position.lerp(pos, 0.7)
	car.rotation.y = lerp_angle(car.rotation.y, yaw, 0.7)
	if in_vehicle and active_vehicle == car and local_player:
		local_player.global_position = car.global_position
		local_player.rotation.y = car.rotation.y


@rpc("any_peer", "call_remote", "reliable")
func request_vehicle_damage(vehicle_id: int, weapon_index: int) -> void:
	if not multiplayer.is_server() or not match_started or match_finished:
		return
	var shooter_id := multiplayer.get_remote_sender_id()
	if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size() or not server_player_states.has(shooter_id) or server_eliminated.has(shooter_id):
		return
	if weapon_index < 0 or weapon_index >= weapon_damage.size() or bool(server_vehicle_destroyed.get(vehicle_id, false)):
		return
	var now := Time.get_ticks_msec() / 1000.0
	var previous_shot := float(server_last_shot_time.get(shooter_id, 0.0))
	if now - previous_shot < float(weapon_fire_delays[weapon_index]) * 0.8:
		return
	var shooter_state: Dictionary = server_player_states[shooter_id]
	var shooter_pos: Vector3 = shooter_state["position"]
	var car := vehicle_nodes[vehicle_id]
	var target_pos := car.global_position + Vector3.UP * 0.8
	if shooter_pos.distance_to(target_pos) > float(weapon_ranges[weapon_index]) + 3.0:
		return
	var yaw := float(shooter_state.get("yaw", 0.0))
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var to_vehicle := Vector3(target_pos.x - shooter_pos.x, 0.0, target_pos.z - shooter_pos.z).normalized()
	if forward.dot(to_vehicle) < 0.25:
		return
	var ray_from := shooter_pos + Vector3.UP * 1.4
	var ray_query := PhysicsRayQueryParameters3D.create(ray_from, target_pos)
	if players.has(shooter_id) and is_instance_valid(players[shooter_id]):
		ray_query.exclude = [players[shooter_id].get_rid()]
	var obstruction := get_world_3d().direct_space_state.intersect_ray(ray_query)
	if not obstruction.is_empty() and obstruction.get("collider") != car:
		return
	server_last_shot_time[shooter_id] = now
	_server_damage_vehicle(vehicle_id, weapon_index)


func _server_damage_vehicle(vehicle_id: int, weapon_index: int) -> void:
	if (multiplayer.multiplayer_peer != null and not multiplayer.is_server()) or vehicle_id < 0 or vehicle_id >= vehicle_nodes.size() or weapon_index < 0 or weapon_index >= weapon_damage.size() or bool(server_vehicle_destroyed.get(vehicle_id, false)):
		return
	var multiplier := 1.4 if weapon_index == 2 else (0.8 if weapon_index == 1 else 1.0)
	var remaining := maxf(0.0, float(server_vehicle_health.get(vehicle_id, 300.0)) - float(weapon_damage[weapon_index]) * multiplier)
	server_vehicle_health[vehicle_id] = remaining
	var destroyed := remaining <= 0.0
	if destroyed:
		server_vehicle_destroyed[vehicle_id] = true
		var driver_id := int(server_vehicle_drivers.get(vehicle_id, 0))
		server_vehicle_drivers.erase(vehicle_id)
		server_vehicle_controls.erase(vehicle_id)
		server_vehicle_speeds[vehicle_id] = 0.0
		if driver_id > 0:
			var car := vehicle_nodes[vehicle_id]
			var exit_pos := car.global_position + car.global_basis.x * 2.2 + Vector3.UP * 0.2
			server_player_states[driver_id] = {"position": exit_pos, "yaw": car.rotation.y}
			rpc("vehicle_driver_changed", vehicle_id, driver_id, false, exit_pos, car.rotation.y)
	vehicle_health_update(vehicle_id, remaining, destroyed)
	if multiplayer.multiplayer_peer != null and multiplayer.is_server():
		rpc("vehicle_health_update", vehicle_id, remaining, destroyed)


@rpc("authority", "call_remote", "reliable")
func vehicle_health_update(vehicle_id: int, remaining: float, destroyed: bool) -> void:
	if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size() or not is_finite(remaining) or remaining < 0.0 or remaining > 300.0:
		return
	server_vehicle_health[vehicle_id] = remaining
	server_vehicle_destroyed[vehicle_id] = destroyed
	var car := vehicle_nodes[vehicle_id]
	car.visible = not destroyed
	for child in car.get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", destroyed)
	if destroyed and in_vehicle and active_vehicle == car:
		_finish_vehicle_exit(vehicle_id)
	if vehicle_status_label:
		vehicle_status_label.text = "VEHICLE DESTROYED" if destroyed else "VEHICLE CONDITION: " + str(roundi(remaining)) + " / 300"


func _drive_vehicle(delta: float) -> void:
	if not is_instance_valid(active_vehicle) or bool(server_vehicle_destroyed.get(vehicle_nodes.find(active_vehicle), false)):
		if is_instance_valid(active_vehicle):
			_finish_vehicle_exit(vehicle_nodes.find(active_vehicle))
		else:
			in_vehicle = false
			active_vehicle = null
			vehicle_speed = 0.0
		return
	# Online driving sends inputs only; the dedicated server owns vehicle physics.
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server():
		if vehicle_status_label:
			vehicle_status_label.text = "DRIVING  •  SERVER SYNC  •  B BRAKE / G EXIT"
		return
	var throttle := 0.0
	if Input.is_action_pressed("move_forward"):
		throttle += 1.0
	if Input.is_action_pressed("move_back"):
		throttle -= 0.65
	var braking := Input.is_action_pressed("vehicle_brake")
	vehicle_speed = move_toward(vehicle_speed, 0.0 if braking else throttle * 20.0, (24.0 if braking else (9.0 if absf(throttle) > 0.0 else 3.5)) * delta)
	var steering := 0.0
	if Input.is_action_pressed("move_left"):
		steering += 1.0
	if Input.is_action_pressed("move_right"):
		steering -= 1.0
	if absf(vehicle_speed) > 0.8:
		active_vehicle.rotation.y += steering * 1.35 * clampf(absf(vehicle_speed) / 8.0, 0.25, 1.0) * delta * signf(vehicle_speed)
	var forward := -active_vehicle.global_basis.z
	active_vehicle.velocity.x = forward.x * vehicle_speed
	active_vehicle.velocity.z = forward.z * vehicle_speed
	active_vehicle.velocity.y -= 18.0 * delta
	if active_vehicle.is_on_floor():
		active_vehicle.velocity.y = -0.15
	active_vehicle.move_and_slide()
	if active_vehicle.get_slide_collision_count() > 0:
		vehicle_speed *= 0.88
	local_player.global_position = active_vehicle.global_position
	local_player.rotation.y = active_vehicle.rotation.y
	if vehicle_status_label:
		var brake_text := "  •  BRAKING" if braking else ""
		vehicle_status_label.text = "DRIVING  •  SPEED " + str(roundi(absf(vehicle_speed) * 5.0)) + " KM/H" + brake_text + "  •  B BRAKE / G EXIT"
