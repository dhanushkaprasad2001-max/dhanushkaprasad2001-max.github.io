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
var weapon_names := ["M4A1", "AK47", "SCAR", "GROZA", "XM8", "MP40", "UMP", "THOMPSON", "MP5", "M1887", "SPAS12", "M1014", "AWM", "KAR98K", "M82B", "M60", "M249", "DESERT EAGLE", "USP", "G18", "KATANA", "PAN", "BAT", "M79", "GRENADE LAUNCHER", "BOW", "CROSSBOW", "GRENADE"]
var weapon_damage := [25.0, 32.0, 28.0, 36.0, 27.0, 18.0, 20.0, 22.0, 17.0, 90.0, 78.0, 65.0, 120.0, 105.0, 140.0, 32.0, 34.0, 48.0, 35.0, 18.0, 55.0, 40.0, 45.0, 95.0, 85.0, 60.0, 70.0, 100.0]
var weapon_headshot_multipliers := [2.0, 1.9, 1.9, 1.85, 1.9, 1.7, 1.75, 1.7, 1.75, 1.55, 1.55, 1.5, 2.2, 2.1, 2.0, 1.8, 1.8, 1.8, 1.8, 1.65, 1.4, 1.3, 1.35, 1.7, 1.65, 1.8, 1.85, 1.2]
var weapon_mag_sizes := [30, 30, 30, 30, 30, 20, 30, 30, 30, 2, 5, 6, 5, 5, 8, 60, 100, 7, 12, 20, 1, 1, 1, 1, 1, 1, 1, 1]
var weapon_reserve := [120, 120, 120, 120, 120, 160, 160, 160, 160, 24, 40, 48, 25, 25, 40, 180, 200, 42, 72, 120, 0, 0, 0, 12, 12, 20, 20, 3]
var weapon_fire_delays := [0.12, 0.15, 0.13, 0.10, 0.11, 0.075, 0.09, 0.10, 0.07, 0.80, 0.65, 0.55, 1.20, 1.0, 1.4, 0.12, 0.10, 0.25, 0.15, 0.08, 0.7, 0.7, 0.7, 0.9, 1.0, 0.8, 0.85, 1.1]
var weapon_ranges := [120.0, 110.0, 115.0, 125.0, 120.0, 65.0, 75.0, 70.0, 75.0, 28.0, 32.0, 35.0, 180.0, 160.0, 200.0, 100.0, 110.0, 65.0, 60.0, 55.0, 12.0, 10.0, 12.0, 100.0, 110.0, 85.0, 95.0, 70.0]
var weapon_spread := [0.012, 0.016, 0.014, 0.011, 0.013, 0.025, 0.022, 0.024, 0.023, 0.10, 0.085, 0.09, 0.004, 0.006, 0.005, 0.025, 0.024, 0.018, 0.022, 0.035, 0.08, 0.10, 0.09, 0.04, 0.035, 0.03, 0.025, 0.06]
var weapon_classes := ["RIFLE", "RIFLE", "RIFLE", "RIFLE", "RIFLE", "SMG", "SMG", "SMG", "SMG", "SHOTGUN", "SHOTGUN", "SHOTGUN", "SNIPER", "SNIPER", "SNIPER", "LMG", "LMG", "PISTOL", "PISTOL", "PISTOL", "MELEE", "MELEE", "MELEE", "LAUNCHER", "LAUNCHER", "BOW", "BOW", "GRENADE"]
var owned_weapon_skins: Array[String] = []
var equipped_weapon_skins: Dictionary = {}
var current_weapon := 0
var ammo_in_mag := 30
var reserve_ammo := 120
var weapon_mag_ammo: Array[int] = []
var weapon_reserve_ammo: Array[int] = []
var fire_cooldown := 0.0
var weapon_recoil := 0.0
var weapon_spread_bloom := 0.0
var weapon_audio_player: AudioStreamPlayer
var active_weapon_projectiles: Array[Dictionary] = []
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
var server_player_gloo_charges: Dictionary = {}
var server_player_skill_ready_at: Dictionary = {}
var server_player_active_skill: Dictionary = {}
var server_player_skill_active_until: Dictionary = {}
var server_skill_regen_sync_timer := 0.0
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
var team_roster_cache: Dictionary = {}
var enemy_marker_refresh_timer := 0.0
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
var server_vehicle_last_hit: Dictionary = {}
var server_vehicle_health: Dictionary = {}
var server_vehicle_destroyed: Dictionary = {}
var network_test_target_id := 0
var network_test_damage_received := false
var network_test_vehicle_driver_candidate := false
var network_test_vehicle_entered := false
var network_test_vehicle_occupied := false
var network_test_vehicle_exited := false
var network_test_vehicle_state_received := false
var network_test_vehicle_start_position := Vector3.ZERO
var network_test_vehicle_last_position := Vector3.ZERO
var network_test_vehicle_denial_message := ""
var network_test_spawn_received := false
var network_test_gloo_wall_received := false
var network_test_gloo_wall_charges_received := false
var capacity_test_spawned := false
var capacity_test_rejected := false
var capacity_test_population := 0
var vehicle_sync_timer := 0.0
# LAST ZONE original character, cosmetics and armory systems
var owned_bundles: Array[String] = ["FIELD OPERATIVE"]
var equipped_bundle := "FIELD OPERATIVE"
var selected_character := "NERO"
var owned_characters: Array[String] = ["NERO"]
var selected_gender := "MALE"
var emote_wheel_open := false
var emote_animation_busy := false
var selected_skill := "SILENT SHOT"
var equipped_passive_skills: Array[String] = ["QUICK HANDS", "FIELD MEDIC", "SCAVENGER"]
var passive_slot_cursor := 0
var skill_regen_rate := 0.0
var skill_armor_regen_rate := 0.0
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
# Local World Forge editor state (saved per device).
var world_forge_cells: Array[bool] = []
var world_forge_grid: GridContainer
var world_forge_status: Label
const WORLD_FORGE_WIDTH := 12
const WORLD_FORGE_HEIGHT := 12
const WORLD_FORGE_SAVE_PATH := "user://last_zone_world_forge.json"
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
	weapon_mag_ammo.clear()
	weapon_reserve_ammo.clear()
	for weapon_index in range(weapon_names.size()):
		weapon_mag_ammo.append(int(weapon_mag_sizes[weapon_index]))
		weapon_reserve_ammo.append(int(weapon_reserve[weapon_index]))
	ammo_in_mag = weapon_mag_ammo[current_weapon]
	reserve_ammo = weapon_reserve_ammo[current_weapon]
	_ensure_audio_buses()
	_apply_audio_settings()
	_build_menu()
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _process(delta: float) -> void:
	_update_remote_character_animations(delta)
	_update_training_bot_ai(delta)
	if multiplayer.is_server():
		_server_tick_active_skill_regeneration(delta)
	enemy_marker_refresh_timer -= delta
	if enemy_marker_refresh_timer <= 0.0:
		enemy_marker_refresh_timer = 0.15
		_update_enemy_proximity_markers()
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	_update_weapon_projectiles(delta)
	weapon_recoil = move_toward(weapon_recoil, 0.0, delta * 2.8)
	weapon_spread_bloom = move_toward(weapon_spread_bloom, 0.0, delta * 0.055)
	if weapon_visual:
		weapon_visual.rotation.x = lerpf(weapon_visual.rotation.x, -weapon_recoil, minf(1.0, delta * 18.0))
		weapon_visual.rotation.z = lerpf(weapon_visual.rotation.z, 0.0, minf(1.0, delta * 14.0))
	if skill_cooldown > 0.0:
		skill_cooldown = maxf(0.0, skill_cooldown - delta)
	if skill_active and skill_duration > 0.0:
		skill_duration = maxf(0.0, skill_duration - delta)
		if skill_regen_rate > 0.0 and health < 100.0 and not is_dead:
			var passive_regen_bonus := 1.0 if equipped_passive_skills.has("FIELD SURVIVOR") else 0.0
			health = minf(100.0, health + (skill_regen_rate + passive_regen_bonus) * delta)
		if skill_armor_regen_rate > 0.0 and armor < 100.0 and not is_dead:
			armor = minf(100.0, armor + skill_armor_regen_rate * delta)
		if skill_duration <= 0.0:
			skill_active = false
			skill_regen_rate = 0.0
			skill_armor_regen_rate = 0.0
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
		ammo_hud_label.text = "∞  •  MELEE" if weapon_classes[current_weapon] == "MELEE" else str(ammo_in_mag) + " / " + str(reserve_ammo)
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
	var operator_traits := _operator_passive_profile(selected_character)
	var signature_mobility := _operator_signature_bonus(selected_character, "MOBILITY") * 1.5
	var speed := normal_speed + float(operator_traits["speed"]) + signature_mobility + (0.5 if equipped_passive_skills.has("SPRINTER") else 0.0) + skill_speed_bonus
	if crouch_enabled:
		speed = crouch_speed
	elif sprint_enabled:
		speed = sprint_speed + float(operator_traits["speed"]) + signature_mobility + (0.5 if equipped_passive_skills.has("SPRINTER") else 0.0) + skill_speed_bonus
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
		_update_character_animation_for_body(local_player, delta, true)

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
	_apply_world_forge_to_island()


