extends VBoxContainer

@onready var vtable = $VBoxContainer/HBoxContainer/PanelContainer/Table/HBoxContainer/DanhSachNguoiDung/Table/Table/VTable
@onready var submenu_table = $VBoxContainer/HBoxContainer/PanelContainer/Table/HBoxContainer2/SubmenuTable
@onready var box_form = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer
@onready var table_buttons = $VBoxContainer/HBoxContainer/PanelContainer/Table/HBoxContainer2/TableButtons
@onready var danh_sach = $VBoxContainer/HBoxContainer/PanelContainer/Table
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
			danh_sach,
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
				danh_sach,
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
				danh_sach,
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
			danh_sach,
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
const tableName = "TamVang"
const query_select_all = "select * from " + tableName + ";"

@onready var fields = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/TruongThongTin
@onready var form = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang
@onready var popup = $Popup/PopupMenu
@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var file = $Popup/FileDialog
@onready var doc_file = $Popup/DocFileDialog

func _ready():
	window_hide()
	Effect.set_ngay_thang_nam(nam_di, thang_di, ngay_di)
	Effect.set_ngay_thang_nam(nam_ve, thang_ve, ngay_ve)
	reset_filters()
	readDataFromDB(query_select_all)

@onready var nam_di = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/ThoiDiemDi/NamDi
@onready var thang_di = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/ThoiDiemDi/ThangDi
@onready var ngay_di = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/ThoiDiemDi/NgayDi
@onready var nam_ve = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/ThoiDiemVe/NamVe
@onready var thang_ve = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/ThoiDiemVe/ThangVe
@onready var ngay_ve = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/ThoiDiemVe/NgayVe

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
	
	Effect.set_chon_nhan_khau(chon_ma_nhan_khau, "nhân khẩu")
	
