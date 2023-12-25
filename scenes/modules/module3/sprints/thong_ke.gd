extends VBoxContainer

@onready var node_chucnang = $VBoxContainer/TruongThongKe
@onready var node_thanhcongcu = $VBoxContainer/HBoxContainer2/ThanhCongCu

func _ready():
	current_query = null
	window_hide()
	tableName = "PhanThuongCuoiNamHoc"
	reset_filters()
	set_chon_lop()
	set_chon_danh_hieu()
	set_chon_ho_khau(ma_ho_khau_cuoi_nam_hoc, chon_ma_ho_khau_cuoi_nam_hoc)
	set_chon_nhan_khau(ma_nhan_khau_cuoi_nam_hoc, chon_ma_nhan_khau_cuoi_nam_hoc)
	set_chon_ho_khau(ma_ho_khau_dip_dac_biet, chon_ma_ho_khau_dip_dac_biet)
	set_chon_nhan_khau(ma_nhan_khau_dip_dac_biet, chon_ma_nhan_khau_dip_dac_biet)
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
func _on_phan_thuong_cuoi_nam_hoc_pressed():
	node_chucnang.current_tab = 0
	update_toggle("PhanThuongCuoiNamHoc")
func _on_phan_thuong_dip_dac_biet_pressed():
	node_chucnang.current_tab = 1
	update_toggle("PhanThuongDipDacBiet")

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
	set_chon_lop()
	set_chon_danh_hieu()
	set_chon_ho_khau(ma_ho_khau_cuoi_nam_hoc, chon_ma_ho_khau_cuoi_nam_hoc)
	set_chon_nhan_khau(ma_nhan_khau_cuoi_nam_hoc, chon_ma_nhan_khau_cuoi_nam_hoc)
	set_chon_ho_khau(ma_ho_khau_dip_dac_biet, chon_ma_ho_khau_dip_dac_biet)
	set_chon_nhan_khau(ma_nhan_khau_dip_dac_biet, chon_ma_nhan_khau_dip_dac_biet)

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

func set_chon_ho_khau(ma_ho_khau: LineEdit, chon_ma_ho_khau: OptionButton):
	ma_ho_khau.text = ""
	chon_ma_ho_khau.clear()
	chon_ma_ho_khau.add_separator("Chọn hộ khẩu")
	var query = "select HoKhau.MaHoKhau, NhanKhau.HoVaTen, HoKhau.SoNha, HoKhau.DuongPho, HoKhau.ThiTran, HoKhau.QuanHuyen, HoKhau.TinhThanh from HoKhau join NhanKhau on HoKhau.MaChuHo = NhanKhau.MaNhanKhau;"
	
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query(query)
	var result = db.query_result
	chon_ma_ho_khau.add_item("Tất cả", result.size() + 1)
	for r in result:
		var info = ""
		info = info + str(r["MaHoKhau"]) + "| "
		info = info + str(r["HoVaTen"]) + ", "
		info = info + str(r["SoNha"]) + ", "
		info = info + str(r["DuongPho"]) + ", "
		info = info + str(r["ThiTran"]) + ", "
		info = info + str(r["QuanHuyen"]) + ", "
		info = info + str(r["TinhThanh"])
		chon_ma_ho_khau.add_item(info, r["MaHoKhau"])
	chon_ma_ho_khau.select(0)
func check_ma_ho_khau(text: String, chon_ma_ho_khau: OptionButton) -> bool:
	if Effect.is_numeric(text) == false:
		return false
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	var result
	
	db.query("select * from HoKhau where MaHoKhau = " + text + ";")
	result = db.query_result
	if result.size() == 0:
		chon_ma_ho_khau.select(0)
		return false
	for i in chon_ma_ho_khau.item_count:
		if text.to_int() == chon_ma_ho_khau.get_item_id(i):
			chon_ma_ho_khau.select(i)
			break
	return true

