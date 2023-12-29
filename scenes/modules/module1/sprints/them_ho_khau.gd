extends VBoxContainer

const tableName = "HoKhau"
const query_select_all = "select * from " + tableName + ";"

@onready var vtable = $Table/HBoxContainer/DanhSachHoKhau/Table/Table/VTable
@onready var fields = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/TruongThongTin
@onready var form_insert = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinHoKhau
@onready var form_edit = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinHoKhau
@onready var popup = $Popup/PopupMenu
@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var accept_fake = $Popup/AcceptDialog2
@onready var file = $Popup/FileDialog

func _ready():
	reset_filters()
	window_hide()
	reset_form(form_edit)
	reset_form(form_insert)
	readDataFromDB(query_select_all)

func _process(_delta):
	if current_pk == null:
		sua_button.disabled = true
	else:
		sua_button.disabled = false
	luu_button.visible = sua_button.button_pressed
	luu_button.disabled = not sua_button.button_pressed
	for f in form_edit.get_children():
		if "Buffer" not in f.name:
			if f.name == "NgaySinh":
				for o in f.get_children():
					o.disabled = not sua_button.button_pressed
#					o.flat = not sua_button.button_pressed
			elif f.name == "MaChuHo":
				sua_chon_ma_chu_ho.disabled = not sua_button.button_pressed
				sua_ma_chu_ho.editable = sua_button.button_pressed
			else:
				f.editable = sua_button.button_pressed
#				f.flat = not sua_button.button_pressed

var row_inst = preload("res://scenes/global_elements/elements/row.tscn")
var cell_inst = preload("res://scenes/global_elements/elements/cell.tscn")
var cell_menu = preload("res://scenes/global_elements/elements/cell_menu.tscn")
func readDataFromDB(_query: String):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	var row 
	db.query("PRAGMA table_info(" + tableName + ");")
	for r in db.query_result:
		if vtable.has_node(r["name"]) == false:
			row = row_inst.instantiate()
			vtable.add_child(row)
			row.name = r["name"]
		else:
			for child in vtable.get_node(r["name"]).get_children():
				child.queue_free()
		row = cell_menu.instantiate()
		vtable.get_node(r["name"]).add_child(row)
		row.text = r["name"]
		row.input.text = current_filters[r["name"]]
		row.filter_submitted.connect(_on_filter_submitted)
		row.column_sorted.connect(_on_column_sorted)
		
	db.query(_query)
	var result = db.query_result
#	print(result)
	
	for c in vtable.get_children():
		for i in range(0, result.size()):
			var cell = cell_inst.instantiate()
			c.add_child(cell)
			cell.text = str(result[i][c.name])
			cell.table = tableName
			cell.field = c.name
			cell.id = i + 1
			cell.cell_pressed.connect(_on_cell_pressed)
	
	Effect.set_chon_nhan_khau(them_chon_ma_chu_ho, "chủ hộ")
	Effect.set_chon_nhan_khau(sua_chon_ma_chu_ho, "chủ hộ")

@onready var them_chon_ma_chu_ho = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinHoKhau/MaChuHo/ThemChonMaChuHo
@onready var sua_chon_ma_chu_ho = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinHoKhau/MaChuHo/SuaChonMaChuHo
@onready var them_ma_chu_ho = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinHoKhau/MaChuHo/ThemMaChuHo
@onready var sua_ma_chu_ho = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinHoKhau/MaChuHo/SuaMaChuHo
func _on_them_ma_chu_ho_text_changed(new_text: String):
	if Effect.check_ma_nhan_khau(new_text) == false:
		them_chon_ma_chu_ho.select(0)
	else:
		for i in them_chon_ma_chu_ho.item_count:
			if new_text.to_int() == them_chon_ma_chu_ho.get_item_id(i):
				them_chon_ma_chu_ho.select(i)
