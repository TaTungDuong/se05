extends VBoxContainer

const tableName = "ChiPhi"
const query_select_all = "select * from " + tableName + ";"

@onready var vtable = $Table/HBoxContainer/DanhSachChiPhi/Table/Table/VTable
@onready var fields = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/TruongThongTin
@onready var form_insert = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinChiPhi
@onready var form_edit = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinChiPhi
@onready var popup = $Popup/PopupMenu
@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var file = $Popup/FileDialog

func _ready():
	reset_filters()
	window_hide()
	Effect.set_ngay_thang_nam(them_nam, them_thang, them_ngay)
	Effect.set_ngay_thang_nam(sua_nam, sua_thang, sua_ngay)
	reset_form(form_edit)
	reset_form(form_insert)
	readDataFromDB(query_select_all)
#	test_excel()

func _process(_delta):
	if current_pk == null:
		sua_button.disabled = true
	else:
		sua_button.disabled = false
	luu_button.visible = sua_button.button_pressed
	luu_button.disabled = not sua_button.button_pressed
	for f in form_edit.get_children():
		if "Buffer" not in f.name and f.name != "NguoiChiuTrachNhiem":
			if f.name == "NgayChi":
				for o in f.get_children():
					o.disabled = not sua_button.button_pressed
#					o.flat = not sua_button.button_pressed
			elif f.name == "MaNhanKhau":
				sua_ma_nhan_khau.editable = sua_button.button_pressed
				sua_chon_ma_nhan_khau.disabled = not sua_button.button_pressed
			else:
				f.editable = sua_button.button_pressed
	
	
@onready var them_ngay = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinChiPhi/NgayChi/ThemNgay
@onready var them_thang = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinChiPhi/NgayChi/ThemThang
@onready var them_nam = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinChiPhi/NgayChi/ThemNam
@onready var sua_nam = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinChiPhi/NgayChi/SuaNam
@onready var sua_thang = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinChiPhi/NgayChi/SuaThang
@onready var sua_ngay = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinChiPhi/NgayChi/SuaNgay

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
	Effect.set_chon_nhan_khau(them_chon_ma_nhan_khau, "nhân khẩu")
	Effect.set_chon_nhan_khau(sua_chon_ma_nhan_khau, "nhân khẩu")

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
			if f["name"] == "NgayChi":
				var nam
				var thang
				var ngay
				if form == form_insert:
					nam = them_nam.get_selected_id()
					thang = them_thang.get_selected_id()
					ngay = them_ngay.get_selected_id()
				elif form == form_edit:
					nam = sua_nam.get_selected_id()
					thang = sua_thang.get_selected_id()
					ngay = sua_ngay.get_selected_id()
				info[f["name"]] = Effect.check_date_valid(nam, thang, ngay)
				if Effect.check_date_valid(nam, thang, ngay) == null:
					valid = false
					popup.add_item("Ngày chi không hợp lệ!")
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
				if f["name"] == "SoTien":
					if Effect.is_numeric(info[f["name"]]) == false:
						valid = false
						popup.add_item("Thông tin " + fields.get_node(f["name"]).text.to_lower().replace("*", "") + ' không hợp lệ!')	
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
			confirm.dialog_text = "Thêm thông tin chi phí này?"
		elif current_form == form_edit:
			confirm.dialog_text = "Sửa thông tin chi phí này?"
		confirm.show()
	else:
		popup.show()

func reset_form(form):
	for f in form.get_children():
		if form == form_insert:
			them_ma_nhan_khau.text = ""
			them_nam.select(0)
			them_thang.select(0)
			them_ngay.select(0)
		elif form == form_edit:
			current_pk = null
			sua_ma_nhan_khau.text = ""
			sua_nam.select(0)
			sua_thang.select(0)
			sua_ngay.select(0)
		if f.name != "NgayChi" and f.name != "MaNhanKhau":
			if "Buffer" not in f.name:
				f.text = ""
