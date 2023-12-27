extends VBoxContainer

const tableName = "NguoiDung"
const query_select_all = "select * from " + tableName + ";"

@onready var vtable = $Table/HBoxContainer/DanhSachNguoiDung/Table/Table/VTable
@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var popup = $Popup/PopupMenu
@onready var file = $Popup/FileDialog
@onready var duong_dan_tep = $Table/HBoxContainer2/HBoxContainer2/DuongDanTep

func _ready():
	reset_filters()
	set_buttons_for_role()
	readDataFromDB(query_select_all)

var row_inst = preload("res://scenes/global_elements/elements/row.tscn")
var cell_inst = preload("res://scenes/global_elements/elements/cell.tscn")
var cell_menu = preload("res://scenes/global_elements/elements/cell_menu.tscn")
func readDataFromDB(query):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	var row 
	db.query("PRAGMA table_info(" + tableName + ");")
	for r in db.query_result:
		if r["name"] != "NhoTaiKhoan":
			if (r["name"] == "TenDangNhap" or r["name"] == "MatKhau" or r["name"] == "ChucVu") and DB.current_user["ChucVu"] == 2:
				continue
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
	
	db.query(query)
	var result = db.query_result
	
	for c in vtable.get_children():
		for i in range(0, result.size()):
			var cell = cell_inst.instantiate()
			c.add_child(cell)
			if c.name == "GioiTinh":
				if str(result[i][c.name]) == "1":
					cell.text = "Nữ"
				else:
					cell.text = "Nam"
			else:
				cell.text = str(result[i][c.name])
			cell.table = tableName
			cell.field = c.name
			cell.id = i + 1
			cell.cell_pressed.connect(_on_cell_pressed)

const theme_normal = preload("res://assets/resources/themes/theme_cell.tres")
const theme_select = preload("res://assets/resources/themes/theme_cell_selected.tres")
var current_pk
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
			DB.current_selected_pk = pk
	_on_doi_chuc_vu_opened()

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
			if f.text == "GioiTinh":
				query_filter = f.text + " = "
				if "na" in filter:
					query_filter = query_filter + "\'0\'"
				elif "nữ" in filter or "nu" in filter:
					query_filter = query_filter + "\'1\'"
			else:
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

@onready var xoa_button = $Table/HBoxContainer2/HBoxContainer/XoaButton
@onready var xoahet_button = $Table/HBoxContainer2/HBoxContainer/XoaHetButton
func set_buttons_for_role():
	if DB.current_user["ChucVu"] == 0:
		xoa_button.disabled = false
		xoahet_button.disabled = false
	if DB.current_user["ChucVu"] == 1:
		xoa_button.disabled = false
		xoahet_button.disabled = false
	if DB.current_user["ChucVu"] == 2:
		xoa_button.disabled = true
		xoahet_button.disabled = true

func _on_doi_chuc_vu_opened():
	if str(DB.current_user["ChucVu"]) == "0" and str(DB.current_user["MaNguoiDung"]) != str(DB.current_selected_pk):
		$Popup/DoiChucVu.visible = true
		var tween = create_tween()
		tween.tween_property(
			$Popup/DoiChucVu,
			"modulate",
			Color(1, 1, 1, 1),
			0.5,
		).from_current(	
			).set_ease(
			Tween.EASE_IN_OUT
		).set_trans(
			Tween.TRANS_LINEAR
		)
		tween.tween_property(
			$Popup/DoiChucVu,
			"position",
			Vector2(448, 128),
			0.5,
		).from_current(	
			).set_ease(
			Tween.EASE_IN_OUT
		).set_trans(
			Tween.TRANS_LINEAR
		)

func _on_doi_chuc_vu_closed():
	var tween = create_tween()
	tween.tween_property(
		$Popup/DoiChucVu,
		"position",
		Vector2(448, 0),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)
	tween.tween_property(
		$Popup/DoiChucVu,
		"modulate",
		Color(1, 1, 1, 0),
		0.5,
	).from_current(	
		).set_ease(
		Tween.EASE_IN_OUT
	).set_trans(
		Tween.TRANS_LINEAR
	)
	await tween.finished
	$Popup/DoiChucVu.visible = false
	_on_lam_moi_button_pressed()

func window_hide():
	popup.clear()
	popup.hide()
	accept.hide()
	confirm.hide()
	file.clear_filters()
	file.add_filter("*.xlsx; Excel Files")
	file.hide()

func _on_mo_tep_button_pressed():
	file.show()

func _on_file_dialog_file_selected(path):
	duong_dan_tep.text = "   " + path

func _on_tai_ve_button_pressed():
	if duong_dan_tep.text.replace(" ", "") == "":
		accept.dialog_text = "Chưa có đường dẫn tệp!"
		accept.show()
	else:
		confirm.dialog_text = "Lưu thông tin người dùng về máy?"
		confirm.show()

func _on_xoa_button_pressed():
	if current_pk != null:
		confirm.dialog_text = "Xóa thông tin người dùng này?\nThông tin đã xóa sẽ không thể truy hồi lại!"
		confirm.show()
	else:
		accept.dialog_text = "Không có thông tin người dùng nào được chọn!"
		accept.show()

func _on_xoa_het_button_pressed():
	confirm.dialog_text = "Xóa hết thông tin người dùng?\nThông tin đã xóa sẽ không thể truy hồi lại!"
	confirm.show()

func _on_confirmation_dialog_confirmed():
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	if confirm.dialog_text == "Xóa thông tin người dùng này?\nThông tin đã xóa sẽ không thể truy hồi lại!":
		if str(current_pk) == str(DB.current_user["Ma" + tableName]):
			accept.dialog_text = "Không thể xóa tài khoản đang đăng nhập!"
			accept.show()
		else:
			db.query("delete from " + tableName + " where Ma" +tableName + " = " + current_pk + " and ChucVu <> 0;")
	if confirm.dialog_text == "Xóa hết thông tin người dùng?\nThông tin đã xóa sẽ không thể truy hồi lại!":
		db.query("delete from " + tableName + " where ChucVu <> 0;")
	if confirm.dialog_text == "Lưu thông tin người dùng về máy?":
		_save_data_to_excel_file(duong_dan_tep.text.replace(" ", ""))
	readDataFromDB(query_select_all)

func _on_lam_moi_button_pressed():
	readDataFromDB(query_select_all)

func _save_data_to_excel_file(path):
	if (FileAccess.file_exists(path) and !FileAccess.open(path, FileAccess.READ_WRITE)) or (!FileAccess.file_exists(path) and !FileAccess.open(path, FileAccess.WRITE)):
		print("can't open file")
		print(FileAccess.file_exists(path))
		return
	var new_file
	var data
	if FileAccess.file_exists(path):
		new_file = FileAccess.open(path, FileAccess.READ_WRITE)
	else:
		new_file = FileAccess.open(path, FileAccess.WRITE)
	data = ""
	# Write some data to the file
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	if DB.current_user["ChucVu"] == 0:
		db.query("select * from " + tableName + ";")
	else:
		db.query("select HoVaTen, GioiTinh, NgaySinh, GhiChu from " + tableName + ";")
	var result = db.query_result
	data = data + Effect.array_to_string(result[0].keys())
	for i in range(result.size()):
		var arr = []
		for f in result[i].keys():
			arr.append(result[i][f])
		data = data + Effect.array_to_string(arr)
	new_file.seek(0)
	new_file.store_string(data)
	print(data)
	print(new_file.get_as_text())
	# Always remember to close the file
	new_file.close()
	duong_dan_tep.text = ""





