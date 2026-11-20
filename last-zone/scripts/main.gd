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
	if local_player == null:
		return
	var direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward"): direction.z -= 1.0
	if Input.is_action_pressed("move_back"): direction.z += 1.0
	if Input.is_action_pressed("move_left"): direction.x -= 1.0
	if Input.is_action_pressed("move_right"): direction.x += 1.0
	direction = direction.normalized()
	var camera := local_player.get_node_or_null("CameraPivot/Camera3D") as Camera3D
	if camera:
		var forward := -camera.global_basis.z
		var right := camera.global_basis.x
		var move := right * direction.x + forward * -direction.z
		move.y = 0
		move = move.normalized()
		local_player.velocity.x = move.x * 6.0
		local_player.velocity.z = move.z * 6.0
	else:
		local_player.velocity.x = direction.x * 6.0
		local_player.velocity.z = direction.z * 6.0
	if not local_player.is_on_floor():
		local_player.velocity.y -= 22.0 * delta
	else:
		local_player.velocity.y = -0.2
	if Input.is_action_just_pressed("jump") and local_player.is_on_floor():
		local_player.velocity.y = 7.0
	local_player.move_and_slide()

func _setup_input() -> void:
	_add_action("move_forward", KEY_W)
	_add_action("move_back", KEY_S)
	_add_action("move_left", KEY_A)
	_add_action("move_right", KEY_D)
	_add_action("jump", KEY_SPACE)
	_add_action("fire", KEY_F)

func _add_action(action: String, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)

func _build_island() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(MAP_SIZE, MAP_SIZE)
	ground.mesh = plane
	ground.position.y = -0.6
	ground.material_override = _material(Color(0.20, 0.31, 0.17))
	add_child(ground)
	var water := MeshInstance3D.new()
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(650, 650)
	water.mesh = water_mesh
	water.position.y = -1.1
	water.material_override = _material(Color(0.025, 0.19, 0.25))
	add_child(water)
	for i in range(42):
		var x := randf_range(-95, 95)
		var z := randf_range(-95, 95)
		var trunk := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.18
		cylinder.bottom_radius = 0.28
		cylinder.height = 3.2
		trunk.mesh = cylinder
		trunk.position = Vector3(x, 1.0, z)
		trunk.material_override = _material(Color(0.22, 0.13, 0.07))
		add_child(trunk)
		var crown := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 1.55
		sphere.height = 3.0
		crown.mesh = sphere
		crown.position = Vector3(x, 3.0, z)
		crown.material_override = _material(Color(0.08, 0.22 + randf() * 0.12, 0.10))
		add_child(crown)
	for i in range(12):
		var building := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(randf_range(5, 10), randf_range(3, 6), randf_range(5, 9))
		building.mesh = box
		building.position = Vector3(randf_range(-80, 80), box.size.y / 2.0, randf_range(-80, 80))
		building.material_override = _material(Color(0.32, 0.34, 0.31))
		add_child(building)
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
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	collision.shape = capsule
	body.add_child(collision)
	var visual := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.42
	mesh.height = 1.8
	visual.mesh = mesh
	visual.material_override = _material(Color(0.12, 0.25, 0.34) if is_local else Color(0.45, 0.19, 0.12))
	body.add_child(visual)
	if is_local:
		var pivot := Node3D.new()
		pivot.name = "CameraPivot"
		pivot.position = Vector3(0, 1.25, 0)
		body.add_child(pivot)
		var camera := Camera3D.new()
		camera.position = Vector3(0, 2.5, 6.5)
		camera.rotation_degrees = Vector3(-12, 180, 0)
		camera.current = true
		pivot.add_child(camera)
	add_child(body)
	players[peer_id] = body
	return body

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		_fire_weapon()

func _fire_weapon() -> void:
	if local_player == null:
		return
	var camera := local_player.get_node_or_null("CameraPivot/Camera3D") as Camera3D
	if camera == null:
		return
	var from := camera.global_position
	var to := from + -camera.global_basis.z * 100.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [local_player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit and hit.collider is CharacterBody3D:
		status_label.text = "TARGET HIT"


# ------------------------------------------------------------
# FIRST EIGHT FOUNDATION SYSTEMS: splash, menu, loading, settings,
# language selection and a locally saved player profile.
# Online account authentication is intentionally left for backend work.
# ------------------------------------------------------------

func _load_local_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://last_zone.cfg") == OK:
		profile_name = str(cfg.get_value("profile", "name", "Player"))
		selected_language = str(cfg.get_value("settings", "language", "English"))
		master_volume = float(cfg.get_value("settings", "master_volume", 0.8))
		music_volume = float(cfg.get_value("settings", "music_volume", 0.7))
		sfx_volume = float(cfg.get_value("settings", "sfx_volume", 0.8))
		graphics_quality = int(cfg.get_value("settings", "graphics_quality", 1))
	_apply_audio_settings()

func _save_local_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("profile", "name", profile_name)
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
	_show_loading_screen()

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
	status_label.text = "READY  •  " + profile_name + "  •  Connect to a Last Zone server"
