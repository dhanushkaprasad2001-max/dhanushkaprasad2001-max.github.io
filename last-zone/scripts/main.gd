extends Node3D
const PORT := 27015
const MAX_PLAYERS := 50
const MAP_SIZE := 220.0
var local_player: CharacterBody3D
var players: Dictionary = {}
var hud: CanvasLayer
var status_label: Label
var address_input: LineEdit
var match_started := false
var safe_radius := 95.0
var safe_timer := 0.0
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
var target_players := 50
var custom_room_code := ""
var party_members: Array[String] = []
var friend_names: Array[String] = []
var player_level := 1
var player_xp := 0
var player_id := ""
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

func _ready() -> void:
	if "--server" in OS.get_cmdline_user_args():
		_build_island()
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
	if is_dead:
		respawn_timer -= delta
		if status_label:
			status_label.text = "ELIMINATED  •  RESPAWNING IN " + str(maxi(0, ceili(respawn_timer)))
		if respawn_timer <= 0.0:
			_respawn_player()
	_update_survival(delta)
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
			rpc_id(1, "server_update_position", local_player.global_position, local_player.rotation.y)
	if multiplayer.is_server() and match_started:
		safe_timer += delta
		if safe_timer >= 12.0:
			safe_timer = 0.0
			safe_radius = maxf(12.0, safe_radius - 4.0)
			rpc("update_safe_zone", safe_radius)

func _physics_process(delta: float) -> void:
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
	var speed := normal_speed
	if crouch_enabled:
		speed = crouch_speed
	elif sprint_enabled:
		speed = sprint_speed
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
	var uniform_color := Color(0.12, 0.34, 0.48) if is_local else Color(0.48, 0.20, 0.12)
	_add_character_part(character, "Torso", Vector3(0, 1.12, 0), Vector3(0.72, 0.82, 0.38), uniform_color)
	_add_character_part(character, "Vest", Vector3(0, 1.18, -0.015), Vector3(0.76, 0.48, 0.40), Color(0.16, 0.19, 0.18))
	_add_character_part(character, "Head", Vector3(0, 1.82, 0), Vector3(0.42, 0.48, 0.42), Color(0.72, 0.53, 0.39), true)
	_add_character_part(character, "Helmet", Vector3(0, 2.03, 0), Vector3(0.50, 0.22, 0.48), Color(0.18, 0.25, 0.19), true)
	_add_character_part(character, "LeftArm", Vector3(-0.48, 1.18, -0.02), Vector3(0.22, 0.72, 0.24), uniform_color, true)
	_add_character_part(character, "RightArm", Vector3(0.48, 1.18, -0.02), Vector3(0.22, 0.72, 0.24), uniform_color, true)
	_add_character_part(character, "LeftLeg", Vector3(-0.20, 0.48, 0), Vector3(0.27, 0.78, 0.30), Color(0.12, 0.14, 0.16))
	_add_character_part(character, "RightLeg", Vector3(0.20, 0.48, 0), Vector3(0.27, 0.78, 0.30), Color(0.12, 0.14, 0.16))
	_add_character_part(character, "LeftBoot", Vector3(-0.20, 0.12, -0.07), Vector3(0.30, 0.20, 0.42), Color(0.07, 0.08, 0.07))
	_add_character_part(character, "RightBoot", Vector3(0.20, 0.12, -0.07), Vector3(0.30, 0.20, 0.42), Color(0.07, 0.08, 0.07))
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
	var row := HBoxContainer.new()
	column.add_child(row)
	address_input = LineEdit.new()
	address_input.placeholder_text = "Server IP address"
	address_input.text = "127.0.0.1"
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
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address_input.text.strip_edges(), PORT)
	if error != OK:
		status_label.text = "Could not start connection: " + str(error)
		return
	multiplayer.multiplayer_peer = peer
	status_label.text = "Connecting to " + address_input.text + "..."

func _start_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		push_error("Server failed to start: " + str(error))
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_server_peer_connected)
	multiplayer.peer_disconnected.connect(_server_peer_disconnected)
	print("LAST ZONE dedicated server listening on UDP ", PORT)

func _on_connected() -> void:
	status_label.text = "ONLINE  •  Connected to server"
	rpc_id(1, "request_spawn")

func _on_connection_failed() -> void:
	status_label.text = "Connection failed. Check server IP and UDP port 27015."

func _on_server_disconnected() -> void:
	status_label.text = "Disconnected from server"

func _on_peer_connected(id: int) -> void:
	status_label.text = "Player connected: " + str(id)

func _on_peer_disconnected(id: int) -> void:
	if players.has(id):
		players[id].queue_free()
		players.erase(id)

func _server_peer_connected(id: int) -> void:
	print("Player joined: ", id)
	match_started = true

func _server_peer_disconnected(id: int) -> void:
	print("Player left: ", id)

@rpc("any_peer", "call_remote", "reliable")
func request_spawn() -> void:
	if not multiplayer.is_server():
		return
	var id := multiplayer.get_remote_sender_id()
	rpc("spawn_remote_player", id)
	rpc_id(id, "spawn_remote_player", 1)

@rpc("authority", "call_remote", "reliable")
func spawn_remote_player(id: int) -> void:
	if players.has(id):
		return
	_create_player(id, false)

@rpc("any_peer", "call_remote", "unreliable")
func server_update_position(pos: Vector3, yaw: float) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	rpc("client_update_position", sender, pos, yaw)