func set_chon_nhan_khau(ma_nhan_khau: LineEdit, chon_ma_nhan_khau: OptionButton):
	ma_nhan_khau.text = ""
	chon_ma_nhan_khau.clear()
	chon_ma_nhan_khau.add_separator("Chọn nhân khẩu")
	
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query("select MaNhanKhau, HoVaTen, GioiTinh, NgaySinh from NhanKhau;")
	var result = db.query_result
	chon_ma_nhan_khau.add_item("Tất cả", result.size() + 1)
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
func check_ma_nhan_khau(text: String, chon_ma_nhan_khau: OptionButton) -> bool:
	if Effect.is_numeric(text) == false:
		return false
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	var result
	
	db.query("select * from NhanKhau where MaNhanKhau = " + text + ";")
	result = db.query_result
	if result.size() == 0:
		chon_ma_nhan_khau.select(0)
		return false
	for i in chon_ma_nhan_khau.item_count:
		if text.to_int() == chon_ma_nhan_khau.get_item_id(i):
			chon_ma_nhan_khau.select(i)
			break
	return true

##It's Thong Ke Time!
func _on_thong_ke_button_pressed():
	if tableName == "PhanThuongCuoiNamHoc":
		readDataFromDB(query_phan_thuong_cuoi_nam_hoc())
	if tableName == "PhanThuongDipDacBiet":
		readDataFromDB(query_phan_thuong_dip_dac_biet())

###Query Phan Thuong Cuoi Nam Hoc
@onready var lop = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/ScrollContainer/HBoxContainer/Filters/Lop
@onready var truong = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/ScrollContainer/HBoxContainer/Filters/Truong
@onready var danh_hieu = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/ScrollContainer/HBoxContainer/Filters/DanhHieu
func set_chon_lop():
	lop.clear()
	lop.add_separator("Chọn lớp")
	lop.add_item("Tất cả", 13)
	for i in range(12):
		lop.add_item(str(i + 1), i + 1)
	lop.select(0)

func set_chon_danh_hieu():
	danh_hieu.clear()
	danh_hieu.add_separator("Chọn danh hiệu")
	danh_hieu.add_item("Tất cả", 4)
	danh_hieu.add_item("Học sinh giỏi và các thành tích đặc biệt", 1)
	danh_hieu.add_item("Học sinh khá", 2)
	danh_hieu.add_item("Học sinh tiên tiến", 3)
	danh_hieu.select(0)

@onready var chon_ma_ho_khau_cuoi_nam_hoc = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/ScrollContainer/HBoxContainer/Filters/MaHoKhau/ChonMaHoKhauCuoiNamHoc
@onready var ma_ho_khau_cuoi_nam_hoc = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/ScrollContainer/HBoxContainer/Filters/MaHoKhau/MaHoKhauCuoiNamHoc
@onready var chon_ma_nhan_khau_cuoi_nam_hoc = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/ScrollContainer/HBoxContainer/Filters/MaNhanKhau/ChonMaNhanKhauCuoiNamHoc
@onready var ma_nhan_khau_cuoi_nam_hoc = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/ScrollContainer/HBoxContainer/Filters/MaNhanKhau/MaNhanKhauCuoiNamHoc
func _on_ma_ho_khau_cuoi_nam_hoc_text_changed(new_text: String):
	check_ma_ho_khau(new_text, chon_ma_ho_khau_cuoi_nam_hoc)
func _on_chon_ma_ho_khau_cuoi_nam_hoc_item_selected(_index: int):
	if chon_ma_ho_khau_cuoi_nam_hoc.get_item_text(chon_ma_ho_khau_cuoi_nam_hoc.get_item_index(chon_ma_ho_khau_cuoi_nam_hoc.get_selected_id())) == "Tất cả":
		ma_ho_khau_cuoi_nam_hoc.text = ""
	else:
		ma_ho_khau_cuoi_nam_hoc.text = str(chon_ma_ho_khau_cuoi_nam_hoc.get_selected_id())

func _on_ma_nhan_khau_cuoi_nam_hoc_text_changed(new_text: String):
	check_ma_nhan_khau(new_text, chon_ma_nhan_khau_cuoi_nam_hoc)
func _on_chon_ma_nhan_khau_cuoi_nam_hoc_item_selected(_index: int):
	if chon_ma_nhan_khau_cuoi_nam_hoc.get_item_text(chon_ma_nhan_khau_cuoi_nam_hoc.get_item_index(chon_ma_nhan_khau_cuoi_nam_hoc.get_selected_id())) == "Tất cả":
		ma_nhan_khau_cuoi_nam_hoc.text = ""
	else:
		ma_nhan_khau_cuoi_nam_hoc.text = str(chon_ma_nhan_khau_cuoi_nam_hoc.get_selected_id())

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

