extends VBoxContainer

var tableName = "TABLE"
var query_select_all = "select * from TABLE;"

@onready var node_thanhcongcu = $VBoxContainer/HBoxContainer/ThanhCongCu

func  _ready():
	_on_lich_su_thu_phi_pressed()

@onready var vtable = $VBoxContainer/Table/HBoxContainer/DanhSachNguoiDung/Table/Table/VTable
func update_toggle(button_name: String):
	for c in vtable.get_children():
		c.free()
	query_select_all = "select * from " + button_name + ";"
	tableName = button_name
	for c in node_thanhcongcu.get_children():
		if "Buffer" not in c.name:
			if c.name != button_name:
				c.button_pressed = false
			else:
				c.button_pressed = true
	reset_filters()
	readDataFromDB(query_select_all)

func _on_lich_su_thu_phi_pressed():
	update_toggle("LichSuThuPhi")
func _on_lich_su_chi_phi_pressed():
	update_toggle("LichSuChiPhi")

@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var popup = $Popup/PopupMenu
@onready var file = $Popup/FileDialog
@onready var duong_dan_tep = $VBoxContainer/Table/HBoxContainer2/HBoxContainer2/DuongDanTep

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
		confirm.dialog_text = "Lưu thông tin về máy?"
		confirm.show()

func _on_confirmation_dialog_confirmed():
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	if confirm.dialog_text == "Lưu thông tin về máy?":
		Effect._save_data_to_excel_file(tableName, duong_dan_tep.text.replace(" ", ""), duong_dan_tep)
	readDataFromDB(query_select_all)

func _on_lam_moi_button_pressed():
	readDataFromDB(query_select_all)