var current_info
func _on_form_filled_in(action: String):
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
			if  "ThoiDiem" in f["name"]:
				var nam
				var thang
				var ngay
				if f["name"] == "ThoiDiemDi":
					nam = nam_di.get_selected_id()
					thang = thang_di.get_selected_id()
					ngay = ngay_di.get_selected_id()
				elif f["name"] == "ThoiDiemVe":
					nam = nam_ve.get_selected_id()
					thang = thang_ve.get_selected_id()
					ngay = ngay_ve.get_selected_id()
				info[f["name"]] = Effect.check_date_valid(nam, thang, ngay)
				if Effect.check_date_valid(nam, thang, ngay) == null:
					valid = false
					popup.add_item("Ngày tháng " + fields.get_node(f["name"]).text.replace("*", "").to_lower() + " không hợp lệ!")
			elif f["name"] == "MaNhanKhau":
				info[f["name"]] = ma_nhan_khau.text
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
				if "*" in fields.get_node(f["name"]).text:
					if info[f["name"]] == null:
						valid = false
						popup.add_item("Chưa điền thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + '!')
	release_focus_form()	
	if valid == true:
		if check_ma_nhan_khau(info["MaNhanKhau"]) == false:
			popup.add_item("Nhân khẩu này không tồn tại!")
		if Effect.check_duration(info["ThoiDiemDi"], info["ThoiDiemVe"]) == true:
			current_info = info
			if action == "insert":
				confirm.dialog_text = "Thêm thông tin tạm vắng này?"
				confirm.show()
			if action == "edit":
				confirm.dialog_text = "Sửa thông tin tạm vắng này?"
				confirm.show()
			return true
		else:
			popup.add_item("Thời điểm đi và về không hợp lệ!")
	popup.show()
	return false

func reset_form():
	for f in form.get_children():
		current_pk = null
		ma_nhan_khau.text = ""
		if f.name == "ThoiDiemDi":
			nam_di.select(0)
			thang_di.select(0)
			ngay_di.select(0)
		elif f.name == "ThoiDiemVe":
			nam_ve.select(0)
			thang_ve.select(0)
			ngay_ve.select(0)
		if "ThoiDiem" not in f.name and "Buffer" not in f.name and f.name != "MaNhanKhau":
			f.text = ""
func release_focus_form():
	for f in form.get_children():
		ma_nhan_khau.release_focus()
		if f.name == "ThoiDiemDi":
			nam_di.release_focus()
			thang_di.release_focus()
			ngay_di.release_focus()
		elif f.name == "ThoiDiemVe":
			nam_ve.release_focus()
			thang_ve.release_focus()
			ngay_ve.release_focus()
		if "ThoiDiem" not in f.name and "Buffer" not in f.name and f.name != "MaNhanKhau":
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
	doc_file.clear_filters()
	doc_file.add_filter("*.doc; Word Files")
	doc_file.hide()

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
			for f in form.get_children():
				if "Buffer" not in f.name:
					if "ThoiDiem" in f.name:
						var dict = Effect.extract_date(result[0][f.name])
						if f.name == "ThoiDiemDi":
							nam_di.select(dict["nam"] + 1 - 2000)
							thang_di.select(dict["thang"])
							ngay_di.select(dict["ngay"])
						if f.name == "ThoiDiemVe":
							nam_ve.select(dict["nam"] + 1 - 2000)
							thang_ve.select(dict["thang"])
							ngay_ve.select(dict["ngay"])
					elif f.name == "MaNhanKhau":
						if result[0][f.name] == null:
							ma_nhan_khau.text = ""
						else:
							ma_nhan_khau.text = str(result[0][f.name])
					elif result[0][f.name] == null:
						f.text = ""
					else:
						f.text = str(result[0][f.name])
	get_current_info()

func get_current_info():
	if current_pk == null:
		return
	
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	var query = "select * from " + tableName + " where Ma" + tableName + " = " + current_pk + ';'
	db.query(query)
	var result = db.query_result
	check_ma_nhan_khau(str(result[0]["MaNhanKhau"]))
	
	_on_nam_di_item_selected(nam_di.get_selected_id() + 1 - 2000)
	_on_thang_di_item_selected(thang_di.get_selected_id())
	_on_ngay_di_item_selected(ngay_di.get_selected_id())
	_on_nam_ve_item_selected(nam_ve.get_selected_id() + 1 - 2000)
	_on_thang_ve_item_selected(thang_ve.get_selected_id())
	_on_ngay_ve_item_selected(ngay_ve.get_selected_id())
	
	_on_thi_tran_tam_tru_text_changed(result[0]["ThiTranTamTru"])
	_on_ly_do_text_changed(str(result[0]["LyDo"]))
	
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

########################Fill in form 'Tam Vang'#####################################################
@onready var form_ho_va_ten = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/HoVaTen
@onready var form_ngay_sinh = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/NgaySinh
@onready var form_cmnd = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/CMND
@onready var form_thi_tran = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/ThiTran
@onready var form_dia_chi_tam_vang = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/DiaChiTamVang
@onready var form_dia_chi_tam_tru = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/DiaChiTamTru
@onready var form_ly_do = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/LyDo
func check_ma_nhan_khau(text: String) -> bool:
	if Effect.check_ma_nhan_khau(text) == false:
		return false
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	var result
	
	db.query("select * from NhanKhau join HoKhau on NhanKhau.MaHoKhau = HoKhau.MaHoKhau where MaNhanKhau = " + text + ";")
	result = db.query_result
	form_ho_va_ten.text = result[0]["HoVaTen"]
	form_ngay_sinh.text = result[0]["NgaySinh"]
	form_cmnd.text = result[0]["CMND"]
		
	for t in form_thi_tran.get_children():
		if "TamVang" in t.name:
			t.text = result[0]["ThiTran"]
	
	form_dia_chi_tam_vang.text = ""
	form_dia_chi_tam_vang.text = form_dia_chi_tam_vang.text + str(result[0]["SoNha"]) + " "
	form_dia_chi_tam_vang.text = form_dia_chi_tam_vang.text + result[0]["DuongPho"] + " "
	form_dia_chi_tam_vang.text = form_dia_chi_tam_vang.text + result[0]["ThiTran"]
	form_dia_chi_tam_vang.text = form_dia_chi_tam_vang.text + " " + result[0]["QuanHuyen"] + " "
	form_dia_chi_tam_vang.text = form_dia_chi_tam_vang.text + result[0]["TinhThanh"]
	
	return true
func update_dia_chi_tam_tru():
	form_dia_chi_tam_tru.text = ""
	for f in form.get_children():
		if "TamTru" in f.name:
			form_dia_chi_tam_tru.text = form_dia_chi_tam_tru.text + f.text + " "
func _on_ma_nhan_khau_text_changed(new_text: String):
	if check_ma_nhan_khau(new_text) == false:
		form_ho_va_ten.text = ""
		form_ngay_sinh.text = ""
		form_cmnd.text = ""
		for t in form_thi_tran.get_children():
			if "TamVang" in t.name:
				t.text = ""
		form_dia_chi_tam_vang.text = ""
@onready var chon_ma_nhan_khau = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/MaNhanKhau/ChonMaNhanKhau
@onready var ma_nhan_khau = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/MaNhanKhau/MaNhanKhau
func _on_chon_ma_nhan_khau_item_selected(_index: int):
	ma_nhan_khau.text = str(chon_ma_nhan_khau.get_selected_id())
	_on_ma_nhan_khau_text_changed(ma_nhan_khau.text)
func _on_ly_do_text_changed(new_text: String):
	form_ly_do.text = new_text
func _on_so_nha_tam_tru_text_changed(_new_text: String):
	update_dia_chi_tam_tru()
func _on_duong_pho_tam_tru_text_changed(_new_text: String):
	update_dia_chi_tam_tru()
func _on_thi_tran_tam_tru_text_changed(new_text: String):
	update_dia_chi_tam_tru()
	for t in form_thi_tran.get_children():
		if "TamTru" in t.name:
			t.text = new_text
func _on_quan_huyen_tam_tru_text_changed(_new_text: String):
	update_dia_chi_tam_tru()
func _on_tinh_thanh_tam_tru_text_changed(_new_text: String):
	update_dia_chi_tam_tru()

@onready var form_thoi_diem_di = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/ThoiDiemDi
@onready var form_nam_di = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/ThoiDiemDi/NamDi
@onready var form_thang_di = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/ThoiDiemDi/ThangDi
@onready var form_ngay_di = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/ThoiDiemDi/NgayDi
@onready var form_thoi_diem_ve = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinTamVang/ThoiDiemVe
@onready var form_nam_ve = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/ThoiDiemVe/NamVe
@onready var form_thang_ve = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/ThoiDiemVe/ThangVe
@onready var form_ngay_ve = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/DonXinTamVang/DienThongTin/ThoiDiemVe/NgayVe
func _on_nam_di_item_selected(_index):
	form_nam_di.text = str(_index + 2000 - 1)
func _on_thang_di_item_selected(_index):
	form_thang_di.text = str(_index)
func _on_ngay_di_item_selected(_index):
	form_ngay_di.text = str(_index)
func _on_nam_ve_item_selected(_index):
	form_nam_ve.text = str(_index + 2000 - 1)
func _on_thang_ve_item_selected(_index):
	form_thang_ve.text = str(_index)
func _on_ngay_ve_item_selected(_index):
	form_ngay_ve.text = str(_index)
####################################################################################################
@onready var them_button = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/ThemButton
@onready var sua_button = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/SuaButton
func _process(_delta):
	them_button.visible = (current_pk == null)
	sua_button.visible = not (current_pk == null)
	
func _on_them_button_pressed():
	window_hide()
	_on_form_filled_in("insert")

func _on_sua_button_pressed():
	window_hide()
	_on_form_filled_in("edit")

func _on_luu_button_pressed():
	window_hide()
	if _on_form_filled_in("save") == true:
		doc_file.show()

func _on_doc_file_dialog_file_selected(path: String):
	doc_file_path = path
	save_to_doc_file()

var doc_file_path
const don_xin_tam_vang = "res://assets/forms/don-xin-tam-vang.txt"
func save_to_doc_file():
	# Open the existing file
	var txt_file = FileAccess.open(don_xin_tam_vang, FileAccess.READ)
	if txt_file != null:
		var data = txt_file.get_as_text()
		
		#Replace data with current info
		data = data.replace("HoVaTen", form_ho_va_ten.text)
		data = data.replace("NgaySinh", form_ngay_sinh.text)
		data = data.replace("CMND", form_cmnd.text)
		data = data.replace("ThiTranTamTru", form_thi_tran.get_node("ThiTranTamTru").text)
		data = data.replace("ThiTranTamVang", form_thi_tran.get_node("ThiTranTamVang").text)
		for f in form_thoi_diem_di.get_children():
			data = data.replace(f.name, f.text)
		for f in form_thoi_diem_ve.get_children():
			data = data.replace(f.name, f.text)
		data = data.replace("DiaChiTamTru", form_dia_chi_tam_tru.text)
		data = data.replace("DiaChiTamVang", form_dia_chi_tam_vang.text)
		data = data.replace("LyDo", form_ly_do.text)
		
		# Save the data from the .txt file to a new .doc file
		var new_doc_file = FileAccess.open(doc_file_path, FileAccess.WRITE)
		if new_doc_file != null:
			new_doc_file.store_string(data)
			new_doc_file.close()
		else:
			print("An error occurred while trying to create the .doc file.")
		txt_file.close()
	else:
		print("An error occurred while trying to open the .txt file.")

func _on_xoa_button_pressed():
	if current_pk != null:
		confirm.dialog_text = "Xóa thông tin tạm vắng này?\nThông tin đã xóa sẽ không thể truy hồi lại!"
		confirm.show()
	else:
		accept.dialog_text = "Không có thông tin tạm vắng nào được chọn!"
		accept.show()

func _on_xoa_het_button_pressed():
	confirm.dialog_text = "Xóa hết thông tin tạm vắng?\nThông tin đã xóa sẽ không thể truy hồi lại!"
	confirm.show()

func _on_lam_moi_button_pressed():
	readDataFromDB(query_select_all)
	reset_form()

func _on_confirmation_dialog_confirmed():	
	if confirm.dialog_text == "Thêm thông tin tạm vắng này?":
		Effect.insert(tableName, current_info, accept)
	if confirm.dialog_text == "Xóa thông tin tạm vắng này?\nThông tin đã xóa sẽ không thể truy hồi lại!":
		Effect.delete(tableName, current_pk, accept)
	if confirm.dialog_text == "Xóa hết thông tin tạm vắng?\nThông tin đã xóa sẽ không thể truy hồi lại!":
		Effect.delete_all(tableName, accept)
	if confirm.dialog_text == "Tải dữ liệu từ tệp lên hệ thống?":
		Effect._import_data_from_excel_file(tableName, file_path.text, self, accept)
	if confirm.dialog_text == "Sửa thông tin tạm vắng này?":
		Effect.edit(tableName, current_pk, current_info, accept)
	accept.show()
	readDataFromDB(query_select_all)

func _on_mo_tep_button_pressed():
	window_hide()
	file.show()

@onready var file_path = $VBoxContainer/HBoxContainer/PanelContainer/Table/HBoxContainer2/TableButtons/HBoxContainer2/DuongDanTep
func _on_file_dialog_file_selected(path: String):
	file_path.text = path

func _on_tai_len_button_pressed():
	if file_path.text != "":
		if FileAccess.file_exists(file_path.text.replace(" ", "")):
			if file_path.text.get_extension() == "xlsx":
				if Effect.check_field_names(tableName, file_path.text) == true:
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





















