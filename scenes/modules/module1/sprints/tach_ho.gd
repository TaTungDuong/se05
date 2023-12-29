extends VBoxContainer

const tableName = "HoKhau"
const query_select_all = "select * from " + tableName + ";"

@onready var vtable = $Table/HBoxContainer/DanhSachNhanKhau/Table/Table/VTable
@onready var popup = $Popup/PopupMenu
@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var file = $Popup/FileDialog
@onready var thong_tin_ho_khau = $Popup/ThongTinHoKhau

@onready var ho_khau_a = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HoKhauA
@onready var ho_khau_b = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HoKhauB

func _ready():
	reset_filters()
	window_hide()
	readDataFromDB(query_select_all)

func _process(_delta):
	chuyen_sang_a.disabled = (current_pk_b == null)
	chuyen_sang_b.disabled = (current_pk_a == null)
	if ho_khau_b.get_child_count() == 0:
		tach_ho_button.disabled = true
	elif ho_khau_b.get_child(0).get_child_count() <= 1:
		tach_ho_button.disabled = true
	else:
		tach_ho_button.disabled = false
	
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

func get_family_members(ho_khau, query):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	var row 
	db.query("PRAGMA table_info(NhanKhau);")
	for r in db.query_result:
		if ho_khau.has_node(r["name"]) == false:
			row = row_inst.instantiate()
			ho_khau.add_child(row)
			row.name = r["name"]
		else:
			for child in ho_khau.get_node(r["name"]).get_children():
				child.queue_free()
		row = cell_menu.instantiate()
		ho_khau.get_node(r["name"]).add_child(row)
		row.text = r["name"]
#		row.input.text = current_filters[r["name"]]
#		row.filter_submitted.connect(_on_filter_submitted)
#		row.column_sorted.connect(_on_column_a_sorted)
		row.option.disabled = true
		
	db.query(query)
	var result = db.query_result
	
	for c in ho_khau.get_children():
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
			cell.cell_pressed.connect(_on_cell_a_pressed)

	db.query("select * from " + tableName + " where Ma" + tableName + " = " + current_pk + ";")
	var current_item = db.query_result[0]
	for i in range(1, ho_khau.get_child(0).get_child_count()):
		if ho_khau.get_child(0).get_child(i).text == str(current_item["MaChuHo"]):
			for j in range(ho_khau.get_child_count()):
				ho_khau.get_child(j).get_child(i).button.disabled = true
			return

func get_shifted_members(ho_khau, query):
	var ho_khau_con_lai
	if ho_khau == ho_khau_a:
		ho_khau_con_lai = ho_khau_b
		current_pk_b = null
	if ho_khau == ho_khau_b:
		ho_khau_con_lai = ho_khau_a
		current_pk_a = null
	
	if ho_khau == ho_khau_b and ho_khau_a.get_child(0).get_child_count() <= 2:
		accept.dialog_text = "Không thể tách hộ có dưới 2 nhân khẩu!"
		accept.show()
		for c in ho_khau_a.get_children():
			for i in c.get_children():
				if i.has_node("Button") and i.theme == theme_select:
					i.theme = theme_normal
	else:
		var db = SQLite.new()
		db.path = DB.db_name
		db.open_db()
		
		var row 
		db.query("PRAGMA table_info(NhanKhau);")
		for r in db.query_result:
			if ho_khau.has_node(r["name"]) == false:
				row = row_inst.instantiate()
				ho_khau.add_child(row)
				row.name = r["name"]
				if row.has_node(r["name"]) == false:
					var cell = cell_menu.instantiate()
					ho_khau.get_node(r["name"]).add_child(cell)
					cell.text = r["name"]
			#		cell.input.text = current_filters[r["name"]]
			#		cell.filter_submitted.connect(_on_filter_submitted)
			#		cell.column_sorted.connect(_on_column_a_sorted)
					cell.option.disabled = true
			elif false:
				for child in ho_khau.get_node(r["name"]).get_children():
					child.queue_free()
			
		db.query(query)
		var result = db.query_result
		
		for c in ho_khau.get_children():
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
				if ho_khau == ho_khau_b:
					cell.cell_pressed.connect(_on_cell_b_pressed)
				if ho_khau == ho_khau_a:
					cell.cell_pressed.connect(_on_cell_a_pressed)
			for i in range(1, c.get_child_count()):
				c.get_child(i).id = i
		
		for c in ho_khau_con_lai.get_children():
			var count_id = 1
			for i in range(1, c.get_child_count()):
				if c.get_child(i).theme == theme_select:
					c.get_child(i).queue_free()
				else:
					c.get_child(i).id = count_id
					count_id = count_id + 1

func window_hide():
	popup.clear()
	popup.hide()
	accept.hide()
	confirm.hide()
	file.clear_filters()
	file.add_filter("*.xlsx; Excel Files")
	file.hide()
	thong_tin_ho_khau.hide()

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
	reset_tables()
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
			var query = "select * from NhanKhau where MaHoKhau = " + pk + ';'
			get_family_members(ho_khau_a, query)