@onready var nam_hoc = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/ScrollContainer/HBoxContainer/Filters/NamHoc
@onready var da_nhan_cuoi_nam_hoc = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/ScrollContainer/HBoxContainer/Filters/DaNhan
@onready var tong_so_tien_cuoi_nam_hoc = $VBoxContainer/TruongThongKe/PhanThuongCuoiNamHoc/PanelContainer/TongSoTien/TongSoTien
func query_phan_thuong_cuoi_nam_hoc():
	var query = "select * from PhanThuongCuoiNamHoc where DaNhan = "
	if da_nhan_cuoi_nam_hoc.button_pressed == true:
		query = query + "1 and "
	else:
		query = query + "0 and "

	var query_nam_hoc = ""
	if is_valid_school_year(nam_hoc.text.replace(" ", "")) == true:
		query_nam_hoc = "NamHoc = '" + nam_hoc.text.replace(" ", "") + "' and "
	query = query + query_nam_hoc
	
	var query_ho_khau = ""
	if check_ma_ho_khau(ma_ho_khau_cuoi_nam_hoc.text, chon_ma_ho_khau_cuoi_nam_hoc) == true:
		query_ho_khau = "MaHoKhau = " + ma_ho_khau_cuoi_nam_hoc.text + " and "
	query = query + query_ho_khau
	
	var query_nhan_khau = ""
	if check_ma_nhan_khau(ma_nhan_khau_cuoi_nam_hoc.text, chon_ma_nhan_khau_cuoi_nam_hoc) == true:
		query_nhan_khau = "MaNhanKhau = " + ma_nhan_khau_cuoi_nam_hoc.text + " and "
	query = query + query_nhan_khau
	
	var query_lop = ""
	if lop.get_selected_id() > 0 and lop.get_selected_id() < 13:
		query_lop = "Lop = " + str(lop.get_selected_id()) + " and "
	query = query + query_lop
	
	var query_truong = ""
	if truong.text.replace(" ", "") != "":
		query_truong = "Truong = '" + truong.text + "' and "
	query = query + query_truong
	
	var query_danh_hieu = ""
	if danh_hieu.get_selected_id() > 0 and danh_hieu.get_selected_id() < 4:
		query_danh_hieu = "DanhHieu = '" + danh_hieu.get_item_text(danh_hieu.get_selected_id()) +"'"
	query = query + query_danh_hieu
	
	if query_danh_hieu == "" and query_nam_hoc == "" and query_ho_khau == "" and query_nhan_khau == "" and query_lop == "" and query_truong == "":
		query = query.replace("and", "")
	query = query + ";"
	print(query)
	
	var so_tien = 0
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query(query)
	for r in db.query_result:
		so_tien = so_tien + r["SoTien"]
	tong_so_tien_cuoi_nam_hoc.text = str(so_tien)
	return query

###Query Phan Thuong Dip Dac Biet
@onready var chon_ma_ho_khau_dip_dac_biet = $VBoxContainer/TruongThongKe/PhanThuongDipDacBiet/PanelContainer/ScrollContainer/HBoxContainer/Filters/MaHoKhau/ChonMaHoKhauDipDacBiet
@onready var ma_ho_khau_dip_dac_biet = $VBoxContainer/TruongThongKe/PhanThuongDipDacBiet/PanelContainer/ScrollContainer/HBoxContainer/Filters/MaHoKhau/MaHoKhauDipDacBiet
@onready var chon_ma_nhan_khau_dip_dac_biet = $VBoxContainer/TruongThongKe/PhanThuongDipDacBiet/PanelContainer/ScrollContainer/HBoxContainer/Filters/MaNhanKhau/ChonMaNhanKhauDipDacBiet
@onready var ma_nhan_khau_dip_dac_biet = $VBoxContainer/TruongThongKe/PhanThuongDipDacBiet/PanelContainer/ScrollContainer/HBoxContainer/Filters/MaNhanKhau/MaNhanKhauDipDacBiet
func _on_ma_ho_khau_dip_dac_biet_text_changed(new_text: String):
	check_ma_ho_khau(new_text, chon_ma_ho_khau_dip_dac_biet)
