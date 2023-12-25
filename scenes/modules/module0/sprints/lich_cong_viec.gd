extends VBoxContainer

@onready var vtable = $Table/HBoxContainer/DanhSachCongViec/Table/Table/VTable
@onready var submenu_table = $Table/HBoxContainer2/SubmenuTable
@onready var box_form = $ScrollContainer
@onready var table_buttons = $Table/HBoxContainer2/TableButtons
@onready var danh_sach = $Table
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
const tableName = "CongViec"
const query_select_all_tmp = "select * from " + tableName + " where Date(ThoiDiem) = 'yyyy-mm-dd%' order by ThoiDiem ASC;"
var query_select_all = ""

@onready var fields = $ScrollContainer/HBoxContainer/TruongThongTin
@onready var form = $ScrollContainer/HBoxContainer/DienThongTinCongViec
@onready var popup = $Popup/PopupMenu
@onready var confirm = $Popup/ConfirmationDialog
@onready var accept = $Popup/AcceptDialog
@onready var file = $Popup/FileDialog
@onready var doc_file = $Popup/DocFileDialog

@onready var hien_tai = $PanelContainer/VBoxContainer/HBoxContainer/HienTai
var current_date

func _ready():
	current_year = Time.get_date_dict_from_system()["year"]
	current_month = Time.get_datetime_dict_from_system()["month"]
	current_date = Effect.get_current_date(hien_tai)
	reset_filters()
	set_days_in_month()
	window_hide()
	Effect.set_ngay_thang_nam(nam_cv, thang_cv, ngay_cv)
	readDataFromDB(query_select_all)
	_on_submenu_table_pressed()

func _physics_process(_delta):
	thang_nam.text = "Tháng " + str(current_month) + " Năm " + str(current_year)

@onready var nam_cv = $ScrollContainer/HBoxContainer/DienThongTinCongViec/ThoiDiem/Ngay/Nam
@onready var thang_cv = $ScrollContainer/HBoxContainer/DienThongTinCongViec/ThoiDiem/Ngay/Thang
@onready var ngay_cv = $ScrollContainer/HBoxContainer/DienThongTinCongViec/ThoiDiem/Ngay/Ngay
@onready var gio_cv = $ScrollContainer/HBoxContainer/DienThongTinCongViec/ThoiDiem/Gio
var row_inst = preload("res://scenes/global_elements/elements/row.tscn")
var cell_inst = preload("res://scenes/global_elements/elements/cell.tscn")
var cell_menu = preload("res://scenes/global_elements/elements/cell_menu.tscn")
func readDataFromDB(_query: String):
	var nam = str(current_year)
	var thang = str(current_month)
	if thang.length() < 2:
		thang = "0" + thang
	var ngay = str(current_day)
	if ngay.length() < 2:
		ngay = "0" + ngay
	var current_datetime = "'" + nam + "-" + thang + "-" + ngay + "'"
	query_select_all = query_select_all_tmp.replace("'yyyy-mm-dd%'", current_datetime)
	print(query_select_all)
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
		if "Ma" in r["name"]:
			row.visible = false
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
			if "Ma" in c.name:
				cell.visible = false
	set_ma_nguoi_dung()
	
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
				nam = str(nam_cv.get_selected_id())
				thang = str(thang_cv.get_selected_id())
				if thang.length() < 2:
					thang = "0" + thang
				ngay = str(ngay_cv.get_selected_id())
				if ngay.length() < 2:
					ngay = "0" + ngay
				info[f["name"]] = nam + "-" + thang + "-" + ngay + " " + gio_cv.text
				print(info[f["name"]])
				if Effect.check_datetime_valid(info[f["name"]]) == false:
					valid = false
					popup.add_item("Thông tin ngày hoặc giờ không hợp lệ!")
			elif f["name"] == "MaNguoiDung":
				info[f["name"]] = str(DB.current_user["MaNguoiDung"])
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
		current_info = info
		if action == "insert":
			confirm.dialog_text = "Thêm thông tin công việc này?"
			confirm.show()
		if action == "edit":
			confirm.dialog_text = "Sửa thông tin công việc này?"
			confirm.show()
		return true
	popup.show()
	return false

