extends VBoxContainer

const tableName = "PhanThuongCuoiNamHoc"
const query_select_all = "select * from " + tableName + ";"

@onready var vtable = $Table/HBoxContainer/DanhSachPhanThuongCuoiNamHoc/Table/Table/VTable
@onready var fields = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/TruongThongTin
@onready var form_insert = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc
@onready var form_edit = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc
@onready var popup = $Popup/PopupMenu
@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var file = $Popup/FileDialog

func _ready():
	reset_filters()
	window_hide()
	reset_form(form_edit)
	reset_form(form_insert)
	readDataFromDB(query_select_all)
	set_chon_lop(them_lop)
	set_chon_lop(sua_lop)
	set_chon_danh_hieu(them_danh_hieu)
	set_chon_danh_hieu(sua_danh_hieu)
#	test_excel()

func _process(_delta):
	if current_pk == null:
		sua_button.disabled = true
	else:
		sua_button.disabled = false
	luu_button.visible = sua_button.button_pressed
	luu_button.disabled = not sua_button.button_pressed
	for f in form_edit.get_children():
		if "Buffer" not in f.name and f.name != "MaHoKhau" and f.name != "PhanThuong" and f.name != "SoTien":
			if f.name == "DaNhan" or f.name == "Lop" or "DanhHieu" in f.name:
				f.disabled = not sua_button.button_pressed
			elif f.name == "MaNhanKhau":
				sua_ma_nhan_khau.editable = sua_button.button_pressed
				sua_chon_ma_nhan_khau.disabled = not sua_button.button_pressed
			else:
				f.editable = sua_button.button_pressed

func is_valid_school_year(year_string):
	var year_parts = year_string.split("-")
	if year_parts.size() != 2:
		return false
	if Effect.is_numeric(year_parts[0]) == false or Effect.is_numeric(year_parts[1]) == false:
		return false
	var year1 = int(year_parts[0])
	var year2 = int(year_parts[1])
	if year1 >= year2:
		return false
	return true

@onready var them_lop = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc/Lop
@onready var sua_lop = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc/Lop
func set_chon_lop(lop: OptionButton):
	lop.clear()
	lop.add_separator("Chọn lớp")
	
	for i in range(12):
		lop.add_item(str(i + 1), i + 1)
	lop.select(0)

@onready var them_truong = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc/Truong
@onready var sua_truong =$VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc/Truong

@onready var them_danh_hieu = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc/ThemDanhHieu
@onready var sua_danh_hieu = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc/SuaDanhHieu
func set_chon_danh_hieu(danh_hieu: OptionButton):
	danh_hieu.clear()
	danh_hieu.add_separator("Chọn danh hiệu")
	
	danh_hieu.add_item("Học sinh giỏi và các thành tích đặc biệt", 1)
	danh_hieu.add_item("Học sinh khá", 2)
	danh_hieu.add_item("Học sinh tiên tiến", 3)
	danh_hieu.select(0)

func _on_them_danh_hieu_item_selected(index: int):
	if index == 1:
		them_phan_thuong.text = "10 cuốn vở"
		them_so_tien.text = "50000"
	if index == 2:
		them_phan_thuong.text = "7 cuốn vở"
		them_so_tien.text = "35000"
	if index == 3:
		them_phan_thuong.text = "5 cuốn vở"
		them_so_tien.text = "25000"
func _on_sua_danh_hieu_item_selected(index: int):
	if index == 1:
		sua_phan_thuong.text = "10 cuốn vở"
		sua_so_tien.text = "50000"
	if index == 2:
		sua_phan_thuong.text = "7 cuốn vở"
		sua_so_tien.text = "35000"
	if index == 3:
		sua_phan_thuong.text = "5 cuốn vở"
		sua_so_tien.text = "25000"

@onready var them_phan_thuong = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc/PhanThuong
@onready var sua_phan_thuong = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc/PhanThuong

@onready var them_so_tien = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc/SoTien
@onready var sua_so_tien = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc/SoTien