func release_focus_form(form):
	for f in form.get_children():
		if form == form_insert:
			them_ma_nhan_khau.release_focus()
			them_nam.release_focus()
			them_thang.release_focus()
			them_ngay.release_focus()
		elif form == form_edit:
			sua_ma_nhan_khau.release_focus()
			sua_nam.release_focus()
			sua_thang.release_focus()
			sua_ngay.release_focus()
		if f.name != "NgayChi" and f.name != "MaNhanKhau":
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
					if f.name == "NgayChi":
						var dict = Effect.extract_date(result[0][f.name])
						sua_nam.select(dict["nam"] + 1 - 2000)
						sua_thang.select(dict["thang"])
						sua_ngay.select(dict["ngay"])
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

@onready var them_ma_nhan_khau = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinChiPhi/MaNhanKhau/ThemMaNhanKhau
@onready var sua_ma_nhan_khau = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinChiPhi/MaNhanKhau/SuaMaNhanKhau
@onready var them_chon_ma_nhan_khau = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinChiPhi/MaNhanKhau/ThemChonMaNhanKhau
@onready var sua_chon_ma_nhan_khau = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinChiPhi/MaNhanKhau/SuaChonMaNhanKhau
@onready var them_nguoi_chiu_trach_nhiem = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/DienThongTinChiPhi/NguoiChiuTrachNhiem
@onready var sua_nguoi_chiu_trach_nhiem = $VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/HBoxContainer/SuaThongTinChiPhi/NguoiChiuTrachNhiem
func check_ma_nhan_khau(text: String, chon_ma_nhan_khau, nguoi_chiu_trach_nhiem) -> bool:
	if Effect.check_ma_nhan_khau(text) == false:
		chon_ma_nhan_khau.select(0)
		nguoi_chiu_trach_nhiem.text = ""
		return false
	for i in chon_ma_nhan_khau.item_count:
		if text.to_int() == chon_ma_nhan_khau.get_item_id(i):
			chon_ma_nhan_khau.select(i)
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query("select * from NhanKhau where MaNhanKhau = " + text + ";")
	nguoi_chiu_trach_nhiem.text = db.query_result[0]["HoVaTen"]
	return true

func _on_them_chon_ma_nhan_khau_item_selected(_index):
	them_ma_nhan_khau.text = str(them_chon_ma_nhan_khau.get_selected_id())
	_on_them_ma_nhan_khau_text_changed(them_ma_nhan_khau.text)
func _on_sua_chon_ma_nhan_khau_item_selected(_index):
	sua_ma_nhan_khau.text = str(sua_chon_ma_nhan_khau.get_selected_id())
	_on_sua_ma_nhan_khau_text_changed(sua_ma_nhan_khau.text)
func _on_them_ma_nhan_khau_text_changed(new_text: String):
	check_ma_nhan_khau(new_text, them_chon_ma_nhan_khau, them_nguoi_chiu_trach_nhiem)
func _on_sua_ma_nhan_khau_text_changed(new_text: String):
	check_ma_nhan_khau(new_text, sua_chon_ma_nhan_khau, sua_nguoi_chiu_trach_nhiem)

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
		confirm.dialog_text = "Xóa thông tin chi phí này?\nThông tin đã xóa sẽ không thể truy hồi lại!"
		confirm.show()
		current_form = form_edit
	else:
		accept.dialog_text = "Không có thông tin chi phí nào được chọn!"
		accept.show()

func _on_xoa_het_button_pressed():
	confirm.dialog_text = "Xóa hết thông tin chi phí?\nThông tin đã xóa sẽ không thể truy hồi lại!"
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
		if confirm.dialog_text == "Xóa thông tin chi phí này?\nThông tin đã xóa sẽ không thể truy hồi lại!":
			Effect.delete(tableName, current_pk, accept)
		if confirm.dialog_text == "Xóa hết thông tin chi phí?\nThông tin đã xóa sẽ không thể truy hồi lại!":
			Effect.delete_all(tableName, accept)
		if confirm.dialog_text == "Sửa thông tin chi phí này?":
			Effect.edit(tableName, current_pk, current_info, accept)
			sua_button.button_pressed = false
		if confirm.dialog_text == "Tải dữ liệu từ tệp lên hệ thống?":
			Effect._import_data_from_excel_file(tableName, file_path.text, self, accept)
#			_import_data_from_excel_file(file_path.text.replace(" ", ""))
		accept.show()
		current_pk = null
	reset_form(current_form)
	readDataFromDB(query_select_all)


