@rpc("authority", "call_remote", "unreliable")
func client_update_position(id: int, pos: Vector3, yaw: float) -> void:
	if players.has(id):
		players[id].global_position = pos
		players[id].rotation.y = yaw

@rpc("authority", "call_remote", "reliable")
func update_safe_zone(radius: float) -> void:
	safe_radius = radius
	if status_label:
		status_label.text = "SAFE ZONE RADIUS: " + str(roundi(radius)) + "m"

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
	var spread: float = float(weapon_spread[current_weapon])
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
			if status_label:
				status_label.text = "HIT: " + target.name + "  (" + str(roundi(weapon_damage[current_weapon])) + " DMG)"
			if target.has_method("apply_damage"):
				target.apply_damage(weapon_damage[current_weapon])
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
	reload_timer = 1.8 if current_weapon != 2 else 2.4
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
		selected_mode = str(cfg.get_value("profile", "mode", "Solo"))
		match_type = str(cfg.get_value("profile", "match_type", "Battle Royale"))
		target_players = clampi(int(cfg.get_value("profile", "target_players", 50)), 2, MAX_PLAYERS)
		custom_room_code = str(cfg.get_value("profile", "custom_room_code", ""))
		var saved_friends: Variant = cfg.get_value("profile", "friends", [])
		for friend in saved_friends:
			friend_names.append(str(friend))
		selected_language = str(cfg.get_value("settings", "language", "English"))
		master_volume = float(cfg.get_value("settings", "master_volume", 0.8))
		music_volume = float(cfg.get_value("settings", "music_volume", 0.7))
		sfx_volume = float(cfg.get_value("settings", "sfx_volume", 0.8))
		graphics_quality = int(cfg.get_value("settings", "graphics_quality", 1))
	if player_id.is_empty():
		player_id = "LZ-" + str(abs(hash(profile_name + str(Time.get_unix_time_from_system())))).pad_zeros(8)
	_save_local_settings()
	_apply_audio_settings()

func _save_local_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("profile", "name", profile_name)
	cfg.set_value("profile", "player_id", player_id)
	cfg.set_value("profile", "level", player_level)
	cfg.set_value("profile", "xp", player_xp)
	cfg.set_value("profile", "mode", selected_mode)
	cfg.set_value("profile", "match_type", match_type)
	cfg.set_value("profile", "target_players", target_players)
	cfg.set_value("profile", "custom_room_code", custom_room_code)
	cfg.set_value("profile", "friends", friend_names)
	cfg.set_value("settings", "language", selected_language)
	cfg.set_value("settings", "master_volume", master_volume)
	cfg.set_value("settings", "music_volume", music_volume)
	cfg.set_value("settings", "sfx_volume", sfx_volume)
	cfg.set_value("settings", "graphics_quality", graphics_quality)
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
	level_label.text = "LEVEL " + str(player_level) + "     XP " + str(player_xp % 100) + " / 100"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(level_label)

	var xp_bar := ProgressBar.new()
	xp_bar.max_value = 100
	xp_bar.value = player_xp % 100
	xp_bar.custom_minimum_size.y = 14
	panel.add_child(xp_bar)

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
	match_type_title.text = "MATCH TYPE"
	match_type_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(match_type_title)

	var match_types := OptionButton.new()
	for match_name in ["Battle Royale", "Training Ground", "Custom Match"]:
		match_types.add_item(match_name)
	match_types.select(maxi(0, ["Battle Royale", "Training Ground", "Custom Match"].find(match_type)))
	match_types.item_selected.connect(func(index: int):
		match_type = ["Battle Royale", "Training Ground", "Custom Match"][index]
		_save_local_settings()
		_show_lobby_screen()
	)
	panel.add_child(match_types)

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

func _on_start_selected_match() -> void:
	if match_type == "Custom Match":
		_show_custom_match_notice()
		return
	_show_loading_screen()


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
	_start_air_drop()
	if match_type == "Training Ground":
		status_label.text = "TRAINING GROUND  •  Practice mode • No online opponents"
	else:
		status_label.text = "BATTLE ROYALE  •  " + selected_mode + "  •  Target " + str(target_players) + " players • Connect to server"

# STAGES 69-78: local loot and inventory prototype
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
	var item_type := str(nearby_loot.get_meta("loot_type", ""))
	var amount := int(nearby_loot.get_meta("loot_amount", 0))
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
	loot_nodes.erase(nearby_loot)
	nearby_loot.queue_free()
	nearby_loot = null
	_update_weapon_hud()
	_update_nearby_loot()

func _use_medkit() -> void:
	if is_dead:
		return
	if medkit_count <= 0:
		if status_label: status_label.text = "NO MEDKITS"
		return
	if health >= 100.0:
		if status_label: status_label.text = "HEALTH IS ALREADY FULL"
		return
	medkit_count -= 1
	health = minf(100.0, health + 50.0)
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
	respawn_timer = 8.0
	if local_player:
		local_player.velocity = Vector3.ZERO
		local_player.visible = false
	if status_label:
		status_label.text = "ELIMINATED  •  RESPAWNING IN 8"
	if pickup_button:
		pickup_button.disabled = true

func _respawn_player() -> void:
	is_dead = false
	respawn_timer = 0.0
	health = 100.0
	armor = 0.0
	zone_damage_timer = 0.0
	if local_player:
		local_player.global_position = Vector3(0, 2, 0)
		local_player.velocity = Vector3.ZERO
		local_player.visible = true
	if status_label:
		status_label.modulate = Color.WHITE
		status_label.text = "RESPAWNED  •  FULL HEALTH"
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
