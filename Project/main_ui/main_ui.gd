extends MarginContainer


const CONFIG_PATH: String = "user://config.cfg"
const RasterToSVG: Script = preload("res://raster_to_svg/raster_to_svg.gd")
const SourceImages: Script = preload("res://main_ui/source_images/source_images.gd")
const SaveControls: Script = preload("res://main_ui/save_controls/save_controls.gd")
const LogViewer: Script = preload("res://main_ui/log_viewer/log_viewer.gd")

export(NodePath) var source_images_ui: NodePath
export(NodePath) var save_ui: NodePath
export(NodePath) var log_viewer: NodePath

var _conversion_thread: Thread = Thread.new()
var _conversion_done: bool = false
var _config_file: ConfigFile = ConfigFile.new()

onready var _source_images_ui: SourceImages = get_node(source_images_ui) as SourceImages
onready var _save_ui: SaveControls = get_node(save_ui) as SaveControls
onready var _log_viewer: LogViewer = get_node(log_viewer) as LogViewer


func _ready() -> void:
	var min_width: int = ProjectSettings.get_setting("display/window/size/min_width")
	var min_height: int = ProjectSettings.get_setting("display/window/size/min_height")
	var default_width: int = ProjectSettings.get_setting("display/window/size/width")
	var default_height: int = ProjectSettings.get_setting("display/window/size/height")

	OS.min_window_size = Vector2(min_width, min_height)

	var err: int = _config_file.load(CONFIG_PATH)
	if err:
		Log.error("Could not load the config file; encountered error: %s" % Log.get_error_description(err))

	OS.window_position = _config_file.get_value("window", "position", OS.window_position)
	OS.window_size = _config_file.get_value("window", "size", Vector2(default_width, default_height))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		_config_file.set_value("window", "position", OS.window_position)
		_config_file.set_value("window", "size", OS.window_size)
		_save_config_file()


func view_log(show: bool) -> void:
	if show:
		_log_viewer.show_log()
		_source_images_ui.visible = false
	else:
		_log_viewer.close_log()
		_source_images_ui.visible = true


func _thread_finished() -> void:
	_conversion_done = true


func _save_config_file() -> void:
	var err: int = _config_file.save(CONFIG_PATH)
	if err:
		Log.error("Could not save the config file to '%s'; encountered error: %s" \
				% [CONFIG_PATH, Log.get_error_description(err)])


func _on_SaveControls_convert_files() -> void:
	if _conversion_thread.is_active():
		return

	var files_to_convert: Array = _source_images_ui.get_files()

	_source_images_ui.busy(true)

	for file in files_to_convert:
		var output_path: String = _save_ui.get_output_path(file)
		var source_image: Image = Image.new()

		var err: int = source_image.load(file)
		if err:
			_log_viewer.log_error("%s: Could not load %s" % [Log.get_error_description(err), file])

			view_log(true)
			continue

		var raster_to_svg: RasterToSVG = RasterToSVG.new()
		var args: Array = [source_image,
				_source_images_ui.scan_mode(),
				_source_images_ui.unit_of_measurement(),
				_source_images_ui.output_scale(),
				_source_images_ui.overdraw_amount(),
				self, "_thread_finished"]
		err = _conversion_thread.start(raster_to_svg, "convert_image_threaded", args)
		if err:
			_log_viewer.log_error("CRITICAL ERROR: Could not spool up new work thread.")
			view_log(true)
			continue

		while !_conversion_done:
			yield(get_tree(), "idle_frame")

		var svg_output: String = _conversion_thread.wait_to_finish()
		_conversion_done = false

		var output_file: File = File.new()
		err = output_file.open(output_path, File.WRITE)
		if err:
			_log_viewer.log_error("%s: Could not create %s" % [Log.get_error_description(err), output_path])

			view_log(true)
			continue

		output_file.store_string(svg_output)
		output_file.close()

		_log_viewer.log_msg("Successfully converted: %s" % file)

	_source_images_ui.busy(false)
	view_log(true)


func _on_SaveControls_view_log() -> void:
	view_log(true)


func _on_Log_log_will_close() -> void:
	view_log(false)