@onready var them_da_nhan = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc/DaNhan
@onready var sua_da_nhan = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc/DaNhan
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
	
	for c in vtable.get_children():
		for i in range(0, result.size()):
			var cell = cell_inst.instantiate()
			c.add_child(cell)
			cell.text = str(result[i][c.name])
			cell.table = tableName
			cell.field = c.name
			cell.id = i + 1
			cell.cell_pressed.connect(_on_cell_pressed)
	set_chon_nhan_khau(them_chon_ma_nhan_khau)
	set_chon_nhan_khau(sua_chon_ma_nhan_khau)
	
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
			if f["name"] == "Lop":
				var lop
				if form == form_insert:
					info[f["name"]] = them_lop.get_selected_id()
					lop = them_lop.get_selected_id()
				elif form == form_edit:
					info[f["name"]] = sua_lop.get_selected_id()
					lop = sua_lop.get_selected_id()
				if lop == 0 or lop == -1:
					popup.add_item("Chưa điền thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + '!')
			elif f["name"] == "DanhHieu":
				var danh_hieu
				if form == form_insert:
					danh_hieu = them_danh_hieu.get_selected_id()
					if danh_hieu != 0 and danh_hieu != -1:
						info[f["name"]] = them_danh_hieu.get_item_text(them_danh_hieu.get_selected_id())
				elif form == form_edit:
					danh_hieu = sua_danh_hieu.get_selected_id()
					if danh_hieu != 0 and danh_hieu != -1:
						info[f["name"]] = sua_danh_hieu.get_item_text(sua_danh_hieu.get_selected_id())
				if danh_hieu == 0 or danh_hieu == -1:
					popup.add_item("Chưa điền thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + '!')
			elif f["name"] == "DaNhan":
				if form == form_insert:
					if them_da_nhan.button_pressed == true:
						info[f["name"]] = 1
					else:
						info[f["name"]] = 0
				elif form == form_edit:
					if sua_da_nhan.button_pressed == true:
						info[f["name"]] = 1
					else:
						info[f["name"]] = 0
			elif f["name"] == "MaNhanKhau":
				if form == form_insert:
					info[f["name"]] = them_ma_nhan_khau.text
				elif form == form_edit:
					info[f["name"]] = sua_ma_nhan_khau.text
				if info[f["name"]] == "":
						info[f["name"]] = null
				if "*" in fields.get_node(f["name"]).text:
					if info[f["name"]] == null:
						valid = false
						popup.add_item("Chưa điền thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + '!')
			else :
				info[f["name"]] = form.get_node(f["name"]).text
				if info[f["name"]] == "":
					info[f["name"]] = null
				if f["name"] == "NamHoc":
					if is_valid_school_year(info[f["name"]]) == false:
						valid = false
						popup.add_item("Thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + " không hợp lệ!")
				if "*" in fields.get_node(f["name"]).text:
					if info[f["name"]] == null and f["name"] != "NamHoc":
						valid = false
						popup.add_item("Chưa điền thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + '!')
	release_focus_form(form)
	if valid == true:
		current_info = info
		if current_form == form_insert:
			confirm.dialog_text = "Thêm thông tin phần thưởng cuối năm học này?"
		elif current_form == form_edit:
			confirm.dialog_text = "Sửa thông tin phần thưởng cuối năm học này?"
		confirm.show()
	else:
		popup.show()

func reset_form(form):
	for f in form.get_children():
		if form == form_insert:
			them_ma_nhan_khau.text = ""
			them_da_nhan.button_pressed = true
			them_lop.select(0)
			them_danh_hieu.select(0)
		elif form == form_edit:
			current_pk = null
			sua_ma_nhan_khau.text = ""
			sua_da_nhan.button_pressed = true
			sua_lop.select(0)
			sua_danh_hieu.select(0)
		if f.name != "DaNhan" and f.name != "MaNhanKhau" and f.name != "Lop" and "DanhHieu" not in f.name:
			if "Buffer" not in f.name:
				f.text = ""
func release_focus_form(form):
	for f in form.get_children():
		if form == form_insert:
			them_ma_nhan_khau.release_focus()
			them_da_nhan.release_focus()
			them_lop.release_focus()
			them_danh_hieu.release_focus()
		elif form == form_edit:
			sua_ma_nhan_khau.release_focus()
			sua_da_nhan.release_focus()
			sua_lop.release_focus()
			sua_danh_hieu.release_focus()
		if f.name != "DaNhan" and f.name != "MaNhanKhau" and f.name != "Lop" and "DanhHieu" not in f.name:
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
					if f.name == "Lop":
						sua_lop.select(result[0][f.name])
					elif "DanhHieu" in f.name:
						for i in range(3):
							if result[0]["DanhHieu"] == sua_danh_hieu.get_item_text(i + 1):
								sua_danh_hieu.select(i + 1)
								break
					elif f.name == "DaNhan":
						sua_da_nhan.button_pressed = (str(result[0][f.name]) == "1")
					elif f.name == "MaNhanKhau":
						if result[0][f.name] == null:
							sua_ma_nhan_khau.text = ""
						else:
							sua_ma_nhan_khau.text = str(result[0][f.name])
						_on_sua_ma_nhan_khau_text_changed(sua_ma_nhan_khau.text)
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

@onready var them_ma_nhan_khau = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc/MaNhanKhau/ThemMaNhanKhau
@onready var sua_ma_nhan_khau = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc/MaNhanKhau/SuaMaNhanKhau
@onready var them_chon_ma_nhan_khau = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc/MaNhanKhau/ThemChonMaNhanKhau
@onready var sua_chon_ma_nhan_khau = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc/MaNhanKhau/SuaChonMaNhanKhau
@onready var them_ma_ho_khau = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinPhanThuongCuoiNamHoc/MaHoKhau
@onready var sua_ma_ho_khau = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinPhanThuongCuoiNamHoc/MaHoKhau
func set_chon_nhan_khau(chon_ma_nhan_khau):
	chon_ma_nhan_khau.clear()
	chon_ma_nhan_khau.add_separator("Chọn nhân khẩu")
	
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query("select MaNhanKhau, HoVaTen, GioiTinh, NgaySinh from NhanKhau where (strftime('%Y', 'now') - strftime('%Y', NgaySinh)) between 6 and 18;")
	var result = db.query_result
	for r in result:
		var info = ""
		info = info + str(r["MaNhanKhau"]) + "| "
		info = info + str(r["HoVaTen"]) + ", "
		if str(r["GioiTinh"]) == "0":
			info = info + "Nam, "
		else:
			info = info + "Nữ, "
		info = info + str(r["NgaySinh"])
		chon_ma_nhan_khau.add_item(info, r["MaNhanKhau"])
	chon_ma_nhan_khau.select(0)

func check_ma_nhan_khau(text: String, text_edit, chon_ma_nhan_khau) -> bool:
	if Effect.check_ma_nhan_khau(text) == false:
		chon_ma_nhan_khau.select(0)
		text_edit.text = ""
		return false
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	var result
	
	db.query("select * from NhanKhau where MaNhanKhau = " + text + ";")
	result = db.query_result
	text_edit.text = result[0]["MaHoKhau"]
	for i in chon_ma_nhan_khau.item_count:
		if text.to_int() == chon_ma_nhan_khau.get_item_id(i):
			chon_ma_nhan_khau.select(i)
	return true

func _on_them_chon_ma_nhan_khau_item_selected(_index):
	them_ma_nhan_khau.text = str(them_chon_ma_nhan_khau.get_selected_id())
	_on_them_ma_nhan_khau_text_changed(them_ma_nhan_khau.text)
func _on_sua_chon_ma_nhan_khau_item_selected(_index):
	sua_ma_nhan_khau.text = str(sua_chon_ma_nhan_khau.get_selected_id())
	_on_sua_ma_nhan_khau_text_changed(sua_ma_nhan_khau.text)
func _on_them_ma_nhan_khau_text_changed(new_text: String):
	check_ma_nhan_khau(new_text, them_ma_ho_khau, them_chon_ma_nhan_khau)
func _on_sua_ma_nhan_khau_text_changed(new_text: String):
	check_ma_nhan_khau(new_text, sua_ma_ho_khau, sua_chon_ma_nhan_khau)

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
		confirm.dialog_text = "Xóa thông tin phần thưởng cuối năm học này?\nThông tin đã xóa sẽ không thể truy hồi lại!"
		confirm.show()
		current_form = form_edit
	else:
		accept.dialog_text = "Không có thông tin phần thưởng cuối năm học nào được chọn!"
		accept.show()

func _on_xoa_het_button_pressed():
	confirm.dialog_text = "Xóa hết thông tin phần thưởng cuối năm học?\nThông tin đã xóa sẽ không thể truy hồi lại!"
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
	elif current_form == form_edit:
		if confirm.dialog_text == "Xóa thông tin phần thưởng cuối năm học này?\nThông tin đã xóa sẽ không thể truy hồi lại!":
			Effect.delete(tableName, current_pk, accept)
		if confirm.dialog_text == "Xóa hết thông tin phần thưởng cuối năm học?\nThông tin đã xóa sẽ không thể truy hồi lại!":
			Effect.delete_all(tableName, accept)
		if confirm.dialog_text == "Sửa thông tin phần thưởng cuối năm học này?":
			Effect.edit(tableName, current_pk, current_info, accept)
			sua_button.button_pressed = false
		if confirm.dialog_text == "Tải dữ liệu từ tệp lên hệ thống?":
			Effect._import_data_from_excel_file(tableName, file_path.text, self, accept)
#			_import_data_from_excel_file(file_path.text.replace(" ", ""))
		accept.show()
		current_pk = null
	reset_form(current_form)
	readDataFromDB(query_select_all)


