func _apply_world_forge_to_island() -> void:
	if not FileAccess.file_exists(WORLD_FORGE_SAVE_PATH):
		return
	var file := FileAccess.open(WORLD_FORGE_SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or int(parsed.get("version", 0)) != 1 or int(parsed.get("width", 0)) != WORLD_FORGE_WIDTH or int(parsed.get("height", 0)) != WORLD_FORGE_HEIGHT:
		return
	var cells: Variant = parsed.get("cells", null)
	if not (cells is Array) or cells.size() != WORLD_FORGE_WIDTH * WORLD_FORGE_HEIGHT:
		return
	for cell_index in range(cells.size()):
		if not bool(cells[cell_index]):
			continue
		var column := cell_index % WORLD_FORGE_WIDTH
		var row := floori(float(cell_index) / float(WORLD_FORGE_WIDTH))
		var x := -82.5 + float(column) * 15.0
		var z := -82.5 + float(row) * 15.0
		_add_map_box(Vector3(x, 1.5, z), Vector3(5.5, 3.0, 5.5), Color(0.28, 0.36, 0.42), true)


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
	# Separate head hitbox lets raycasts distinguish headshots from body hits.
	var head_area := Area3D.new()
	head_area.name = "HeadHitbox"
	head_area.collision_layer = 1
	head_area.collision_mask = 0
	var head_shape := CollisionShape3D.new()
	var head_sphere := SphereShape3D.new()
	head_sphere.radius = 0.29
	head_shape.shape = head_sphere
	head_shape.position = Vector3(0, 1.82, 0)
	head_area.add_child(head_shape)
	body.add_child(head_area)
	var character := Node3D.new()
	character.name = "CharacterVisual"
	body.add_child(character)
	var team_marker := Label3D.new()
	team_marker.name = "TeamMarker"
	team_marker.position = Vector3(0, 2.55, 0)
	team_marker.text = "▲"
	team_marker.font_size = 28
	team_marker.outline_size = 4
	team_marker.modulate = Color(1.0, 0.72, 0.28)
	team_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	team_marker.no_depth_test = false
	team_marker.visible = false
	body.add_child(team_marker)
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


func _refresh_team_markers() -> void:
	_update_enemy_proximity_markers()


func _update_enemy_proximity_markers() -> void:
	if local_player == null:
		return
	const ENEMY_MARKER_RANGE := 24.0
	for peer_variant in players.keys():
		var peer_id := int(peer_variant)
		var body := players[peer_id] as CharacterBody3D
		if not is_instance_valid(body):
			continue
		var marker := body.get_node_or_null("TeamMarker") as Label3D
		if marker == null:
			continue
		var player_team := int(body.get_meta("team_id", 0))
		var is_ally := selected_mode != "Solo" and player_team > 0 and player_team == local_team_id
		if peer_id == multiplayer.get_unique_id() or is_ally or player_team <= 0 or local_team_id <= 0:
			marker.visible = false
			continue
		# No enemy names, team labels, outlines or long-range markers: only a tiny
		# overhead direction cue while a real opposing player is physically nearby.
		var distance := local_player.global_position.distance_to(body.global_position)
		marker.visible = distance <= ENEMY_MARKER_RANGE and distance > 0.1


func _are_teammates(first_id: int, second_id: int) -> bool:
	if server_match_mode == "Solo" or first_id <= 0 or second_id <= 0:
		return false
	return int(server_player_teams.get(first_id, -1)) == int(server_player_teams.get(second_id, -2))


func _add_character_part(parent: Node3D, part_name: String, pos: Vector3, dimensions: Vector3, tint: Color, use_sphere: bool = false) -> MeshInstance3D:
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
	return part

func _create_local_player() -> void:
	local_player = _create_player(1, true)
	local_player.position = Vector3(0, 2, 0)
	# Build the selected operator locally as well as for remote players.
	var default_visual := local_player.get_node_or_null("CharacterVisual")
	if default_visual:
		local_player.remove_child(default_visual)
		default_visual.queue_free()
	var selected_visual := Node3D.new()
	selected_visual.name = "CharacterVisual"
	local_player.add_child(selected_visual)
	var safe_gender := selected_gender if selected_gender in ["MALE", "FEMALE"] else "MALE"
	var safe_character := selected_character if _is_valid_operator(selected_character) else "NERO"
	_build_operator_visual(selected_visual, true, safe_gender, safe_character)
	_apply_bundle_to_visual(selected_visual, equipped_bundle, safe_character)
	armor = 10.0 if equipped_passive_skills.has("FORTIFIED") else 0.0
	_apply_equipped_bundle()
	_equip_character_signature_weapon(safe_character)

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
	_add_touch_button("BRAKE", Vector2(960, 635), "vehicle_brake")
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
	rpc_id(1, "request_player_damage", network_test_target_id, 0, 0.8)
	wait_time = 0.0
	while wait_time < 4.0 and not network_test_damage_received:
		await get_tree().create_timer(0.1).timeout
		wait_time += 0.1
	if not network_test_damage_received:
		push_error("NETWORK TEST: server-authoritative damage was not received")
		get_tree().quit(1)
		return
	rpc_id(1, "request_deploy_gloo_wall", "TACTICAL BLUE")
	wait_time = 0.0
	while wait_time < 4.0 and not network_test_gloo_wall_received:
		await get_tree().create_timer(0.1).timeout
		wait_time += 0.1
	if not network_test_gloo_wall_received:
		push_error("NETWORK TEST: authoritative gloo wall spawn was not replicated")
		get_tree().quit(1)
		return
	if network_test_vehicle_driver_candidate:
		wait_time = 0.0
		while wait_time < 4.0 and not network_test_gloo_wall_charges_received:
			await get_tree().create_timer(0.1).timeout
			wait_time += 0.1
		if not network_test_gloo_wall_charges_received:
			push_error("NETWORK TEST: server did not confirm authoritative Gloo Wall charge deduction")
			get_tree().quit(1)
			return
		print("NETWORK TEST: server-authoritative Gloo Wall charge deduction passed")
	print("NETWORK TEST: server-authoritative Gloo Wall spawn replication passed")
	if network_test_vehicle_driver_candidate:
		rpc_id(1, "request_vehicle_enter", 0)
		wait_time = 0.0
		while wait_time < 4.0 and not network_test_vehicle_entered:
			await get_tree().create_timer(0.1).timeout
			wait_time += 0.1
		if not network_test_vehicle_entered:
			push_error("NETWORK TEST: server did not approve vehicle entry: " + network_test_vehicle_denial_message)
			get_tree().quit(1)
			return
		network_test_vehicle_state_received = false
		wait_time = 0.0
		while wait_time < 2.0 and not network_test_vehicle_state_received:
			await get_tree().create_timer(0.1).timeout
			wait_time += 0.1
		if not network_test_vehicle_state_received:
			push_error("NETWORK TEST: no initial server vehicle state was received")
			get_tree().quit(1)
			return
		network_test_vehicle_start_position = network_test_vehicle_last_position
		for input_tick in range(20):
			rpc_id(1, "request_vehicle_update", 0, 1.0, 0.0, false)
			await get_tree().create_timer(0.1).timeout
		wait_time = 0.0
		while wait_time < 3.0 and network_test_vehicle_start_position.distance_to(network_test_vehicle_last_position) < 2.0:
			await get_tree().create_timer(0.1).timeout
			wait_time += 0.1
		if network_test_vehicle_start_position.distance_to(network_test_vehicle_last_position) < 2.0:
			push_error("NETWORK TEST: dedicated server did not move the vehicle from input controls; delta=" + str(network_test_vehicle_start_position.distance_to(network_test_vehicle_last_position)) + " start=" + str(network_test_vehicle_start_position) + " last=" + str(network_test_vehicle_last_position))
			get_tree().quit(1)
			return
		rpc_id(1, "request_vehicle_exit", 0)
		wait_time = 0.0
		while wait_time < 3.0 and not network_test_vehicle_exited:
			await get_tree().create_timer(0.1).timeout
			wait_time += 0.1
		if not network_test_vehicle_exited:
			push_error("NETWORK TEST: vehicle exit was not replicated")
			get_tree().quit(1)
			return
		print("NETWORK TEST: authoritative vehicle movement and exit passed")
	else:
		# The second client verifies the server rejects a second driver for an occupied vehicle.
		wait_time = 0.0
		while wait_time < 5.0 and not network_test_vehicle_occupied:
			await get_tree().create_timer(0.1).timeout
			wait_time += 0.1
		if not network_test_vehicle_occupied:
			push_error("NETWORK TEST: second client did not receive occupied vehicle state")
			get_tree().quit(1)
			return
		rpc_id(1, "request_vehicle_enter", 0)
		wait_time = 0.0
		while wait_time < 3.0 and network_test_vehicle_denial_message.is_empty():
			await get_tree().create_timer(0.1).timeout
			wait_time += 0.1
		if network_test_vehicle_denial_message != "VEHICLE ALREADY OCCUPIED":
			push_error("NETWORK TEST: occupied vehicle was not rejected correctly: " + network_test_vehicle_denial_message)
			get_tree().quit(1)
			return
		print("NETWORK TEST: occupied vehicle entry correctly rejected")
		await get_tree().create_timer(12.0).timeout
	print("NETWORK TEST: client joined, readied, started match and received server-authoritative damage")
	get_tree().quit(0)

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
	var operator_roster := _character_roster()
	if operator_roster.size() != 50:
		failures.append("Operator roster must contain exactly 50 characters")
	var operator_names: Dictionary = {}
	for operator_data in operator_roster:
		if operator_data.size() != 5:
			failures.append("Operator entry must define name, role, skill, weapon and bundle")
			continue
		var operator_name := str(operator_data[0])
		var operator_skill := str(operator_data[2])
		if operator_names.has(operator_name):
			failures.append("Duplicate operator name: " + operator_name)
		operator_names[operator_name] = true
		# Validate that every roster entry resolves to its own importable, skinned GLTF asset.
		var model_path := "res://assets/characters/" + operator_name.to_lower() + ".gltf"
		if not ResourceLoader.exists(model_path):
			failures.append("Missing rigged character model: " + operator_name)
		else:
			var model_resource := load(model_path)
			if not model_resource is PackedScene:
				failures.append("Character GLTF did not import as a PackedScene: " + operator_name)
			else:
				var model_instance := (model_resource as PackedScene).instantiate()
				if not model_instance is Node3D:
					failures.append("Character model root is not Node3D: " + operator_name)
				else:
					var model_skeleton := model_instance.find_child("Skeleton3D", true, false) as Skeleton3D
					if model_skeleton == null:
						failures.append("Character model has no imported Skeleton3D: " + operator_name)
					else:
						for required_bone in ["Pelvis", "Spine", "Head", "LeftArm", "RightArm", "LeftLeg", "RightLeg"]:
							if model_skeleton.find_bone(required_bone) < 0:
								failures.append("Character rig missing " + required_bone + ": " + operator_name)
				model_instance.free()
		if operator_skill.is_empty() or str(operator_data[1]).is_empty() or str(operator_data[3]).is_empty() or str(operator_data[4]).is_empty():
			failures.append("Incomplete operator data: " + operator_name)
		if _active_skill_cooldown(operator_skill) < 1:
			failures.append("Invalid active skill cooldown: " + operator_skill)
		if _active_skill_description(operator_skill) == "Activates a tactical operator effect.":
			failures.append("Operator skill is missing a specific description: " + operator_skill)
		if _character_signature_weapon_index(operator_name) < 0:
			failures.append("Operator signature weapon is not mapped to an in-game weapon: " + operator_name)
		var operator_style := _character_style(operator_name)
		for style_channel in ["uniform", "vest", "accent", "pants"]:
			if not operator_style.has(style_channel):
				failures.append("Operator is missing a cosmetic style channel: " + operator_name + " / " + style_channel)
	if not operator_names.has("NERO"):
		failures.append("NERO must be present in the operator roster")
	# Every operator must have a unique, non-default gameplay tuning multiplier.
	var skill_tuning_values: Dictionary = {}
	for skill_index in range(operator_roster.size()):
		var skill_character := str(operator_roster[skill_index][0])
		var skill_tuning := _operator_skill_multiplier(skill_character)
		var tuning_key := "%.3f" % skill_tuning
		if skill_tuning_values.has(tuning_key):
			failures.append("Duplicate operator skill tuning: " + skill_character)
		skill_tuning_values[tuning_key] = true
	if skill_tuning_values.size() != 50:
		failures.append("All 50 operators must have unique skill tuning values")
	# Verify every operator maps to its own deterministic silhouette signature.
	var signature_indices: Dictionary = {}
	for signature_index in range(operator_roster.size()):
		var signature_name := str(operator_roster[signature_index][0])
		var signature_key := str(signature_index % 5) + ":" + str(floori(float(signature_index) / 5.0) % 5) + ":" + str(floori(float(signature_index) / 25.0) % 2) + ":" + str(floori(float(signature_index) / 2.0) % 5) + ":" + str(floori(float(signature_index) / 10.0) % 5)
		if signature_indices.has(signature_key):
			failures.append("Duplicate operator silhouette signature: " + signature_name)
		signature_indices[signature_key] = true
	if signature_indices.size() != 50:
		failures.append("All 50 operators must have unique silhouette combinations")
	# The field-kit profile is a 10 x 5 deterministic matrix: all 50 entries must be unique.
	var field_kit_signatures: Dictionary = {}
	for kit_index in range(operator_roster.size()):
		var kit_key := str(kit_index % 10) + ":" + str(floori(float(kit_index) / 10.0) % 5)
		if field_kit_signatures.has(kit_key):
			failures.append("Duplicate field-kit signature: " + str(operator_roster[kit_index][0]))
		field_kit_signatures[kit_key] = true
	if field_kit_signatures.size() != 50:
		failures.append("All 50 operators must have unique field-kit combinations")
	var operator_passive_signatures: Dictionary = {}
	for passive_operator in operator_roster:
		var passive_operator_name := str(passive_operator[0])
		var passive_signature := _operator_passive_profile_signature(passive_operator_name)
		if operator_passive_signatures.has(passive_signature):
			failures.append("Duplicate operator passive trait profile: " + passive_operator_name)
		operator_passive_signatures[passive_signature] = true
	if operator_passive_signatures.size() != 50:
		failures.append("All 50 operators must have unique passive trait profiles")
	var signature_passive_names: Dictionary = {}
	for passive_operator in operator_roster:
		var signature_profile := _operator_passive_profile(str(passive_operator[0]))
		var signature_passive_name := str(signature_profile["signature_passive"])
		if signature_passive_names.has(signature_passive_name):
			failures.append("Duplicate signature passive: " + signature_passive_name)
		signature_passive_names[signature_passive_name] = true
	if signature_passive_names.size() != 50:
		failures.append("All 50 operators must have unique named signature passives")
	var passive_catalog := _passive_skill_catalog()
	var passive_names: Dictionary = {}
	for passive_data in passive_catalog:
		if passive_data.size() != 3 or str(passive_data[0]).is_empty() or int(passive_data[1]) < 1 or str(passive_data[2]).is_empty():
			failures.append("Passive skill entry has missing or invalid fields")
			continue
		var passive_name := str(passive_data[0])
		if passive_names.has(passive_name):
			failures.append("Duplicate passive skill: " + passive_name)
		passive_names[passive_name] = true
	for required_passive in ["QUICK HANDS", "FIELD MEDIC", "SCAVENGER", "SPRINTER", "SHARP EYE", "FORTIFIED", "TACTICAL FOCUS", "FIELD SURVIVOR"]:
		if not passive_names.has(required_passive):
			failures.append("Missing passive skill: " + required_passive)
	var server_test_cooldown := _server_validated_skill_cooldown("NERO", "BLITZ DASH", ["TACTICAL FOCUS"])
	if server_test_cooldown != 45:
		failures.append("Server skill cooldown validation must apply TACTICAL FOCUS exactly once")
	var server_test_cooldown_no_passive := _server_validated_skill_cooldown("RAVEN", "BLITZ DASH", [])
	if server_test_cooldown_no_passive < 25 or server_test_cooldown_no_passive > 50:
		failures.append("Server skill cooldown validation must remain inside the configured range")
	var sanitized_test_loadout := _sanitize_passive_loadout(["FORTIFIED", "SCAVENGER", "FORTIFIED", "INVALID", "FIELD MEDIC"])
	if sanitized_test_loadout != ["FORTIFIED", "SCAVENGER", "FIELD MEDIC"]:
		failures.append("Passive loadout sanitization failed")
	if _passive_starting_armor(sanitized_test_loadout) != 10.0 or _passive_starting_armor([]) != 0.0:
		failures.append("FORTIFIED starting armor calculation failed")
	if _passive_loot_amount(sanitized_test_loadout, "ammo_rifle", 25) != 30 or _passive_loot_amount(sanitized_test_loadout, "medkit", 25) != 25:
		failures.append("SCAVENGER loot bonus calculation failed")
	if _server_skill_damage_multiplier("LONGSHOT") != 1.25 or _server_skill_damage_multiplier("BLITZ DASH") != 1.0:
		failures.append("Server active-skill damage boost validation failed")
	if _server_skill_damage_reduction("BULWARK PULSE") != 0.80 or _server_skill_damage_reduction("SILENT SHOT") != 1.0:
		failures.append("Server active-skill damage mitigation validation failed")
	if _server_skill_effect_duration("BLITZ DASH") != 5.0 or _server_skill_effect_duration("FAST HEAL") != 8.0:
		failures.append("Server active-skill duration validation failed")
	var nero_duration_profile := _operator_skill_profile("NERO")
	var nero_expected_skill_duration := float(nero_duration_profile["duration"]) + float(nero_duration_profile["mechanic_duration"])
	if not is_equal_approx(_server_skill_effect_duration(str(nero_duration_profile["skill"])), nero_expected_skill_duration):
		failures.append("Server skill expiry must include the operator-specific tactical duration modifier")
	var skill_vitals_test := _server_calculate_skill_vitals("NERO", 50.0, 10.0)
	if float(skill_vitals_test.get("health", -1.0)) < 50.0 or float(skill_vitals_test.get("health", 101.0)) > 100.0 or float(skill_vitals_test.get("armor", -1.0)) < 10.0 or float(skill_vitals_test.get("armor", 101.0)) > 100.0:
		failures.append("Server-authoritative skill vitals calculation is outside valid bounds")
	var capped_skill_vitals := _server_calculate_skill_vitals("NERO", 100.0, 100.0)
	if not is_equal_approx(float(capped_skill_vitals["health"]), 100.0) or not is_equal_approx(float(capped_skill_vitals["armor"]), 100.0):
		failures.append("Server-authoritative skill vitals must respect 100-point caps")
	# Exercise the authoritative immediate-vitals calculation for every operator,
	# including the FIELD ENGINEER (archetype 8) armor grant.
	for vitals_operator in operator_roster:
		var vitals_profile := _operator_skill_profile(str(vitals_operator[0]))
		var vitals_result := _server_calculate_skill_vitals(str(vitals_operator[0]), 50.0, 10.0)
		if float(vitals_result.get("health", -1.0)) < 0.0 or float(vitals_result.get("health", 101.0)) > 100.0 or float(vitals_result.get("armor", -1.0)) < 0.0 or float(vitals_result.get("armor", 101.0)) > 100.0:
			failures.append("Authoritative skill vitals out of bounds for " + str(vitals_operator[0]))
		if int(vitals_profile["archetype"]) == 8 and float(vitals_result["armor"]) <= 10.0:
			failures.append("FIELD ENGINEER skill must grant authoritative armor for " + str(vitals_operator[0]))
	# Validate the complete per-operator active-skill and procedural animation clip sets.
	var active_mechanic_names: Dictionary = {}
	for mechanic_operator in operator_roster:
		var mechanic_profile := _operator_skill_profile(str(mechanic_operator[0]))
		var mechanic_name := str(mechanic_profile["active_mechanic_name"])
		if mechanic_name.is_empty() or active_mechanic_names.has(mechanic_name):
			failures.append("Operator active mechanic name is missing or duplicated: " + str(mechanic_operator[0]))
		active_mechanic_names[mechanic_name] = true
		if int(mechanic_profile["active_mechanic_id"]) != int(mechanic_profile["index"]):
			failures.append("Operator active mechanic ID does not match its roster slot: " + str(mechanic_operator[0]))
	if active_mechanic_names.size() != 50:
		failures.append("All 50 operators must expose unique named active mechanic identities")
	var active_recipe_signatures: Dictionary = {}
	for recipe_operator in operator_roster:
		var recipe_profile := _operator_skill_profile(str(recipe_operator[0]))
		var recipe_signature := "%.3f|%.3f|%.3f|%.3f|%.3f|%.3f|%d|%d|%.3f" % [
			float(recipe_profile["mechanic_speed"]),
			float(recipe_profile["mechanic_reload"]),
			float(recipe_profile["mechanic_heal"]),
			float(recipe_profile["mechanic_armor"]),
			float(recipe_profile["mechanic_health_regen"]),
			float(recipe_profile["mechanic_armor_regen"]),
			int(recipe_profile["mechanic_ammo"]),
			int(recipe_profile["mechanic_cover"]),
			float(recipe_profile["mechanic_duration"])
		]
		if active_recipe_signatures.has(recipe_signature):
			failures.append("Two operators share the same active-skill tactical recipe: " + str(recipe_operator[0]))
		active_recipe_signatures[recipe_signature] = true
	if active_recipe_signatures.size() != 50:
		failures.append("All 50 active-skill tactical recipes must be mechanically distinct")
	var tactical_action_signatures: Dictionary = {}
	for tactical_operator in operator_roster:
		var tactical_id := int(_operator_skill_profile(str(tactical_operator[0]))["active_mechanic_id"])
		var tactical_recipe := _operator_tactical_component_recipe(tactical_id)
		if tactical_recipe.size() < 2 or tactical_recipe.size() > 3:
			failures.append("Tactical action must combine two or three components: " + str(tactical_operator[0]))
		var tactical_parts := PackedStringArray()
		for component_id in tactical_recipe:
			if int(component_id) < 0 or int(component_id) > 9:
				failures.append("Unknown tactical component for " + str(tactical_operator[0]))
			tactical_parts.append(str(component_id))
		var tactical_signature := ",".join(tactical_parts)
		if tactical_action_signatures.has(tactical_signature):
			failures.append("Two operators share a tactical action combination: " + str(tactical_operator[0]))
		tactical_action_signatures[tactical_signature] = true
	if tactical_action_signatures.size() != 50:
		failures.append("All 50 operators must have unique tactical action combinations")
	var animation_probe := Node3D.new()
	var animation_probe_rig := Node3D.new()
	animation_probe_rig.name = "KeyframeRig"
	animation_probe.add_child(animation_probe_rig)
	_create_operator_keyframe_animations(animation_probe, "NERO")
	var animation_probe_player := animation_probe.get_node_or_null("OperatorAnimationPlayer") as AnimationPlayer
	if animation_probe_player == null or not animation_probe_player.has_animation_library(""):
		failures.append("Operator keyframe AnimationPlayer/library failed to initialize")
	else:
		var animation_probe_library := animation_probe_player.get_animation_library("")
		for required_keyframe_clip in ["idle", "walk", "sprint", "crouch", "jump", "fire", "reload", "hit", "death", "emote"]:
			if not animation_probe_library.has_animation(required_keyframe_clip):
				failures.append("Missing real keyframe animation resource: " + required_keyframe_clip)
				continue
			var tested_animation := animation_probe_library.get_animation(required_keyframe_clip)
			if tested_animation.get_track_count() != 3:
				failures.append("Keyframe clip must contain position, rotation and scale tracks: " + required_keyframe_clip)
			for track_index in range(tested_animation.get_track_count()):
				if tested_animation.track_get_key_count(track_index) != 5:
					failures.append("Keyframe clip must contain five authored poses: " + required_keyframe_clip)
	animation_probe.free()
	var operator_skill_signatures: Dictionary = {}
	var operator_motion_signatures: Dictionary = {}
	var required_animation_clips := ["idle", "walk", "sprint", "crouch", "jump", "fire", "reload", "hit", "death", "emote"]
	for skill_operator in operator_roster:
		var skill_operator_name := str(skill_operator[0])
		var skill_profile := _operator_skill_profile(skill_operator_name)
		var motion_style: Dictionary = _operator_animation_clip_set(skill_operator_name)["style"]
		var motion_signature := "%.3f:%.3f:%.3f:%.3f:%d:%.3f" % [float(motion_style["shoulder_roll"]), float(motion_style["hip_sway"]), float(motion_style["elbow_tuck"]), float(motion_style["head_tilt"]), int(motion_style["gait"]), float(motion_style["phase"])]
		if operator_motion_signatures.has(motion_signature):
			failures.append("Duplicate operator motion style: " + skill_operator_name)
		operator_motion_signatures[motion_signature] = true
		var skill_signature := "%.3f:%.2f:%d:%.2f:%.2f" % [float(skill_profile["power"]), float(skill_profile["duration"]), int(skill_profile["archetype"]), float(skill_profile["radius"]), float(skill_profile["reload"])]
		if operator_skill_signatures.has(skill_signature):
			failures.append("Duplicate active skill profile: " + skill_operator_name)
		operator_skill_signatures[skill_signature] = true
		if str(skill_profile["signature_channel"]) not in ["MOBILITY", "FORTIFY", "RECOVERY", "SUPPLY", "TEMPO"]:
			failures.append("Invalid signature skill mechanic: " + skill_operator_name)
		var passive_profile := _operator_passive_profile(skill_operator_name)
		if str(passive_profile["signature_channel"]) not in ["MOBILITY", "RELOAD", "PRECISION", "RESILIENCE", "TACTICAL"]:
			failures.append("Invalid signature passive channel: " + skill_operator_name)
		if float(passive_profile["signature_value"]) <= 0.0:
			failures.append("Missing signature passive strength: " + skill_operator_name)
		var clip_set := _operator_animation_clip_set(skill_operator_name)
		if not clip_set.has("style") or not (clip_set["style"] is Dictionary):
			failures.append("Operator unique animation style missing: " + skill_operator_name)
		for clip_name in required_animation_clips:
			if not clip_set.has(clip_name) or not (clip_set[clip_name] is Dictionary):
				failures.append("Operator animation state missing: " + skill_operator_name + " / " + clip_name)
	if operator_skill_signatures.size() != 50:
		failures.append("All 50 operators must have unique active-skill tuning profiles")
	if operator_motion_signatures.size() != 50:
		failures.append("All 50 operators must have unique procedural motion styles")
	var skill_visual_signatures: Dictionary = {}
	for visual_operator in operator_roster:
		var visual_profile := _operator_skill_visual_profile(str(visual_operator[0]))
		var visual_key := str(visual_profile["shape"]) + ":" + str(visual_profile["radius"]) + ":" + str(visual_profile["segments"]) + ":" + str(visual_profile["ring_count"]) + ":" + str(visual_profile["ring_spacing"]) + ":" + str(visual_profile["ring_width"])
		if skill_visual_signatures.has(visual_key):
			failures.append("Duplicate operator skill visual signature: " + str(visual_operator[0]))
		skill_visual_signatures[visual_key] = true
	if skill_visual_signatures.size() != 50:
		failures.append("All 50 operators must have unique skill visual signatures")
	if MAX_PLAYERS != 50:
		failures.append("MAX_PLAYERS must remain 50")
	if weapon_names.size() != weapon_damage.size() or weapon_names.size() != weapon_mag_sizes.size() or weapon_names.size() != weapon_fire_delays.size() or weapon_names.size() != weapon_ranges.size():
		failures.append("Weapon configuration arrays have different lengths")
	for index in range(weapon_names.size()):
		if float(weapon_damage[index]) <= 0.0 or int(weapon_mag_sizes[index]) <= 0 or float(weapon_fire_delays[index]) <= 0.0 or float(weapon_ranges[index]) <= 0.0:
			failures.append("Invalid weapon configuration at index " + str(index))
	if weapon_names.size() != 28 or weapon_headshot_multipliers.size() != weapon_names.size() or weapon_classes.size() != weapon_names.size() or weapon_damage[9] <= weapon_damage[0] or weapon_ranges[12] <= weapon_ranges[0] or weapon_mag_sizes[16] <= weapon_mag_sizes[0]:
		failures.append("Weapon class balance relationships are invalid")
	if weapon_spread.size() != weapon_names.size() or weapon_reserve.size() != weapon_names.size():
		failures.append("Weapon spread/reserve configuration length mismatch")
	if weapon_classes[23] != "LAUNCHER" or weapon_classes[24] != "LAUNCHER" or weapon_classes[25] != "BOW" or weapon_classes[26] != "BOW" or weapon_classes[27] != "GRENADE":
		failures.append("Projectile weapon classes are incorrectly configured")
	if weapon_classes.size() == weapon_names.size():
		for index in range(weapon_names.size()):
			if float(weapon_headshot_multipliers[index]) < 1.2 or float(weapon_headshot_multipliers[index]) > 2.5:
				failures.append("Headshot multiplier outside balance limits: " + weapon_names[index])
			if str(weapon_classes[index]) not in ["RIFLE", "SMG", "SHOTGUN", "SNIPER", "LMG", "PISTOL", "MELEE", "LAUNCHER", "BOW", "GRENADE"]:
				failures.append("Unknown weapon class: " + weapon_names[index])
	for melee_index in range(20, 23):
		if weapon_classes[melee_index] != "MELEE" or int(weapon_reserve[melee_index]) != 0:
			failures.append("Melee weapons must not consume reserve ammunition")
	# Every configured weapon must be available as a world pickup.
	var weapon_loot_indices := _weapon_loot_drop_indices()
	var weapon_loot_seen: Dictionary = {}
	for loot_weapon_index in weapon_loot_indices:
		if loot_weapon_index < 0 or loot_weapon_index >= weapon_names.size() or weapon_loot_seen.has(loot_weapon_index):
			failures.append("Weapon loot table contains an invalid or duplicate weapon index")
		weapon_loot_seen[loot_weapon_index] = true
	if weapon_loot_seen.size() != weapon_names.size():
		failures.append("Every weapon must have a corresponding world loot pickup")
	# Validate every weapon stat table, not only the core damage arrays.
	for table_index in range([weapon_damage, weapon_headshot_multipliers, weapon_mag_sizes, weapon_reserve, weapon_fire_delays, weapon_ranges, weapon_spread, weapon_classes].size()):
		var weapon_table: Array = [weapon_damage, weapon_headshot_multipliers, weapon_mag_sizes, weapon_reserve, weapon_fire_delays, weapon_ranges, weapon_spread, weapon_classes][table_index]
		if weapon_table.size() != weapon_names.size():
			failures.append("Weapon stat table length mismatch at table " + str(table_index))
	for weapon_index in range(weapon_names.size()):
		if float(weapon_headshot_multipliers[weapon_index]) < 1.0 or float(weapon_headshot_multipliers[weapon_index]) > 3.0:
			failures.append("Weapon headshot multiplier outside safe bounds: " + str(weapon_index))
		if float(weapon_spread[weapon_index]) > 0.25:
			failures.append("Weapon spread exceeds configured maximum: " + str(weapon_index))
	for index in range(weapon_spread.size()):
		if float(weapon_spread[index]) <= 0.0 or int(weapon_reserve[index]) < 0:
			failures.append("Invalid weapon spread or reserve ammo at index " + str(index))
	if MAP_SIZE < 100.0 or safe_radius <= 0.0 or health <= 0.0:
		failures.append("Invalid world or player survival configuration")
	var saved_teams: Dictionary = server_player_teams.duplicate(true)
	server_player_teams.clear()
	var solo_counts: Dictionary = {}
	for fake_id in range(1, 51):
		var solo_team := _assign_team_id(fake_id, 1)
		server_player_teams[fake_id] = solo_team
		solo_counts[solo_team] = int(solo_counts.get(solo_team, 0)) + 1
	if solo_counts.size() != 50:
		failures.append("Solo mode must assign each player to a separate team")
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
	var saved_team_mode := server_match_mode
	var saved_test_teams: Dictionary = server_player_teams.duplicate(true)
	server_match_mode = "Squad"
	server_player_teams = {1: 1, 2: 1, 3: 2}
	if not _are_teammates(1, 2) or _are_teammates(1, 3):
		failures.append("Squad teammate relationship detection is incorrect")
	server_match_mode = "Solo"
	if _are_teammates(1, 2):
		failures.append("Solo players must not be treated as teammates")
	server_player_teams = saved_test_teams
	server_match_mode = saved_team_mode
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
	# Exercise local-save sanitization with deliberately corrupted local profile data.
	var saved_profile_probe := {
		"name": profile_name, "level": player_level, "xp": player_xp,
		"matches": career_matches, "wins": career_wins, "coins": career_coins,
		"volume": master_volume, "quality": graphics_quality, "language": selected_language,
		"mode": selected_mode, "game_mode": selected_game_mode, "submode": selected_submode,
		"target": target_players, "history": match_history.duplicate(true),
		"achievements": unlocked_achievements.duplicate(true),
		"daily_matches": daily_mission_matches, "daily_wins": daily_mission_wins,
		"friends": friend_names.duplicate(true)
	}
	profile_name = "  "
	player_level = -10
	player_xp = 999999
	career_matches = -2
	career_wins = 900
	career_coins = -1
	master_volume = 4.0
	graphics_quality = 9
	selected_language = "INVALID"
	selected_mode = "INVALID"
	selected_game_mode = "INVALID"
	selected_submode = "INVALID"
	target_players = 500
	match_history = ["not-a-record", {"kills": 2}]
	unlocked_achievements = ["", "TEST ACHIEVEMENT", "TEST ACHIEVEMENT"]
	daily_mission_matches = -5
	daily_mission_wins = 100
	friend_names = ["A", "Valid Friend", "Valid Friend"]
	_sanitize_loaded_profile()
	if profile_name != "Player" or player_level != 1 or player_xp != 99 or career_matches != 0 or career_wins != 0 or career_coins != 0:
		failures.append("Local profile numeric/name sanitization failed")
	if master_volume != 1.0 or graphics_quality != 2 or selected_language != "English" or selected_mode != "Solo":
		failures.append("Local settings sanitization failed")
	if selected_game_mode != "Battle Royale" or selected_submode not in _available_submodes("Battle Royale") or target_players != MAX_PLAYERS:
		failures.append("Local matchmaking preference sanitization failed")
	if match_history.size() != 1 or unlocked_achievements != ["TEST ACHIEVEMENT"] or daily_mission_matches != 0 or daily_mission_wins != 0:
		failures.append("Local career history/mission sanitization failed")
	if friend_names != ["Valid Friend"]:
		failures.append("Local friends-list sanitization failed")
	profile_name = str(saved_profile_probe["name"])
	player_level = int(saved_profile_probe["level"])
	player_xp = int(saved_profile_probe["xp"])
	career_matches = int(saved_profile_probe["matches"])
	career_wins = int(saved_profile_probe["wins"])
	career_coins = int(saved_profile_probe["coins"])
	master_volume = float(saved_profile_probe["volume"])
	graphics_quality = int(saved_profile_probe["quality"])
	selected_language = str(saved_profile_probe["language"])
	selected_mode = str(saved_profile_probe["mode"])
	selected_game_mode = str(saved_profile_probe["game_mode"])
	selected_submode = str(saved_profile_probe["submode"])
	target_players = int(saved_profile_probe["target"])
	match_history = saved_profile_probe["history"]
	unlocked_achievements = saved_profile_probe["achievements"]
	daily_mission_matches = int(saved_profile_probe["daily_matches"])
	daily_mission_wins = int(saved_profile_probe["daily_wins"])
	friend_names = saved_profile_probe["friends"]
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
	rpc_id(1, "request_spawn", selected_mode + "|" + queue_type, selected_character, selected_gender, equipped_bundle, equipped_passive_skills)

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
	for hit_key_variant in server_vehicle_last_hit.keys():
		if str(hit_key_variant).ends_with(":" + str(id)):
			server_vehicle_last_hit.erase(hit_key_variant)
	server_player_health.erase(id)
	server_player_armor.erase(id)
	server_player_medkits.erase(id)
	server_player_gloo_charges.erase(id)
	server_player_skill_ready_at.erase(id)
	server_player_active_skill.erase(id)
	server_player_skill_active_until.erase(id)
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
func request_spawn(requested_mode: String, character_name: String = "KAIRO", gender: String = "MALE", bundle_name: String = "FIELD OPERATIVE", passive_loadout: Array = []) -> void:
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
	var safe_character := character_name if _is_valid_operator(character_name) else "NERO"
	var safe_gender := gender if gender in ["MALE", "FEMALE"] else "MALE"
	var safe_bundle := bundle_name if bundle_name in ["FIELD OPERATIVE", "EMBER PHANTOM", "NEON WRAITH", "IRON SENTINEL"] or bundle_name in _operator_bundle_names() else "FIELD OPERATIVE"
	var spawn_position := Vector3(randf_range(-65.0, 65.0), 48.0, randf_range(-65.0, 65.0))
	var server_spawn_position := spawn_position
	var spawn_yaw := 0.0
	if OS.get_environment("LAST_ZONE_TEST_MODE") == "1":
		if server_player_states.is_empty():
			spawn_position = Vector3(0.0, 48.0, 20.0)
			server_spawn_position = Vector3(0.0, 2.0, 20.0) if OS.get_environment("LAST_ZONE_VEHICLE_TEST_MODE") == "1" else spawn_position
		else:
			spawn_position = Vector3(0.0, 48.0, 16.0)
			server_spawn_position = Vector3(0.0, 2.0, -30.0) if OS.get_environment("LAST_ZONE_VEHICLE_TEST_MODE") == "1" else spawn_position
			spawn_yaw = PI
	if not server_player_states.is_empty():
		server_match_had_multiple_players = true
	var safe_passives := _sanitize_passive_loadout(passive_loadout)
	server_player_states[sender] = {"position": server_spawn_position, "yaw": spawn_yaw, "character": safe_character, "gender": safe_gender, "bundle": safe_bundle, "passives": safe_passives}
	server_match_roster[sender] = true
	server_player_ready[sender] = false
	lobby_countdown = -1.0
	lobby_last_broadcast_second = -1
	server_player_health[sender] = 100.0
	server_player_kills[sender] = int(server_player_kills.get(sender, 0))
	server_player_deaths[sender] = int(server_player_deaths.get(sender, 0))
	server_player_damage[sender] = float(server_player_damage.get(sender, 0.0))
	server_player_armor[sender] = _passive_starting_armor(safe_passives)
	server_player_medkits[sender] = 1
	server_player_gloo_charges[sender] = 2
	server_player_skill_ready_at[sender] = 0.0
	server_player_teams[sender] = team_id
	server_eliminated.erase(sender)
	last_server_position[sender] = server_spawn_position
	server_position_time[sender] = Time.get_ticks_msec() / 1000.0
	rpc_id(sender, "set_local_team", team_id, team_mode, team_capacity)
	rpc_id(sender, "set_local_spawn", spawn_position, spawn_yaw)
	rpc_id(sender, "receive_authoritative_inventory", float(server_player_armor[sender]), int(server_player_medkits[sender]))
	# Send the already connected players to the newcomer first.
	for existing_id_variant in server_player_states.keys():
		var existing_id := int(existing_id_variant)
		if existing_id == sender:
			continue
		var state: Dictionary = server_player_states[existing_id]
		rpc_id(sender, "spawn_remote_player", existing_id, state["position"], float(state["yaw"]), int(server_player_teams.get(existing_id, existing_id)), str(state.get("character", "KAIRO")), str(state.get("gender", "MALE")), str(state.get("bundle", "FIELD OPERATIVE")))
	# Announce the newcomer to every connected client.
	rpc("spawn_remote_player", sender, spawn_position, spawn_yaw, team_id, safe_character, safe_gender, safe_bundle)
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
	var expected_team_capacity := 1 if selected_mode == "Solo" else (2 if selected_mode == "Duo" else 4)
	for team_id in team_ids:
		team_counts[team_id] = int(team_counts.get(team_id, 0)) + 1
		if int(team_counts[team_id]) > expected_team_capacity:
			return
	team_roster_cache.clear()
	for index in range(peer_ids.size()):
		var team_id := team_ids[index]
		if not team_roster_cache.has(team_id):
			team_roster_cache[team_id] = []
		team_roster_cache[team_id].append(peer_ids[index])
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
	var team_capacity := expected_team_capacity
	if local_team_id > 0 and team_hud_label:
		var local_team_count := int(team_members.get(local_team_id, 1))
		team_hud_label.text = selected_mode.to_upper() + "  •  TEAM " + str(local_team_id) + "  •  ALLIES " + str(maxi(0, local_team_count - 1)) + "/" + str(maxi(0, team_capacity - 1))
	var team_keys: Array = team_members.keys()
	team_keys.sort()
	for team_variant in team_keys:
		lines.append("TEAM " + str(team_variant) + "  •  " + str(team_members[team_variant]) + "/" + str(team_capacity))
	for index in range(count):
		var peer_id := peer_ids[index]
		var team_id := team_ids[index] if index < team_ids.size() else 0
		var relation := "YOU" if peer_id == multiplayer.get_unique_id() else ("ALLY" if team_id == local_team_id and selected_mode != "Solo" else "PLAYER")
		lines.append("  " + relation + "  " + str(peer_id) + "  •  TEAM " + str(team_id))
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
		team_hud_label.text = mode.to_upper() + "  •  TEAM " + str(team_id) + "  •  ALLIES 0/" + str(maxi(0, team_capacity - 1))
	_refresh_team_markers()

@rpc("authority", "call_remote", "reliable")
func set_local_spawn(spawn_position: Vector3, spawn_yaw: float) -> void:
	if not spawn_position.is_finite() or not is_finite(spawn_yaw):
		return
	if OS.get_cmdline_user_args().has("--network-test-client"):
		network_test_spawn_received = spawn_position.y >= 40.0
		network_test_vehicle_driver_candidate = absf(spawn_position.z - 20.0) < 0.1
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
func spawn_remote_player(id: int, spawn_position: Vector3, yaw: float, team_id: int, character_name: String = "KAIRO", gender: String = "MALE", bundle_name: String = "FIELD OPERATIVE") -> void:
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
	body.set_meta("character", character_name if _is_valid_operator(character_name) else "NERO")
	body.set_meta("bundle", bundle_name if bundle_name in ["FIELD OPERATIVE", "EMBER PHANTOM", "NEON WRAITH", "IRON SENTINEL"] or bundle_name in _operator_bundle_names() else "FIELD OPERATIVE")
	var old_visual := body.get_node_or_null("CharacterVisual")
	if old_visual:
		old_visual.queue_free()
	var remote_visual := Node3D.new()
	remote_visual.name = "CharacterVisual"
	body.add_child(remote_visual)
	_build_operator_visual(remote_visual, true, gender if gender in ["MALE", "FEMALE"] else "MALE", str(body.get_meta("character", "NERO")) )
	_apply_bundle_to_visual(remote_visual, str(body.get_meta("bundle")), str(body.get_meta("character")) )
	_refresh_team_markers()

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
	_set_server_player_transform(sender, pos, yaw)
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
func _set_server_player_transform(peer_id: int, pos: Vector3, yaw: float) -> void:
	if not server_player_states.has(peer_id):
		return
	var state: Dictionary = server_player_states[peer_id].duplicate(true)
	state["position"] = pos
	state["yaw"] = yaw
	server_player_states[peer_id] = state


func _server_apply_damage(target_id: int, incoming: float, source: String) -> void:
	if not server_player_states.has(target_id) or server_eliminated.has(target_id) or incoming <= 0.0:
		return
	var target_state: Dictionary = server_player_states[target_id]
	var target_character := str(target_state.get("character", "NERO"))
	# Apply the selected operator's passive damage-resistance trait on the server,
	# so multiplayer health/armor outcomes remain authoritative.
	var target_passive_traits := _operator_passive_profile(target_character)
	var resilience_bonus := _operator_signature_bonus(target_character, "RESILIENCE") * 0.65
	var now := Time.get_ticks_msec() / 1000.0
	var active_defense_skill := str(server_player_active_skill.get(target_id, "")) if now < float(server_player_skill_active_until.get(target_id, 0.0)) else ""
	var skill_defense_multiplier := _server_skill_damage_reduction(active_defense_skill)
	var mitigated_incoming := incoming * float(target_passive_traits.get("damage_taken", 1.0)) * (1.0 - resilience_bonus) * skill_defense_multiplier
	var target_armor := float(server_player_armor.get(target_id, 0.0))
	var absorbed := minf(target_armor, mitigated_incoming * 0.60)
	target_armor = maxf(0.0, target_armor - absorbed)
	var target_health := maxf(0.0, float(server_player_health.get(target_id, 100.0)) - (mitigated_incoming - absorbed))
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
		_server_release_vehicle_driver(target_id)
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
func request_player_damage(target_id: int, weapon_index: int, hit_height: float = 0.8) -> void:
	if not multiplayer.is_server() or match_finished:
		return
	var shooter_id := multiplayer.get_remote_sender_id()
	if not match_started or shooter_id == target_id or not server_player_states.has(shooter_id) or not server_player_states.has(target_id):
		return
	if server_eliminated.has(shooter_id) or server_eliminated.has(target_id):
		return
	if _are_teammates(shooter_id, target_id):
		return
	if weapon_index < 0 or weapon_index >= weapon_damage.size():
		return
	var now := Time.get_ticks_msec() / 1000.0
	var previous_shot: float = float(server_last_shot_time.get(shooter_id, 0.0))
	if now - previous_shot < _weapon_stat(weapon_index, "fire_rate") * 0.8:
		return
	var shooter_state: Dictionary = server_player_states[shooter_id]
	var target_state: Dictionary = server_player_states[target_id]
	var shooter_pos: Vector3 = shooter_state["position"]
	var target_pos: Vector3 = target_state["position"]
	var shot_distance := shooter_pos.distance_to(target_pos)
	var authoritative_range := 2.8 if weapon_classes[weapon_index] == "MELEE" else _weapon_stat(weapon_index, "range") + 3.0
	if shot_distance > authoritative_range:
		return
	# Require the target to be broadly in front of the shooter; prevents arbitrary remote-target damage RPCs.
	var shooter_yaw := float(shooter_state.get("yaw", 0.0))
	var forward := Vector3(-sin(shooter_yaw), 0.0, -cos(shooter_yaw))
	var to_target := Vector3(target_pos.x - shooter_pos.x, 0.0, target_pos.z - shooter_pos.z).normalized()
	if forward.length_squared() > 0.1 and to_target.length_squared() > 0.1 and forward.dot(to_target) < 0.35:
		return
	# Server checks static world geometry so clients cannot shoot through buildings.
	var validated_hit_height := clampf(hit_height, 0.0, 2.1)
	var ray_from := shooter_pos + Vector3(0.0, 1.4, 0.0)
	var ray_to := target_pos + Vector3(0.0, validated_hit_height, 0.0)
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
	# Validate the hit height against the server's target position.
	var is_headshot := validated_hit_height >= 1.52 and validated_hit_height <= 2.1
	var final_damage := _weapon_stat(weapon_index, "damage")
	var attacker_skill := str(server_player_active_skill.get(shooter_id, "")) if now < float(server_player_skill_active_until.get(shooter_id, 0.0)) else ""
	final_damage *= _server_skill_damage_multiplier(attacker_skill)
	var damage_source := "PLAYER " + str(shooter_id)
	if is_headshot:
		final_damage *= float(weapon_headshot_multipliers[weapon_index])
		damage_source += " • HEADSHOT"
	_server_apply_damage(target_id, final_damage, damage_source)

@rpc("authority", "call_remote", "reliable")
func receive_authoritative_damage(new_health: float, new_armor: float, source: String, eliminated: bool) -> void:
	if OS.get_cmdline_user_args().has("--network-test-client"):
		network_test_damage_received = new_health < 100.0
	if local_player == null or is_dead:
		return
	health = clampf(new_health, 0.0, 100.0)
	armor = clampf(new_armor, 0.0, 100.0)
	damage_flash_timer = 0.25
	_trigger_character_hit_animation(local_player)
	if status_label:
		status_label.text = ("HEADSHOT! " if source.contains("HEADSHOT") else "UNDER ATTACK: ") + source
	if health_bar:
		health_bar.value = health
	if armor_bar:
		armor_bar.value = armor
	if eliminated or health <= 0.0:
		_die()

func broadcast_player_status(peer_id: int, current_health: float, current_armor: float) -> void:
	if players.has(peer_id):
		var observed := players[peer_id] as CharacterBody3D
		if is_instance_valid(observed):
			var previous_health := float(observed.get_meta("anim_observed_health", 100.0))
			if current_health < previous_health:
				_trigger_character_hit_animation(observed)
			observed.set_meta("anim_observed_health", current_health)
	if status_label:
		status_label.text = "PLAYER " + str(peer_id) + "  HP " + str(roundi(current_health)) + "  ARMOR " + str(roundi(current_armor))

@rpc("authority", "call_remote", "reliable")
func broadcast_elimination(killer_id: int, victim_id: int, total_eliminations: int) -> void:
	if players.has(victim_id):
		var victim := players[victim_id] as CharacterBody3D
		_trigger_character_death_animation(victim)
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

func _weapon_skin_id(index: int, tier: String) -> String:
	return tier + "|" + weapon_names[index]


func _weapon_skin_tier(index: int) -> String:
	var skin_id := str(equipped_weapon_skins.get(weapon_names[index], "BASE"))
	return skin_id.get_slice("|", 0) if skin_id.contains("|") else "BASE"


func _weapon_stat(index: int, stat: String) -> float:
	var tier := _weapon_skin_tier(index)
	var multiplier := 1.0
	match tier:
		"STARTER":
			if stat == "damage": multiplier = 1.02
			elif stat == "range": multiplier = 1.02
		"COIN":
			if stat == "damage": multiplier = 1.05
			elif stat == "range": multiplier = 1.04
			elif stat == "reload": multiplier = 0.96
			elif stat == "spread": multiplier = 0.97
		"LEVEL":
			if stat == "damage": multiplier = 1.04
			elif stat == "range": multiplier = 1.06
			elif stat == "reload": multiplier = 0.94
			elif stat == "spread": multiplier = 0.98
		"DIAMOND":
			if stat == "damage": multiplier = 1.10
			elif stat == "range": multiplier = 1.10
			elif stat == "reload": multiplier = 0.90
			elif stat == "spread": multiplier = 0.94
	if stat == "damage": return float(weapon_damage[index]) * multiplier
	if stat == "range": return float(weapon_ranges[index]) * multiplier
	if stat == "reload": return multiplier
	if stat == "spread": return float(weapon_spread[index]) * multiplier
	if stat == "fire_rate": return float(weapon_fire_delays[index]) * (0.95 if tier == "COIN" else (0.92 if tier == "LEVEL" else (0.88 if tier == "DIAMOND" else 1.0)))
	return 1.0


func _fire_weapon() -> void:
	if local_player == null or fire_cooldown > 0.0 or is_reloading:
		return
	var is_melee_weapon: bool = str(weapon_classes[current_weapon]) == "MELEE"
	if not is_melee_weapon and ammo_in_mag <= 0:
		if status_label:
			status_label.text = "MAGAZINE EMPTY - RELOAD"
		_start_reload()
		return
	if not is_melee_weapon:
		ammo_in_mag -= 1
		weapon_mag_ammo[current_weapon] = ammo_in_mag
	fire_cooldown = _weapon_stat(current_weapon, "fire_rate")
	local_player.set_meta("anim_fire_until", Time.get_ticks_msec() / 1000.0 + 0.22)
	_update_weapon_hud()
	var camera := local_player.get_node_or_null("CameraPivot/Camera3D") as Camera3D
	if camera == null:
		return
	var operator_spread_profile := _operator_passive_profile(selected_character)
	var operator_spread_trait := float(operator_spread_profile["spread"]) * (1.0 - _operator_signature_bonus(selected_character, "PRECISION") * 0.65)
	var spread: float = 0.0 if is_melee_weapon else (_weapon_stat(current_weapon, "spread") + weapon_spread_bloom) * operator_spread_trait * (0.85 if equipped_passive_skills.has("SHARP EYE") else 1.0)
	weapon_recoil = minf(0.24, weapon_recoil + (0.095 if weapon_classes[current_weapon] == "SHOTGUN" else (0.055 if weapon_classes[current_weapon] == "SNIPER" else (0.018 if weapon_classes[current_weapon] == "PISTOL" else 0.03))))
	weapon_spread_bloom = minf(0.12, weapon_spread_bloom + (0.035 if weapon_classes[current_weapon] == "SHOTGUN" else (0.004 if weapon_classes[current_weapon] == "SNIPER" else 0.008)))
	if weapon_visual:
		weapon_visual.rotation.z = randf_range(-0.018, 0.018)
	_play_weapon_sound(current_weapon)
	var aim_direction := -camera.global_basis.z
	aim_direction += camera.global_basis.x * randf_range(-spread, spread)
	aim_direction += camera.global_basis.y * randf_range(-spread, spread)
	aim_direction = aim_direction.normalized()
	if weapon_classes[current_weapon] in ["LAUNCHER", "BOW", "GRENADE"]:
		_spawn_weapon_projectile(camera.global_position + aim_direction * 0.65, aim_direction, current_weapon)
		_show_muzzle_flash()
		return
	var from := camera.global_position
	var effective_range := 2.6 if is_melee_weapon else _weapon_stat(current_weapon, "range")
	var to: Vector3 = from + aim_direction * effective_range
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.exclude = [local_player.get_rid()]
	var own_head_area := local_player.get_node_or_null("HeadHitbox") as Area3D
	if own_head_area:
		query.exclude.append(own_head_area.get_rid())
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit:
		_spawn_bullet_impact(hit.position, hit.normal, hit.collider)
		var hit_collider := hit.collider as Node
		var is_headshot := hit_collider is Area3D and hit_collider.name == "HeadHitbox"
		var target := hit_collider as CharacterBody3D
		if target == null and hit_collider is Area3D:
			target = hit_collider.get_parent() as CharacterBody3D
		if target:
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
			var hit_damage := _weapon_stat(current_weapon, "damage")
			if is_headshot:
				hit_damage *= float(weapon_headshot_multipliers[current_weapon])
			if status_label:
				status_label.text = ("HEADSHOT! " if is_headshot else "HIT: ") + target.name + "  (" + str(roundi(hit_damage)) + " DMG)"
			_show_damage_popup(hit.position, hit_damage, is_headshot)
			if target.has_meta("training_target"):
				_damage_training_target(target, hit_damage)
			elif target.has_method("apply_damage"):
				target.apply_damage(hit_damage)
			elif target.name.begins_with("Player_") and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server():
				var target_id := int(target.name.trim_prefix("Player_"))
				var hit_height: float = hit.position.y - target.global_position.y
				rpc_id(1, "request_player_damage", target_id, current_weapon, hit_height)
		else:
			if status_label:
				status_label.text = "SHOT FIRED - IMPACT"
	else:
		if status_label:
			status_label.text = "SHOT FIRED"
	_show_muzzle_flash()
	if weapon_visual:
		weapon_visual.rotation.x = -0.08


func _spawn_weapon_projectile(spawn_position: Vector3, direction: Vector3, weapon_index: int) -> void:
	var projectile := Node3D.new()
	projectile.name = "WeaponProjectile_" + weapon_names[weapon_index].replace(" ", "_")
	projectile.global_position = spawn_position
	var visual := MeshInstance3D.new()
	var material_color := Color(1.0, 0.42, 0.12) if weapon_classes[weapon_index] in ["LAUNCHER", "GRENADE"] else Color(0.78, 0.68, 0.35)
	var material := _material(material_color)
	if weapon_classes[weapon_index] in ["LAUNCHER", "GRENADE"]:
		var shell := SphereMesh.new()
		shell.radius = 0.16 if weapon_index == 23 else 0.12
		shell.height = shell.radius * 2.0
		visual.mesh = shell
	else:
		var bolt := CylinderMesh.new()
		bolt.top_radius = 0.025
		bolt.bottom_radius = 0.012
		bolt.height = 0.72
		visual.mesh = bolt
		visual.rotation.x = PI * 0.5
	visual.material_override = material
	projectile.add_child(visual)
	add_child(projectile)
	var speed := (18.0 if weapon_classes[weapon_index] == "GRENADE" else 28.0) if weapon_classes[weapon_index] in ["LAUNCHER", "GRENADE"] else (62.0 if weapon_index == 25 else 72.0)
	active_weapon_projectiles.append({
		"node": projectile,
		"velocity": direction.normalized() * speed + Vector3.UP * (4.0 if weapon_classes[weapon_index] == "GRENADE" else (2.0 if weapon_classes[weapon_index] == "LAUNCHER" else 0.0)),
		"weapon": weapon_index,
		"life": (2.2 if weapon_classes[weapon_index] == "GRENADE" else 4.0) if weapon_classes[weapon_index] in ["LAUNCHER", "GRENADE"] else 2.5,
		"damage": _weapon_stat(weapon_index, "damage")
	})


func _update_weapon_projectiles(delta: float) -> void:
	for projectile_index in range(active_weapon_projectiles.size() - 1, -1, -1):
		var data: Dictionary = active_weapon_projectiles[projectile_index]
		var projectile_node := data.get("node") as Node3D
		if not is_instance_valid(projectile_node):
			active_weapon_projectiles.remove_at(projectile_index)
			continue
		var old_position: Vector3 = projectile_node.global_position
		var velocity: Vector3 = data["velocity"]
		velocity.y -= 9.8 * delta if weapon_classes[int(data["weapon"])] in ["LAUNCHER", "GRENADE"] else 1.2 * delta
		var next_position := old_position + velocity * delta
		var query := PhysicsRayQueryParameters3D.create(old_position, next_position)
		query.collide_with_areas = true
		if local_player:
			query.exclude = [local_player.get_rid()]
			var own_head := local_player.get_node_or_null("HeadHitbox") as Area3D
			if own_head:
				query.exclude.append(own_head.get_rid())
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		data["velocity"] = velocity
		data["life"] = float(data["life"]) - delta
		active_weapon_projectiles[projectile_index] = data
		if not hit.is_empty():
			var collider := hit["collider"] as Object
			var hit_node := collider as Node
			var target := collider as CharacterBody3D
			if target == null and hit_node is Area3D:
				target = hit_node.get_parent() as CharacterBody3D
			if weapon_classes[int(data["weapon"])] in ["LAUNCHER", "GRENADE"]:
				_resolve_launcher_explosion(hit["position"], int(data["weapon"]), float(data["damage"]))
			elif target:
				_apply_weapon_projectile_hit(target, hit["position"], float(data["damage"]), int(data["weapon"]))
			else:
				_spawn_bullet_impact(hit["position"], hit["normal"], collider)
			projectile_node.queue_free()
			active_weapon_projectiles.remove_at(projectile_index)
			continue
		projectile_node.global_position = next_position
		if velocity.length_squared() > 0.1:
			projectile_node.look_at(next_position + velocity, Vector3.UP)
		if float(data["life"]) <= 0.0:
			if weapon_classes[int(data["weapon"])] in ["LAUNCHER", "GRENADE"]:
				_resolve_launcher_explosion(projectile_node.global_position, int(data["weapon"]), float(data["damage"]))
			projectile_node.queue_free()
			active_weapon_projectiles.remove_at(projectile_index)


func _apply_weapon_projectile_hit(target: CharacterBody3D, hit_position: Vector3, damage: float, weapon_index: int) -> void:
	if not is_instance_valid(target):
		return
	_spawn_bullet_impact(hit_position, Vector3.UP, target)
	var head_area := target.get_node_or_null("HeadHitbox") as Area3D
	var is_headshot := head_area != null and head_area.global_position.distance_to(hit_position) <= 0.42
	var final_damage := damage * (float(weapon_headshot_multipliers[weapon_index]) if is_headshot else 1.0)
	_show_damage_popup(hit_position, final_damage, is_headshot)
	if target.has_meta("training_target"):
		_damage_training_target(target, final_damage)
	elif target.has_method("apply_damage"):
		target.apply_damage(final_damage)
	elif target.name.begins_with("Player_") and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server():
		var target_id := int(target.name.trim_prefix("Player_"))
		var hit_height := hit_position.y - target.global_position.y
		rpc_id(1, "request_player_damage", target_id, weapon_index, hit_height)
	if status_label:
		status_label.text = ("HEADSHOT! " if is_headshot else "PROJECTILE HIT: ") + target.name


func _resolve_launcher_explosion(explosion_position: Vector3, weapon_index: int, base_damage: float) -> void:
	var blast := MeshInstance3D.new()
	blast.name = "LauncherExplosion"
	var blast_mesh := SphereMesh.new()
	blast_mesh.radius = 0.2
	blast_mesh.height = 0.4
	blast.mesh = blast_mesh
	blast.material_override = _material(Color(1.0, 0.38, 0.08, 0.78))
	blast.global_position = explosion_position
	add_child(blast)
	var tween := create_tween()
	tween.tween_property(blast, "scale", Vector3.ONE * 18.0, 0.22)
	tween.parallel().tween_property(blast, "transparency", 1.0, 0.22)
	tween.tween_callback(blast.queue_free)
	const BLAST_RADIUS := 5.0
	for peer_variant in players.keys():
		var peer_id := int(peer_variant)
		var target := players[peer_id] as CharacterBody3D
		if not is_instance_valid(target) or target == local_player or not target.visible:
			continue
		var distance := target.global_position.distance_to(explosion_position)
		if distance > BLAST_RADIUS:
			continue
		var falloff := 1.0 - (distance / BLAST_RADIUS) * 0.55
		_apply_weapon_projectile_hit(target, target.global_position + Vector3.UP * 0.9, base_damage * falloff, weapon_index)
	for target in training_targets:
		if is_instance_valid(target):
			var distance := target.global_position.distance_to(explosion_position)
			if distance <= BLAST_RADIUS:
				_damage_training_target(target, base_damage * (1.0 - (distance / BLAST_RADIUS) * 0.55))


func _equip_weapon(index: int) -> void:
	if index < 0 or index >= weapon_names.size() or is_reloading:
		return
	if weapon_mag_ammo.size() != weapon_names.size() or weapon_reserve_ammo.size() != weapon_names.size():
		weapon_mag_ammo.resize(weapon_names.size())
		weapon_reserve_ammo.resize(weapon_names.size())
		for weapon_index in range(weapon_names.size()):
			if weapon_mag_ammo[weapon_index] <= 0:
				weapon_mag_ammo[weapon_index] = int(weapon_mag_sizes[weapon_index])
			if weapon_reserve_ammo[weapon_index] <= 0:
				weapon_reserve_ammo[weapon_index] = int(weapon_reserve[weapon_index])
	current_weapon = index
	ammo_in_mag = weapon_mag_ammo[index]
	reserve_ammo = weapon_reserve_ammo[index]
	_update_weapon_visual()
	_update_weapon_hud()
	if status_label:
		status_label.text = "EQUIPPED: " + weapon_names[index]


func _start_reload() -> void:
	if is_reloading or weapon_classes[current_weapon] == "MELEE" or ammo_in_mag >= weapon_mag_sizes[current_weapon] or reserve_ammo <= 0:
		return
	is_reloading = true
	if local_player:
		local_player.set_meta("anim_reload_until", Time.get_ticks_msec() / 1000.0 + 2.8)
	var operator_reload_profile := _operator_passive_profile(selected_character)
	var operator_reload_trait := float(operator_reload_profile["reload"]) * (1.0 - _operator_signature_bonus(selected_character, "RELOAD") * 0.70)
	reload_timer = (2.4 if weapon_classes[current_weapon] == "SHOTGUN" else (2.8 if weapon_classes[current_weapon] == "SNIPER" else (1.0 if weapon_classes[current_weapon] == "MELEE" else 1.8))) * _weapon_stat(current_weapon, "reload") * operator_reload_trait * (0.82 if equipped_passive_skills.has("QUICK HANDS") else 1.0) * (1.0 - skill_reload_bonus)
	if status_label:
		status_label.text = "RELOADING " + weapon_names[current_weapon] + "..."


func _finish_reload() -> void:
	var needed: int = int(weapon_mag_sizes[current_weapon]) - ammo_in_mag
	var loaded := mini(needed, reserve_ammo)
	ammo_in_mag += loaded
	reserve_ammo -= loaded
	weapon_mag_ammo[current_weapon] = ammo_in_mag
	weapon_reserve_ammo[current_weapon] = reserve_ammo
	is_reloading = false
	reload_timer = 0.0
	_update_weapon_hud()
	if status_label:
		status_label.text = "RELOAD COMPLETE"


func _update_weapon_hud() -> void:
	if current_weapon < 0 or current_weapon >= weapon_names.size():
		return
	if weapon_hud_label:
		weapon_hud_label.text = weapon_names[current_weapon] + "  •  " + str(weapon_classes[current_weapon])
	if ammo_hud_label:
		if weapon_classes[current_weapon] == "MELEE":
			ammo_hud_label.text = "∞  •  MELEE"
		else:
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
	var skin_tier := _weapon_skin_tier(current_weapon)
	var skin_color := Color(0.22, 0.25, 0.26)
	match skin_tier:
		"STARTER": skin_color = Color(0.25, 0.48, 0.58)
		"COIN": skin_color = Color(0.72, 0.55, 0.20)
		"LEVEL": skin_color = Color(0.36, 0.68, 0.42)
		"DIAMOND": skin_color = Color(0.48, 0.34, 0.82)
	var dark := _material(Color(0.075, 0.085, 0.09))
	var metal := _material(skin_color)
	var grip := _material(Color(0.12, 0.105, 0.085))
	var body_mesh := MeshInstance3D.new()
	var body_box := BoxMesh.new()
	if weapon_classes[current_weapon] == "RIFLE":
		body_box.size = Vector3(0.16, 0.18, 0.72)
	elif weapon_classes[current_weapon] in ["SMG", "PISTOL"]:
		body_box.size = Vector3(0.15, 0.16, 0.56)
	elif weapon_classes[current_weapon] == "MELEE":
		body_box.size = Vector3(0.11, 0.12, 0.62)
	elif weapon_classes[current_weapon] in ["LAUNCHER", "BOW"]:
		body_box.size = Vector3(0.20, 0.22, 0.88)
	else:
		body_box.size = Vector3(0.19, 0.20, 0.48)
	body_mesh.mesh = body_box
	body_mesh.material_override = metal
	weapon_visual.add_child(body_mesh)
	var barrel := MeshInstance3D.new()
	if weapon_classes[current_weapon] == "SHOTGUN":
		var shotgun_tube := CylinderMesh.new()
		shotgun_tube.top_radius = 0.055
		shotgun_tube.bottom_radius = 0.055
		shotgun_tube.height = 0.52
		barrel.mesh = shotgun_tube
	else:
		var barrel_mesh := CylinderMesh.new()
		barrel_mesh.top_radius = 0.027 if weapon_classes[current_weapon] in ["SMG", "PISTOL"] else 0.035
		barrel_mesh.bottom_radius = 0.035 if weapon_classes[current_weapon] in ["SMG", "PISTOL"] else 0.045
		barrel_mesh.height = 0.48 if weapon_classes[current_weapon] == "RIFLE" else 0.34
		barrel.mesh = barrel_mesh
	barrel.rotation.x = PI * 0.5
	barrel.position.z = -0.48 if weapon_classes[current_weapon] == "SHOTGUN" else -0.52
	barrel.material_override = dark
	weapon_visual.add_child(barrel)
	var stock := MeshInstance3D.new()
	var stock_mesh := BoxMesh.new()
	stock_mesh.size = Vector3(0.13, 0.13, 0.28 if current_weapon != 2 else 0.18)
	stock.mesh = stock_mesh
	stock.position.z = 0.40
	stock.material_override = grip
	weapon_visual.add_child(stock)
	var magazine := MeshInstance3D.new()
	var mag_mesh := BoxMesh.new()
	mag_mesh.size = Vector3(0.10, 0.24 if weapon_classes[current_weapon] in ["SMG", "PISTOL"] else 0.18, 0.13)
	magazine.mesh = mag_mesh
	magazine.position = Vector3(0, -0.17, 0.05)
	magazine.material_override = dark
	weapon_visual.add_child(magazine)
	if weapon_classes[current_weapon] == "RIFLE":
		var sight := MeshInstance3D.new()
		var sight_mesh := BoxMesh.new()
		sight_mesh.size = Vector3(0.07, 0.09, 0.12)
		sight.mesh = sight_mesh
		sight.position = Vector3(0, 0.13, -0.08)
		sight.material_override = dark
		weapon_visual.add_child(sight)
	elif weapon_classes[current_weapon] in ["SMG", "PISTOL"]:
		var front_grip := MeshInstance3D.new()
		var grip_mesh := BoxMesh.new()
		grip_mesh.size = Vector3(0.09, 0.16, 0.09)
		front_grip.mesh = grip_mesh
		front_grip.position = Vector3(0, -0.13, -0.18)
		front_grip.material_override = grip
		weapon_visual.add_child(front_grip)
	else:
		for side in [-1.0, 1.0]:
			var barrel_side := MeshInstance3D.new()
			var side_mesh := CylinderMesh.new()
			side_mesh.top_radius = 0.035
			side_mesh.bottom_radius = 0.035
			side_mesh.height = 0.48
			barrel_side.mesh = side_mesh
			barrel_side.rotation.x = PI * 0.5
			barrel_side.position = Vector3(side * 0.065, 0.015, -0.47)
			barrel_side.material_override = dark
			weapon_visual.add_child(barrel_side)


func _play_weapon_sound(weapon_index: int) -> void:
	if weapon_audio_player == null:
		weapon_audio_player = AudioStreamPlayer.new()
		weapon_audio_player.name = "WeaponAudio"
		weapon_audio_player.bus = "SFX"
		add_child(weapon_audio_player)
	var sample_rate := 22050
	var duration := 0.19 if weapon_classes[weapon_index] == "SHOTGUN" else (0.16 if weapon_classes[weapon_index] == "SNIPER" else 0.11)
	var sample_count := int(sample_rate * duration)
	var samples := PackedByteArray()
	samples.resize(sample_count * 2)
	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var envelope := exp(-t * (17.0 if weapon_classes[weapon_index] == "SHOTGUN" else (22.0 if weapon_classes[weapon_index] == "SNIPER" else 34.0)))
		var tone := sin(TAU * (105.0 + float(weapon_index) * 42.0) * t) * 0.42
		var noise := randf_range(-1.0, 1.0) * (0.48 if weapon_classes[weapon_index] == "SHOTGUN" else 0.28)
		var value := clampf((tone + noise) * envelope, -1.0, 1.0)
		samples.encode_s16(i * 2, int(value * 18000.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = samples
	weapon_audio_player.stop()
	weapon_audio_player.stream = stream
	weapon_audio_player.pitch_scale = randf_range(0.96, 1.04)
	weapon_audio_player.play()


func _show_damage_popup(position: Vector3, damage: float, is_headshot: bool) -> void:
	var popup := Label3D.new()
	popup.name = "DamagePopup"
	popup.text = ("HEADSHOT! " if is_headshot else "") + str(roundi(damage))
	popup.font_size = 42 if is_headshot else 30
	popup.outline_size = 8
	popup.modulate = Color(1.0, 0.78, 0.18) if is_headshot else Color(1.0, 1.0, 1.0)
	popup.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	popup.no_depth_test = true
	popup.position = position + Vector3(0, 0.55, 0)
	add_child(popup)
	var tween := create_tween()
	tween.tween_property(popup, "position:y", popup.position.y + 0.8, 0.65)
	tween.parallel().tween_property(popup, "modulate:a", 0.0, 0.65)
	tween.tween_callback(popup.queue_free)


func _spawn_bullet_impact(position: Vector3, normal: Vector3, collider: Object) -> void:
	var effect := Node3D.new()
	effect.name = "BulletImpact"
	effect.global_position = position + normal * 0.025
	add_child(effect)
	var spark := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.055
	sphere.height = 0.11
	spark.mesh = sphere
	spark.material_override = _material(Color(1.0, 0.68, 0.28) if collider is CharacterBody3D else Color(0.72, 0.76, 0.78))
	effect.add_child(spark)
	var timer := get_tree().create_timer(0.16)
	timer.timeout.connect(func():
		if is_instance_valid(effect):
			effect.queue_free()
	)


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
		selected_character = str(cfg.get_value("collection", "character", "NERO"))
		var saved_characters: Array = cfg.get_value("collection", "owned_characters", ["NERO"])
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
		if not owned_characters.has(selected_character) or not _is_valid_operator(selected_character): selected_character = "NERO"
		selected_skill = _character_active_skill(selected_character)
		owned_emotes = cfg.get_value("collection", "emotes", ["SALUTE"])
		equipped_emote = str(cfg.get_value("collection", "equipped_emote", "SALUTE"))
		owned_gloo_skins = cfg.get_value("collection", "gloo_skins", ["TACTICAL BLUE"])
		equipped_gloo_skin = str(cfg.get_value("collection", "equipped_gloo_skin", "TACTICAL BLUE"))
		weapon_upgrade_levels = cfg.get_value("collection", "weapon_upgrades", {"ASSAULT RIFLE": 0, "SMG": 0, "SHOTGUN": 0})
		owned_weapon_skins = cfg.get_value("collection", "weapon_skins", [])
		equipped_weapon_skins = cfg.get_value("collection", "equipped_weapon_skins", {})
	_sanitize_loaded_profile()
	for weapon_index in range(weapon_names.size()):
		var starter_skin := _weapon_skin_id(weapon_index, "STARTER")
		if not owned_weapon_skins.has(starter_skin): owned_weapon_skins.append(starter_skin)
	if player_id.is_empty():
		player_id = "LZ-" + str(abs(hash(profile_name + str(Time.get_unix_time_from_system())))).pad_zeros(8)
	_save_local_settings()
	_apply_audio_settings()
	_reset_daily_missions_if_needed()
	_claim_daily_login_reward()


func _sanitize_loaded_profile() -> void:
	# ConfigFile is local, user-editable data. Treat loaded values as untrusted
	# and repair malformed or outdated entries before gameplay consumes them.
	profile_name = profile_name.strip_edges().left(16)
	if profile_name.length() < 3:
		profile_name = "Player"
	player_level = clampi(player_level, 1, 10000)
	player_xp = clampi(player_xp, 0, maxi(0, player_level * 100 - 1))
	career_matches = maxi(0, career_matches)
	career_wins = clampi(career_wins, 0, career_matches)
	career_kills = maxi(0, career_kills)
	career_deaths = maxi(0, career_deaths)
	career_damage = maxi(0, career_damage)
	career_best_kills = clampi(career_best_kills, 0, career_kills)
	career_coins = maxi(0, career_coins)
	ranked_points = maxi(0, ranked_points)
	master_volume = clampf(master_volume, 0.0, 1.0)
	music_volume = clampf(music_volume, 0.0, 1.0)
	sfx_volume = clampf(sfx_volume, 0.0, 1.0)
	graphics_quality = clampi(graphics_quality, 0, 2)
	if selected_language not in ["English", "Sinhala"]:
		selected_language = "English"
	if selected_mode not in ["Solo", "Duo", "Squad"]:
		selected_mode = "Solo"
	if selected_game_mode not in ["Battle Royale", "Ranked Battle Royale", "Squad Strike", "Duel Zone", "Combat Academy", "World Forge", "Survival Events", "Private Operations"]:
		selected_game_mode = "Battle Royale"
	var valid_submodes := _available_submodes(selected_game_mode)
	if selected_submode not in valid_submodes:
		selected_submode = str(valid_submodes[0]) if not valid_submodes.is_empty() else "Solo"
	target_players = clampi(target_players, 2, MAX_PLAYERS)
	server_address = server_address.strip_edges().left(253)
	custom_room_code = custom_room_code.strip_edges().to_upper().left(12)
	if not (match_history is Array):
		match_history = []
	var clean_history: Array = []
	for entry in match_history:
		if entry is Dictionary and clean_history.size() < 20:
			clean_history.append(entry)
	match_history = clean_history
	if not (unlocked_achievements is Array):
		unlocked_achievements = []
	var clean_achievements: Array = []
	for achievement in unlocked_achievements:
		var achievement_name := str(achievement).strip_edges()
		if not achievement_name.is_empty() and not clean_achievements.has(achievement_name):
			clean_achievements.append(achievement_name)
	unlocked_achievements = clean_achievements
	if not (daily_claimed is Array):
		daily_claimed = []
	var clean_claimed: Array[String] = []
	for claim in daily_claimed:
		var claim_name := str(claim).strip_edges()
		if not claim_name.is_empty() and not clean_claimed.has(claim_name):
			clean_claimed.append(claim_name)
	daily_claimed = clean_claimed
	daily_mission_matches = maxi(0, daily_mission_matches)
	daily_mission_kills = maxi(0, daily_mission_kills)
	daily_mission_damage = maxi(0, daily_mission_damage)
	daily_mission_wins = clampi(daily_mission_wins, 0, daily_mission_matches)
	daily_mission_loot = maxi(0, daily_mission_loot)
	var clean_friends: Array[String] = []
	for friend in friend_names:
		var friend_name := str(friend).strip_edges().left(16)
		if friend_name.length() >= 3 and not clean_friends.has(friend_name) and clean_friends.size() < 100:
			clean_friends.append(friend_name)
	friend_names = clean_friends
	if not (owned_bundles is Array):
		owned_bundles = ["FIELD OPERATIVE"]
	if not (owned_characters is Array):
		owned_characters = ["NERO"]
	if not (owned_emotes is Array):
		owned_emotes = ["SALUTE"]
	if not (owned_gloo_skins is Array):
		owned_gloo_skins = ["TACTICAL BLUE"]
	if not (owned_weapon_skins is Array):
		owned_weapon_skins = []
	if not (equipped_weapon_skins is Dictionary):
		equipped_weapon_skins = {}
	if not (weapon_upgrade_levels is Dictionary):
		weapon_upgrade_levels = {"ASSAULT RIFLE": 0, "SMG": 0, "SHOTGUN": 0}
	for upgrade_key in weapon_upgrade_levels.keys():
		weapon_upgrade_levels[upgrade_key] = clampi(int(weapon_upgrade_levels[upgrade_key]), 0, 10)
	if not owned_bundles.has("FIELD OPERATIVE"):
		owned_bundles.append("FIELD OPERATIVE")
	if not owned_characters.has("NERO"):
		owned_characters.append("NERO")
	if not owned_characters.has("KAIRO"):
		owned_characters.append("KAIRO")
	if not owned_characters.has("NYX"):
		owned_characters.append("NYX")
	if not owned_emotes.has("SALUTE"):
		owned_emotes.append("SALUTE")
	if not owned_gloo_skins.has("TACTICAL BLUE"):
		owned_gloo_skins.append("TACTICAL BLUE")
	if not owned_bundles.has(equipped_bundle):
		equipped_bundle = "FIELD OPERATIVE"
	if not owned_emotes.has(equipped_emote):
		equipped_emote = "SALUTE"
	if not owned_gloo_skins.has(equipped_gloo_skin):
		equipped_gloo_skin = "TACTICAL BLUE"

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
	cfg.set_value("collection", "weapon_skins", owned_weapon_skins)
	cfg.set_value("collection", "equipped_weapon_skins", equipped_weapon_skins)
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
	for weapon_index in range(weapon_names.size()):
		var required_level := 5 + (weapon_index % 5) * 5
		if player_level >= required_level:
			var level_skin := _weapon_skin_id(weapon_index, "LEVEL")
			if not owned_weapon_skins.has(level_skin):
				owned_weapon_skins.append(level_skin)
				var reward_id: String = "WEAPON SKIN: " + str(weapon_names[weapon_index]) + " LEVEL CAMO"
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



func _character_signature_weapon_index(character: String) -> int:
	var signature_name := ""
	for operator_data in _character_roster():
		if str(operator_data[0]) == character:
			signature_name = str(operator_data[3])
			break
	var weapon_aliases := {
		"ASSAULT RIFLE": "M4A1",
		"KATANA + SMG": "KATANA",
		"SNIPER RIFLE": "AWM",
		"KAR98": "KAR98K",
		"SKS": "KAR98K",
		"SVD": "AWM",
		"VSS": "MP5",
		"VECTOR": "MP40",
		"P90": "MP5"
	}
	var resolved_name := str(weapon_aliases.get(signature_name, signature_name))
	return weapon_names.find(resolved_name)

func _equip_character_signature_weapon(character: String) -> void:
	var signature_index := _character_signature_weapon_index(character)
	if signature_index < 0:
		return
	current_weapon = signature_index
	if weapon_mag_ammo.size() == weapon_names.size():
		ammo_in_mag = int(weapon_mag_ammo[current_weapon])
	if weapon_reserve_ammo.size() == weapon_names.size():
		reserve_ammo = int(weapon_reserve_ammo[current_weapon])
	_update_weapon_visual()
	_update_weapon_hud()


func _character_unlock_level(character: String) -> int:
	var roster := _character_roster()
	for i in range(roster.size()):
		if str(roster[i][0]) == character:
			return 1 + (i / 5) * 5
	match character:
		"KAIRO", "NYX": return 1
		"MIRA": return 5
		"ROOK": return 15
		"VEX": return 30
		"SABLE": return 50
		"ORION": return 70
	return 999

func _character_coin_price(character: String) -> int:
	var roster := _character_roster()
	for i in range(roster.size()):
		if str(roster[i][0]) == character:
			return 500 + i * 75
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
	var panel := _show_simple_screen("OPERATORS • 50 CHARACTER ROSTER")
	_content_label(panel, "50 ORIGINAL OPERATORS • Choose a character to inspect its role, weapon, bundle and active skill. Character purchases are saved locally on this device.")
	var roster := _character_roster()
	for data in roster:
		var character_name := str(data[0])
		var role := str(data[1])
		var skill_name := str(data[2])
		var weapon_name := str(data[3])
		var bundle_name := str(data[4])
		var required_level := _character_unlock_level(character_name)
		var price := _character_coin_price(character_name)
		var is_owned := owned_characters.has(character_name)
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 3)
		panel.add_child(row)
		var heading := Label.new()
		heading.text = character_name + "  •  " + role + ("  •  SELECTED" if selected_character == character_name else "")
		heading.add_theme_color_override("font_color", Color(0.35, 0.95, 0.83) if selected_character == character_name else Color(0.88, 0.92, 0.94))
		row.add_child(heading)
		var detail := Label.new()
		detail.text = "SKILL: " + skill_name + "  •  WEAPON: " + weapon_name + "\nBUNDLE: " + bundle_name
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(detail)
		var action := Button.new()
		action.custom_minimum_size.y = 42
		action.text = ("SELECTED" if selected_character == character_name else "SELECT") if is_owned else ("REACH LEVEL " + str(required_level) if player_level < required_level else "UNLOCK • " + str(price) + " COINS")
		action.disabled = (is_owned and selected_character == character_name) or (not is_owned and (player_level < required_level or career_coins < price))
		action.pressed.connect(func():
			if not owned_characters.has(character_name):
				if player_level < required_level or career_coins < price:
					return
				career_coins -= price
				owned_characters.append(character_name)
				if not owned_bundles.has(bundle_name):
					owned_bundles.append(bundle_name)
			selected_character = character_name
			selected_skill = skill_name
			equipped_bundle = bundle_name
			_equip_character_signature_weapon(character_name)
			if local_player:
				_rebuild_local_character_visual()
			_save_local_settings()
			_show_character_screen()
		)
		row.add_child(action)
		panel.add_child(HSeparator.new())
	_content_label(panel, "EQUIPPED OPERATOR • " + selected_character + "\nACTIVE SKILL • " + selected_skill + "\n" + _active_skill_description(selected_skill) + "\nCOOLDOWN: " + str(_active_skill_cooldown(selected_skill)) + " seconds")
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
	_content_label(panel, "LEVEL " + str(player_level) + " • COINS " + str(career_coins) + "\nOWNED OPERATORS: " + str(owned_characters.size()) + " / 50")
	_content_back(panel)

func _is_valid_operator(character: String) -> bool:
	for entry in _character_roster():
		if str(entry[0]) == character:
			return true
	return false

func _operator_bundle_names() -> Array:
	var names: Array = []
	for entry in _character_roster():
		names.append(str(entry[4]))
	return names

func _character_roster() -> Array:
	return [
		["NERO", "SNIPER / RECON", "SILENT SHOT", "SNIPER RIFLE", "JUNGLE HUNTER LEGENDARY"],
		["RAVEN", "ASSAULT / RUSHER", "BLITZ DASH", "ASSAULT RIFLE", "RAVEN STREET"],
		["BLAZE", "ASSAULT / FIRE", "FIRE TRAIL", "ASSAULT RIFLE", "FIRE BLAZE"],
		["FANG", "ASSAULT / CLOSE", "FANG BITE", "MP40", "FANG BIKER"],
		["VORTEX", "ASSAULT / SPIN", "VORTEX SPIN", "SCAR", "VORTEX CYBER"],
		["BULL", "ASSAULT / TANK", "BERSERK MODE", "SPAS12", "BULL TANK"],
		["STORM", "ASSAULT / SPEED", "STORM RUSH", "UMP", "STORM RUNNER"],
		["REAPER", "ASSAULT / SOUL", "SOUL STEAL", "M1014", "REAPER SOUL"],
		["JAGUAR", "ASSAULT / JUNGLE", "JUNGLE RUN", "VECTOR", "JAGUAR GRAFFITI"],
		["TIGER", "ASSAULT / POWER", "TIGER PUNCH", "GROZA", "TIGER POWER"],
		["VIPER", "SNIPER / STEALTH", "POISON BULLET", "SNIPER RIFLE", "VIPER POISON"],
		["HAWK", "SNIPER / SCOUT", "EAGLE EYE", "KAR98", "HAWK DESERT"],
		["GHOST", "SNIPER / SHADOW", "VANISH", "AWM", "GHOST SHADOW"],
		["COBRA", "SNIPER / POISON", "COBRA BITE", "SKS", "COBRA GOLD"],
		["EAGLE", "SNIPER / LONG", "LONGSHOT", "M82B", "EAGLE SNOW"],
		["LYNX", "SNIPER / TRACKER", "BLOOD TRAIL", "SVD", "LYNX TRACKER"],
		["ORION", "SNIPER / ELITE", "ONE SHOT", "AWM", "ORION SPACE"],
		["FROST", "SNIPER / COLD", "FREEZE SHOT", "KAR98", "FROST ICE"],
		["SHADOW", "SNIPER / NIGHT", "NIGHT VISION", "VSS", "SHADOW NIGHT"],
		["LUNA", "SNIPER / MOON", "MOON SHOT", "AWM", "LUNA MOON"],
		["FALCON", "MEDIC / SUPPORT", "FAST HEAL", "MP5", "FALCON MEDIC"],
		["ANGEL", "MEDIC / REVIVE", "REVIVE SHIELD", "UMP", "ANGEL WHITE"],
		["GUARDIAN", "SUPPORT / SHIELD", "HEAL AURA", "M4A1", "GUARDIAN BLUE"],
		["NANO", "SUPPORT / DRONE", "DRONE HEAL", "P90", "NANO PINK"],
		["HOPE", "SUPPORT / SECOND LIFE", "SECOND LIFE", "MP40", "HOPE YELLOW"],
		["CALM", "SUPPORT / TEAM", "CALM AURA", "SCAR", "CALM BEIGE"],
		["SUPPLY", "SUPPORT / AMMO", "AMMO BOX", "AK47", "SUPPLY ORANGE"],
		["RESCUE", "SUPPORT / CARRY", "FAST CARRY", "M1014", "RESCUE RED"],
		["SHIELD", "SUPPORT / WALL", "ENERGY WALL", "M60", "SHIELD SILVER"],
		["DOC", "MEDIC / ELITE", "FULL HEAL", "MP5", "DOC BLACK"],
		["HACKER", "TECH / EMP", "EMP BLAST", "VECTOR", "HACKER NEON"],
		["BOMBER", "TECH / EXPLOSIVE", "STICKY BOMB", "M79", "BOMBER YELLOW"],
		["MIRAGE", "TECH / CLONE", "CLONE", "SCAR", "MIRAGE PURPLE"],
		["TRAP", "TECH / MINE", "TRIP MINE", "SPAS12", "TRAP ENGINEER"],
		["DRONE", "TECH / SPY", "SPY DRONE", "UMP", "DRONE PILOT"],
		["SMOKE", "TECH / COVER", "SMOKE KING", "MP40", "SMOKE GREY"],
		["MAGNET", "TECH / LOOT", "LOOT MAGNET", "P90", "MAGNET BLUE"],
		["JAMMER", "TECH / SIGNAL", "SIGNAL JAM", "VECTOR", "JAMMER BLACK"],
		["BUILDER", "TECH / COVER", "INSTANT COVER", "GROZA", "BUILDER YELLOW"],
		["ECHO", "TECH / RADAR", "SOUND RADAR", "SCAR", "ECHO WHITE"],
		["TITAN", "LEGENDARY / TANK", "TITAN MODE", "M60", "TITAN GOLD"],
		["GLITCH", "LEGENDARY / TELEPORT", "GLITCH TELEPORT", "MP40", "GLITCH NEON"],
		["BEAST", "LEGENDARY / POWER", "BEAST MODE", "M1014", "BEAST RED"],
		["MOON", "LEGENDARY / NIGHT", "NIGHT MODE", "AWM", "MOON DARK"],
		["TIME", "LEGENDARY / SLOW", "TIME SLOW", "SCAR", "TIME WHITE"],
		["PHOENIX", "LEGENDARY / REBORN", "REBORN", "AK47", "PHOENIX FIRE"],
		["LUCKY", "LEGENDARY / LOOT", "LUCKY LOOT", "UMP", "LUCKY GREEN"],
		["SIREN", "LEGENDARY / CONFUSE", "CONFUSE SOUND", "P90", "SIREN PINK"],
		["KIRA", "LEGENDARY / SHADOW", "SHADOW WALK", "KATANA + SMG", "KIRA NINJA"],
		["ACE", "LEGENDARY / KING", "KING AURA", "GROZA", "ACE KING"]
	]

func _character_active_skill(character: String) -> String:
	for data in _character_roster():
		if str(data[0]) == character:
			return str(data[2])
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
	var profile := _operator_skill_profile_for_skill(skill)
	var archetype := int(profile["archetype"])
	var strength := str(roundi((float(profile["power"]) - 0.90) * 100.0))
	match archetype:
		0: return "Precision assault: a unique operator-scaled weapon damage window (" + strength + " tuning points)."
		1: return "Mobility technique: a timed movement burst with operator-specific speed and duration."
		2: return "Fortress technique: instant armor plus sustained armor regeneration."
		3: return "Medical technique: instant health restoration followed by regeneration."
		4: return "Supply technique: replenishes reserve ammunition using this operator's loadout tuning."
		5: return "Recon technique: sends an operator-colored pulse and refreshes nearby loot intelligence."
		6: return "Disruption technique: combines a server-validated combat modifier with a fast reload window."
		7: return "Stealth technique: reduces reload time for a character-tuned tactical window."
		8: return "Engineering technique: restores armor and adds a deployable cover charge."
		9: return "Survival technique: restores health and armor with dual regeneration."
	return "Operator skill profile unavailable."

func _active_skill_cooldown(skill: String) -> int:
	match skill:
		"BLITZ DASH", "STORM RUSH", "JUNGLE RUN", "SHADOW WALK", "VANISH", "GLITCH TELEPORT", "VOLT DASH", "PHASE RUN": return 50
		"FAST HEAL", "FULL HEAL", "DRONE HEAL", "SECOND LIFE", "REVIVE SHIELD", "HEAL AURA", "CALM AURA", "FIELD MEDIC": return 55
		"LAST STAND", "BERSERK MODE", "TITAN MODE", "BEAST MODE", "KING AURA", "FIRE TRAIL", "FANG BITE", "VORTEX SPIN", "SOUL STEAL", "TIGER PUNCH", "BULWARK PULSE": return 65
		"AMMO BOX", "LOOT MAGNET", "SCAVENGER INSTINCT", "LUCKY LOOT": return 50
		"EAGLE EYE", "NIGHT VISION", "NIGHT MODE", "BLOOD TRAIL", "SOUND RADAR", "SPY DRONE", "ECHO SCAN": return 55
		"STICKY BOMB", "TRIP MINE", "EMP BLAST", "SIGNAL JAM", "CONFUSE SOUND", "SMOKE KING", "POISON BULLET", "COBRA BITE", "FREEZE SHOT": return 60
		"SILENT SHOT", "LONGSHOT", "ONE SHOT", "MOON SHOT", "TIME SLOW", "REBORN", "CLONE", "FAST CARRY", "INSTANT COVER": return 45
	return 50

func _operator_passive_profile(character: String) -> Dictionary:
	var operator_index := 0
	var roster := _character_roster()
	for i in range(roster.size()):
		if str(roster[i][0]) == character:
			operator_index = i
			break
	# Every operator receives a named signature passive as well as a balanced,
	# deterministic five-stat profile. The 5 x 10 name matrix yields 50 identities.
	var passive_prefixes := ["VANGUARD", "RECON", "FIELD", "COMBAT", "ELITE"]
	var passive_suffixes := ["SPECIALIST", "SCOUT", "GUARD", "ACE", "EXPERT", "RANGER", "SENTINEL", "STRIKER", "MEDIC", "OPERATIVE"]
	var passive_channels := ["MOBILITY", "RELOAD", "PRECISION", "RESILIENCE", "TACTICAL"]
	var passive_channel := operator_index % 5
	var passive_value := 0.01 + float(operator_index) * 0.0005
	return {
		"speed": float(operator_index % 5) * 0.04,
		"reload": 1.0 - float(posmod(floori(float(operator_index) / 5.0), 5)) * 0.025,
		"spread": 1.0 - float(posmod(floori(float(operator_index) / 10.0), 5)) * 0.025,
		"damage_taken": 1.0 - float(posmod(floori(float(operator_index) / 2.0), 5)) * 0.018,
		"cooldown": 1.0 - float(posmod(floori(float(operator_index) / 25.0), 2)) * 0.04,
		"signature_index": operator_index,
		"signature_passive": passive_prefixes[floori(float(operator_index) / 10.0)] + " " + passive_suffixes[operator_index % 10],
		"signature_channel": passive_channels[passive_channel],
		"signature_value": passive_value
	}

func _operator_signature_bonus(character: String, channel: String) -> float:
	var profile := _operator_passive_profile(character)
	return float(profile.get("signature_value", 0.0)) if str(profile.get("signature_channel", "")) == channel else 0.0

func _operator_passive_profile_signature(character: String) -> String:
	var profile := _operator_passive_profile(character)
	return "%.3f:%.3f:%.3f:%.3f:%.3f:%s:%.4f" % [profile["speed"], profile["reload"], profile["spread"], profile["damage_taken"], profile["cooldown"], profile["signature_passive"], profile["signature_value"]]

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

func _passive_starting_armor(passives: Array) -> float:
	return 10.0 if passives.has("FORTIFIED") else 0.0

func _passive_loot_amount(passives: Array, item_type: String, amount: int) -> int:
	if amount <= 0:
		return 0
	if passives.has("SCAVENGER") and item_type.begins_with("ammo_"):
		return ceili(float(amount) * 1.2)
	return amount

func _sanitize_passive_loadout(passive_loadout: Array) -> Array[String]:
	var safe_passives: Array[String] = []
	var allowed_names: Array[String] = []
	for passive_entry in _passive_skill_catalog():
		allowed_names.append(str(passive_entry[0]))
	for passive_value in passive_loadout:
		var passive_name := str(passive_value)
		if passive_name in allowed_names and not safe_passives.has(passive_name) and safe_passives.size() < 3:
			safe_passives.append(passive_name)
	return safe_passives

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
	_apply_bundle_to_visual(visual, equipped_bundle, selected_character)

func _apply_bundle_to_visual(visual: Node3D, bundle_name: String, character_name: String = "KAIRO") -> void:
	var style := _character_style(character_name)
	var tint: Color = style["uniform"]
	var trim: Color = style["accent"]
	match bundle_name:
		"EMBER PHANTOM":
			tint = Color(0.48, 0.12, 0.08)
			trim = Color(1.0, 0.34, 0.08)
		"NEON WRAITH":
			tint = Color(0.06, 0.25, 0.32)
			trim = Color(0.15, 0.95, 1.0)
		"IRON SENTINEL":
			tint = Color(0.32, 0.34, 0.38)
			trim = Color(0.82, 0.86, 0.92)
		_:
			if bundle_name != "FIELD OPERATIVE" and not bundle_name.is_empty():
				# Every operator's signature bundle receives a deterministic palette,
				# rather than falling back to the same generic outfit tint.
				var bundle_hue := float(absi(bundle_name.hash()) % 360) / 360.0
				tint = Color.from_hsv(bundle_hue, 0.48, 0.72)
				trim = Color.from_hsv(fposmod(bundle_hue + 0.12, 1.0), 0.78, 1.0)
	var core_material := StandardMaterial3D.new()
	core_material.albedo_color = tint
	core_material.roughness = 0.72
	var armor_material := StandardMaterial3D.new()
	armor_material.albedo_color = tint.darkened(0.22)
	armor_material.metallic = 0.28
	armor_material.roughness = 0.58
	var trim_material := StandardMaterial3D.new()
	trim_material.albedo_color = trim
	trim_material.metallic = 0.18
	trim_material.roughness = 0.5
	for part_name in ["Torso", "LeftArmPivot/UpperArm", "RightArmPivot/UpperArm"]:
		var part := visual.get_node_or_null(part_name) as MeshInstance3D
		if part:
			part.material_override = core_material
	for part_name in ["Vest", "ChestPlate", "Helmet", "Backpack", "LeftArmPivot/Forearm", "RightArmPivot/Forearm", "UtilityBelt"]:
		var part := visual.get_node_or_null(part_name) as MeshInstance3D
		if part:
			part.material_override = armor_material
	for part_name in ["ShoulderPad-1", "ShoulderPad1", "LeftPouch", "RightPouch", "Visor"]:
		var part := visual.get_node_or_null(part_name) as MeshInstance3D
		if part:
			part.material_override = trim_material
	# Keep the added field-kit pieces visually tied to the equipped cosmetic bundle.
	for signature_part in visual.find_children("FieldKit*", "MeshInstance3D", true, false):
		var kit_mesh := signature_part as MeshInstance3D
		if kit_mesh:
			kit_mesh.material_override = trim_material
	for support_part in visual.find_children("FieldSupport*", "MeshInstance3D", true, false):
		var support_mesh := support_part as MeshInstance3D
		if support_mesh:
			support_mesh.material_override = armor_material
	# Imported GLTF operators use different node names, so recolor their meshes
	# by semantic part-name groups instead of relying on the procedural rig names.
	if visual.get_node_or_null("Torso") == null:
		_apply_bundle_materials_to_imported_model(visual, tint, tint.darkened(0.22), trim)

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
	var panel := _show_simple_screen("ARMORY • WEAPON & SKIN COLLECTION")
	_content_label(panel, "ALL BASE WEAPONS ARE AVAILABLE FROM THE START. Starter skins are free. Coins buy standard skins. Level rewards unlock free skins. Premium Diamond skins are shown but real-money top-up is not connected yet.")
	_content_label(panel, "COINS: " + str(career_coins) + "   •   DIAMONDS: NOT CONNECTED")
	for weapon_index in range(weapon_names.size()):
		var index := weapon_index
		var weapon_name: String = str(weapon_names[index])
		var tier := _weapon_skin_tier(index)
		var skin_id := str(equipped_weapon_skins.get(weapon_name, "BASE"))
		var damage_value := _weapon_stat(index, "damage")
		var range_value := _weapon_stat(index, "range")
		var reload_value := _weapon_stat(index, "reload")
		var equipped_label := "BASE WEAPON" if tier == "BASE" else tier + " SKIN EQUIPPED"
		_content_label(panel, weapon_name + "  •  " + weapon_classes[index] + "\n" + equipped_label + "\nDAMAGE " + str(snappedf(damage_value, 0.1)) + "  •  RANGE " + str(snappedf(range_value, 0.1)) + "  •  RELOAD " + str(snappedf(reload_value * 100.0, 1)) + "%")
		var starter_id := _weapon_skin_id(index, "STARTER")
		var starter_button := Button.new()
		starter_button.text = "EQUIP FREE STARTER SKIN" if skin_id != starter_id else "STARTER SKIN EQUIPPED"
		starter_button.disabled = skin_id == starter_id
		starter_button.pressed.connect(func():
			equipped_weapon_skins[weapon_name] = starter_id
			_save_local_settings()
			_show_armory_screen()
		)
		panel.add_child(starter_button)
		var coin_id := _weapon_skin_id(index, "COIN")
		var coin_button := Button.new()
		coin_button.text = "EQUIP COIN SKIN" if owned_weapon_skins.has(coin_id) else "BUY COIN SKIN • " + str(300 + index * 20) + " COINS"
		coin_button.disabled = skin_id == coin_id
		coin_button.pressed.connect(func():
			if owned_weapon_skins.has(coin_id):
				equipped_weapon_skins[weapon_name] = coin_id
			elif career_coins >= 300 + index * 20:
				career_coins -= 300 + index * 20
				owned_weapon_skins.append(coin_id)
				equipped_weapon_skins[weapon_name] = coin_id
			else:
				status_label.text = "NOT ENOUGH COINS"
			_save_local_settings()
			_show_armory_screen()
		)
		panel.add_child(coin_button)
		var level_id := _weapon_skin_id(index, "LEVEL")
		var required_level := 5 + (index % 5) * 5
		var level_button := Button.new()
		level_button.text = "EQUIP LEVEL SKIN" if owned_weapon_skins.has(level_id) else "LEVEL SKIN • UNLOCK AT LEVEL " + str(required_level)
		level_button.disabled = not owned_weapon_skins.has(level_id) or skin_id == level_id
		level_button.pressed.connect(func():
			equipped_weapon_skins[weapon_name] = level_id
			_save_local_settings()
			_show_armory_screen()
		)
		panel.add_child(level_button)
		var diamond_id := _weapon_skin_id(index, "DIAMOND")
		var diamond_button := Button.new()
		diamond_button.text = "PREMIUM DIAMOND SKIN • TOP-UP NOT CONNECTED"
		diamond_button.disabled = true
		panel.add_child(diamond_button)
		panel.add_child(HSeparator.new())
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

func _operator_skill_multiplier(character: String) -> float:
	var roster := _character_roster()
	for index in range(roster.size()):
		if str(roster[index][0]) == character:
			# A distinct, deterministic tuning value for every operator (0.900–1.145).
			return 0.90 + float(index) * 0.005
	return 1.0

func _activate_character_skill() -> void:
	if local_player == null or is_dead or skill_cooldown > 0.0:
		if status_label: status_label.text = "SKILL COOLDOWN: " + str(ceili(skill_cooldown)) + "s"
		return
	var online_client := multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server()
	if online_client:
		rpc_id(1, "request_activate_character_skill")
		if status_label: status_label.text = "VERIFYING SKILL..."
		return
	_apply_character_skill_effects()

@rpc("any_peer", "call_remote", "reliable")
func request_activate_character_skill() -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0 or not server_player_states.has(sender) or server_eliminated.has(sender):
		return
	var now := Time.get_ticks_msec() / 1000.0
	var ready_at := float(server_player_skill_ready_at.get(sender, 0.0))
	if now < ready_at:
		rpc_id(sender, "receive_skill_activation_result", false, ready_at - now, "SKILL COOLDOWN")
		return
	var state: Dictionary = server_player_states[sender]
	var character_name := str(state.get("character", "NERO"))
	var passives: Array = state.get("passives", [])
	var operator_skill := ""
	for entry in _character_roster():
		if str(entry[0]) == character_name:
			operator_skill = str(entry[2])
			break
	if operator_skill.is_empty():
		rpc_id(sender, "receive_skill_activation_result", false, 0.0, "INVALID OPERATOR")
		return
	var cooldown := _server_validated_skill_cooldown(character_name, operator_skill, passives)
	server_player_skill_ready_at[sender] = now + float(cooldown)
	server_player_active_skill[sender] = operator_skill
	server_player_skill_active_until[sender] = now + _server_skill_effect_duration(operator_skill)
	# Apply all immediate health/armor gains on the authoritative server before
	# acknowledging the skill. Client-side visuals may predict, but cannot mint vitals.
	var current_health := float(server_player_health.get(sender, 100.0))
	var current_armor := float(server_player_armor.get(sender, 0.0))
	var authoritative_vitals := _server_calculate_skill_vitals(character_name, current_health, current_armor)
	current_health = float(authoritative_vitals["health"])
	current_armor = float(authoritative_vitals["armor"])
	server_player_health[sender] = current_health
	server_player_armor[sender] = current_armor
	rpc_id(sender, "receive_skill_activation_result", true, float(cooldown), "APPROVED", current_health, current_armor)
	rpc("broadcast_player_status", sender, current_health, current_armor)

@rpc("authority", "call_remote", "reliable")
func receive_skill_activation_result(approved: bool, cooldown_or_remaining: float, message: String, authoritative_health: float = -1.0, authoritative_armor: float = -1.0) -> void:
	if not approved:
		skill_cooldown = maxf(0.0, cooldown_or_remaining)
		if status_label: status_label.text = message + " • " + str(ceili(skill_cooldown)) + "s"
		return
	if local_player == null or is_dead:
		return
	skill_cooldown = maxf(0.0, cooldown_or_remaining)
	_apply_character_skill_effects(cooldown_or_remaining)
	# Reconcile predicted local effects to server-approved vitals.
	if authoritative_health >= 0.0:
		health = clampf(authoritative_health, 0.0, 100.0)
	if authoritative_armor >= 0.0:
		armor = clampf(authoritative_armor, 0.0, 100.0)
	_update_nearby_loot()
	_update_weapon_hud()

func _server_tick_active_skill_regeneration(delta: float) -> void:
	if server_player_states.is_empty():
		return
	var now := Time.get_ticks_msec() / 1000.0
	server_skill_regen_sync_timer = maxf(0.0, server_skill_regen_sync_timer - delta)
	var should_sync := server_skill_regen_sync_timer <= 0.0
	if should_sync:
		server_skill_regen_sync_timer = 0.5
	for peer_variant in server_player_states.keys():
		var peer_id := int(peer_variant)
		if server_eliminated.has(peer_id) or now >= float(server_player_skill_active_until.get(peer_id, 0.0)):
			continue
		var player_state: Dictionary = server_player_states[peer_id]
		var profile := _operator_skill_profile(str(player_state.get("character", "NERO")))
		var power := float(profile["power"])
		var health_rate := float(profile["mechanic_health_regen"])
		var armor_rate := float(profile["mechanic_armor_regen"])
		match int(profile["archetype"]):
			2, 8:
				armor_rate += float(profile["regen"]) * (0.65 if int(profile["archetype"]) == 2 else 0.5)
			3:
				health_rate += float(profile["regen"])
			9:
				health_rate += float(profile["regen"]) * 0.5
				armor_rate += float(profile["regen"]) * 0.35
		var signature_channel := str(profile["signature_channel"])
		var signature_value := float(profile["signature_value"]) * power
		if signature_channel == "FORTIFY":
			armor_rate += signature_value * 0.5
		elif signature_channel == "RECOVERY":
			health_rate += signature_value * 0.35
		for component_variant in _operator_tactical_component_recipe(int(profile["active_mechanic_id"])):
			if int(component_variant) == 2:
				armor_rate += 0.25 + power * 0.1
		var current_health := float(server_player_health.get(peer_id, 100.0))
		var current_armor := float(server_player_armor.get(peer_id, 0.0))
		var next_health := minf(100.0, current_health + maxf(0.0, health_rate) * delta)
		var next_armor := minf(100.0, current_armor + maxf(0.0, armor_rate) * delta)
		if not is_equal_approx(next_health, current_health):
			server_player_health[peer_id] = next_health
		if not is_equal_approx(next_armor, current_armor):
			server_player_armor[peer_id] = next_armor
		if should_sync and (not is_equal_approx(next_health, current_health) or not is_equal_approx(next_armor, current_armor)):
			rpc_id(peer_id, "receive_authoritative_heal", next_health, next_armor, int(server_player_medkits.get(peer_id, 0)))

func _server_calculate_skill_vitals(character_name: String, current_health: float, current_armor: float) -> Dictionary:
	var profile := _operator_skill_profile(character_name)
	var power := float(profile["power"])
	var health_after := clampf(current_health, 0.0, 100.0)
	var armor_after := clampf(current_armor, 0.0, 100.0)
	match int(profile["archetype"]):
		2, 8:
			armor_after = minf(100.0, armor_after + float(profile["armor"]) * power)
		3:
			health_after = minf(100.0, health_after + float(profile["heal"]) * power)
		9:
			health_after = minf(100.0, health_after + float(profile["heal"]) * 0.65)
			armor_after = minf(100.0, armor_after + float(profile["armor"]) * 0.65)
	var signature_channel := str(profile["signature_channel"])
	var signature_value := float(profile["signature_value"]) * power
	match signature_channel:
		"FORTIFY":
			armor_after = minf(100.0, armor_after + signature_value * 20.0)
		"RECOVERY":
			health_after = minf(100.0, health_after + signature_value * 18.0)
	health_after = minf(100.0, health_after + float(profile["mechanic_heal"]))
	armor_after = minf(100.0, armor_after + float(profile["mechanic_armor"]))
	var recipe: Array = _operator_tactical_component_recipe(int(profile["active_mechanic_id"]))
	for component_variant in recipe:
		match int(component_variant):
			2:
				armor_after = minf(100.0, armor_after + 14.0 + power * 8.0)
			6:
				health_after = minf(100.0, health_after + 10.0 + power * 10.0)
			8:
				armor_after = minf(100.0, armor_after + 10.0)
	return {"health": health_after, "armor": armor_after}

func _server_validated_skill_cooldown(character_name: String, skill_name: String, passives: Array) -> int:
	var operator_cooldown_profile := _operator_passive_profile(character_name)
	var operator_cooldown_trait := float(operator_cooldown_profile.get("cooldown", 1.0)) * (1.0 - _operator_signature_bonus(character_name, "TACTICAL") * 0.65)
	var cooldown := maxi(25, ceili(float(_active_skill_cooldown(skill_name)) * operator_cooldown_trait))
	if passives.has("TACTICAL FOCUS"):
		cooldown = maxi(25, cooldown - 5)
	return cooldown

func _operator_skill_profile(character: String) -> Dictionary:
	var roster := _character_roster()
	var index := -1
	for i in range(roster.size()):
		if str(roster[i][0]) == character:
			index = i
			break
	# Unknown character IDs safely resolve to NERO instead of inheriting an accidental roster slot.
	if index < 0:
		index = 0
	var tier := index % 5
	var rank := float(index) / 49.0
	return {
		"index": index,
		"skill": str(roster[index][2]),
		"archetype": index % 10,
		"signature": index,
		"power": 0.90 + float(index) * 0.005,
		"duration": 5.0 + float(tier) * 0.35 + rank * 0.30,
		"cooldown_scale": 1.0 - float(tier) * 0.018 - rank * 0.025,
		"damage": 1.06 + rank * 0.16,
		"mitigation": 0.08 + rank * 0.12,
		"armor": 10.0 + float(tier) * 3.0 + rank * 5.0,
		"heal": 16.0 + float(tier) * 3.0 + rank * 5.0,
		"speed": 2.2 + float(tier) * 0.25 + rank * 0.45,
		"regen": 0.8 + float(tier) * 0.25 + rank * 0.45,
		"ammo": 20 + tier * 4 + floori(rank * 8.0),
		"reload": 0.12 + float(tier) * 0.025 + rank * 0.05,
		"spread": 0.94 - float(tier) * 0.025 - rank * 0.08,
		"radius": 5.5 + float(tier) * 1.0 + rank * 2.0,
		"signature_damage": 1.0 + float(index + 1) * 0.0015,
		"signature_mitigation": 0.005 + float(index + 1) * 0.00035,
		"signature_skill_id": index,
		"active_mechanic_id": index,
		"tactical_action_id": index % 10,
		"tactical_action_name": ["PHASE DASH", "BLINK SHIFT", "AEGIS SHIELD", "HOLOGRAM DECOY", "SONAR PULSE", "INSTANT RELOAD", "FIELD MEDIC", "AMMO CACHE", "FORTIFY BARRIER", "KINETIC LEAP"][index % 10],
		"active_mechanic_name": ["PHASE LANCE","KINETIC AFTERBURN","AEGIS MIRROR","TRIAGE NOVA","SALVAGE SWARM","ECHO DECOY","JAMMER CASCADE","GHOST MAGAZINE","BASTION DEPLOY","SECOND WIND","VOID STEP","RAPID VECTOR","IRON VEIL","MEDIC PULSE","AMMO FORGE","SPECTRAL TRACE","SIGNAL BLACKOUT","SLIPSTREAM RELOAD","FORTRESS SPIKE","ADRENAL SURGE","BLINK DRIVE","RECOIL CONVERTER","AEGIS BLOOM","REGENERATOR FIELD","SCAVENGE STORM","SONAR MIRAGE","STATIC LOCK","PHANTOM CYCLER","WALLBREAKER","LAST STAND","QUANTUM DASH","HYPERBURST","TITAN SHELL","LIFELINE ARRAY","RESERVE MATRIX","AFTERIMAGE","EMP RUPTURE","QUICKDRAW GHOST","RAMPART GRID","PHOENIX CORE","NOVA SHIFT","KINETIC RIFT","AEGIS OVERLOAD","BIOREPAIR WAVE","SUPPLY FOUNTAIN","DECOY NETWORK","DISRUPTOR RING","SILENT STORM","IRON SANCTUARY","REBIRTH PROTOCOL"][index],
		# Every roster slot receives its own multi-effect tactical recipe.
		# Prime-step sequences make each combination unique across all 50 operators.
		"mechanic_speed": 0.35 + float((index * 7) % 13) * 0.075,
		"mechanic_reload": 0.025 + float((index * 11) % 17) * 0.006,
		"mechanic_heal": float((index * 3) % 9) * 1.25,
		"mechanic_armor": float((index * 5) % 11) * 1.4,
		"mechanic_health_regen": 0.08 + float((index * 13) % 19) * 0.018,
		"mechanic_armor_regen": 0.06 + float((index * 17) % 23) * 0.014,
		"mechanic_ammo": (index * 7) % 16,
		"mechanic_cover": 1 if index % 7 == 0 else 0,
		"mechanic_duration": 0.15 + float((index * 19) % 17) * 0.035,
		"signature_channel": ["MOBILITY", "FORTIFY", "RECOVERY", "SUPPLY", "TEMPO"][index % 5],
		"signature_value": 0.015 + float(index + 1) * 0.001
	}


func _apply_operator_signature_mechanic(profile: Dictionary) -> void:
	# Apply the selected operator's own tactical recipe. The 50 recipes combine
	# different movement, reload, recovery, armor, supply and duration effects.
	var mechanic_id := int(profile["active_mechanic_id"])
	var mechanic_name := str(profile["active_mechanic_name"])
	var speed_effect := float(profile["mechanic_speed"])
	var reload_effect := float(profile["mechanic_reload"])
	var heal_effect := float(profile["mechanic_heal"])
	var armor_effect := float(profile["mechanic_armor"])
	var health_regen_effect := float(profile["mechanic_health_regen"])
	var armor_regen_effect := float(profile["mechanic_armor_regen"])
	var ammo_effect := int(profile["mechanic_ammo"])
	var cover_effect := int(profile["mechanic_cover"])
	var duration_effect := float(profile["mechanic_duration"])
	skill_speed_bonus += speed_effect
	skill_reload_bonus += reload_effect
	health = minf(100.0, health + heal_effect)
	armor = minf(100.0, armor + armor_effect)
	skill_regen_rate += health_regen_effect
	skill_armor_regen_rate += armor_regen_effect
	if ammo_effect > 0:
		reserve_ammo += ammo_effect
		weapon_reserve_ammo[current_weapon] = reserve_ammo
	if cover_effect > 0:
		gloo_wall_charges = mini(5, gloo_wall_charges + cover_effect)
	skill_duration += duration_effect
	status_label.text += " • " + mechanic_name + " [OP-" + str(mechanic_id + 1) + "]"


func _perform_operator_tactical_action(profile: Dictionary) -> void:
	# 50 roster slots each activate a distinct combination of real tactical actions.
	if local_player == null or not is_instance_valid(local_player) or is_dead:
		return
	var action_id := int(profile.get("active_mechanic_id", 0))
	var action_name := str(profile.get("active_mechanic_name", "TACTICAL SKILL"))
	var details: Array[String] = []
	var selected_components: Array = _operator_tactical_component_recipe(action_id)
	for component_variant in selected_components:
		var detail := _apply_tactical_component(int(component_variant), profile)
		if not detail.is_empty():
			details.append(detail)
	status_label.text += " • " + action_name + " • " + " + ".join(PackedStringArray(details))
	_update_weapon_hud()



func _operator_tactical_component_recipe(operator_id: int) -> Array:
	var components: Array = [
		[0,1],
		[0,2],
		[0,3],
		[0,4],
		[0,5],
		[0,6],
		[0,7],
		[0,8],
		[0,9],
		[1,2],
		[1,3],
		[1,4],
		[1,5],
		[1,6],
		[1,7],
		[1,8],
		[1,9],
		[2,3],
		[2,4],
		[2,5],
		[2,6],
		[2,7],
		[2,8],
		[2,9],
		[3,4],
		[3,5],
		[3,6],
		[3,7],
		[3,8],
		[3,9],
		[4,5],
		[4,6],
		[4,7],
		[4,8],
		[4,9],
		[5,6],
		[5,7],
		[5,8],
		[5,9],
		[6,7],
		[6,8],
		[6,9],
		[7,8],
		[7,9],
		[8,9],
		[0,3,6],
		[1,4,7],
		[2,5,8],
		[3,6,9],
		[4,7,0],
	
	]
	return components[posmod(operator_id, components.size())]

func _apply_tactical_component(component_id: int, profile: Dictionary) -> String:
	var power := float(profile.get("power", 1.0))
	var forward := -local_player.global_basis.z
	match component_id:
		0:
			local_player.velocity.x += forward.x * (7.0 + power * 2.0)
			local_player.velocity.z += forward.z * (7.0 + power * 2.0)
			return "PHASE DASH"
		1:
			var destination := local_player.global_position + forward * (4.0 + power * 1.5)
			var query := PhysicsRayQueryParameters3D.create(local_player.global_position + Vector3.UP, destination + Vector3.UP)
			query.exclude = [local_player.get_rid()]
			if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
				local_player.global_position = destination
				return "BLINK SHIFT"
			local_player.velocity.x += forward.x * 4.0
			local_player.velocity.z += forward.z * 4.0
			return "BLINK BLOCKED • DASH FALLBACK"
		2:
			var shield_gain := 14.0 + power * 8.0
			armor = minf(100.0, armor + shield_gain)
			skill_armor_regen_rate += 0.25 + power * 0.1
			_spawn_operator_effect(Color(0.20, 0.72, 1.0), 2.1, 0.8)
			return "AEGIS SHIELD +" + str(roundi(shield_gain))
		3:
			_spawn_operator_decoy()
			return "HOLOGRAM DECOY"
		4:
			_update_nearby_loot()
			_spawn_operator_effect(Color(0.15, 0.95, 0.82), float(profile.get("radius", 6.0)) * 0.25, 0.65)
			return "SONAR PULSE"
		5:
			if weapon_mag_ammo.size() > current_weapon and weapon_reserve_ammo.size() > current_weapon:
				var needed := maxi(0, int(weapon_mag_sizes[current_weapon]) - weapon_mag_ammo[current_weapon])
				var loaded := mini(needed, weapon_reserve_ammo[current_weapon])
				weapon_mag_ammo[current_weapon] += loaded
				weapon_reserve_ammo[current_weapon] -= loaded
				ammo_in_mag = weapon_mag_ammo[current_weapon]
				reserve_ammo = weapon_reserve_ammo[current_weapon]
				is_reloading = false
				reload_timer = 0.0
				return "INSTANT RELOAD +" + str(loaded)
			return "INSTANT RELOAD"
		6:
			var healing := 10.0 + power * 10.0
			health = minf(100.0, health + healing)
			_spawn_operator_effect(Color(0.25, 1.0, 0.42), 1.5, 0.75)
			return "FIELD MEDIC +" + str(roundi(healing)) + " HP"
		7:
			var cache_amount := 8 + roundi(power * 8.0)
			reserve_ammo += cache_amount
			if weapon_reserve_ammo.size() > current_weapon:
				weapon_reserve_ammo[current_weapon] = reserve_ammo
			return "AMMO CACHE +" + str(cache_amount)
		8:
			gloo_wall_charges = mini(5, gloo_wall_charges + 1)
			armor = minf(100.0, armor + 10.0)
			_spawn_operator_effect(Color(1.0, 0.68, 0.18), 1.8, 0.7)
			return "FORTIFY BARRIER"
		9:
			local_player.velocity.y = maxf(local_player.velocity.y, 8.0 + power)
			local_player.velocity.x += forward.x * 3.0
			local_player.velocity.z += forward.z * 3.0
			return "KINETIC LEAP"
	return ""

func _spawn_operator_effect(effect_color: Color, effect_radius: float, lifetime: float) -> void:
	if local_player == null:
		return
	var effect := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = maxf(0.08, effect_radius * 0.88)
	ring.outer_radius = maxf(0.12, effect_radius)
	ring.rings = 3
	ring.ring_segments = 24
	effect.mesh = ring
	var material := StandardMaterial3D.new()
	material.albedo_color = effect_color
	material.emission_enabled = true
	material.emission = effect_color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.72
	effect.material_override = material
	get_tree().current_scene.add_child(effect)
	effect.global_position = local_player.global_position + Vector3.UP * 0.12
	effect.rotation.x = PI * 0.5
	get_tree().create_timer(lifetime).timeout.connect(effect.queue_free)


func _spawn_operator_decoy() -> void:
	if local_player == null:
		return
	var source := local_player.get_node_or_null("CharacterVisual") as Node3D
	if source == null:
		return
	var decoy := source.duplicate() as Node3D
	if decoy == null:
		return
	decoy.name = "OperatorHologramDecoy"
	decoy.set_meta("is_decoy", true)
	get_tree().current_scene.add_child(decoy)
	decoy.global_transform = source.global_transform
	decoy.global_position += -local_player.global_basis.z * 2.4
	decoy.rotation.y = local_player.rotation.y
	decoy.scale *= 0.92
	# The decoy is a visual distraction only; it never receives player input or damage.
	for child in decoy.find_children("*", "CollisionObject3D", true, false):
		child.queue_free()
	get_tree().create_timer(4.0).timeout.connect(decoy.queue_free)



func _operator_skill_profile_for_skill(skill_name: String) -> Dictionary:
	for entry in _character_roster():
		if str(entry[2]) == skill_name:
			return _operator_skill_profile(str(entry[0]))
	return _operator_skill_profile("NERO")

func _operator_animation_clip_set(character: String) -> Dictionary:
	var profile := _operator_skill_profile(character)
	var index := int(profile["index"])
	var phase := float(index) * 0.173
	var tier := float(index % 5)
	var signature := float(index) / 49.0
	# Per-operator clip parameters stay distinct across all 50 rigs while remaining
	# within restrained animation ranges so the shared procedural rig remains stable.
	return {
		"idle": {"rate": 1.35 + tier * 0.045 + signature * 0.08, "sway": 0.009 + tier * 0.0015 + signature * 0.003, "phase": phase},
		"walk": {"rate": 6.2 + tier * 0.14 + signature * 0.22, "arm": 0.32 + tier * 0.018 + signature * 0.035, "leg": 0.40 + tier * 0.022 + signature * 0.04},
		"sprint": {"rate": 9.5 + tier * 0.18 + signature * 0.30, "arm": 0.50 + tier * 0.022 + signature * 0.04, "leg": 0.60 + tier * 0.025 + signature * 0.045},
		"crouch": {"rate": 3.0 + tier * 0.06 + signature * 0.12, "arm": 0.11 + tier * 0.008 + signature * 0.015, "leg": 0.17 + tier * 0.012 + signature * 0.02},
		"jump": {"lift": 0.28 + tier * 0.018 + signature * 0.035, "tuck": 0.32 + tier * 0.015 + signature * 0.03},
		"fire": {"recoil": 0.40 + tier * 0.018 + signature * 0.04, "hold": 0.11 + tier * 0.008 + signature * 0.015},
		"reload": {"reach": 0.70 + tier * 0.025 + signature * 0.05, "hold": 0.43 + tier * 0.018 + signature * 0.035},
		"hit": {"flinch": 0.17 + tier * 0.009 + signature * 0.02, "duration": 0.26 + tier * 0.018 + signature * 0.035},
		"death": {"fall": 1.12 + tier * 0.03 + signature * 0.06, "sink": 0.38 + tier * 0.018 + signature * 0.035},
		"emote": {"amplitude": 1.30 + tier * 0.06 + signature * 0.12, "tempo": 0.82 + tier * 0.035 + signature * 0.07},
		"style": {"phase": phase, "lean": 0.012 + signature * 0.035, "bounce": 0.008 + tier * 0.002 + signature * 0.006, "arm_bias": -0.035 + signature * 0.07, "stride": 0.90 + signature * 0.20, "head_turn": 0.012 + float(index % 7) * 0.004, "gait": index % 5, "shoulder_roll": 0.018 + float(index % 5) * 0.006, "hip_sway": 0.016 + float((index * 3) % 7) * 0.003, "elbow_tuck": 0.018 + float((index * 7) % 5) * 0.012, "head_tilt": 0.01 + float((index * 11) % 5) * 0.012, "breath": 0.002 + float((index * 13) % 7) * 0.001}
	}

func _server_skill_damage_multiplier(skill_name: String) -> float:
	# Keep the original balance-contract skills fixed; all other operator skills
	# receive a per-operator signature multiplier instead of sharing one value.
	if skill_name == "LONGSHOT":
		return 1.25
	if skill_name == "BLITZ DASH":
		return 1.0
	var profile := _operator_skill_profile_for_skill(skill_name)
	var archetype := int(profile["archetype"])
	var archetype_bonus := 0.0
	if archetype == 0 or archetype == 6:
		archetype_bonus = float(profile["damage"]) - 1.0
	elif archetype == 7:
		archetype_bonus = (float(profile["damage"]) - 1.0) * 0.65
	return 1.0 + archetype_bonus + float(profile["signature_damage"]) - 1.0

func _server_skill_damage_reduction(skill_name: String) -> float:
	if skill_name == "BULWARK PULSE":
		return 0.80
	if skill_name == "SILENT SHOT":
		return 1.0
	var profile := _operator_skill_profile_for_skill(skill_name)
	var archetype := int(profile["archetype"])
	var archetype_reduction := 0.0
	if archetype == 2 or archetype == 8 or archetype == 9:
		archetype_reduction = float(profile["mitigation"])
	return clampf(1.0 - archetype_reduction - float(profile["signature_mitigation"]), 0.70, 1.0)

func _server_skill_effect_duration(skill_name: String) -> float:
	# Preserve the server-authoritative baseline durations used by the original
	# roster contract; per-operator duration tuning remains available to clients.
	match skill_name:
		"BLITZ DASH":
			return 5.0
		"FAST HEAL":
			return 8.0
	var profile := _operator_skill_profile_for_skill(skill_name)
	# Keep server expiry aligned with the client skill timer, including each
	# operator's individual tactical-duration modifier.
	return float(profile["duration"]) + float(profile["mechanic_duration"])

func _apply_character_skill_effects(cooldown_override: float = -1.0) -> void:
	if status_label == null:
		status_label = Label.new()
	if local_player == null or is_dead or (cooldown_override < 0.0 and skill_cooldown > 0.0):
		if status_label:
			status_label.text = "SKILL COOLDOWN: " + str(ceili(skill_cooldown)) + "s"
		return
	var profile := _operator_skill_profile(selected_character)
	var archetype := int(profile["archetype"])
	var power := float(profile["power"])
	var duration := float(profile["duration"])
	var cooldown := _server_validated_skill_cooldown(selected_character, selected_skill, equipped_passive_skills) if cooldown_override < 0.0 else ceili(cooldown_override)
	skill_cooldown = float(cooldown)
	skill_active = true
	skill_duration = duration
	skill_regen_rate = 0.0
	skill_armor_regen_rate = 0.0
	skill_speed_bonus = 0.0
	skill_reload_bonus = 0.0
	match archetype:
		0:
			skill_duration = duration
			status_label.text = selected_skill + " • PRECISION OVERDRIVE • +" + str(roundi((float(profile["damage"]) - 1.0) * 100.0)) + "% DAMAGE"
		1:
			skill_speed_bonus = float(profile["speed"]) * power
			status_label.text = selected_skill + " • MOBILITY BURST • " + str(snappedf(skill_speed_bonus, 0.1)) + " SPEED"
		2:
			armor = minf(100.0, armor + float(profile["armor"]) * power)
			skill_armor_regen_rate = float(profile["regen"]) * 0.65
			status_label.text = selected_skill + " • FORTRESS • +" + str(roundi(float(profile["armor"]) * power)) + " ARMOR"
		3:
			health = minf(100.0, health + float(profile["heal"]) * power)
			skill_regen_rate = float(profile["regen"])
			status_label.text = selected_skill + " • MEDICAL SURGE • +" + str(roundi(float(profile["heal"]) * power)) + " HP"
		4:
			var bonus_ammo := roundi(float(profile["ammo"]) * power)
			reserve_ammo += bonus_ammo
			weapon_reserve_ammo[current_weapon] = reserve_ammo
			status_label.text = selected_skill + " • SUPPLY DROP • +" + str(bonus_ammo) + " AMMO"
		5:
			_update_nearby_loot()
			skill_duration = duration
			status_label.text = selected_skill + " • RECON SCAN • " + str(snappedf(float(profile["radius"]), 0.1)) + "M PULSE"
		6:
			skill_duration = duration
			skill_reload_bonus = float(profile["reload"])
			status_label.text = selected_skill + " • DISRUPTION • DAMAGE + RELOAD WINDOW"
		7:
			skill_reload_bonus = float(profile["reload"])
			skill_duration = duration
			status_label.text = selected_skill + " • SHADOW TECHNIQUE • FAST RELOAD"
		8:
			armor = minf(100.0, armor + float(profile["armor"]) * power)
			gloo_wall_charges = mini(5, gloo_wall_charges + 1)
			skill_armor_regen_rate = float(profile["regen"]) * 0.5
			status_label.text = selected_skill + " • FIELD ENGINEER • COVER CHARGE +1"
		9:
			health = minf(100.0, health + float(profile["heal"]) * 0.65)
			armor = minf(100.0, armor + float(profile["armor"]) * 0.65)
			skill_regen_rate = float(profile["regen"]) * 0.5
			skill_armor_regen_rate = float(profile["regen"]) * 0.35
			status_label.text = selected_skill + " • LAST SURVIVOR • RECOVERY"
	# Add an operator-specific signature mechanic on top of the ten core skill families.
	var signature_channel := str(profile["signature_channel"])
	var signature_value := float(profile["signature_value"]) * power
	match signature_channel:
		"MOBILITY":
			skill_speed_bonus += signature_value
		"FORTIFY":
			armor = minf(100.0, armor + signature_value * 20.0)
			skill_armor_regen_rate += signature_value * 0.5
		"RECOVERY":
			health = minf(100.0, health + signature_value * 18.0)
			skill_regen_rate += signature_value * 0.35
		"SUPPLY":
			var signature_ammo := maxi(1, roundi(signature_value * 100.0))
			reserve_ammo += signature_ammo
			weapon_reserve_ammo[current_weapon] = reserve_ammo
		"TEMPO":
			skill_reload_bonus += signature_value * 0.35
	status_label.text += " • " + signature_channel + " SIGNATURE"
	_apply_operator_signature_mechanic(profile)
	_perform_operator_tactical_action(profile)
	_spawn_skill_pulse()
	_update_nearby_loot()
	_update_weapon_hud()

# Procedural original operator rig: articulated limbs, body-type proportions and cosmetic attachments.
func _character_style(character: String) -> Dictionary:
	var styles := {
		"NERO": [Color(0.22, 0.34, 0.16), Color(0.12, 0.18, 0.10), Color(0.55, 0.62, 0.30), Color(0.16, 0.22, 0.13)],
		"RAVEN": [Color(0.10, 0.08, 0.11), Color(0.55, 0.06, 0.09), Color(0.78, 0.08, 0.12), Color(0.10, 0.09, 0.12)],
		"BLAZE": [Color(0.78, 0.25, 0.06), Color(0.18, 0.10, 0.08), Color(1.0, 0.42, 0.05), Color(0.16, 0.12, 0.10)],
		"FANG": [Color(0.16, 0.17, 0.18), Color(0.72, 0.72, 0.68), Color(0.08, 0.08, 0.09), Color(0.12, 0.12, 0.13)],
		"VORTEX": [Color(0.06, 0.27, 0.58), Color(0.75, 0.86, 0.94), Color(0.05, 0.85, 1.0), Color(0.10, 0.20, 0.38)],
		"BULL": [Color(0.34, 0.24, 0.14), Color(0.48, 0.43, 0.34), Color(0.62, 0.50, 0.28), Color(0.20, 0.17, 0.13)],
		"STORM": [Color(0.28, 0.32, 0.36), Color(0.10, 0.12, 0.15), Color(0.65, 0.76, 0.88), Color(0.16, 0.18, 0.20)],
		"REAPER": [Color(0.035, 0.035, 0.045), Color(0.12, 0.12, 0.16), Color(0.48, 0.48, 0.55), Color(0.06, 0.06, 0.08)],
		"JAGUAR": [Color(0.18, 0.42, 0.12), Color(0.82, 0.62, 0.08), Color(0.20, 0.72, 0.18), Color(0.12, 0.16, 0.12)],
		"TIGER": [Color(0.78, 0.34, 0.06), Color(0.10, 0.10, 0.10), Color(0.95, 0.55, 0.08), Color(0.16, 0.13, 0.10)],
		"VIPER": [Color(0.12, 0.30, 0.18), Color(0.08, 0.12, 0.09), Color(0.30, 0.78, 0.25), Color(0.08, 0.14, 0.10)],
		"HAWK": [Color(0.58, 0.46, 0.30), Color(0.30, 0.24, 0.16), Color(0.78, 0.66, 0.43), Color(0.28, 0.23, 0.16)],
		"GHOST": [Color(0.035, 0.045, 0.06), Color(0.08, 0.09, 0.12), Color(0.24, 0.28, 0.34), Color(0.04, 0.05, 0.07)],
		"COBRA": [Color(0.08, 0.24, 0.12), Color(0.24, 0.18, 0.08), Color(0.82, 0.62, 0.12), Color(0.08, 0.12, 0.08)],
		"EAGLE": [Color(0.78, 0.82, 0.86), Color(0.40, 0.48, 0.56), Color(0.92, 0.96, 1.0), Color(0.48, 0.55, 0.62)],
		"LYNX": [Color(0.30, 0.34, 0.38), Color(0.12, 0.16, 0.20), Color(0.48, 0.66, 0.76), Color(0.20, 0.24, 0.28)],
		"ORION": [Color(0.52, 0.58, 0.68), Color(0.12, 0.22, 0.42), Color(0.16, 0.62, 1.0), Color(0.34, 0.42, 0.56)],
		"FROST": [Color(0.30, 0.68, 0.82), Color(0.82, 0.92, 0.96), Color(0.40, 0.86, 1.0), Color(0.18, 0.42, 0.56)],
		"SHADOW": [Color(0.18, 0.10, 0.30), Color(0.08, 0.06, 0.12), Color(0.55, 0.25, 0.82), Color(0.12, 0.08, 0.18)],
		"LUNA": [Color(0.76, 0.76, 0.90), Color(0.34, 0.24, 0.55), Color(0.72, 0.62, 1.0), Color(0.30, 0.28, 0.44)],
		"FALCON": [Color(0.82, 0.84, 0.82), Color(0.62, 0.12, 0.12), Color(0.24, 0.68, 0.36), Color(0.30, 0.34, 0.26)],
		"ANGEL": [Color(0.90, 0.88, 0.80), Color(0.72, 0.58, 0.28), Color(1.0, 0.88, 0.50), Color(0.88, 0.86, 0.80)],
		"GUARDIAN": [Color(0.10, 0.28, 0.58), Color(0.48, 0.64, 0.82), Color(0.20, 0.68, 1.0), Color(0.10, 0.20, 0.40)],
		"NANO": [Color(0.72, 0.22, 0.48), Color(0.90, 0.62, 0.78), Color(1.0, 0.34, 0.72), Color(0.38, 0.12, 0.30)],
		"HOPE": [Color(0.82, 0.62, 0.12), Color(0.34, 0.26, 0.08), Color(1.0, 0.82, 0.18), Color(0.34, 0.26, 0.08)],
		"CALM": [Color(0.58, 0.48, 0.34), Color(0.26, 0.22, 0.18), Color(0.78, 0.68, 0.50), Color(0.30, 0.26, 0.20)],
		"SUPPLY": [Color(0.88, 0.38, 0.08), Color(0.24, 0.24, 0.22), Color(1.0, 0.62, 0.12), Color(0.28, 0.22, 0.14)],
		"RESCUE": [Color(0.62, 0.08, 0.08), Color(0.88, 0.84, 0.78), Color(1.0, 0.20, 0.16), Color(0.34, 0.10, 0.10)],
		"SHIELD": [Color(0.58, 0.62, 0.68), Color(0.20, 0.24, 0.30), Color(0.82, 0.88, 0.96), Color(0.28, 0.32, 0.38)],
		"DOC": [Color(0.08, 0.08, 0.10), Color(0.28, 0.28, 0.30), Color(0.72, 0.78, 0.82), Color(0.10, 0.10, 0.12)],
		"HACKER": [Color(0.05, 0.08, 0.06), Color(0.08, 0.22, 0.10), Color(0.16, 1.0, 0.28), Color(0.04, 0.10, 0.06)],
		"BOMBER": [Color(0.88, 0.62, 0.08), Color(0.22, 0.18, 0.10), Color(1.0, 0.78, 0.18), Color(0.32, 0.24, 0.10)],
		"MIRAGE": [Color(0.36, 0.16, 0.58), Color(0.72, 0.56, 0.86), Color(0.76, 0.32, 1.0), Color(0.20, 0.12, 0.34)],
		"TRAP": [Color(0.38, 0.28, 0.16), Color(0.16, 0.14, 0.12), Color(0.72, 0.52, 0.24), Color(0.24, 0.18, 0.12)],
		"DRONE": [Color(0.38, 0.42, 0.46), Color(0.14, 0.18, 0.22), Color(0.68, 0.76, 0.82), Color(0.20, 0.24, 0.28)],
		"SMOKE": [Color(0.34, 0.38, 0.40), Color(0.12, 0.14, 0.16), Color(0.68, 0.72, 0.72), Color(0.18, 0.20, 0.22)],
		"MAGNET": [Color(0.08, 0.28, 0.66), Color(0.18, 0.22, 0.32), Color(0.24, 0.66, 1.0), Color(0.08, 0.16, 0.38)],
		"JAMMER": [Color(0.08, 0.08, 0.10), Color(0.24, 0.24, 0.28), Color(0.76, 0.18, 0.30), Color(0.08, 0.08, 0.12)],
		"BUILDER": [Color(0.86, 0.58, 0.08), Color(0.26, 0.22, 0.12), Color(1.0, 0.76, 0.18), Color(0.32, 0.26, 0.14)],
		"ECHO": [Color(0.78, 0.82, 0.86), Color(0.20, 0.28, 0.36), Color(0.28, 0.86, 1.0), Color(0.34, 0.40, 0.46)],
		"TITAN": [Color(0.34, 0.34, 0.38), Color(0.72, 0.54, 0.14), Color(1.0, 0.76, 0.22), Color(0.20, 0.20, 0.24)],
		"GLITCH": [Color(0.04, 0.08, 0.20), Color(0.12, 0.24, 0.58), Color(0.12, 0.72, 1.0), Color(0.04, 0.08, 0.18)],
		"BEAST": [Color(0.48, 0.06, 0.08), Color(0.18, 0.08, 0.08), Color(0.92, 0.16, 0.12), Color(0.18, 0.06, 0.06)],
		"MOON": [Color(0.06, 0.10, 0.30), Color(0.20, 0.24, 0.48), Color(0.42, 0.50, 0.96), Color(0.05, 0.08, 0.22)],
		"TIME": [Color(0.78, 0.80, 0.84), Color(0.30, 0.34, 0.42), Color(0.92, 0.72, 0.30), Color(0.40, 0.42, 0.46)],
		"PHOENIX": [Color(0.62, 0.10, 0.04), Color(0.78, 0.48, 0.08), Color(1.0, 0.42, 0.05), Color(0.28, 0.08, 0.04)],
		"LUCKY": [Color(0.10, 0.42, 0.18), Color(0.28, 0.58, 0.24), Color(0.56, 0.94, 0.30), Color(0.08, 0.24, 0.10)],
		"SIREN": [Color(0.76, 0.24, 0.48), Color(0.32, 0.12, 0.24), Color(1.0, 0.42, 0.78), Color(0.28, 0.10, 0.22)],
		"KIRA": [Color(0.06, 0.06, 0.10), Color(0.22, 0.18, 0.28), Color(0.56, 0.28, 0.72), Color(0.05, 0.05, 0.08)],
		"ACE": [Color(0.08, 0.08, 0.10), Color(0.72, 0.54, 0.12), Color(1.0, 0.78, 0.22), Color(0.08, 0.08, 0.10)]
	}
	if styles.has(character):
		var c: Array = styles[character]
		return {"uniform": c[0], "vest": c[1], "accent": c[2], "pants": c[3]}
	return {"uniform": Color(0.18, 0.24, 0.30), "vest": Color(0.12, 0.16, 0.18), "accent": Color(0.35, 0.65, 0.85), "pants": Color(0.12, 0.14, 0.16)}

func _build_operator_visual(parent: Node3D, is_local: bool, gender: String, character_name: String = "") -> void:
	var visual_root := parent
	var rig_root := Node3D.new()
	rig_root.name = "KeyframeRig"
	visual_root.add_child(rig_root)
	parent = rig_root
	_create_operator_keyframe_animations(visual_root, character_name if not character_name.is_empty() else (selected_character if is_local else "NERO"))
	var operator_name := character_name
	if operator_name.is_empty():
		operator_name = selected_character if is_local else "NERO"
	var rigged_path := "res://assets/characters/" + operator_name.to_lower() + ".gltf"
	if ResourceLoader.exists(rigged_path):
		var rigged_scene := load(rigged_path) as PackedScene
		if rigged_scene != null:
			var rigged_model := rigged_scene.instantiate() as Node3D
			if rigged_model != null:
				rigged_model.name = "RiggedOperatorModel"
				rigged_model.set_meta("operator_name", operator_name)
				parent.add_child(rigged_model)
				_apply_operator_model_signature(rigged_model, operator_name)
				var model_bundle := equipped_bundle if is_local else _operator_bundle_for_character(operator_name)
				_apply_bundle_to_visual(rigged_model, model_bundle, operator_name)
				return
	var style := _character_style(operator_name)
	var uniform: Color = style["uniform"]
	var vest_color: Color = style["vest"]
	var accent: Color = style["accent"]
	var pants_color: Color = style["pants"]
	# Each operator gets a deterministic body/helmet profile in addition to their own palette.
	# This keeps the lightweight procedural rig readable while making the 50 silhouettes less uniform.
	var operator_index := 0
	var roster_for_visuals := _character_roster()
	for visual_index in range(roster_for_visuals.size()):
		if str(roster_for_visuals[visual_index][0]) == operator_name:
			operator_index = visual_index
			break
	var body_width := (0.68 if gender == "FEMALE" else 0.74) + float(posmod(operator_index, 5) - 2) * 0.018
	var torso_height := 0.78 + float(posmod(operator_index / 5, 3) - 1) * 0.035
	_add_character_part(parent, "Torso", Vector3(0, 1.13, 0), Vector3(body_width, torso_height, 0.38), uniform)
	_add_character_part(parent, "Vest", Vector3(0, 1.18, -0.015), Vector3(body_width + 0.08, 0.48, 0.41), vest_color)
	var head_pivot := Node3D.new()
	head_pivot.name = "HeadPivot"
	head_pivot.position = Vector3(0, 1.82, 0)
	parent.add_child(head_pivot)
	var skin_tones: Array[Color] = [Color(0.72, 0.53, 0.39), Color(0.54, 0.34, 0.24), Color(0.84, 0.65, 0.49), Color(0.38, 0.25, 0.20), Color(0.67, 0.47, 0.34)]
	_add_character_part(head_pivot, "Head", Vector3.ZERO, Vector3(0.40, 0.46, 0.40), skin_tones[posmod(operator_index, skin_tones.size())], true)
	var helmet_color := vest_color.lerp(uniform, 0.45)
	var helmet_width := 0.46 + float(posmod(operator_index, 4)) * 0.025
	var helmet_height := 0.18 + float(posmod(operator_index / 4, 3)) * 0.025
	_add_character_part(head_pivot, "Helmet", Vector3(0, 0.21, 0), Vector3(helmet_width, helmet_height, 0.48), helmet_color, true)
	_add_character_part(head_pivot, "Visor", Vector3(0, 0.05, -0.19), Vector3(0.31 + float(posmod(operator_index, 3)) * 0.025, 0.09, 0.035), accent)
	match posmod(operator_index, 5):
		0:
			_add_character_part(head_pivot, "OperatorComms", Vector3(-0.23, 0.02, 0), Vector3(0.10, 0.16, 0.12), accent, true)
		1:
			_add_character_part(head_pivot, "HelmetCrest", Vector3(0, 0.34, 0.02), Vector3(0.08, 0.16, 0.28), accent)
		2:
			_add_character_part(head_pivot, "SideArmor", Vector3(0.22, 0.02, 0), Vector3(0.12, 0.22, 0.30), vest_color)
		3:
			_add_character_part(head_pivot, "RangeFinder", Vector3(0.18, 0.08, -0.18), Vector3(0.14, 0.08, 0.10), accent)
		4:
			_add_character_part(head_pivot, "ForeheadPlate", Vector3(0, 0.10, -0.205), Vector3(0.20, 0.12, 0.04), accent)
	_add_character_part(parent, "ChestPlate", Vector3(0, 1.22, -0.225), Vector3(0.34, 0.32, 0.035), vest_color.lerp(Color(0.04, 0.05, 0.06), 0.3))
	_add_character_part(parent, "Backpack", Vector3(0, 1.12, 0.27), Vector3(0.48, 0.56, 0.20), vest_color.darkened(0.35))
	for side in [-1.0, 1.0]:
		var arm := Node3D.new()
		arm.name = "LeftArmPivot" if side < 0.0 else "RightArmPivot"
		arm.position = Vector3(side * 0.43, 1.48, 0)
		parent.add_child(arm)
		_add_character_part(arm, "UpperArm", Vector3(0, -0.22, 0), Vector3(0.21, 0.50, 0.23), uniform, true)
		_add_character_part(arm, "Forearm", Vector3(0, -0.52, -0.015), Vector3(0.19, 0.34, 0.20), vest_color, true)
		_add_character_part(parent, "ShoulderPad" + str(int(side)), Vector3(side * 0.46, 1.49, 0), Vector3(0.30, 0.20, 0.30), accent.darkened(0.25), true)
		var leg := Node3D.new()
		leg.name = "LeftLegPivot" if side < 0.0 else "RightLegPivot"
		leg.position = Vector3(side * 0.19, 0.78, 0)
		parent.add_child(leg)
		_add_character_part(leg, "Thigh", Vector3(0, -0.18, 0), Vector3(0.27, 0.46, 0.30), pants_color, true)
		_add_character_part(leg, "Shin", Vector3(0, -0.48, 0), Vector3(0.23, 0.34, 0.25), pants_color.darkened(0.12), true)
		_add_character_part(leg, "Boot", Vector3(0, -0.67, -0.07), Vector3(0.30, 0.18, 0.40), vest_color.darkened(0.35))
	_add_character_part(parent, "UtilityBelt", Vector3(0, 0.83, 0), Vector3(0.70, 0.12, 0.40), vest_color.darkened(0.2))
	_add_character_part(parent, "LeftPouch", Vector3(-0.30, 0.86, -0.22), Vector3(0.16, 0.20, 0.12), accent.darkened(0.35))
	_add_character_part(parent, "RightPouch", Vector3(0.30, 0.86, -0.22), Vector3(0.16, 0.20, 0.12), accent.darkened(0.35))
	# Distinctive signature details for the selected operator, built from lightweight meshes.
	if operator_name in ["RAVEN", "GHOST", "REAPER", "KIRA", "VIPER", "COBRA", "SHADOW"]:
		_add_character_part(head_pivot, "FaceMask", Vector3(0, -0.12, -0.19), Vector3(0.32, 0.17, 0.08), vest_color)
	if operator_name in ["NERO", "HAWK", "EAGLE", "FALCON"]:
		for stripe_x in [-0.13, 0.13]:
			_add_character_part(parent, "CamoStripe" + str(stripe_x), Vector3(stripe_x, 1.14, -0.225), Vector3(0.07, 0.42, 0.025), accent.darkened(0.35))
	if operator_name in ["VORTEX", "HACKER", "GLITCH", "ORION", "NANO"]:
		var glow := StandardMaterial3D.new()
		glow.albedo_color = accent
		glow.emission_enabled = true
		glow.emission = accent
		glow.emission_energy_multiplier = 1.5
		for stripe_y in [1.28, 1.02]:
			var stripe := MeshInstance3D.new()
			stripe.name = "NeonStripe"
			var stripe_mesh := BoxMesh.new()
			stripe_mesh.size = Vector3(body_width + 0.10, 0.045, 0.025)
			stripe.mesh = stripe_mesh
			stripe.position = Vector3(0, stripe_y, -0.22)
			stripe.material_override = glow
			parent.add_child(stripe)
	if operator_name in ["BULL", "TITAN", "SHIELD", "GUARDIAN"]:
		_add_character_part(parent, "HeavyShoulderL", Vector3(-0.47, 1.52, 0), Vector3(0.36, 0.30, 0.34), accent, true)
		_add_character_part(parent, "HeavyShoulderR", Vector3(0.47, 1.52, 0), Vector3(0.36, 0.30, 0.34), accent, true)
	if operator_name in ["ANGEL", "PHOENIX"]:
		_add_character_part(parent, "BackEmblem", Vector3(0, 1.30, 0.39), Vector3(0.70, 0.46, 0.10), accent, true)
	_add_operator_signature_geometry(parent, head_pivot, operator_name, uniform, vest_color, accent)
	_add_operator_field_kit(parent, operator_name, vest_color, accent)
	_add_roster_identity_geometry(parent, head_pivot, operator_index, uniform, vest_color, accent, pants_color)


func _operator_bundle_for_character(character_name: String) -> String:
	for entry in _character_roster():
		if str(entry[0]) == character_name:
			return str(entry[4])
	return "FIELD OPERATIVE"


func _apply_operator_model_signature(model: Node3D, character_name: String) -> void:
	# Add lightweight, individually tuned attachments to the imported rig so each
	# operator keeps a readable identity even when the GLTF source has no named armor slots.
	var style := _character_style(character_name)
	var armor: Color = style["vest"]
	var accent: Color = style["accent"]
	var index := 0
	var roster := _character_roster()
	for i in range(roster.size()):
		if str(roster[i][0]) == character_name:
			index = i
			break
	var chest_width := 0.30 + float(index % 5) * 0.025
	var chest := _add_character_part(model, "OperatorSignatureChest", Vector3(0, 1.18, -0.235), Vector3(chest_width, 0.26, 0.045), armor.darkened(0.12), true)
	if chest:
		chest.rotation.y = float(index % 4) * 0.08
	var shoulder_size := 0.20 + float((index / 5) % 4) * 0.025
	_add_character_part(model, "OperatorSignatureShoulderL", Vector3(-0.46, 1.48, 0.0), Vector3(shoulder_size, 0.16, 0.27), accent.darkened(0.12), true)
	_add_character_part(model, "OperatorSignatureShoulderR", Vector3(0.46, 1.48, 0.0), Vector3(shoulder_size, 0.16, 0.27), accent.darkened(0.12), true)
	match index % 5:
		0:
			_add_character_part(model, "OperatorCrest", Vector3(0, 2.08, 0.02), Vector3(0.08, 0.22, 0.12), accent, true)
		1:
			_add_character_part(model, "OperatorCommsPack", Vector3(-0.30, 1.55, 0.12), Vector3(0.12, 0.20, 0.12), accent, true)
		2:
			_add_character_part(model, "OperatorRangeModule", Vector3(0.24, 1.82, -0.18), Vector3(0.14, 0.10, 0.12), accent, true)
		3:
			_add_character_part(model, "OperatorBackCanister", Vector3(0.22, 1.12, 0.30), Vector3(0.13, 0.42, 0.13), armor, true)
		4:
			_add_character_part(model, "OperatorChestInsignia", Vector3(0, 1.40, -0.27), Vector3(0.12, 0.12, 0.035), accent, true)
	var glow_names := ["VORTEX", "ORION", "NANO", "HACKER", "GLITCH", "ECHO", "SIREN", "ACE"]
	if character_name in glow_names:
		var glow := StandardMaterial3D.new()
		glow.albedo_color = accent
		glow.emission_enabled = true
		glow.emission = accent
		glow.emission_energy_multiplier = 1.2
		var light_strip := MeshInstance3D.new()
		light_strip.name = "OperatorSignatureGlow"
		var strip_mesh := BoxMesh.new()
		strip_mesh.size = Vector3(0.48, 0.035, 0.025)
		light_strip.mesh = strip_mesh
		light_strip.position = Vector3(0, 1.02, -0.23)
		light_strip.material_override = glow
		model.add_child(light_strip)


func _apply_bundle_materials_to_imported_model(model: Node3D, tint: Color, armor_tint: Color, trim: Color) -> void:
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node == null:
			continue
		var part_name := mesh_node.name.to_lower()
		var material := StandardMaterial3D.new()
		material.roughness = 0.62
		if part_name.contains("helmet") or part_name.contains("visor") or part_name.contains("head"):
			material.albedo_color = trim
			material.metallic = 0.22
		elif part_name.contains("armor") or part_name.contains("vest") or part_name.contains("chest") or part_name.contains("shoulder"):
			material.albedo_color = armor_tint
			material.metallic = 0.30
		else:
			material.albedo_color = tint
		mesh_node.material_override = material


# Fifty deterministic silhouette combinations: each roster index receives its own
# headgear, torso profile, shoulder rig, and field equipment combination.
func _add_roster_identity_geometry(parent: Node3D, head: Node3D, idx: int, uniform: Color, armor: Color, accent: Color, pants: Color) -> void:
	var helmet_profile := posmod(idx, 10)
	var torso_profile := posmod(floori(float(idx) / 10.0), 5)
	match helmet_profile:
		0:
			_add_character_part(head, "RosterCrownPlate", Vector3(0, 0.31, -0.04), Vector3(0.34, 0.12, 0.38), accent, true)
		1:
			_add_character_part(head, "RosterDualAntennaL", Vector3(-0.16, 0.34, 0.02), Vector3(0.035, 0.30, 0.035), accent)
			_add_character_part(head, "RosterDualAntennaR", Vector3(0.16, 0.34, 0.02), Vector3(0.035, 0.30, 0.035), accent)
		2:
			_add_character_part(head, "RosterWideVisor", Vector3(0, 0.04, -0.235), Vector3(0.48, 0.13, 0.055), accent, true)
		3:
			_add_character_part(head, "RosterSideShellL", Vector3(-0.25, 0.02, 0.02), Vector3(0.16, 0.28, 0.32), armor)
			_add_character_part(head, "RosterSideShellR", Vector3(0.25, 0.02, 0.02), Vector3(0.16, 0.28, 0.32), armor)
		4:
			_add_character_part(head, "RosterTopRail", Vector3(0, 0.30, 0.10), Vector3(0.12, 0.12, 0.46), accent)
		5:
			_add_character_part(head, "RosterForeheadShield", Vector3(0, 0.13, -0.23), Vector3(0.38, 0.15, 0.07), armor)
		6:
			_add_character_part(head, "RosterSensorPod", Vector3(0.23, 0.13, -0.12), Vector3(0.13, 0.13, 0.16), accent, true)
		7:
			_add_character_part(head, "RosterBackHelmet", Vector3(0, 0.08, 0.25), Vector3(0.38, 0.22, 0.16), armor)
		8:
			_add_character_part(head, "RosterMohawk", Vector3(0, 0.37, 0), Vector3(0.08, 0.25, 0.32), accent)
		9:
			_add_character_part(head, "RosterJawGuard", Vector3(0, -0.19, -0.19), Vector3(0.38, 0.13, 0.10), accent)
	match torso_profile:
		0:
			_add_character_part(parent, "RosterCrossChestRig", Vector3(0, 1.20, -0.245), Vector3(0.48, 0.12, 0.06), accent)
		1:
			_add_character_part(parent, "RosterHeavyFrontPlate", Vector3(0, 1.20, -0.25), Vector3(0.50, 0.42, 0.08), armor)
		2:
			_add_character_part(parent, "RosterAmmoBandolier", Vector3(0, 1.30, -0.26), Vector3(0.62, 0.09, 0.07), accent)
		3:
			_add_character_part(parent, "RosterChestRadio", Vector3(0.27, 1.22, -0.27), Vector3(0.16, 0.24, 0.09), accent, true)
		4:
			_add_character_part(parent, "RosterChestShield", Vector3(-0.25, 1.20, -0.27), Vector3(0.18, 0.34, 0.08), armor, true)
	# A second index digit alters the silhouette of the shoulder and lower-leg kit.
	var shoulder_profile := posmod(idx, 5)
	match shoulder_profile:
		0:
			_add_character_part(parent, "RosterShoulderSpikes", Vector3(-0.48, 1.62, 0), Vector3(0.13, 0.32, 0.13), accent)
		1:
			_add_character_part(parent, "RosterShoulderShell", Vector3(0.48, 1.54, 0), Vector3(0.36, 0.30, 0.38), armor, true)
		2:
			_add_character_part(parent, "RosterArmShield", Vector3(-0.47, 1.22, -0.08), Vector3(0.25, 0.34, 0.12), accent, true)
		3:
			_add_character_part(parent, "RosterShoulderRadio", Vector3(0.48, 1.56, 0.10), Vector3(0.20, 0.20, 0.22), accent)
		4:
			_add_character_part(parent, "RosterShoulderStrap", Vector3(0, 1.48, -0.25), Vector3(0.78, 0.07, 0.07), accent)
	var equipment_profile := posmod(floori(float(idx) / 5.0), 10)
	match equipment_profile:
		0:
			_add_character_part(parent, "RosterPackA", Vector3(0, 1.20, 0.39), Vector3(0.38, 0.54, 0.22), armor)
		1:
			_add_character_part(parent, "RosterPackB", Vector3(0, 1.24, 0.40), Vector3(0.52, 0.34, 0.25), accent.darkened(0.25))
		2:
			_add_character_part(parent, "RosterTankL", Vector3(-0.30, 1.22, 0.36), Vector3(0.16, 0.48, 0.16), accent)
		3:
			_add_character_part(parent, "RosterTankR", Vector3(0.30, 1.22, 0.36), Vector3(0.16, 0.48, 0.16), accent)
		4:
			_add_character_part(parent, "RosterBackBlade", Vector3(0.24, 1.34, 0.40), Vector3(0.08, 0.72, 0.08), armor)
		5:
			_add_character_part(parent, "RosterBackAntenna", Vector3(-0.24, 1.46, 0.38), Vector3(0.04, 0.72, 0.04), accent)
		6:
			_add_character_part(parent, "RosterUtilityPack", Vector3(0, 0.98, 0.39), Vector3(0.62, 0.26, 0.18), armor)
		7:
			_add_character_part(parent, "RosterBackPlate", Vector3(0, 1.22, 0.40), Vector3(0.60, 0.62, 0.08), accent.darkened(0.2))
		8:
			_add_character_part(parent, "RosterHipArmorL", Vector3(-0.34, 0.76, 0), Vector3(0.18, 0.38, 0.28), armor)
			_add_character_part(parent, "RosterHipArmorR", Vector3(0.34, 0.76, 0), Vector3(0.18, 0.38, 0.28), armor)
		9:
			_add_character_part(parent, "RosterLegRig", Vector3(0, 0.55, -0.18), Vector3(0.56, 0.18, 0.08), accent)



# Each roster member receives a deterministic combination of original silhouette
# pieces. These are lightweight procedural meshes, not reused character presets.
func _add_operator_signature_geometry(parent: Node3D, head: Node3D, operator_name: String, uniform: Color, armor_color: Color, accent: Color) -> void:
	var roster := _character_roster()
	var operator_index := 0
	for i in range(roster.size()):
		if str(roster[i][0]) == operator_name:
			operator_index = i
			break
	# Operator-specific face protection and head silhouette details.
	var face_style := floori(float(operator_index) / 2.0) % 5
	match face_style:
		0:
			_add_character_part(head, "SignatureRespirator", Vector3(0, -0.13, -0.22), Vector3(0.24, 0.16, 0.10), armor_color, true)
			_add_character_part(head, "SignatureFilterL", Vector3(-0.15, -0.13, -0.24), Vector3(0.08, 0.12, 0.08), accent, true)
			_add_character_part(head, "SignatureFilterR", Vector3(0.15, -0.13, -0.24), Vector3(0.08, 0.12, 0.08), accent, true)
		1:
			_add_character_part(head, "SignatureLowerFaceGuard", Vector3(0, -0.17, -0.21), Vector3(0.34, 0.13, 0.07), accent)
		2:
			_add_character_part(head, "SignatureCheekGuardL", Vector3(-0.19, -0.07, -0.13), Vector3(0.10, 0.22, 0.12), armor_color)
			_add_character_part(head, "SignatureCheekGuardR", Vector3(0.19, -0.07, -0.13), Vector3(0.10, 0.22, 0.12), armor_color)
		3:
			_add_character_part(head, "SignatureJawPlate", Vector3(0, -0.22, -0.12), Vector3(0.27, 0.09, 0.18), armor_color)
		4:
			_add_character_part(head, "SignatureFaceStripe", Vector3(0, -0.04, -0.215), Vector3(0.055, 0.25, 0.035), accent)
	var eye_style := operator_index % 4
	match eye_style:
		0:
			_add_character_part(head, "SignatureEyeLensL", Vector3(-0.10, 0.03, -0.215), Vector3(0.10, 0.055, 0.035), accent, true)
			_add_character_part(head, "SignatureEyeLensR", Vector3(0.10, 0.03, -0.215), Vector3(0.10, 0.055, 0.035), accent, true)
		1:
			_add_character_part(head, "SignatureEyeBar", Vector3(0, 0.03, -0.22), Vector3(0.38, 0.07, 0.04), armor_color)
		2:
			_add_character_part(head, "SignatureMonocle", Vector3(0.12, 0.03, -0.225), Vector3(0.13, 0.13, 0.045), accent, true)
		3:
			_add_character_part(head, "SignatureEyeShield", Vector3(0, 0.04, -0.22), Vector3(0.42, 0.14, 0.055), accent, true)
	var helmet_style := operator_index % 5
	match helmet_style:
		0:
			_add_character_part(head, "SignatureHelmetCrest", Vector3(0, 0.34, 0.02), Vector3(0.12, 0.20, 0.34), accent)
		1:
			_add_character_part(head, "SignatureHelmetLeft", Vector3(-0.27, 0.04, 0), Vector3(0.12, 0.24, 0.28), accent, true)
			_add_character_part(head, "SignatureHelmetRight", Vector3(0.27, 0.04, 0), Vector3(0.12, 0.24, 0.28), accent, true)
		2:
			_add_character_part(head, "SignatureHelmetAntenna", Vector3(0.16, 0.37, 0), Vector3(0.045, 0.34, 0.045), accent)
		3:
			_add_character_part(head, "SignatureHelmetBrow", Vector3(0, 0.16, -0.22), Vector3(0.46, 0.09, 0.08), accent)
		4:
			_add_character_part(head, "SignatureHelmetSide", Vector3(0, 0.04, 0.25), Vector3(0.34, 0.16, 0.12), accent)
	# Side communications, neck protection and rear head gear add another identity layer.
	var comms_style := floori(float(operator_index) / 3.0) % 5
	match comms_style:
		0:
			_add_character_part(head, "SignatureCommsLeft", Vector3(-0.24, -0.02, 0.02), Vector3(0.12, 0.20, 0.16), armor_color, true)
			_add_character_part(head, "SignatureCommsMic", Vector3(-0.18, -0.14, -0.17), Vector3(0.20, 0.035, 0.035), accent)
		1:
			_add_character_part(head, "SignatureCommsRight", Vector3(0.24, -0.02, 0.02), Vector3(0.12, 0.20, 0.16), armor_color, true)
		2:
			_add_character_part(head, "SignatureDualCommsL", Vector3(-0.24, -0.02, 0.02), Vector3(0.10, 0.16, 0.14), accent, true)
			_add_character_part(head, "SignatureDualCommsR", Vector3(0.24, -0.02, 0.02), Vector3(0.10, 0.16, 0.14), accent, true)
		3:
			_add_character_part(head, "SignatureRearAntenna", Vector3(-0.18, 0.26, 0.20), Vector3(0.035, 0.34, 0.035), accent)
		4:
			_add_character_part(head, "SignatureHeadsetBand", Vector3(0, 0.14, 0.17), Vector3(0.40, 0.08, 0.08), armor_color, true)
	var neck_style := floori(float(operator_index) / 5.0) % 4
	match neck_style:
		0:
			_add_character_part(parent, "SignatureNeckGuard", Vector3(0, 1.62, -0.02), Vector3(0.44, 0.18, 0.40), armor_color)
		1:
			_add_character_part(parent, "SignatureNeckScarf", Vector3(0, 1.58, -0.23), Vector3(0.36, 0.14, 0.08), accent)
		2:
			_add_character_part(parent, "SignatureCollarArmorL", Vector3(-0.20, 1.59, -0.13), Vector3(0.16, 0.18, 0.20), armor_color)
			_add_character_part(parent, "SignatureCollarArmorR", Vector3(0.20, 1.59, -0.13), Vector3(0.16, 0.18, 0.20), armor_color)
		3:
			_add_character_part(parent, "SignatureNeckTag", Vector3(0, 1.52, -0.25), Vector3(0.10, 0.16, 0.04), accent)
	var shoulder_style := floori(float(operator_index) / 5.0) % 5
	match shoulder_style:
		0:
			_add_character_part(parent, "SignatureShoulderL", Vector3(-0.49, 1.52, 0), Vector3(0.34, 0.25, 0.34), armor_color, true)
			_add_character_part(parent, "SignatureShoulderR", Vector3(0.49, 1.52, 0), Vector3(0.34, 0.25, 0.34), armor_color, true)
		1:
			_add_character_part(parent, "SignatureShoulderL", Vector3(-0.49, 1.52, 0), Vector3(0.22, 0.38, 0.34), accent)
		2:
			_add_character_part(parent, "SignatureShoulderR", Vector3(0.49, 1.52, 0), Vector3(0.22, 0.38, 0.34), accent)
		3:
			_add_character_part(parent, "SignatureShoulderL", Vector3(-0.48, 1.54, 0), Vector3(0.38, 0.16, 0.38), accent, true)
			_add_character_part(parent, "SignatureShoulderR", Vector3(0.48, 1.54, 0), Vector3(0.38, 0.16, 0.38), accent, true)
		4:
			_add_character_part(parent, "SignatureShoulderPlate", Vector3(0, 1.55, 0.12), Vector3(0.78, 0.16, 0.22), accent)
	var backpack_style := floori(float(operator_index) / 25.0) % 2
	if backpack_style == 0:
		_add_character_part(parent, "SignatureBackModule", Vector3(0, 1.28, 0.39), Vector3(0.30, 0.30, 0.18), accent, true)
	else:
		_add_character_part(parent, "SignatureBackModuleL", Vector3(-0.22, 1.24, 0.39), Vector3(0.16, 0.52, 0.18), accent)
		_add_character_part(parent, "SignatureBackModuleR", Vector3(0.22, 1.24, 0.39), Vector3(0.16, 0.52, 0.18), accent)
	var chest_style := floori(float(operator_index) / 2.0) % 5
	match chest_style:
		0:
			_add_character_part(parent, "SignatureChestMark", Vector3(0, 1.24, -0.255), Vector3(0.18, 0.18, 0.045), accent, true)
		1:
			_add_character_part(parent, "SignatureChestMark", Vector3(-0.12, 1.25, -0.255), Vector3(0.07, 0.28, 0.04), accent)
		2:
			_add_character_part(parent, "SignatureChestMark", Vector3(0.12, 1.25, -0.255), Vector3(0.07, 0.28, 0.04), accent)
		3:
			_add_character_part(parent, "SignatureChestMark", Vector3(0, 1.34, -0.255), Vector3(0.26, 0.07, 0.04), accent)
		4:
			_add_character_part(parent, "SignatureChestMark", Vector3(0, 1.12, -0.255), Vector3(0.26, 0.07, 0.04), accent)
	var leg_style := floori(float(operator_index) / 10.0) % 5
	if leg_style == 0:
		_add_character_part(parent, "SignatureKneeL", Vector3(-0.19, 0.43, -0.17), Vector3(0.28, 0.20, 0.12), accent, true)
	elif leg_style == 1:
		_add_character_part(parent, "SignatureKneeR", Vector3(0.19, 0.43, -0.17), Vector3(0.28, 0.20, 0.12), accent, true)
	elif leg_style == 2:
		_add_character_part(parent, "SignatureThighStripeL", Vector3(-0.19, 0.64, -0.16), Vector3(0.07, 0.24, 0.035), accent)
	elif leg_style == 3:
		_add_character_part(parent, "SignatureThighStripeR", Vector3(0.19, 0.64, -0.16), Vector3(0.07, 0.24, 0.035), accent)
	else:
		_add_character_part(parent, "SignatureWaistPlate", Vector3(0, 0.84, -0.23), Vector3(0.24, 0.18, 0.08), accent)
	# Extra identity pieces: wrist guards, belt hardware and a shoulder insignia.
	var wrist_style := operator_index % 4
	if wrist_style == 0:
		_add_character_part(parent, "SignatureWristL", Vector3(-0.43, 0.91, -0.04), Vector3(0.24, 0.12, 0.23), accent, true)
	elif wrist_style == 1:
		_add_character_part(parent, "SignatureWristR", Vector3(0.43, 0.91, -0.04), Vector3(0.24, 0.12, 0.23), accent, true)
	elif wrist_style == 2:
		_add_character_part(parent, "SignatureWristBothL", Vector3(-0.43, 0.91, -0.04), Vector3(0.20, 0.09, 0.22), accent)
		_add_character_part(parent, "SignatureWristBothR", Vector3(0.43, 0.91, -0.04), Vector3(0.20, 0.09, 0.22), accent)
	else:
		_add_character_part(parent, "SignatureForearmBadge", Vector3(0.43, 1.12, -0.12), Vector3(0.16, 0.16, 0.06), accent, true)
	var belt_style := floori(float(operator_index) / 4.0) % 5
	match belt_style:
		0:
			_add_character_part(parent, "SignatureBeltBuckle", Vector3(0, 0.84, -0.25), Vector3(0.18, 0.14, 0.06), accent, true)
		1:
			_add_character_part(parent, "SignatureBeltToolL", Vector3(-0.40, 0.84, -0.05), Vector3(0.12, 0.24, 0.14), accent)
		2:
			_add_character_part(parent, "SignatureBeltToolR", Vector3(0.40, 0.84, -0.05), Vector3(0.12, 0.24, 0.14), accent)
		3:
			_add_character_part(parent, "SignatureBeltFront", Vector3(0, 0.94, -0.22), Vector3(0.34, 0.07, 0.05), accent)
		4:
			_add_character_part(parent, "SignatureBeltSide", Vector3(0.34, 0.82, 0), Vector3(0.12, 0.22, 0.20), accent)
	var insignia_style := floori(float(operator_index) / 8.0) % 5
	match insignia_style:
		0:
			_add_character_part(parent, "SignatureInsigniaL", Vector3(-0.34, 1.42, -0.21), Vector3(0.12, 0.12, 0.045), accent, true)
		1:
			_add_character_part(parent, "SignatureInsigniaR", Vector3(0.34, 1.42, -0.21), Vector3(0.12, 0.12, 0.045), accent, true)
		2:
			_add_character_part(parent, "SignatureCollarL", Vector3(-0.18, 1.53, -0.20), Vector3(0.12, 0.10, 0.06), accent)
		3:
			_add_character_part(parent, "SignatureCollarR", Vector3(0.18, 1.53, -0.20), Vector3(0.12, 0.10, 0.06), accent)
		4:
			_add_character_part(parent, "SignatureRankBar", Vector3(0, 1.49, -0.22), Vector3(0.26, 0.055, 0.045), accent)


	# Operator-specific leg rig accents: knee plates, thigh straps and boot guards.
	var lower_leg_style := operator_index % 5
	match lower_leg_style:
		0:
			_add_character_part(parent, "SignatureKneeL", Vector3(-0.19, 0.47, -0.17), Vector3(0.25, 0.20, 0.10), accent, true)
			_add_character_part(parent, "SignatureKneeR", Vector3(0.19, 0.47, -0.17), Vector3(0.25, 0.20, 0.10), accent, true)
		1:
			_add_character_part(parent, "SignatureThighStrapL", Vector3(-0.19, 0.72, -0.16), Vector3(0.30, 0.07, 0.06), armor_color)
			_add_character_part(parent, "SignatureThighStrapR", Vector3(0.19, 0.72, -0.16), Vector3(0.30, 0.07, 0.06), armor_color)
		2:
			_add_character_part(parent, "SignatureShinGuardL", Vector3(-0.19, 0.34, -0.15), Vector3(0.18, 0.28, 0.08), accent)
			_add_character_part(parent, "SignatureShinGuardR", Vector3(0.19, 0.34, -0.15), Vector3(0.18, 0.28, 0.08), accent)
		3:
			_add_character_part(parent, "SignatureKneeGuardL", Vector3(-0.19, 0.48, -0.18), Vector3(0.27, 0.14, 0.08), armor_color)
		4:
			_add_character_part(parent, "SignatureLegBadge", Vector3(0.34, 0.61, -0.17), Vector3(0.10, 0.18, 0.05), accent, true)
	var boot_style := floori(float(operator_index) / 5.0) % 4
	match boot_style:
		0:
			_add_character_part(parent, "SignatureBootToeL", Vector3(-0.19, 0.10, -0.27), Vector3(0.27, 0.09, 0.13), armor_color)
			_add_character_part(parent, "SignatureBootToeR", Vector3(0.19, 0.10, -0.27), Vector3(0.27, 0.09, 0.13), armor_color)
		1:
			_add_character_part(parent, "SignatureBootAnkleL", Vector3(-0.19, 0.18, -0.04), Vector3(0.28, 0.14, 0.27), accent)
			_add_character_part(parent, "SignatureBootAnkleR", Vector3(0.19, 0.18, -0.04), Vector3(0.28, 0.14, 0.27), accent)
		2:
			_add_character_part(parent, "SignatureBootStripeL", Vector3(-0.19, 0.12, -0.285), Vector3(0.22, 0.045, 0.025), accent)
			_add_character_part(parent, "SignatureBootStripeR", Vector3(0.19, 0.12, -0.285), Vector3(0.22, 0.045, 0.025), accent)
		3:
			_add_character_part(parent, "SignatureBootHeelL", Vector3(-0.19, 0.08, 0.10), Vector3(0.25, 0.12, 0.12), armor_color)



func _add_operator_field_kit(parent: Node3D, operator_name: String, armor_color: Color, accent: Color) -> void:
	# A second identity layer gives every operator a distinct field-equipment
	# combination in addition to the face, helmet, armour and leg signatures.
	var roster := _character_roster()
	var operator_index := 0
	for i in range(roster.size()):
		if str(roster[i][0]) == operator_name:
			operator_index = i
			break
	var pack_style := operator_index % 10
	match pack_style:
		0:
			_add_character_part(parent, "FieldKitCanisterL", Vector3(-0.29, 1.25, 0.38), Vector3(0.13, 0.42, 0.14), accent, true)
			_add_character_part(parent, "FieldKitCanisterR", Vector3(0.29, 1.25, 0.38), Vector3(0.13, 0.42, 0.14), accent, true)
		1:
			_add_character_part(parent, "FieldKitRadio", Vector3(0.32, 1.35, 0.25), Vector3(0.18, 0.30, 0.16), armor_color)
			_add_character_part(parent, "FieldKitRadioAntenna", Vector3(0.32, 1.58, 0.25), Vector3(0.025, 0.25, 0.025), accent)
		2:
			_add_character_part(parent, "FieldKitMedicalPack", Vector3(0, 1.20, 0.40), Vector3(0.42, 0.38, 0.16), accent)
			_add_character_part(parent, "FieldKitMedicalCross", Vector3(0, 1.20, 0.31), Vector3(0.22, 0.07, 0.035), armor_color)
		3:
			_add_character_part(parent, "FieldKitAmmoL", Vector3(-0.39, 1.03, -0.12), Vector3(0.15, 0.25, 0.18), accent)
			_add_character_part(parent, "FieldKitAmmoR", Vector3(0.39, 1.03, -0.12), Vector3(0.15, 0.25, 0.18), accent)
		4:
			_add_character_part(parent, "FieldKitSensor", Vector3(0, 1.48, 0.38), Vector3(0.24, 0.24, 0.18), accent, true)
			_add_character_part(parent, "FieldKitSensorAntenna", Vector3(0, 1.68, 0.38), Vector3(0.035, 0.20, 0.035), armor_color)
		5:
			_add_character_part(parent, "FieldKitShieldBatteryL", Vector3(-0.25, 1.18, 0.38), Vector3(0.18, 0.48, 0.16), armor_color)
			_add_character_part(parent, "FieldKitShieldBatteryR", Vector3(0.25, 1.18, 0.38), Vector3(0.18, 0.48, 0.16), armor_color)
		6:
			_add_character_part(parent, "FieldKitHydrationTube", Vector3(-0.30, 1.43, 0.20), Vector3(0.055, 0.42, 0.055), accent, true)
		7:
			_add_character_part(parent, "FieldKitDroneCore", Vector3(0, 1.30, 0.42), Vector3(0.30, 0.22, 0.20), accent, true)
			_add_character_part(parent, "FieldKitDroneWingL", Vector3(-0.25, 1.30, 0.42), Vector3(0.22, 0.045, 0.08), armor_color)
			_add_character_part(parent, "FieldKitDroneWingR", Vector3(0.25, 1.30, 0.42), Vector3(0.22, 0.045, 0.08), armor_color)
		8:
			_add_character_part(parent, "FieldKitHarnessL", Vector3(-0.31, 1.25, -0.22), Vector3(0.09, 0.54, 0.08), accent)
			_add_character_part(parent, "FieldKitHarnessR", Vector3(0.31, 1.25, -0.22), Vector3(0.09, 0.54, 0.08), accent)
		9:
			_add_character_part(parent, "FieldKitShoulderPack", Vector3(0.43, 1.48, 0.10), Vector3(0.22, 0.34, 0.26), accent, true)
	var support_style := floori(float(operator_index) / 10.0) % 5
	match support_style:
		0:
			_add_character_part(parent, "FieldSupportChestPanel", Vector3(0, 1.04, -0.245), Vector3(0.30, 0.16, 0.045), armor_color)
		1:
			_add_character_part(parent, "FieldSupportArmBadge", Vector3(-0.49, 1.30, -0.12), Vector3(0.16, 0.14, 0.06), accent)
			_add_character_part(parent, "FieldSupportArmStrap", Vector3(0.43, 1.20, -0.12), Vector3(0.22, 0.06, 0.06), armor_color)
		2:
			_add_character_part(parent, "FieldSupportThighHolster", Vector3(0.30, 0.62, -0.12), Vector3(0.18, 0.28, 0.16), armor_color)
			_add_character_part(parent, "FieldSupportHolsterClip", Vector3(0.30, 0.76, -0.20), Vector3(0.20, 0.045, 0.035), accent)
		3:
			_add_character_part(parent, "FieldSupportForearmL", Vector3(-0.43, 1.02, -0.15), Vector3(0.22, 0.12, 0.08), accent)
			_add_character_part(parent, "FieldSupportForearmR", Vector3(0.43, 1.02, -0.15), Vector3(0.22, 0.12, 0.08), accent)
		4:
			_add_character_part(parent, "FieldSupportSignalMast", Vector3(-0.30, 1.70, 0.22), Vector3(0.035, 0.34, 0.035), accent)
			_add_character_part(parent, "FieldSupportCable", Vector3(-0.30, 1.40, 0.10), Vector3(0.045, 0.35, 0.045), armor_color, true)


func _rebuild_local_character_visual() -> void:
	if local_player == null:
		return
	var old := local_player.get_node_or_null("CharacterVisual")
	if old:
		local_player.remove_child(old)
		old.queue_free()
	var visual := Node3D.new()
	visual.name = "CharacterVisual"
	local_player.add_child(visual)
	local_player.set_meta("operator_name", selected_character)
	var safe_gender := selected_gender if selected_gender in ["MALE", "FEMALE"] else "MALE"
	var safe_character := selected_character if _is_valid_operator(selected_character) else "NERO"
	_build_operator_visual(visual, true, safe_gender, safe_character)
	_apply_bundle_to_visual(visual, equipped_bundle, safe_character)

# Procedural third-person animation controller shared by local and remote operators.
# Motion is inferred from replicated transforms for remote players, so animation does not
# depend on a separate animation RPC stream.
func _update_remote_character_animations(delta: float) -> void:
	for peer_variant in players.keys():
		var peer_id := int(peer_variant)
		if peer_id == multiplayer.get_unique_id():
			continue
		var body := players[peer_id] as CharacterBody3D
		if is_instance_valid(body):
			_update_character_animation_for_body(body, delta, false)


func _create_operator_keyframe_animations(visual_root: Node3D, operator_name: String) -> void:
	if visual_root.get_node_or_null("OperatorAnimationPlayer") != null:
		return
	var player := AnimationPlayer.new()
	player.name = "OperatorAnimationPlayer"
	player.root_node = NodePath("..")
	visual_root.add_child(player)
	var library := AnimationLibrary.new()
	var profile := _operator_skill_profile(operator_name)
	var operator_index := int(profile["index"])
	var signature := float(operator_index) / 49.0
	var gait := float(operator_index % 5)
	var phase := float(operator_index) * 0.173
	# Authored five-pose keyframe tracks drive a shared parent motion layer.
	# Imported GLTF skeletons and fallback rigs inherit the same deterministic clips.
	var clips := {
		"idle": [1.8, Vector3(0.0, 0.012 + signature * 0.008, 0.0), Vector3(0.0, 0.0, 0.008 + gait * 0.002)],
		"walk": [0.72, Vector3(0.0, 0.025, 0.0), Vector3(0.0, 0.0, 0.035 + signature * 0.01)],
		"sprint": [0.48, Vector3(0.0, 0.045, 0.0), Vector3(0.0, 0.0, 0.055 + signature * 0.012)],
		"crouch": [1.1, Vector3(0.0, -0.015, 0.0), Vector3(0.0, 0.0, 0.012)],
		"jump": [0.62, Vector3(0.0, 0.12 + signature * 0.025, 0.0), Vector3(-0.04, 0.0, 0.0)],
		"fire": [0.22, Vector3(0.0, 0.018, 0.0), Vector3(0.035, 0.0, 0.0)],
		"reload": [0.95, Vector3(0.0, 0.008, 0.0), Vector3(0.0, 0.0, -0.025)],
		"hit": [0.3, Vector3(0.0, -0.025, 0.0), Vector3(0.0, 0.0, 0.08)],
		"death": [1.0, Vector3(0.0, -0.32, 0.0), Vector3(0.0, 0.0, -1.1)],
		"emote": [1.25, Vector3(0.0, 0.035, 0.0), Vector3(0.0, 0.0, 0.06)]
	}
	for clip_name in clips.keys():
		var values: Array = clips[clip_name]
		var duration := float(values[0]) * (1.0 + signature * 0.08)
		var lift: Vector3 = values[1]
		var tilt: Vector3 = values[2]
		var animation := Animation.new()
		animation.resource_name = operator_name + "_" + clip_name.to_upper()
		animation.length = duration
		animation.loop_mode = Animation.LOOP_NONE if clip_name in ["death", "hit", "fire"] else Animation.LOOP_LINEAR
		var phase_offset := phase + float(clip_name.length()) * 0.11
		var position_track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(position_track, NodePath("KeyframeRig:position"))
		var rotation_track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(rotation_track, NodePath("KeyframeRig:rotation"))
		var scale_track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(scale_track, NodePath("KeyframeRig:scale"))
		var key_times := [0.0, duration * 0.25, duration * 0.5, duration * 0.75, duration]
		var motion_wave := 0.65 + float(operator_index % 7) * 0.055
		for key_index in range(key_times.size()):
			var t := float(key_times[key_index])
			var wave := sin(float(key_index) * PI * 0.5 + phase_offset) * motion_wave
			var envelope := 0.0 if key_index == 0 or key_index == 4 else (1.0 if key_index == 2 else 0.55)
			var position_value := lift * envelope
			position_value.x += wave * (0.004 + signature * 0.004)
			position_value.z += cos(float(key_index) * PI * 0.5 + phase_offset) * envelope * 0.006
			var rotation_value := tilt * envelope
			rotation_value.y += wave * 0.012
			var scale_breath := 1.0 + sin(float(key_index) * PI * 0.5 + phase_offset) * (0.002 + signature * 0.002)
			animation.track_insert_key(position_track, t, position_value)
			animation.track_insert_key(rotation_track, t, rotation_value)
			animation.track_insert_key(scale_track, t, Vector3(1.0, scale_breath, 1.0))
		library.add_animation(clip_name, animation)
	player.add_animation_library("", library)
	player.play("idle")

func _update_operator_keyframe_state(body: CharacterBody3D, visual: Node3D, moving: bool, sprinting: bool, crouched: bool, airborne: bool, fire_active: bool, reload_active: bool, hit_active: bool, dead_pose: bool, is_local: bool) -> void:
	var player := visual.get_node_or_null("OperatorAnimationPlayer") as AnimationPlayer
	if player == null:
		return
	var desired := "idle"
	if dead_pose:
		desired = "death"
	elif hit_active:
		desired = "hit"
	elif reload_active:
		desired = "reload"
	elif fire_active:
		desired = "fire"
	elif airborne:
		desired = "jump"
	elif crouched:
		desired = "crouch"
	elif sprinting:
		desired = "sprint"
	elif moving:
		desired = "walk"
	if is_local and emote_animation_busy:
		desired = "emote"
	if player.current_animation != desired:
		player.play(desired)


func _update_character_animation_for_body(body: CharacterBody3D, delta: float, is_local: bool) -> void:
	if not is_instance_valid(body):
		return
	var visual := body.get_node_or_null("CharacterVisual") as Node3D
	if visual == null:
		return
	var rigged_skeleton := visual.find_child("Skeleton3D", true, false) as Skeleton3D
	var now := Time.get_ticks_msec() / 1000.0
	var operator_name := str(body.get_meta("operator_name", selected_character if is_local else "NERO"))
	var operator_index := 0
	var operator_roster := _character_roster()
	for operator_i in range(operator_roster.size()):
		if str(operator_roster[operator_i][0]) == operator_name:
			operator_index = operator_i
			break
	var clip_set := _operator_animation_clip_set(operator_name)
	var idle_clip: Dictionary = clip_set["idle"]
	var walk_clip: Dictionary = clip_set["walk"]
	var sprint_clip: Dictionary = clip_set["sprint"]
	var crouch_clip: Dictionary = clip_set["crouch"]
	var jump_clip: Dictionary = clip_set["jump"]
	var fire_clip: Dictionary = clip_set["fire"]
	var reload_clip: Dictionary = clip_set["reload"]
	var hit_clip: Dictionary = clip_set["hit"]
	var death_clip: Dictionary = clip_set["death"]
	var style_clip: Dictionary = clip_set["style"]
	var animation_signature := float(idle_clip["phase"])
	var previous_position: Vector3 = body.get_meta("anim_previous_position", body.global_position)
	var travel := body.global_position.distance_to(previous_position)
	body.set_meta("anim_previous_position", body.global_position)
	var moving := false
	var speed_ratio := 0.0
	var vertical_speed := 0.0
	if is_local:
		moving = Vector2(body.velocity.x, body.velocity.z).length() > 0.25
		speed_ratio = clampf(Vector2(body.velocity.x, body.velocity.z).length() / maxf(normal_speed, 0.1), 0.0, 1.5)
		vertical_speed = body.velocity.y
	else:
		moving = travel > 0.006
		speed_ratio = clampf(travel / maxf(delta * normal_speed, 0.001), 0.0, 1.5)
		vertical_speed = (body.global_position.y - previous_position.y) / maxf(delta, 0.001)
	var crouched := is_local and crouch_enabled
	var sprinting := is_local and sprint_enabled and moving
	var phase_rate := float(sprint_clip["rate"]) if sprinting else (float(crouch_clip["rate"]) if crouched else float(walk_clip["rate"]))
	var phase := float(body.get_meta("anim_phase", animation_signature)) + delta * phase_rate
	body.set_meta("anim_phase", phase)
	var locomotion_amount := (float(walk_clip["leg"]) if not sprinting else float(sprint_clip["leg"])) * float(style_clip["stride"])
	if crouched:
		locomotion_amount = float(crouch_clip["leg"])
	var airborne := vertical_speed > 1.0 or (not body.is_on_floor() and vertical_speed < -1.0)
	var fire_active := now < float(body.get_meta("anim_fire_until", 0.0))
	var reload_active := now < float(body.get_meta("anim_reload_until", 0.0))
	var hit_active := now < float(body.get_meta("anim_hit_until", 0.0))
	var dead_pose := bool(body.get_meta("anim_dead", false))
	_update_operator_keyframe_state(body, visual, moving, sprinting, crouched, airborne, fire_active, reload_active, hit_active, dead_pose, is_local)
	var blend := minf(1.0, delta * 11.0)
	var keyframe_rig := visual.get_node_or_null("KeyframeRig") as Node3D
	var pose_root := keyframe_rig if keyframe_rig != null else visual
	var left_arm := pose_root.get_node_or_null("LeftArmPivot") as Node3D
	var right_arm := pose_root.get_node_or_null("RightArmPivot") as Node3D
	var left_leg := pose_root.get_node_or_null("LeftLegPivot") as Node3D
	var right_leg := pose_root.get_node_or_null("RightLegPivot") as Node3D
	var head := pose_root.get_node_or_null("HeadPivot") as Node3D
	var torso := pose_root.get_node_or_null("Torso") as MeshInstance3D
	if dead_pose:
		visual.rotation.z = lerpf(visual.rotation.z, -float(death_clip["fall"]), blend)
		visual.position.y = lerpf(visual.position.y, -float(death_clip["sink"]), blend)
		return
	visual.rotation.z = lerpf(visual.rotation.z, 0.0, blend)
	visual.position.y = lerpf(visual.position.y, 0.0, blend)
	var arm_amount := float(walk_clip["arm"]) if not sprinting else float(sprint_clip["arm"])
	if crouched:
		arm_amount = float(crouch_clip["arm"])
	var arm_swing := sin(phase) * arm_amount if moving else 0.0
	var leg_swing := sin(phase) * locomotion_amount if moving else 0.0
	var aim_arm_x := -0.32 if is_local else -0.12
	if airborne:
		arm_swing = 0.0
		leg_swing = 0.0
	for side in [-1.0, 1.0]:
		var arm := left_arm if side < 0.0 else right_arm
		var leg := left_leg if side < 0.0 else right_leg
		var swing := arm_swing * (1.0 if side < 0.0 else -1.0)
		var leg_angle := leg_swing * (-1.0 if side < 0.0 else 1.0)
		var idle_pose := sin(animation_signature * TAU + float(side) * 1.7) * 0.055
		var gait_style := int(style_clip["gait"])
		var gait_phase := phase + float(operator_index % 5) * 0.31
		var gait_arm_offset := sin(gait_phase * (1.0 + float(gait_style) * 0.08) + float(side) * 0.7) * float(style_clip["shoulder_roll"])
		var target_arm := Vector3(aim_arm_x + swing * 0.45 + float(style_clip["arm_bias"]) * side + (idle_pose if not moving else 0.0) + gait_arm_offset, 0.0, -0.08 * side + (idle_pose * 0.6 if not moving else 0.0) + float(style_clip["elbow_tuck"]) * side)
		if crouched:
			target_arm.x += 0.08
		if reload_active:
			target_arm.x = -float(reload_clip["reach"])
			target_arm.z = -0.35 * side
		elif fire_active:
			target_arm.x = -float(fire_clip["recoil"])
		elif airborne:
			target_arm.x = -0.18
			target_arm.z = -0.30 * side
		if hit_active:
			target_arm.z += float(hit_clip["flinch"]) * side
		if arm and not (is_local and emote_animation_busy):
			arm.rotation = arm.rotation.lerp(target_arm, blend)
		if rigged_skeleton and not (is_local and emote_animation_busy):
			var arm_bone := rigged_skeleton.find_bone("LeftArm" if side < 0.0 else "RightArm")
			if arm_bone >= 0:
				rigged_skeleton.set_bone_pose_rotation(arm_bone, Quaternion.from_euler(target_arm))
		var gait_leg_bias := sin(phase * (1.0 + float(int(style_clip["gait"])) * 0.06) + float(side) * 0.9) * float(style_clip["hip_sway"])
		var target_leg := Vector3(leg_angle + gait_leg_bias, 0.0, float(style_clip["hip_sway"]) * side * (0.35 if moving else 0.12))
		if airborne:
			target_leg.x = -float(jump_clip["tuck"]) if side < 0.0 else float(jump_clip["tuck"])
		elif crouched:
			target_leg.x = -0.22
		if leg and not (is_local and emote_animation_busy):
			leg.rotation = leg.rotation.lerp(target_leg, blend)
		if rigged_skeleton and not (is_local and emote_animation_busy):
			var leg_bone := rigged_skeleton.find_bone("LeftLeg" if side < 0.0 else "RightLeg")
			if leg_bone >= 0:
				rigged_skeleton.set_bone_pose_rotation(leg_bone, Quaternion.from_euler(target_leg))
	if head and not (is_local and emote_animation_busy):
		var head_target := Vector3(float(style_clip["head_turn"]) * sin(phase * (0.5 + float(int(style_clip["gait"])) * 0.035) + animation_signature * TAU), 0.0, sin(animation_signature * TAU * 2.0 + phase * 0.08) * float(style_clip["head_tilt"]))
		if hit_active:
			head_target.z = 0.22
		head.rotation = head.rotation.lerp(head_target, blend)
	if rigged_skeleton and not (is_local and emote_animation_busy):
		var head_bone := rigged_skeleton.find_bone("Head")
		if head_bone >= 0:
			var rig_head_target := Vector3(0.025 * sin(phase * 0.5 + animation_signature * TAU), 0.0, 0.22 if hit_active else 0.0)
			rigged_skeleton.set_bone_pose_rotation(head_bone, Quaternion.from_euler(rig_head_target))
		# Full-body procedural pose channels for the imported seven-bone rigs.
		var pelvis_bone := rigged_skeleton.find_bone("Pelvis")
		if pelvis_bone >= 0:
			var pelvis_pitch := -float(style_clip["lean"]) if sprinting else (-float(style_clip["lean"]) * 0.55 if moving else 0.0)
			var pelvis_roll := sin(phase * (1.0 + float(int(style_clip["gait"])) * 0.045)) * (0.025 + float(style_clip["lean"]) + float(style_clip["hip_sway"])) if moving else sin(now * 1.3 + animation_signature) * float(style_clip["hip_sway"])
			if crouched:
				pelvis_pitch = -0.12
			rigged_skeleton.set_bone_pose_rotation(pelvis_bone, Quaternion.from_euler(Vector3(pelvis_pitch, 0.0, pelvis_roll)))
		var spine_bone := rigged_skeleton.find_bone("Spine")
		if spine_bone >= 0:
			var spine_pitch := float(style_clip["lean"]) * 0.8 if moving else 0.0
			var spine_roll := -sin(phase) * (0.018 + float(style_clip["lean"]) * 0.5) if moving else sin(now * 1.1 + animation_signature) * 0.009
			if airborne:
				spine_pitch = -0.10
			rigged_skeleton.set_bone_pose_rotation(spine_bone, Quaternion.from_euler(Vector3(spine_pitch, 0.0, spine_roll)))
	if torso:
		var breath := 1.0 + sin(now * float(idle_clip["rate"]) + animation_signature) * float(idle_clip["sway"]) + sin(now * (2.1 + float(int(style_clip["gait"])) * 0.13) + animation_signature) * (float(style_clip["bounce"]) + float(style_clip["breath"]))
		torso.scale.y = lerpf(torso.scale.y, breath, blend)
	if is_local:
		visual.scale.y = lerpf(visual.scale.y, 0.72 if crouched else 1.0, blend)
	if hit_active:
		visual.rotation.x = lerpf(visual.rotation.x, 0.12, blend)
	else:
		visual.rotation.x = lerpf(visual.rotation.x, 0.0, blend)

func _trigger_character_hit_animation(body: CharacterBody3D) -> void:
	if is_instance_valid(body):
		var character_name := str(body.get_meta("operator_name", selected_character))
		var hit_clip: Dictionary = _operator_animation_clip_set(character_name)["hit"]
		body.set_meta("anim_hit_until", Time.get_ticks_msec() / 1000.0 + float(hit_clip["duration"]))

func _trigger_character_death_animation(body: CharacterBody3D) -> void:
	if is_instance_valid(body):
		body.set_meta("anim_dead", true)

func _play_emote_animation(visual: Node3D, emote_name: String) -> void:
	emote_animation_busy = true
	var emote_clip: Dictionary = _operator_animation_clip_set(selected_character)["emote"]
	var emote_amplitude := float(emote_clip["amplitude"])
	var emote_tempo := float(emote_clip["tempo"])
	var rig_root := visual.get_node_or_null("KeyframeRig") as Node3D
	var pose_root := rig_root if rig_root != null else visual
	var left := pose_root.get_node_or_null("LeftArmPivot") as Node3D
	var right := pose_root.get_node_or_null("RightArmPivot") as Node3D
	var l_leg := pose_root.get_node_or_null("LeftLegPivot") as Node3D
	var r_leg := pose_root.get_node_or_null("RightLegPivot") as Node3D
	var tween := create_tween()
	tween.set_parallel(true)
	if emote_name == "SALUTE":
		if right: tween.tween_property(right, "rotation:z", -1.9 * emote_amplitude, 0.28 / emote_tempo)
	elif emote_name == "VICTORY POSE":
		if left: tween.tween_property(left, "rotation:z", 2.4 * emote_amplitude, 0.25 / emote_tempo)
		if right: tween.tween_property(right, "rotation:z", -2.4 * emote_amplitude, 0.25 / emote_tempo)
	elif emote_name == "HYPE DANCE" or emote_name == "SQUAD CELEBRATION":
		if left: tween.tween_property(left, "rotation:z", 2.2 * emote_amplitude, 0.22 / emote_tempo)
		if right: tween.tween_property(right, "rotation:z", -2.2 * emote_amplitude, 0.22 / emote_tempo)
		if l_leg: tween.tween_property(l_leg, "rotation:x", -0.65, 0.22)
		if r_leg: tween.tween_property(r_leg, "rotation:x", 0.65, 0.22)
	else:
		if left: tween.tween_property(left, "rotation:z", 1.4, 0.18)
		if right: tween.tween_property(right, "rotation:z", -1.4, 0.18)
	# Imported GLTF rigs do not expose the procedural pivot nodes; animate their
	# actual skeleton bones so emotes work on the 50 imported operator models too.
	var emote_skeleton := visual.find_child("Skeleton3D", true, false) as Skeleton3D
	if emote_skeleton:
		var left_bone := emote_skeleton.find_bone("LeftArm")
		var right_bone := emote_skeleton.find_bone("RightArm")
		var head_bone := emote_skeleton.find_bone("Head")
		var left_pose := Vector3(-0.25, 0.0, 1.45 * emote_amplitude)
		var right_pose := Vector3(-0.25, 0.0, -1.45 * emote_amplitude)
		if emote_name == "SALUTE":
			right_pose = Vector3(-1.05, 0.0, -0.85 * emote_amplitude)
		elif emote_name == "VICTORY POSE" or emote_name == "SQUAD CELEBRATION":
			left_pose = Vector3(-0.35, 0.0, 2.0 * emote_amplitude)
			right_pose = Vector3(-0.35, 0.0, -2.0 * emote_amplitude)
		elif emote_name == "HYPE DANCE":
			left_pose = Vector3(-0.7, 0.0, 2.2 * emote_amplitude)
			right_pose = Vector3(-0.7, 0.0, -2.2 * emote_amplitude)
		if left_bone >= 0:
			emote_skeleton.set_bone_pose_rotation(left_bone, Quaternion.from_euler(left_pose))
		if right_bone >= 0:
			emote_skeleton.set_bone_pose_rotation(right_bone, Quaternion.from_euler(right_pose))
		if head_bone >= 0:
			emote_skeleton.set_bone_pose_rotation(head_bone, Quaternion.from_euler(Vector3(-0.12, 0.0, 0.0)))
	tween.set_parallel(false)
	tween.tween_interval(0.55 / emote_tempo)
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

func _operator_skill_visual_profile(character: String) -> Dictionary:
	var profile := _operator_skill_profile(character)
	var index := int(profile["index"])
	var archetype := int(profile["archetype"])
	var shape_names := ["SPHERE", "CYLINDER", "BOX", "SPHERE", "CYLINDER", "SPHERE", "BOX", "SPHERE", "BOX", "CYLINDER"]
	return {
		"shape": shape_names[archetype],
		"radius": 3.8 + float(index) * 0.035,
		"height": 0.07 + float(archetype % 4) * 0.025,
		"segments": 20 + (index % 7) * 4,
		"ring_count": 1 + (index % 3),
		"ring_spacing": 0.08 + float(index % 5) * 0.018,
		"ring_width": 0.055 + float(index % 6) * 0.008,
		"archetype": archetype,
		"signature": index
	}

func _spawn_skill_pulse() -> void:
	if local_player == null:
		return
	var visual_profile := _operator_skill_visual_profile(selected_character)
	var pulse := MeshInstance3D.new()
	var mesh: PrimitiveMesh
	match str(visual_profile["shape"]):
		"CYLINDER":
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = 1.0
			cylinder.bottom_radius = 1.0
			cylinder.height = float(visual_profile["height"])
			cylinder.radial_segments = int(visual_profile["segments"])
			mesh = cylinder
		"BOX":
			var box := BoxMesh.new()
			box.size = Vector3(1.8, float(visual_profile["height"]), 1.8)
			mesh = box
		_:
			var sphere := SphereMesh.new()
			sphere.radius = 1.0
			sphere.height = 0.12
			sphere.radial_segments = int(visual_profile["segments"])
			sphere.rings = 6
			mesh = sphere
	pulse.mesh = mesh
	pulse.position = local_player.global_position + Vector3(0, 0.12, 0)
	pulse.scale = Vector3(0.42, 0.08, 0.42)
	var operator_style := _character_style(selected_character)
	var accent: Color = operator_style["accent"]
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(accent.r, accent.g, accent.b, 0.42)
	material.emission_enabled = true
	material.emission = accent
	material.emission_energy_multiplier = 0.7 + float(int(visual_profile["signature"]) % 5) * 0.12
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pulse.material_override = material
	add_child(pulse)
	# Add operator-tuned concentric torus bands so each signature pulse has its own
	# layered silhouette, spacing, width and tessellation rather than a single disc.
	var ring_materials: Array[StandardMaterial3D] = []
	for ring_index in range(int(visual_profile["ring_count"])):
		var ring_node := MeshInstance3D.new()
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = maxf(0.1, 1.0 - float(visual_profile["ring_width"]))
		ring_mesh.outer_radius = 1.0 + float(ring_index) * float(visual_profile["ring_spacing"])
		ring_mesh.rings = int(visual_profile["segments"])
		ring_mesh.ring_segments = 8 + (int(visual_profile["signature"]) % 5)
		ring_node.mesh = ring_mesh
		ring_node.rotation.x = PI * 0.5
		ring_node.position.y = float(ring_index) * float(visual_profile["ring_spacing"])
		ring_node.scale = Vector3.ONE * (0.92 + float(ring_index) * 0.16)
		var ring_material := StandardMaterial3D.new()
		ring_material.albedo_color = Color(accent.r, accent.g, accent.b, 0.72)
		ring_material.emission_enabled = true
		ring_material.emission = accent
		ring_material.emission_energy_multiplier = 1.0 + float(int(visual_profile["signature"]) % 7) * 0.1
		ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring_node.material_override = ring_material
		pulse.add_child(ring_node)
		ring_materials.append(ring_material)
	var target_radius := float(visual_profile["radius"])
	var target_scale := Vector3(target_radius, 0.08 + float(visual_profile["archetype"] % 3) * 0.025, target_radius)
	var tween := create_tween()
	tween.tween_property(pulse, "scale", target_scale, 0.62)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, 0.62)
	for ring_material in ring_materials:
		tween.parallel().tween_property(ring_material, "albedo_color:a", 0.0, 0.62)
	tween.tween_callback(pulse.queue_free)

func _deploy_gloo_wall() -> void:
	if local_player == null or is_dead or gloo_wall_charges <= 0:
		if status_label: status_label.text = "NO GLOO WALL CHARGES"
		return
	var online_client := multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not multiplayer.is_server()
	if online_client:
		rpc_id(1, "request_deploy_gloo_wall", equipped_gloo_skin)
		if status_label: status_label.text = "VERIFYING GLOO WALL..."
		return
	if multiplayer.multiplayer_peer != null and multiplayer.is_server():
		var peer_id := multiplayer.get_unique_id()
		var remaining := int(server_player_gloo_charges.get(peer_id, gloo_wall_charges))
		if remaining <= 0:
			if status_label: status_label.text = "NO SERVER-APPROVED GLOO CHARGES"
			return
		server_player_gloo_charges[peer_id] = remaining - 1
		gloo_wall_charges = remaining - 1
	var wall_position := local_player.global_position + (-local_player.global_basis.z) * 2.4
	_create_gloo_wall(wall_position, local_player.rotation.y, equipped_gloo_skin)
	if gloo_wall_button: gloo_wall_button.text = "GLOO WALL (" + str(gloo_wall_charges) + ")"
	if status_label: status_label.text = "GLOO WALL DEPLOYED • " + equipped_gloo_skin


func _create_gloo_wall(wall_position: Vector3, wall_yaw: float, skin_name: String) -> void:
	var wall := StaticBody3D.new()
	wall.name = "GlooWall_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000)
	wall.position = wall_position + Vector3(0, 1.35, 0)
	wall.rotation.y = wall_yaw
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
	match skin_name:
		"CRIMSON GRID": material.albedo_color = Color(0.65, 0.12, 0.16, 0.88)
		"ARCTIC SHIELD": material.albedo_color = Color(0.25, 0.75, 0.9, 0.88)
		"GOLD CIRCUIT": material.albedo_color = Color(0.78, 0.58, 0.16, 0.88)
		_: material.albedo_color = Color(0.12, 0.48, 0.78, 0.88)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.35
	visual.material_override = material
	wall.add_child(visual)
	add_child(wall)


@rpc("any_peer", "call_remote", "reliable")
func request_deploy_gloo_wall(skin_name: String) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0 or not server_player_states.has(sender) or server_eliminated.has(sender) or match_finished:
		return
	var remaining := int(server_player_gloo_charges.get(sender, 0))
	if remaining <= 0:
		rpc_id(sender, "receive_gloo_wall_result", false, remaining, "NO GLOO WALL CHARGES")
		return
	var state: Dictionary = server_player_states[sender]
	var player_position: Vector3 = state.get("position", Vector3.ZERO)
	var player_yaw := float(state.get("yaw", 0.0))
	var forward := Vector3(-sin(player_yaw), 0.0, -cos(player_yaw))
	var wall_position := player_position + forward * 2.4
	if absf(wall_position.x) > MAP_SIZE * 0.5 or absf(wall_position.z) > MAP_SIZE * 0.5:
		rpc_id(sender, "receive_gloo_wall_result", false, remaining, "INVALID WALL POSITION")
		return
	var safe_skin := skin_name if skin_name in ["CRIMSON GRID", "ARCTIC SHIELD", "GOLD CIRCUIT"] else "STANDARD"
	server_player_gloo_charges[sender] = remaining - 1
	_create_gloo_wall(wall_position, player_yaw, safe_skin)
	rpc("receive_gloo_wall_spawn", wall_position, player_yaw, safe_skin)
	rpc_id(sender, "receive_gloo_wall_result", true, remaining - 1, "GLOO WALL DEPLOYED")


@rpc("authority", "call_remote", "reliable")
func receive_gloo_wall_spawn(wall_position: Vector3, wall_yaw: float, skin_name: String) -> void:
	_create_gloo_wall(wall_position, wall_yaw, skin_name)
	if OS.get_cmdline_user_args().has("--network-test-client") and wall_position.is_finite() and is_finite(wall_yaw):
		network_test_gloo_wall_received = true


@rpc("authority", "call_remote", "reliable")
func receive_gloo_wall_result(approved: bool, remaining: int, message: String) -> void:
	if not approved:
		if status_label: status_label.text = message
		return
	gloo_wall_charges = clampi(remaining, 0, 5)
	if OS.get_cmdline_user_args().has("--network-test-client") and approved and remaining == 1:
		network_test_gloo_wall_charges_received = true
	if gloo_wall_button: gloo_wall_button.text = "GLOO WALL (" + str(gloo_wall_charges) + ")"
	if status_label: status_label.text = message + " • " + equipped_gloo_skin

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
	_show_world_forge_editor()


func _show_world_forge_editor() -> void:
	var panel := _show_simple_screen("WORLD FORGE • LOCAL MAP BUILDER")
	if world_forge_cells.size() != WORLD_FORGE_WIDTH * WORLD_FORGE_HEIGHT:
		world_forge_cells.resize(WORLD_FORGE_WIDTH * WORLD_FORGE_HEIGHT)
		for i in range(world_forge_cells.size()):
			world_forge_cells[i] = false
	var intro := Label.new()
	intro.text = "Build a local 12 × 12 battle layout. Tap cells to place or remove cover blocks. Your map is saved on this device."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(intro)
	world_forge_status = Label.new()
	world_forge_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world_forge_status.text = _world_forge_summary()
	panel.add_child(world_forge_status)
	world_forge_grid = GridContainer.new()
	world_forge_grid.columns = WORLD_FORGE_WIDTH
	world_forge_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	world_forge_grid.add_theme_constant_override("h_separation", 3)
	world_forge_grid.add_theme_constant_override("v_separation", 3)
	panel.add_child(world_forge_grid)
	for cell_index in range(WORLD_FORGE_WIDTH * WORLD_FORGE_HEIGHT):
		var cell := Button.new()
		cell.custom_minimum_size = Vector2(25, 25)
		cell.text = "■" if world_forge_cells[cell_index] else "·"
		cell.tooltip_text = "Tap to toggle cover"
		cell.pressed.connect(_world_forge_toggle_cell.bind(cell_index))
		world_forge_grid.add_child(cell)
	var controls := HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(controls)
	var save_button := Button.new()
	save_button.text = "SAVE MAP"
	save_button.pressed.connect(_world_forge_save)
	controls.add_child(save_button)
	var load_button := Button.new()
	load_button.text = "LOAD MAP"
	load_button.pressed.connect(_world_forge_load)
	controls.add_child(load_button)
	var clear_button := Button.new()
	clear_button.text = "CLEAR"
	clear_button.pressed.connect(_world_forge_clear)
	controls.add_child(clear_button)
	var back := Button.new()
	back.text = "BACK TO LOBBY"
	back.pressed.connect(_show_lobby_screen)
	panel.add_child(back)


func _world_forge_toggle_cell(cell_index: int) -> void:
	if cell_index < 0 or cell_index >= world_forge_cells.size():
		return
	world_forge_cells[cell_index] = not world_forge_cells[cell_index]
	_world_forge_refresh()


func _world_forge_refresh() -> void:
	if world_forge_grid == null:
		return
	for i in range(world_forge_grid.get_child_count()):
		var cell := world_forge_grid.get_child(i) as Button
		if cell:
			cell.text = "■" if world_forge_cells[i] else "·"
	if world_forge_status:
		world_forge_status.text = _world_forge_summary()


func _world_forge_summary() -> String:
	var blocks := 0
	for occupied in world_forge_cells:
		if occupied:
			blocks += 1
	return "MAP SIZE: 12 × 12   •   COVER BLOCKS: " + str(blocks) + "   •   OPEN TILES: " + str(world_forge_cells.size() - blocks)


func _world_forge_save() -> void:
	var payload := {"version": 1, "width": WORLD_FORGE_WIDTH, "height": WORLD_FORGE_HEIGHT, "cells": world_forge_cells}
	var file := FileAccess.open(WORLD_FORGE_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		if world_forge_status:
			world_forge_status.text = "SAVE FAILED: " + error_string(FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(payload))
	file.close()
	if world_forge_status:
		world_forge_status.text = "MAP SAVED ON THIS DEVICE  •  " + _world_forge_summary()


func _world_forge_load() -> void:
	if not FileAccess.file_exists(WORLD_FORGE_SAVE_PATH):
		if world_forge_status:
			world_forge_status.text = "NO SAVED MAP FOUND ON THIS DEVICE."
		return
	var file := FileAccess.open(WORLD_FORGE_SAVE_PATH, FileAccess.READ)
	if file == null:
		if world_forge_status:
			world_forge_status.text = "LOAD FAILED: " + error_string(FileAccess.get_open_error())
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or int(parsed.get("version", 0)) != 1 or int(parsed.get("width", 0)) != WORLD_FORGE_WIDTH or int(parsed.get("height", 0)) != WORLD_FORGE_HEIGHT or not (parsed.get("cells", null) is Array):
		if world_forge_status:
			world_forge_status.text = "SAVED MAP IS INVALID OR FROM AN UNSUPPORTED VERSION."
		return
	var loaded_cells: Array = parsed["cells"]
	if loaded_cells.size() != WORLD_FORGE_WIDTH * WORLD_FORGE_HEIGHT:
		if world_forge_status:
			world_forge_status.text = "SAVED MAP HAS AN INVALID TILE COUNT."
		return
	world_forge_cells.clear()
	for value in loaded_cells:
		world_forge_cells.append(bool(value))
	_world_forge_refresh()
	if world_forge_status:
		world_forge_status.text = "MAP LOADED  •  " + _world_forge_summary()


func _world_forge_clear() -> void:
	for i in range(world_forge_cells.size()):
		world_forge_cells[i] = false
	_world_forge_refresh()


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
		dummy.set_meta("bot_lane_center", dummy.position.x)
		dummy.set_meta("bot_lane_phase", randf() * TAU)
		dummy.set_meta("bot_lane_speed", randf_range(0.65, 1.35))
		dummy.set_meta("bot_lane_width", randf_range(1.0, 3.2))
		dummy.set_meta("bot_duck_phase", randf() * TAU)
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
		var head_area := Area3D.new()
		head_area.name = "HeadHitbox"
		head_area.collision_layer = 1
		head_area.collision_mask = 0
		var head_shape := CollisionShape3D.new()
		var head_sphere := SphereShape3D.new()
		head_sphere.radius = 0.30
		head_shape.shape = head_sphere
		head_shape.position.y = 1.58
		head_area.add_child(head_shape)
		dummy.add_child(head_area)
		add_child(dummy)
		training_targets.append(dummy)
	if status_label:
		status_label.text = "AIM ACADEMY • Targets: " + str(training_targets.size()) + " • Shoot to score"




func _update_training_bot_ai(delta: float) -> void:
	# Combat Academy targets use lightweight lane-based bot movement so players
	# can practise tracking moving targets without spawning bots in live queues.
	if training_targets.is_empty() or local_player == null or match_started:
		return
	var now := Time.get_ticks_msec() / 1000.0
	for target in training_targets:
		if not is_instance_valid(target) or not target.has_meta("bot_lane_center"):
			continue
		var phase := float(target.get_meta("bot_lane_phase", 0.0)) + delta * float(target.get_meta("bot_lane_speed", 1.0))
		target.set_meta("bot_lane_phase", phase)
		var center_x := float(target.get_meta("bot_lane_center", target.position.x))
		var lane_width := float(target.get_meta("bot_lane_width", 1.5))
		var desired_x := center_x + sin(phase) * lane_width
		var target_velocity := (desired_x - target.position.x) * 3.2
		target.velocity.x = clampf(target_velocity, -4.0, 4.0)
		target.velocity.z = 0.0
		target.move_and_slide()
		var duck_phase := float(target.get_meta("bot_duck_phase", 0.0)) + delta * 1.4
		target.set_meta("bot_duck_phase", duck_phase)
		var body_mesh := target.get_node_or_null("MeshInstance3D") as MeshInstance3D
		if body_mesh:
			body_mesh.scale.y = 0.72 if sin(duck_phase + now * 0.15) > 0.88 else 1.0
		target.rotation.y = atan2(local_player.global_position.x - target.global_position.x, local_player.global_position.z - target.global_position.z)

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
	# Guaranteed starter supplies near the main districts.
	var spawn_data := [
		["ammo_rifle", 60, Vector3(-55, 0.8, -48)],
		["ammo_smg", 60, Vector3(48, 0.8, -55)],
		["ammo_shotgun", 12, Vector3(-62, 0.8, 45)],
		["ammo_sniper", 12, Vector3(-72, 0.8, 8)],
		["ammo_pistol", 45, Vector3(68, 0.8, 8)],
		["ammo_launcher", 6, Vector3(12, 0.8, 70)],
		["ammo_bow", 12, Vector3(-12, 0.8, 70)],
		["medkit", 2, Vector3(50, 0.8, 45)],
		["armor", 50, Vector3(4, 0.8, -12)]
	]
	for data in spawn_data:
		_create_loot_item(str(data[0]), int(data[1]), data[2] as Vector3)
	# Add weapon drops across all weapon families instead of limiting the island
	# to two hard-coded pickup types. Melee and explosive ordnance are included.
	var weapon_drop_indices := _weapon_loot_drop_indices()
	for drop_index in range(weapon_drop_indices.size()):
		var weapon_index := int(weapon_drop_indices[drop_index])
		var angle := TAU * float(drop_index) / float(weapon_drop_indices.size())
		var radius := 32.0 + float(drop_index % 4) * 11.0
		var drop_position := Vector3(cos(angle) * radius, 0.8, sin(angle) * radius)
		_create_loot_item("weapon_" + str(weapon_index), 1, drop_position)
	# Distributed ammo, healing and armour keep every district viable.
	for supply_index in range(24):
		var supply_angle := randf() * TAU
		var supply_radius := randf_range(18.0, 88.0)
		var supply_position := Vector3(cos(supply_angle) * supply_radius, 0.8, sin(supply_angle) * supply_radius)
		var supply_type := ["ammo_rifle", "ammo_smg", "ammo_shotgun", "ammo_sniper", "ammo_pistol", "medkit", "armor"][supply_index % 7]
		var supply_amount := 1 if supply_type == "medkit" else (35 if supply_type.begins_with("ammo_") else 25)
		_create_loot_item(supply_type, supply_amount, supply_position)


func _weapon_loot_drop_indices() -> Array[int]:
	var indices: Array[int] = []
	for weapon_index in range(weapon_names.size()):
		indices.append(weapon_index)
	return indices

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
	if item_type.begins_with("weapon_"):
		tint = Color(0.95, 0.65, 0.12)
		var weapon_index := int(item_type.trim_prefix("weapon_"))
		if weapon_index >= 0 and weapon_index < weapon_names.size():
			item.set_meta("weapon_index", weapon_index)
			var weapon_label := Label3D.new()
			weapon_label.text = weapon_names[weapon_index]
			weapon_label.font_size = 24
			weapon_label.position.y = 0.75
			weapon_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			item.add_child(weapon_label)
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

func _add_ammo_to_class(class_names: Array, amount: int) -> void:
	for weapon_index in range(weapon_classes.size()):
		if weapon_classes[weapon_index] in class_names:
			weapon_reserve_ammo[weapon_index] += amount
			weapon_reserve[weapon_index] = weapon_reserve_ammo[weapon_index]
	if weapon_classes[current_weapon] in class_names:
		reserve_ammo = weapon_reserve_ammo[current_weapon]
	_update_weapon_hud()


func _apply_loot_reward(item_type: String, amount: int) -> void:
	match item_type:
		"ammo_rifle":
			_add_ammo_to_class(["RIFLE", "LMG"], amount)
			status_label.text = "RIFLE / LMG AMMO +" + str(amount)
		"ammo_smg":
			_add_ammo_to_class(["SMG"], amount)
			status_label.text = "SMG AMMO +" + str(amount)
		"ammo_shotgun":
			_add_ammo_to_class(["SHOTGUN"], amount)
			status_label.text = "SHOTGUN AMMO +" + str(amount)
		"ammo_sniper":
			_add_ammo_to_class(["SNIPER"], amount)
			status_label.text = "SNIPER AMMO +" + str(amount)
		"ammo_pistol":
			_add_ammo_to_class(["PISTOL"], amount)
			status_label.text = "PISTOL AMMO +" + str(amount)
		"ammo_launcher":
			_add_ammo_to_class(["LAUNCHER", "GRENADE"], amount)
			status_label.text = "LAUNCHER / GRENADE AMMO +" + str(amount)
		"ammo_bow":
			_add_ammo_to_class(["BOW"], amount)
			status_label.text = "BOW AMMO +" + str(amount)
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
		_:
			if item_type.begins_with("weapon_"):
				var pickup_weapon_index := int(item_type.trim_prefix("weapon_"))
				if pickup_weapon_index >= 0 and pickup_weapon_index < weapon_names.size():
					_equip_weapon(pickup_weapon_index)
					status_label.text = weapon_names[pickup_weapon_index] + " PICKED UP"
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
				var reward_type := str(item.get_meta("loot_type", ""))
				var reward_amount := int(item.get_meta("loot_amount", 0))
				reward_amount = _passive_loot_amount(equipped_passive_skills, reward_type, reward_amount)
				_apply_loot_reward(reward_type, reward_amount)
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
	var player_state: Dictionary = server_player_states[sender]
	var player_passives: Array = player_state.get("passives", [])
	var heal_amount := 65.0 if player_passives.has("FIELD MEDIC") else 50.0
	current_health = minf(100.0, current_health + heal_amount)
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
	var operator_damage_profile := _operator_passive_profile(selected_character)
	var operator_damage_trait := float(operator_damage_profile["damage_taken"]) * (1.0 - _operator_signature_bonus(selected_character, "RESILIENCE") * 0.65)
	var incoming: float = amount * operator_damage_trait
	var absorbed: float = minf(armor, incoming * 0.60)
	armor = maxf(0.0, armor - absorbed)
	var health_damage: float = incoming - absorbed
	health = maxf(0.0, health - health_damage)
	damage_flash_timer = 0.25
	_trigger_character_hit_animation(local_player)
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
			local_player.set_meta("anim_dead", true)
			local_player.visible = true
			var death_visual := local_player.get_node_or_null("CharacterVisual") as Node3D
			if death_visual:
				var death_tween := create_tween()
				death_tween.tween_property(death_visual, "rotation:z", -1.25, 0.42)
				death_tween.parallel().tween_property(death_visual, "position:y", -0.45, 0.42)
				death_tween.tween_callback(func():
					if is_instance_valid(local_player) and is_dead:
						local_player.visible = false
				)
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


func _vehicle_spawn_position(vehicle_id: int) -> Vector3:
	if vehicle_id == 0 and OS.get_environment("LAST_ZONE_VEHICLE_TEST_MODE") == "1":
		return Vector3(0, 0.15, 20)
	return Vector3(-24, 0.15, 0) if vehicle_id == 0 else Vector3(28, 0.15, 0)


func _vehicle_spawn_yaw(vehicle_id: int) -> float:
	return 0.0 if vehicle_id == 0 else PI


func _spawn_vehicles() -> void:
	# Two simple drivable vehicles placed on open roads.
	_create_vehicle(_vehicle_spawn_position(0), _vehicle_spawn_yaw(0), Color(0.10, 0.34, 0.62))
	_create_vehicle(_vehicle_spawn_position(1), _vehicle_spawn_yaw(1), Color(0.66, 0.20, 0.12))

func _reset_vehicle_fleet() -> void:
	if not multiplayer.is_server():
		return
	server_vehicle_drivers.clear()
	server_vehicle_update_time.clear()
	server_vehicle_controls.clear()
	server_vehicle_speeds.clear()
	server_vehicle_last_hit.clear()
	for vehicle_id in range(vehicle_nodes.size()):
		var car := vehicle_nodes[vehicle_id]
		if not is_instance_valid(car):
			continue
		var spawn_position := _vehicle_spawn_position(vehicle_id)
		var spawn_yaw := _vehicle_spawn_yaw(vehicle_id)
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
	if OS.get_environment("LAST_ZONE_VEHICLE_TEST_MODE") == "1":
		var fleet_restored := true
		for vehicle_id in range(vehicle_nodes.size()):
			if vehicle_nodes[vehicle_id].global_position.distance_to(_vehicle_spawn_position(vehicle_id)) > 0.01 or float(server_vehicle_health.get(vehicle_id, 0.0)) != 300.0 or bool(server_vehicle_destroyed.get(vehicle_id, true)) or server_vehicle_drivers.has(vehicle_id):
				fleet_restored = false
		if fleet_restored:
			print("VEHICLE TEST: fleet reset passed")
		else:
			push_error("VEHICLE TEST: fleet reset failed")

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
	if not server_player_states.has(sender) or server_eliminated.has(sender):
		rpc_id(sender, "vehicle_request_denied", "PLAYER NOT ACTIVE")
		return
	if match_finished:
		rpc_id(sender, "vehicle_request_denied", "MATCH ALREADY FINISHED")
		return
	if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size():
		rpc_id(sender, "vehicle_request_denied", "INVALID VEHICLE ID")
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
	var now := Time.get_ticks_msec() / 1000.0
	_set_server_player_transform(sender, exit_pos, car.rotation.y)
	last_server_position[sender] = exit_pos
	server_position_time[sender] = now
	server_position_last_packet_time[sender] = now
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
	var now := Time.get_ticks_msec() / 1000.0
	var previous_input := float(server_vehicle_update_time.get(sender, 0.0))
	if previous_input > 0.0 and now - previous_input < 0.04:
		return
	server_vehicle_controls[vehicle_id] = {"driver": sender, "throttle": clampf(throttle, -0.65, 1.0), "steering": clampf(steering, -1.0, 1.0), "braking": braking}
	server_vehicle_update_time[sender] = now


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
		_set_server_player_transform(driver_id, car.global_position, car.rotation.y)
		_server_check_vehicle_collisions(vehicle_id, driver_id, car, float(server_vehicle_speeds.get(vehicle_id, 0.0)))
	if vehicle_sync_timer >= 0.1:
		vehicle_sync_timer = 0.0
		for vehicle_id in range(vehicle_nodes.size()):
			var car := vehicle_nodes[vehicle_id]
			if is_instance_valid(car) and not bool(server_vehicle_destroyed.get(vehicle_id, false)):
				rpc("vehicle_state_update", vehicle_id, car.global_position, car.rotation.y)


func _server_release_vehicle_driver(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	for vehicle_id_variant in server_vehicle_drivers.keys():
		var vehicle_id := int(vehicle_id_variant)
		if int(server_vehicle_drivers[vehicle_id_variant]) != peer_id:
			continue
		if vehicle_id < 0 or vehicle_id >= vehicle_nodes.size():
			server_vehicle_drivers.erase(vehicle_id_variant)
			server_vehicle_controls.erase(vehicle_id)
			server_vehicle_speeds.erase(vehicle_id)
			continue
		var car := vehicle_nodes[vehicle_id]
		server_vehicle_drivers.erase(vehicle_id_variant)
		server_vehicle_controls.erase(vehicle_id)
		server_vehicle_speeds[vehicle_id] = 0.0
		server_vehicle_update_time.erase(peer_id)
		var exit_pos := car.global_position + car.global_basis.x * 2.2 + Vector3.UP * 0.2
		var now := Time.get_ticks_msec() / 1000.0
		_set_server_player_transform(peer_id, exit_pos, car.rotation.y)
		last_server_position[peer_id] = exit_pos
		server_position_time[peer_id] = now
		server_position_last_packet_time[peer_id] = now
		rpc("vehicle_driver_changed", vehicle_id, peer_id, false, exit_pos, car.rotation.y)
		return


func _server_check_vehicle_collisions(vehicle_id: int, driver_id: int, car: CharacterBody3D, speed: float) -> void:
	if not multiplayer.is_server() or not match_started or match_finished or absf(speed) < 6.0:
		return
	var now := Time.get_ticks_msec() / 1000.0
	for target_variant in server_player_states.keys():
		var target_id := int(target_variant)
		if target_id == driver_id or server_eliminated.has(target_id):
			continue
		if _are_teammates(driver_id, target_id):
			continue
		var target_state: Dictionary = server_player_states[target_id]
		var target_position: Vector3 = target_state.get("position", Vector3.ZERO)
		var horizontal_distance := Vector2(target_position.x - car.global_position.x, target_position.z - car.global_position.z).length()
		if horizontal_distance > 2.7:
			continue
		var cooldown_key := str(vehicle_id) + ":" + str(target_id)
		if now - float(server_vehicle_last_hit.get(cooldown_key, 0.0)) < 1.25:
			continue
		server_vehicle_last_hit[cooldown_key] = now
		var impact_damage := clampf(absf(speed) * 2.0, 15.0, 40.0)
		_server_apply_damage(target_id, impact_damage, "PLAYER " + str(driver_id))


@rpc("authority", "call_remote", "reliable")
func vehicle_driver_changed(vehicle_id: int, driver_id: int, entering: bool, position: Vector3, yaw: float) -> void:
	if OS.get_cmdline_user_args().has("--network-test-client"):
		if driver_id == multiplayer.get_unique_id():
			network_test_vehicle_entered = entering
			network_test_vehicle_exited = not entering
		elif entering and vehicle_id == 0:
			network_test_vehicle_occupied = true
		return
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


@rpc("authority", "call_remote", "reliable")
func vehicle_request_denied(message: String) -> void:
	if OS.get_cmdline_user_args().has("--network-test-client"):
		network_test_vehicle_denial_message = message
		return
	if vehicle_status_label:
		vehicle_status_label.text = message


@rpc("authority", "call_remote", "unreliable")
func vehicle_state_update(vehicle_id: int, pos: Vector3, yaw: float) -> void:
	if OS.get_cmdline_user_args().has("--network-test-client"):
		if vehicle_id == 0 and pos.is_finite() and is_finite(yaw):
			network_test_vehicle_last_position = pos
			network_test_vehicle_state_received = true
		return
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
	if now - previous_shot < _weapon_stat(weapon_index, "fire_rate") * 0.8:
		return
	var shooter_state: Dictionary = server_player_states[shooter_id]
	var shooter_pos: Vector3 = shooter_state["position"]
	var car := vehicle_nodes[vehicle_id]
	var target_pos := car.global_position + Vector3.UP * 0.8
	if shooter_pos.distance_to(target_pos) > _weapon_stat(weapon_index, "range") + 3.0:
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
	var remaining := maxf(0.0, float(server_vehicle_health.get(vehicle_id, 300.0)) - _weapon_stat(weapon_index, "damage") * multiplier)
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
			var now := Time.get_ticks_msec() / 1000.0
			_set_server_player_transform(driver_id, exit_pos, car.rotation.y)
			last_server_position[driver_id] = exit_pos
			server_position_time[driver_id] = now
			server_position_last_packet_time[driver_id] = now
			server_vehicle_update_time.erase(driver_id)
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
