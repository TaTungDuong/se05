extends VBoxContainer

@onready var node_chucnang = $VBoxContainer/TruongThongKe
@onready var node_thanhcongcu = $VBoxContainer/HBoxContainer2/ThanhCongCu

func _ready():
	current_query = null
	window_hide()
	tableName = "NhanKhau"
	reset_filters()

####################################################################################################
@onready var popup = $Popup/PopupMenu
@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var file = $Popup/FileDialog
@onready var duong_dan_tep = $Table/HBoxContainer2/TableButtons/HBoxContainer2/DuongDanTep
func _on_mo_tep_button_pressed():
	window_hide()
	file.show()

func _on_file_dialog_file_selected(path: String):
	duong_dan_tep.text = path

func _on_tai_ve_button_pressed():
	if duong_dan_tep.text.replace(" ", "") == "":
		accept.dialog_text = "Chưa có đường dẫn tệp!"
		accept.show()
	elif current_query == null:
		accept.dialog_text = "Chưa có thông tin để tải!"
		accept.show()
	else:
		confirm.dialog_text = "Lưu thông tin về máy?"
		confirm.show()

func _on_confirmation_dialog_confirmed():
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	if confirm.dialog_text == "Lưu thông tin về máy?":
		_save_data_to_excel_file(current_query, duong_dan_tep.text.replace(" ", ""))

func _save_data_to_excel_file(query, path):
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
	
	db.query(query)
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

func window_hide():
	popup.clear()
	popup.hide()
	accept.hide()
	confirm.hide()
	file.clear_filters()
	file.add_filter("*.csv; Excel Files")
	file.hide()

####################################################################################################
func update_toggle(button_name: String):
	for c in node_thanhcongcu.get_children():
		if c.name != button_name:
			c.button_pressed = false
		else:
			c.button_pressed = true
	reset_filters()
func _on_nhan_khau_pressed():
	node_chucnang.current_tab = 0
	update_toggle("NhanKhau")
func _on_tam_tru_pressed():
	node_chucnang.current_tab = 1
	update_toggle("TamTru")
func _on_tam_vang_pressed():
	node_chucnang.current_tab = 2
	update_toggle("TamVang")
func _on_thong_ke_pressed():
	node_chucnang.current_tab = 3
	update_toggle("ThongKe")

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

####################################################################################################
var tableName = ""
var query_select_all = ""

func _on_truong_thong_ke_tab_selected(tab):
	tableName = node_chucnang.get_tab_title(tab)
	for c in vtable.get_children():
		c.free()
	current_query = null
	
@onready var vtable = $Table/HBoxContainer/DanhSachNhanKhau/Table/Table/VTable


var row_inst = preload("res://scenes/global_elements/elements/row.tscn")
var cell_inst = preload("res://scenes/global_elements/elements/cell.tscn")
var cell_menu = preload("res://scenes/global_elements/elements/cell_menu.tscn")
var current_query
func readDataFromDB(_query: String):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	current_query = _query
	var row 
	var result

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
	result = db.query_result
	print(result)
	
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

##It's Thong Ke Time!
func _on_thong_ke_button_pressed():
	if tableName == "NhanKhau":
		readDataFromDB(query_nhan_khau())
	if tableName == "TamTru":
		readDataFromDB(query_tam_tru())
	if tableName == "TamVang":
		readDataFromDB(query_tam_vang())

###Query Nhan Khau
@onready var gioi_tinh = $VBoxContainer/TruongThongKe/NhanKhau/PanelContainer/ScrollContainer/HBoxContainer/Filters/GioiTinh
@onready var do_tuoi_min = $VBoxContainer/TruongThongKe/NhanKhau/PanelContainer/ScrollContainer/HBoxContainer/Filters/DoTuoi/DoTuoiMin
@onready var do_tuoi_max = $VBoxContainer/TruongThongKe/NhanKhau/PanelContainer/ScrollContainer/HBoxContainer/Filters/DoTuoi/DoTuoiMax
@onready var nam_min = $VBoxContainer/TruongThongKe/NhanKhau/PanelContainer/ScrollContainer/HBoxContainer/Filters/NamSinh/NamMin
@onready var nam_max = $VBoxContainer/TruongThongKe/NhanKhau/PanelContainer/ScrollContainer/HBoxContainer/Filters/NamSinh/NamMax
var query_gioi_tinh = [
	" (GioiTinh = 0 or GioiTinh = 1) ",
	" GioiTinh = 0 ",
	" GioiTinh = 1 "
]
const tmp_query_do_tuoi = " date(NgaySinh)> date('now', '-DoTuoiMax years') and date(NgaySinh) <= date('now', '-DoTuoiMin years') "
var query_do_tuoi
const tmp_query_nam_sinh = " strftime('%Y', NgaySinh) >= 'NamMin' and strftime('%Y', NgaySinh) <= 'NamMax' "
var query_nam_sinh
func query_nhan_khau() -> String:
	var query = "select * from NhanKhau where "
	query = query + query_gioi_tinh[gioi_tinh.get_selected_id()] + "and"
	
	query_do_tuoi = tmp_query_do_tuoi
	var age_min = do_tuoi_min.text.replace(" ", "")
	if age_min == "":
		query_do_tuoi = query_do_tuoi.replace("DoTuoiMin", "0")
	elif Effect.is_numeric(age_min) == false:
		query_do_tuoi = query_do_tuoi.replace("DoTuoiMin", "0")
	else:
		query_do_tuoi = query_do_tuoi.replace("DoTuoiMin", age_min)
	var age_max = do_tuoi_max.text.replace(" ", "")
	if age_max == "":
		query_do_tuoi = query_do_tuoi.replace("DoTuoiMax", "999")
	elif Effect.is_numeric(age_max) == false:
		query_do_tuoi = query_do_tuoi.replace("DoTuoiMax", "999")
	else:
		query_do_tuoi = query_do_tuoi.replace("DoTuoiMax", age_max)
	query = query + query_do_tuoi + "and"
	
	query_nam_sinh = tmp_query_nam_sinh
	var year_min = nam_min.text.replace(" ", "")
	if year_min == "":
		query_nam_sinh = query_nam_sinh.replace("NamMin", "1900")
	elif Effect.is_numeric(year_min) == false:
		query_nam_sinh = query_nam_sinh.replace("NamMin", "1900")
	else:
		query_nam_sinh = query_nam_sinh.replace("NamMin", year_min)
	var year_max = nam_max.text.replace(" ", "")
	if year_max == "":
		query_nam_sinh = query_nam_sinh.replace("NamMax", str(Time.get_date_dict_from_system()["year"]))
	elif Effect.is_numeric(year_max) == false:
		query_nam_sinh = query_nam_sinh.replace("NamMax", str(Time.get_date_dict_from_system()["year"]))
	else:
		query_nam_sinh = query_nam_sinh.replace("NamMax", year_max)
	query = query + query_nam_sinh
	
	query = query + ";"
	print(query)
	return query