func reset_form():
	for f in form.get_children():
		current_pk = null
		if f.name == "ThoiDiem":
			nam_cv.select(0)
			thang_cv.select(0)
			ngay_cv.select(0)
			gio_cv.text = ""
		if "ThoiDiem" not in f.name and "Buffer" not in f.name and f.name != "MaNguoiDung":
			f.text = ""
func release_focus_form():
	for f in form.get_children():
		if f.name == "ThoiDiem":
			nam_cv.release_focus()
			thang_cv.release_focus()
			ngay_cv.release_focus()
			gio_cv.release_focus()
		if "ThoiDiem" not in f.name and f.name != "MaNguoiDung":
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
				if "Buffer" not in f.name and f.name != "MaNguoiDung":
					if "ThoiDiem" in f.name:
						var dict = Effect.extract_datetime(result[0][f.name])
						nam_cv.select(dict["nam"] + 1 - 2000)
						thang_cv.select(dict["thang"])
						ngay_cv.select(dict["ngay"])
						gio_cv.text = dict["gio"]
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

var current_month
var current_year
var current_day
@onready var thang_nam = $PanelContainer/VBoxContainer/HBoxContainer2/ThangNam
@onready var truoc_button = $PanelContainer/VBoxContainer/HBoxContainer2/Truoc
@onready var sau_button = $PanelContainer/VBoxContainer/HBoxContainer2/Sau
func _on_truoc_pressed():
	if current_month == 1:
		if current_year == 2000:
			truoc_button.disabled = true
		else:
			current_month = 12
			current_year = current_year - 1
	else:
		current_month = current_month - 1
	sau_button.disabled = false
	set_days_in_month()
func _on_sau_pressed():
	if current_month == 12:
		if current_year == 2099:
			sau_button.disabled = true
		else:
			current_month = 1
			current_year = current_year + 1
	else:
		current_month = current_month + 1
	truoc_button.disabled = false
	set_days_in_month()

@onready var ngay_trong_thang = $PanelContainer/VBoxContainer/NgayTrongThang
@export var is_chosen = false
signal day_pressed(row, col)
func set_days_in_month():
	var number_of_days = Effect.get_days_in_month(current_year, current_month)
	var pos = 1
	for c in range(ngay_trong_thang.get_child_count()):
		for i in range(7):
			if ngay_trong_thang.get_child(c).get_child(i).is_connected("day_chosen", _on_day_chosen) == false:
				ngay_trong_thang.get_child(c).get_child(i).day_chosen.connect(_on_day_chosen)
			ngay_trong_thang.get_child(c).get_child(i).text = ""
			ngay_trong_thang.get_child(c).get_child(i).disabled = true
			ngay_trong_thang.get_child(c).get_child(i).flat = true
	var first_day = Time.get_datetime_dict_from_datetime_string(str(current_year) + "-" + str(current_month) + "-1", 1)
	for i in range(first_day["weekday"], 7):
		ngay_trong_thang.get_child(0).get_child(i).text = str(pos)
		ngay_trong_thang.get_child(0).get_child(i).disabled = false
		pos = pos + 1
	for c in range(1, ngay_trong_thang.get_child_count()):
		for i in range(7):
			if pos <= number_of_days:
				ngay_trong_thang.get_child(c).get_child(i).text = str(pos)
				ngay_trong_thang.get_child(c).get_child(i).disabled = false
				pos = pos + 1
			else:
				ngay_trong_thang.get_child(c).get_child(i).text = ""
				ngay_trong_thang.get_child(c).get_child(i).disabled = true
	for c in range(ngay_trong_thang.get_child_count()):
		for i in range(7):
			if current_date == str(current_year) + "-" + str(current_month) + "-" + str(ngay_trong_thang.get_child(c).get_child(i).text):
				ngay_trong_thang.get_child(c).get_child(i).flat = is_chosen
				ngay_trong_thang.get_child(c).get_child(i).focus_mode = FOCUS_CLICK
				_on_day_chosen(ngay_trong_thang.get_child(c).get_child(i))
			else:
				if ngay_trong_thang.get_child(c).get_child(i).text == "":
					ngay_trong_thang.get_child(c).get_child(i).flat = true
					ngay_trong_thang.get_child(c).get_child(i).focus_mode = FOCUS_NONE
				else:
					ngay_trong_thang.get_child(c).get_child(i).flat = not is_chosen
					ngay_trong_thang.get_child(c).get_child(i).focus_mode = FOCUS_CLICK