var current_pk_a = null
func _on_cell_a_pressed(cell):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	for c in ho_khau_a.get_children():
		for i in c.get_children():
			if i.has_node("Button"):
				i.theme = theme_normal
		if c.get_child(cell.id).theme == theme_normal:
			c.get_child(cell.id).set_deferred("theme", theme_select)
		else:
			c.get_child(cell.id).set_deferred("theme", theme_normal)
		if c.name == "MaNhanKhau":
			current_pk_a = c.get_child(cell.id).text

var current_pk_b = null
func _on_cell_b_pressed(cell):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	for c in ho_khau_b.get_children():
		for i in c.get_children():
			if i.has_node("Button"):
				i.theme = theme_normal
		if c.get_child(cell.id).theme == theme_normal:
			c.get_child(cell.id).set_deferred("theme", theme_select)
		else:
			c.get_child(cell.id).set_deferred("theme", theme_normal)
		if c.name == "MaNhanKhau":
			current_pk_b = c.get_child(cell.id).text

func reset_tables():
	current_pk_a = null
	for i in ho_khau_a.get_children():
		i.queue_free()
	current_pk_b = null
	for i in ho_khau_b.get_children():
		i.queue_free()
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

func _on_column_a_sorted(order: String):
	get_family_members(ho_khau_a, "select * from NhanKhau where MaHoKhau = " + current_pk + order)

func _on_column_b_sorted(order: String):
	get_family_members(ho_khau_b, "select * from NhanKhau where MaHoKhau = " + current_pk + order)

@onready var chuyen_sang_a = $VBoxContainer/HBoxContainer/PanelContainer/ChuyenSangA
@onready var chuyen_sang_b = $VBoxContainer/HBoxContainer/VBoxContainer2/ChuyenSangB
@onready var tach_ho_button = $VBoxContainer/HBoxContainer2/TachHoButton
func _on_chuyen_sang_a_pressed():
	window_hide()
	get_shifted_members(ho_khau_a, "select * from NhanKhau where MaNhanKhau = " + current_pk_b + ";")

func _on_chuyen_sang_b_pressed():
	window_hide()
	get_shifted_members(ho_khau_b, "select * from NhanKhau where MaNhanKhau = " + current_pk_a + ";")

func _on_confirmation_dialog_confirmed():
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	Effect.insert(tableName, current_info, accept)
	
	db.query("select * from " + tableName + " where MaChuHo" + " = " + str(current_info["MaChuHo"]) + ";")
	var new_id = str(db.query_result[0]["MaHoKhau"])
	
	var member_id = []
	for i in range(1, ho_khau_b.get_child(0).get_child_count()):
		member_id.append(ho_khau_b.get_child(0).get_child(i).text)
#	db.query("select * from NhanKhau where MaHoKhau = " + str(current_pk) + ";")
#	var result = db.query_result
	for f in member_id:
		db.query("select * from NhanKhau where MaNhanKhau = " + str(f) + ";")
		var info = db.query_result[0]
		info["MaHoKhau"] = new_id
		if str(f) == str(current_info["MaChuHo"]):
			info["QuanHeVoiChuHo"] = "Chủ hộ"
		else:
			info["QuanHeVoiChuHo"] = null
		Effect.edit("NhanKhau", f, info, accept)
	
	Effect.split(current_pk, new_id)
	
	reset_tables()
	for f in form.get_children():
		if "Buffer" not in f.name:
			f.text = ""
	window_hide()
	readDataFromDB(query_select_all)
	
func _on_tach_ho_button_pressed():
	thong_tin_ho_khau.show()

func _on_dong_button_pressed():
	thong_tin_ho_khau.hide()

@onready var fields = $Popup/ThongTinHoKhau/VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/TruongThongTin
@onready var form = $Popup/ThongTinHoKhau/VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinNhanKhau
var current_info
func _on_form_filled_in():
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
			info[f["name"]] = form.get_node(f["name"]).text
			if info[f["name"]] == "":
				info[f["name"]] = null
			if "*" in fields.get_node(f["name"]).text:
				if info[f["name"]] == null:
					valid = false
					popup.add_item("Chưa điền thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + '!')
	release_focus_form()
	if valid == true and check_valid_form(info) == true:
		current_info = info
		confirm.dialog_text = "Thêm thông tin hộ khẩu này?"
		confirm.show()
	else:
		popup.show()

func check_valid_form(info: Dictionary) -> bool:
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	var is_existing = false
	db.query("select MaNhanKhau from NhanKhau;")
	for f in db.query_result:
		if str(f["MaNhanKhau"]) == str(info["MaChuHo"]):
			is_existing = true
			break
	if is_existing == false:
		popup.add_item("Mã chủ hộ không tồn tại!")
		return false

	db.query(query_select_all)
	for f in db.query_result:
		if str(f["MaChuHo"]) == str(info["MaChuHo"]):
			popup.add_item("Mã chủ hộ này đã tồn tại ở hộ khẩu khác!")
			return false
	return true
func reset_form():
	for f in form.get_children():
		if f.name != "GioiTinh" and f.name != "NgaySinh":
			if "Buffer" not in f.name:
				f.text = ""
func release_focus_form():
	for f in form.get_children():
		if f.name != "GioiTinh" and f.name != "NgaySinh":
			if "Buffer" not in f.name:
				f.release_focus()

func _on_luu_button_pressed():
	_on_form_filled_in()