func _on_sua_ma_chu_ho_text_changed(new_text: String):
	if Effect.check_ma_nhan_khau(new_text) == false:
		sua_chon_ma_chu_ho.select(0)
	else:
		for i in sua_chon_ma_chu_ho.item_count:
			if new_text.to_int() == sua_chon_ma_chu_ho.get_item_id(i):
				sua_chon_ma_chu_ho.select(i)
func _on_them_chon_ma_chu_ho_item_selected(_index: int):
	them_ma_chu_ho.text = str(them_chon_ma_chu_ho.get_selected_id())
func _on_sua_chon_ma_chu_ho_item_selected(_index: int):
	sua_ma_chu_ho.text = str(sua_chon_ma_chu_ho.get_selected_id())
		
var current_form
var current_info
func _on_form_filled_in(form):
	current_form = form
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	var valid = true
	var info : Dictionary = Dictionary()
	var result
	db.query("PRAGMA table_info(" + tableName + ");")
	result = db.query_result
	for f in result:
		if f["name"] != "Ma" + tableName:
			if f["name"] == "MaChuHo":
				if current_form == form_insert:
					info[f["name"]] = them_ma_chu_ho.text
				elif current_form == form_edit:
					info[f["name"]] = sua_ma_chu_ho.text
				if info[f["name"]] == "":
					info[f["name"]] = null
					valid = false
					popup.add_item("Chưa điền thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + '!')
				else:
					if Effect.check_ma_nhan_khau(info[f["name"]]) == false:
						valid = false
						popup.add_item("Mã nhân khẩu này không tồn tại!")
					elif current_form == form_insert:
						db.query("select * from " + tableName + " where MaChuHo = " + str(info[f["name"]]) + ";")
						if db.query_result.size() != 0:
							valid = false
							popup.add_item("Mã nhân khẩu này đã là chủ hộ của hộ khẩu khác!")
			else:
				info[f["name"]] = form.get_node(f["name"]).text
				if info[f["name"]] == "":
					info[f["name"]] = null
				if "*" in fields.get_node(f["name"]).text:
					if info[f["name"]] == null:
						valid = false
						popup.add_item("Chưa điền thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + '!')
	release_focus_form(form)
	if valid == true:
		current_info = info
		if current_form == form_insert:
			confirm.dialog_text = "Thêm thông tin hộ khẩu này?"
		elif current_form == form_edit:
			confirm.dialog_text = "Sửa thông tin hộ khẩu này?"
		confirm.show()
	else:
		popup.show()

func reset_form(form):
	for f in form.get_children():
		if f.name != "MaChuHo" and f.name != "NgaySinh":
			if "Buffer" not in f.name:
				f.text = ""
func release_focus_form(form):
	for f in form.get_children():
		if f.name != "MaChuHo" and f.name != "NgaySinh":
			if "Buffer" not in f.name:
				f.release_focus()

func window_hide():
	popup.clear()
	popup.hide()
	accept.hide()
	confirm.hide()
	file.clear_filters()
	file.add_filter("*.xlsx; Excel Files")
	file.hide()

@onready var submenu_table = $Table/HBoxContainer2/SubmenuTable
@onready var box_form = $VBoxContainer
@onready var table_buttons = $Table/HBoxContainer2/TableButtons
const icon_submenu = preload("res://assets/sprites/ui/buttons/submenu.png")
const icon_submenu_mirrored = preload("res://assets/sprites/ui/buttons/submenu_mirrored.png")
const icon_submenu_normal = preload("res://assets/sprites/ui/buttons/submenu_normal.png")
var direction_submenu = false
func _on_submenu_table_pressed():
	var tween = create_tween()
	if submenu_table.icon == icon_submenu:
		box_form.visible = true
		submenu_table.icon = icon_submenu_normal
		tween.tween_property(
			$Table,
			"size_flags_stretch_ratio",
			1,
			0.5,
		).from_current(	
			).set_ease(
			Tween.EASE_IN_OUT
		).set_trans(
			Tween.TRANS_LINEAR
		)
		vtable.visible = true
		table_buttons.visible = true
		submenu_table.size_flags_stretch_ratio = 0
		await  tween.finished
	elif submenu_table.icon == icon_submenu_normal:
		direction_submenu = not direction_submenu
		if direction_submenu == true:
			submenu_table.icon = icon_submenu_mirrored
			vtable.visible = true
			table_buttons.visible = true
			tween.tween_property(
				$Table,
				"size_flags_stretch_ratio",
				20,
				0.5,
			).from_current(	
				).set_ease(
				Tween.EASE_IN_OUT
			).set_trans(
				Tween.TRANS_LINEAR
			)
			await  tween.finished
			submenu_table.size_flags_stretch_ratio = 0
			box_form.visible = false
		else:
			submenu_table.icon = icon_submenu
			tween.tween_property(
				$Table,
				"size_flags_stretch_ratio",
				0,
				0.5,
			).from_current(	
				).set_ease(
				Tween.EASE_IN_OUT
			).set_trans(
				Tween.TRANS_LINEAR
			)
			await  tween.finished
			vtable.visible = false
			table_buttons.visible = false
			submenu_table.size_flags_stretch_ratio = 20
	elif submenu_table.icon == icon_submenu_mirrored:
		box_form.visible = true
		submenu_table.icon = icon_submenu_normal
		tween.tween_property(
			$Table,
			"size_flags_stretch_ratio",
			1,
			0.5,
		).from_current(	
			).set_ease(
			Tween.EASE_IN_OUT
		).set_trans(
			Tween.TRANS_LINEAR
		)
		await  tween.finished
		vtable.visible = true
		table_buttons.visible = true
		submenu_table.size_flags_stretch_ratio = 00

func _on_lam_moi_button_pressed():
	readDataFromDB(query_select_all)

const theme_normal = preload("res://assets/resources/themes/theme_cell.tres")
const theme_select = preload("res://assets/resources/themes/theme_cell_selected.tres")
var current_pk = null
func _on_cell_pressed(cell):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	for c in vtable.get_children():
		for i in c.get_children():
			if i.has_node("Button"):
				i.theme = theme_normal
		if c.get_child(cell.id).theme == theme_normal:
			c.get_child(cell.id).set_deferred("theme", theme_select)
		else:
			c.get_child(cell.id).set_deferred("theme", theme_normal)
		if c.name == "Ma" + tableName:
			var pk = c.get_child(cell.id).text
			current_pk = pk
			var query = "select * from " + tableName + " where Ma" + tableName + " = " + pk + ';'
			db.query(query)
			var result = db.query_result
			for f in form_edit.get_children():
				if "Buffer" not in f.name:
					if f.name == "MaChuHo":
						f.get_node("SuaMaChuHo").text = str(result[0][f.name])
						_on_sua_ma_chu_ho_text_changed(str(result[0][f.name]))
					elif result[0][f.name] == null:
						f.text = ""
					else:
						f.text = str(result[0][f.name])

var current_filters = {}
func reset_filters():
	current_filters = {}
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query("PRAGMA table_info(" + tableName + ");")
	for i in db.query_result:
		current_filters[i["name"]] = ""
func _on_filter_submitted():
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	db.query("PRAGMA table_info(" + tableName + ");")
	
	var query = "select * from " + tableName + " where "

	var count_filter = 0
	for c in vtable.get_children():
		var f = c.get_child(0)
		if f.filter.replace(" ", "").to_lower() != "":
			count_filter = count_filter + 1
	reset_filters()
	if count_filter == 0:
		readDataFromDB(query_select_all)
		return
	
	for c in vtable.get_children():
		var f = c.get_child(0)
		if f.filter.replace(" ", "").to_lower() != "":
			current_filters[f.text] = f.filter
			var filter = f.filter.to_lower()
			var query_filter = ""
			query_filter = "lower(" + f.text + ") like lower(\'%" + filter + "%\')" 
			count_filter = count_filter - 1
			if count_filter > 0:
				query_filter = query_filter + " and "
			else:
				query_filter = query_filter + "; "
			query = query + query_filter
	print(query)
	db.query(query)
	print(db.query_result)
	readDataFromDB(query)

func _on_column_sorted(order: String):
	readDataFromDB("select * from " + tableName + order)

@onready var them_button = $VBoxContainer/HBoxContainer/PanelContainer/ThemButton
@onready var sua_button = $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/SuaButton
@onready var luu_button = $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/LuuButton
func _on_them_button_pressed():
	window_hide()
	_on_form_filled_in(form_insert)
	
func _on_sua_button_toggled(_button_pressed: bool):
	if _button_pressed == true:
		sua_button.button_pressed = true
	else:
		sua_button.button_pressed = false

func _on_luu_button_pressed():
	window_hide()
	_on_form_filled_in(form_edit)

func _on_xoa_button_pressed():
	if current_pk != null:
		confirm.dialog_text = "Xóa thông tin hộ khẩu này?\nThông tin đã xóa sẽ không thể truy hồi lại!"
		confirm.show()
		current_form = form_edit
	else:
		accept.dialog_text = "Không có thông tin hộ khẩu nào được chọn!"
		accept.show()

func _on_xoa_het_button_pressed():
	confirm.dialog_text = "Xóa hết thông tin hộ khẩu?\nThông tin đã xóa sẽ không thể truy hồi lại!"
	confirm.show()
	current_form = form_edit

func _on_mo_tep_button_pressed():
	file.show()

@onready var file_path = $Table/HBoxContainer2/TableButtons/HBoxContainer2/DuongDanTep
func _on_file_dialog_file_selected(path):
	file_path.text = path

func _on_tai_len_button_pressed():
	if file_path.text != "":
		if FileAccess.file_exists(file_path.text.replace(" ", "")):
			if file_path.text.get_extension() == "xlsx":
				if Effect.check_field_names(tableName, file_path.text) == true:
					current_form = form_edit
					confirm.dialog_text = "Tải dữ liệu từ tệp lên hệ thống?"
					confirm.show()
				else:
					accept.dialog_text = "Không thể đọc dữ liệu!\nVui lòng kiểm tra lại các trường thông tin!"
					accept.show()
			else:
				accept.dialog_text = "Không thể tải dữ liệu!\nTệp được chọn không phải tệp excel (.xlsx)!"
				accept.show()
		else:
			accept.dialog_text = "Đường dẫn tệp không tồn tại!"
			accept.show()
	else:
		accept.dialog_text = "Chưa chọn tệp excel nào!"
		accept.show()

func _on_confirmation_dialog_confirmed():
	if current_form == form_insert:
		Effect.insert(tableName, current_info, accept)
		await get_tree().create_timer(1.0).timeout
		var db = SQLite.new()
		db.path = DB.db_name
		db.open_db()
		db.query("select * from NhanKhau where MaNhanKhau = " + current_info["MaChuHo"] + ";")
		var info = db.query_result[0]
		db.query("select * from HoKhau where MaChuHo = " + current_info["MaChuHo"] + ";")
		info["MaHoKhau"] = str(db.query_result[0]["MaHoKhau"])
		info["QuanHeVoiChuHo"] = "Chủ hộ"
		Effect.edit("NhanKhau", current_info["MaChuHo"], info, accept_fake)
	elif current_form == form_edit:
		if confirm.dialog_text == "Xóa thông tin hộ khẩu này?\nThông tin đã xóa sẽ không thể truy hồi lại!":
			Effect.delete(tableName, current_pk, accept)
		if confirm.dialog_text == "Xóa hết thông tin hộ khẩu?\nThông tin đã xóa sẽ không thể truy hồi lại!":
			Effect.delete_all(tableName, accept)
		if confirm.dialog_text == "Sửa thông tin hộ khẩu này?":
			Effect.edit(tableName, current_pk, current_info, accept)
			sua_button.button_pressed = false
		if confirm.dialog_text == "Tải dữ liệu từ tệp lên hệ thống?":
			Effect._import_data_from_excel_file(tableName, file_path.text, self, accept)
		accept.show()
		current_pk = null
	reset_form(current_form)
	readDataFromDB(query_select_all)


















	