func _on_chon_ma_ho_khau_dip_dac_biet_item_selected(_index: int):
	if chon_ma_ho_khau_dip_dac_biet.get_item_text(chon_ma_ho_khau_dip_dac_biet.get_item_index(chon_ma_ho_khau_dip_dac_biet.get_selected_id())) == "Tất cả":
		ma_ho_khau_dip_dac_biet.text = ""
	else:
		ma_ho_khau_dip_dac_biet.text = str(chon_ma_ho_khau_dip_dac_biet.get_selected_id())

func _on_ma_nhan_khau_dip_dac_biet_text_changed(new_text: String):
	check_ma_nhan_khau(new_text, chon_ma_nhan_khau_dip_dac_biet)
func _on_chon_ma_nhan_khau_dip_dac_biet_item_selected(_index: int):
	if chon_ma_nhan_khau_dip_dac_biet.get_item_text(chon_ma_nhan_khau_dip_dac_biet.get_item_index(chon_ma_nhan_khau_dip_dac_biet.get_selected_id())) == "Tất cả":
		ma_nhan_khau_dip_dac_biet.text = ""
	else:
		ma_nhan_khau_dip_dac_biet.text = str(chon_ma_nhan_khau_dip_dac_biet.get_selected_id())

@onready var dip_dac_biet = $VBoxContainer/TruongThongKe/PhanThuongDipDacBiet/PanelContainer/ScrollContainer/HBoxContainer/Filters/DipDacBiet
@onready var nam = $VBoxContainer/TruongThongKe/PhanThuongDipDacBiet/PanelContainer/ScrollContainer/HBoxContainer/Filters/Nam
@onready var phan_thuong = $VBoxContainer/TruongThongKe/PhanThuongDipDacBiet/PanelContainer/ScrollContainer/HBoxContainer/Filters/PhanThuong
@onready var da_nhan_dip_dac_biet = $VBoxContainer/TruongThongKe/PhanThuongDipDacBiet/PanelContainer/ScrollContainer/HBoxContainer/Filters/DaNhan
@onready var tong_so_tien_dip_dac_biet = $VBoxContainer/TruongThongKe/PhanThuongDipDacBiet/PanelContainer/TongSoTien/TongSoTien
func query_phan_thuong_dip_dac_biet():
	var query = "select * from PhanThuongDipDacBiet where "
	if da_nhan_dip_dac_biet.button_pressed == true:
		query = query + "1 and "
	else:
		query = query + "0 and "
	
	var query_dip_dac_biet = ""
	if dip_dac_biet.text.replace(" ", "") != "":
		query_dip_dac_biet = "DipDacBiet = '" + dip_dac_biet.text + "' and "
	query = query + query_dip_dac_biet

	var query_nam = ""
	if Effect.is_numeric(nam.text.replace(" ", "")) == true:
		query_nam = "Nam = " + nam.text.replace(" ", "") + " and "
	query = query + query_nam
	
	var query_ho_khau = ""
	if check_ma_ho_khau(ma_ho_khau_dip_dac_biet.text, chon_ma_ho_khau_dip_dac_biet) == true:
		query_ho_khau = "MaHoKhau = " + ma_ho_khau_dip_dac_biet.text + " and "
	query = query + query_ho_khau
	
	var query_nhan_khau = ""
	if check_ma_nhan_khau(ma_nhan_khau_dip_dac_biet.text, chon_ma_nhan_khau_dip_dac_biet) == true:
		query_nhan_khau = "MaNhanKhau = " + ma_nhan_khau_dip_dac_biet.text + " and "
	query = query + query_nhan_khau
	
	var query_phan_thuong = ""
	if phan_thuong.text.replace(" ", "") != "":
		query_phan_thuong = "PhanThuong = '" + phan_thuong.text + "' and "
	query = query + query_phan_thuong
	
	if query_dip_dac_biet == "" and query_nam == "" and query_ho_khau == "" and query_nhan_khau == "" and query_phan_thuong == "":
		query = query.replace("and", "")
	query = query + ";"
	print(query)
	
	var so_tien = 0
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query(query)
	for r in db.query_result:
		so_tien = so_tien + r["SoTien"]
	tong_so_tien_dip_dac_biet.text = str(so_tien)
	return query