func _on_day_chosen(day: Button):
	for c in range(ngay_trong_thang.get_child_count()):
		for i in range(7):
			ngay_trong_thang.get_child(c).get_child(i).button_pressed = false
	day.button_pressed = true
	current_day = int(day.text)
	readDataFromDB(query_select_all)

@onready var ma_nguoi_dung = $ScrollContainer/HBoxContainer/DienThongTinCongViec/MaNguoiDung/MaNguoiDung
@onready var chon_ma_nguoi_dung = $ScrollContainer/HBoxContainer/DienThongTinCongViec/MaNguoiDung/ChonMaNguoiDung
func set_ma_nguoi_dung():
	ma_nguoi_dung.text = str(DB.current_user["MaNguoiDung"])
	chon_ma_nguoi_dung.clear()
	chon_ma_nguoi_dung.add_item(str(DB.current_user["MaNguoiDung"]) + "|" + DB.current_user["HoVaTen"])
####################################################################################################
@onready var them_button = $HBoxContainer/ThemButton
@onready var sua_button = $HBoxContainer/SuaButton
func _process(_delta):
	them_button.visible = (current_pk == null)
	sua_button.visible = not (current_pk == null)
	
func _on_them_button_pressed():
	window_hide()
	_on_form_filled_in("insert")

func _on_sua_button_pressed():
	window_hide()
	_on_form_filled_in("edit")

func _on_xoa_button_pressed():
	if current_pk != null:
		confirm.dialog_text = "Xóa thông tin công việc này?\nThông tin đã xóa sẽ không thể truy hồi lại!"
		confirm.show()
	else:
		accept.dialog_text = "Không có thông tin công việc nào được chọn!"
		accept.show()

func _on_xoa_het_button_pressed():
	confirm.dialog_text = "Xóa hết thông tin công việc?\nThông tin đã xóa sẽ không thể truy hồi lại!"
	confirm.show()

func _on_lam_moi_button_pressed():
	readDataFromDB(query_select_all)
	reset_form()

func _on_confirmation_dialog_confirmed():
	if confirm.dialog_text == "Thêm thông tin công việc này?":
		Effect.insert(tableName, current_info, accept)
	if confirm.dialog_text == "Xóa thông tin công việc này?\nThông tin đã xóa sẽ không thể truy hồi lại!":
		Effect.delete(tableName, current_pk, accept)
	if confirm.dialog_text == "Xóa hết thông tin công việc?\nThông tin đã xóa sẽ không thể truy hồi lại!":
		Effect.delete_all(tableName, accept)
	if confirm.dialog_text == "Tải dữ liệu từ tệp lên hệ thống?":
		Effect._import_data_from_excel_file(tableName, file_path.text, self, accept)
	if confirm.dialog_text == "Sửa thông tin công việc này?":
		Effect.edit(tableName, current_pk, current_info, accept)
	accept.show()
	readDataFromDB(query_select_all)
	reset_form()
	release_focus_form()

func _on_mo_tep_button_pressed():
	window_hide()
	file.show()

@onready var file_path = $Table/HBoxContainer2/TableButtons/HBoxContainer2/DuongDanTep
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





