###Query Tam Tru
@onready var thong_tin_hien_thi_tam_tru = $VBoxContainer/TruongThongKe/TamTru/PanelContainer/ScrollContainer/HBoxContainer/Filters/ThongTinHienThiTamTru/HienThiFilters
@onready var tat_ca_tam_tru = $VBoxContainer/TruongThongKe/TamTru/PanelContainer/ScrollContainer/HBoxContainer/Filters/ThongTinHienThiTamTru/HienThiFilters/TatCaTamTru
@onready var thoi_han_tam_tru = $VBoxContainer/TruongThongKe/TamTru/PanelContainer/ScrollContainer/HBoxContainer/Filters/ThoiHanTamTru
var query_thoi_han_tam_tru = [
	" where (ThoiDiemVe > CURRENT_DATE or ThoiDiemVe < CURRENT_DATE);",
	" where ThoiDiemVe > CURRENT_DATE;",
	" where ThoiDiemVe < CURRENT_DATE;",
]
func query_tam_tru() -> String:
	var query = "select "
	var fields = []
	for c in thong_tin_hien_thi_tam_tru.get_children():
		if "TatCa" not in c.name and c.button_pressed == true:
			fields.append(c.name)
	if fields.size() == 0 or fields.size() == thong_tin_hien_thi_tam_tru.get_child_count() - 1:
		query = "select * "
	else:
		for f in fields:
			query = query + f
			if f != fields[fields.size() - 1]:
				query = query + ", "
	query = query + " from " + tableName + query_thoi_han_tam_tru[thoi_han_tam_tru.get_selected_id()]
	print(query)
	return query

func _on_tat_ca_tam_tru_toggled(button_pressed: bool):
	for c in thong_tin_hien_thi_tam_tru.get_children():
		if "TatCa" not in c.name:
			c.button_pressed = button_pressed
			c.disabled = button_pressed

###Query Tam Vang
@onready var thong_tin_hien_thi_tam_vang = $VBoxContainer/TruongThongKe/TamVang/PanelContainer/ScrollContainer/HBoxContainer/Filters/ThongTinHienThiTamVang/HienThiFilters
@onready var tat_ca_tam_vang = $VBoxContainer/TruongThongKe/TamVang/PanelContainer/ScrollContainer/HBoxContainer/Filters/ThongTinHienThiTamVang/HienThiFilters/TatCaTamVang
@onready var thoi_han_tam_vang = $VBoxContainer/TruongThongKe/TamVang/PanelContainer/ScrollContainer/HBoxContainer/Filters/ThoiHanTamVang
var query_thoi_han_tam_vang = [
	" where (ThoiDiemVe > CURRENT_DATE or ThoiDiemVe < CURRENT_DATE);",
	" where ThoiDiemVe > CURRENT_DATE;",
	" where ThoiDiemVe < CURRENT_DATE;",
]
func query_tam_vang() -> String:
	var query = "select "
	var fields = []
	for c in thong_tin_hien_thi_tam_vang.get_children():
		if "TatCa" not in c.name and c.button_pressed == true:
			fields.append(c.name)
	if fields.size() == 0 or fields.size() == thong_tin_hien_thi_tam_vang.get_child_count() - 1:
		query = "select * "
	else:
		for f in fields:
			query = query + f
			if f != fields[fields.size() - 1]:
				query = query + ", "
	query = query + " from " + tableName + query_thoi_han_tam_vang[thoi_han_tam_vang.get_selected_id()]
	print(query)
	return query

func _on_tat_ca_tam_vang_toggled(button_pressed: bool):
	for c in thong_tin_hien_thi_tam_vang.get_children():
		if "TatCa" not in c.name:
			c.button_pressed = button_pressed
			c.disabled = button_pressed









