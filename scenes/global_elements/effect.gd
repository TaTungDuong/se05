extends Node2D

const loading_inst = preload("res://scenes/modules/module0/sprints/loading.tscn")
func generate_loading(node, next_scene):
	var loading = loading_inst.instantiate()
	node.add_child(loading)
	loading.next_scene = next_scene

###########################################################################Functions related to date
const weekday = ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"]
func get_current_date(hien_tai) -> String:
	var today = Time.get_datetime_dict_from_system()
	hien_tai.text = weekday[today["weekday"]] + ", Ngày " + str(today["day"]) + " Tháng " + str(today["month"]) + " Năm " + str(today["year"])
	return str(today["year"]) + "-" + str(today["month"]) + "-" + str(today["day"])
	
func get_days_in_month(year, month):
	if month in [4, 6, 9, 11]:
		return 30
	elif month == 2:
		if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
			return 29
		else:
			return 28
	else:
		return 31

func check_date_valid(nam, thang, ngay):
	if nam == 0 or thang == 0 or ngay == 0:
		return null
	var is_leap_year = (nam % 4 == 0 and nam % 100 != 0) or (nam % 400 == 0)
	if thang == 2:
		if is_leap_year == true and ngay > 29:
			return null
		elif is_leap_year == false and ngay > 28:
			return null
	elif thang in [4, 6, 9, 11] and ngay > 30:
		return null
	var sngay = str(ngay)
	var sthang = str(thang)
	if thang < 10:
		sthang = '0' + sthang
	if ngay < 10:
		sngay = '0' + sngay
	return str(nam) + '-' + sthang + '-' + sngay
func extract_date(date: String):
	var parts = date.split("-")
	var nam = int(parts[0])
	var thang = int(parts[1])
	var ngay = int(parts[2])
	var dict: Dictionary = Dictionary()
	dict["nam"] = nam
	dict["thang"] = thang
	dict["ngay"] = ngay
	return dict

func check_datetime_valid(datetime_string):
	var datetime_regex = RegEx.new()
	datetime_regex.compile("^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) (00|[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$")
	if datetime_regex.search(datetime_string) == null:
		return false
	var date_parts = datetime_string.get_slice(" ", 0).split("-")
	var year = int(date_parts[0])
	var month = int(date_parts[1])
	var day = int(date_parts[2])
	var days_in_month = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if year % 400 == 0 or (year % 100 != 0 and year % 4 == 0):
		days_in_month[2] = 29
	return day <= days_in_month[month]
func extract_datetime(datetime_string):
	var datetime_parts = datetime_string.split(" ")
	var date_parts = datetime_parts[0].split("-")
	var time_parts = datetime_parts[1].split(":")
	
	return {
		"nam": int(date_parts[0]),
		"thang": int(date_parts[1]),
		"ngay": int(date_parts[2]),
		"gio": str(time_parts[0]) + ":" + str(time_parts[1]) + ":" + str(time_parts[2])
	}

func date_to_seconds(date: String) -> Dictionary:
	var parts = date.split("-")
	var datetime = Dictionary()
	datetime["year"] = int(parts[0])
	datetime["month"] = int(parts[1])
	datetime["day"] = int(parts[2])
	datetime["hour"] = 0
	datetime["minute"] = 0
	datetime["second"] = 0
	return datetime

func check_duration(thoi_diem_di: String, thoi_diem_ve: String) -> bool:
	if thoi_diem_di.replace(" ", "") == "" or thoi_diem_ve.replace(" ", "") == "":
		return false
	var di = date_to_seconds(thoi_diem_di)
	var ve = date_to_seconds(thoi_diem_ve)
	if di["year"] > ve["year"]:
		return false
	if di ["year"] == ve["year"] and di["month"] > ve["month"]:
		return false
	if di ["year"] == ve["year"] and di["month"] == ve["month"] and di["day"] > ve["day"]:
		return false
	return true

func array_to_string(arr) -> String:
	var s: String = ""
	for i in range(arr.size()):
		if arr[i] == null:
			s = s + " "
		else:
			s = s + str(arr[i])
		if i == arr.size() - 1:
			s = s + "\n"
		else:
			s = s + ","
	return s

func set_ngay_sinh(nam, thang, ngay):
	for i in range(1, 31 + 1):
		ngay.add_item(str(i), i)
	for i in range(1, 12 + 1):
		thang.add_item(str(i), i)
	for i in range(1900, Time.get_date_dict_from_system()["year"] + 1):
		nam.add_item(str(i), i)
	nam.select(0)
	thang.select(0)
	ngay.select(0)

func set_ngay_thang_nam(nam, thang, ngay):
	for i in range(1, 31 + 1):
		ngay.add_item(str(i), i)
	for i in range(1, 12 + 1):
		thang.add_item(str(i), i)
	for i in range(2000, 2100):
		nam.add_item(str(i), i)
	nam.select(0)
	thang.select(0)
	ngay.select(0)

func is_numeric(s: String) -> bool:
	s = s.replace(" ", "")
	if s == "":
		return false
	for i in s.length():
		if s[i] != '0' and (s[i] < '1' or s[i] > '9'):
			return false
	return true

###########################################################################Functions related to files	
func _import_data_from_excel_file(tableName: String, path: String, node, accept: AcceptDialog):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	db.query("PRAGMA table_info(" + tableName + ");")
	var not_null_result = []
	for r in db.query_result:
		if r["notnull"] == 1:
			not_null_result.append(r["name"])
	
	var excel = ExcelFile.open_file(path)
	var workbook = excel.get_workbook()	
	var sheet = workbook.get_sheet(0) as ExcelSheet
	var table_data = sheet.get_table_data()
	
	var keys = table_data.keys()
	keys.sort()
	var field_names = table_data[keys[0]]
	
	for i in range(1, keys.size()):  # Start from 1 to exclude the first row
		var info: Dictionary = Dictionary()
		var column_data = table_data[keys[i]]
		for field in field_names:
			if field in column_data:
				var cell_value = column_data[field]
				if "Ngay" in field_names[field] or "ThoiDiem" in field_names[field] or field_names[field] == "HanThu":
					var unix_timestamp = (cell_value - 25569) * 86400
					var datetime = Time.get_datetime_dict_from_unix_time(unix_timestamp)
					info[field_names[field]] = Effect.check_date_valid(datetime["year"], datetime["month"], datetime["day"])
					if info[field_names[field]] == "1899-12-31":
						info[field_names[field]] = "1900-01-01"
				elif field_names[field] == "GioiTinh":
					if cell_value == "Nam":
						info[field_names[field]] = 0
					if cell_value == "Nữ":
						info[field_names[field]] = 1
				else:
					info[field_names[field]] = str(cell_value)
			else:
				info[field_names[field]] = null
#		print(info)
		var valid = true
		for f in not_null_result:
			if info[f] == null:
				valid = false
				break
		if valid == true:
			db.insert_row(tableName, info)
			DB.update_current_history(tableName, "", info, "insert")
	node.file_path.set_deferred("text", "")
	if node.has_method("readDataFromDB"):
		node.readDataFromDB(node.query_select_all)
	accept.dialog_text = "Đã tải dữ liệu lên hệ thống thành công!"

func check_field_names(tableName: String, path: String):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	var excel = ExcelFile.open_file(path)
	var workbook = excel.get_workbook()	
	var sheet = workbook.get_sheet(0) as ExcelSheet
	var table_data = sheet.get_table_data()
	
	var keys = table_data.keys()
	keys.sort()
	var field_names = []
	for field in table_data[keys[0]]:
		field_names.append(table_data[keys[0]][field])	
	field_names.sort()
	
	db.query("PRAGMA table_info(" + tableName + ");")
	var result = []
	for r in db.query_result:
		if r["name"] != "Ma" + tableName:
			result.append(r["name"])
	result.sort()
	
	return (field_names == result)


func _save_data_to_excel_file(tableName: String, path: String, duong_dan_tep):
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
	
	db.query("select * from " + tableName + ";")
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


###########################################################################Functions related to db
func insert(tableName: String, current_info: Dictionary, accept: AcceptDialog):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.insert_row(tableName, current_info)
	DB.update_current_history(tableName, "", current_info, "insert")
	accept.dialog_text = "Đã thêm thông tin " + DB.tableVietnameseName[tableName] + "!"
	accept.show()
	
func edit(tableName: String, current_pk: String, current_info: Dictionary, accept: AcceptDialog):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query("PRAGMA table_info(" + tableName + ");")
	var result = db.query_result
	var query = "update " + tableName + " set\n"
	for f in result:
		if f["name"] != "Ma" + tableName:
			if typeof(current_info[f["name"]]) == TYPE_STRING:
				current_info[f["name"]] = '\'' + current_info[f["name"]] + '\''
			elif typeof(current_info[f["name"]]) == TYPE_INT:
				current_info[f["name"]] = str(current_info[f["name"]])
			elif typeof(current_info[f["name"]]) == TYPE_NIL:
				current_info[f["name"]] = "null"
			query = query + f["name"] + '=' + current_info[f["name"]]
			if f["name"] != result[result.size() - 1]["name"]:
				query = query + ",\n"
			else:
				query = query + " \n"
	query = query + "where Ma" + tableName + " = " + current_pk + ';'
	db.query(query)
	DB.update_current_history(tableName, current_pk, current_info, "edit")
#	print(query)
	accept.dialog_text = "Đã cập nhật thông tin " + DB.tableVietnameseName[tableName] + "!"

func delete(tableName: String, current_pk: String, accept: AcceptDialog):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	db.query("select * from " + tableName + " where Ma" + tableName + " = " + current_pk + ';')
	DB.update_current_history(tableName, current_pk, db.query_result[0], "delete")
	db.query("delete from " + tableName + " where Ma" + tableName + " = " + current_pk + ';')
	accept.dialog_text = "Đã xóa thông tin " + DB.tableVietnameseName[tableName] + "!"

func delete_all(tableName: String, accept: AcceptDialog):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
			
	db.query("select * from " + tableName + ";")
	for r in db.query_result:
		DB.update_current_history(tableName, str(r["Ma" + tableName]), r, "delete")
	db.query("delete from " + tableName + ';')
	accept.dialog_text = "Đã xóa hết thông tin " + DB.tableVietnameseName[tableName] + "!"

func split(old_id: String, new_id: String):
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	
	var new_history = Dictionary()
	new_history["MaHoKhauA"] = old_id
	new_history["MaHoKhauB"] = new_id
	new_history["NgayThem"] = str(Time.get_datetime_string_from_system()).replace("T", " ")
	
	new_history["HoatDong"] = "Tách Hộ khẩu mã " + str(new_history["MaHoKhauA"]) + ", tạo Hộ khẩu mới mã " + str(new_history["MaHoKhauB"]) + "."
	new_history["HoatDong"] = new_history["HoatDong"] + "Thành viên Hộ khẩu mã " + str(new_history["MaHoKhauA"]) + ": "
	db.query("select HoVaTen from NhanKhau where MaHoKhau = " + str(new_history["MaHoKhauA"]) + ";")
	for r in db.query_result:
		new_history["HoatDong"] = new_history["HoatDong"] + r["HoVaTen"] + ", "
	new_history["HoatDong"] = new_history["HoatDong"] + "Thành viên Hộ khẩu mã " + str(new_history["MaHoKhauB"]) + ": "
	db.query("select HoVaTen from NhanKhau where MaHoKhau = " + str(new_history["MaHoKhauB"]) + ";")
	for r in db.query_result:
		new_history["HoatDong"] = new_history["HoatDong"] + r["HoVaTen"] + ", "
	db.insert_row("LichSuTachHo", new_history)

#Chon nhan khau
func set_chon_nhan_khau(chon_ma_nhan_khau, separator_name):
	chon_ma_nhan_khau.clear()
	chon_ma_nhan_khau.add_separator("Chọn " + separator_name)
	
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query("select MaNhanKhau, HoVaTen, GioiTinh, NgaySinh from NhanKhau;")
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

func check_ma_nhan_khau(text: String):
	if Effect.is_numeric(text) == false:
		return false
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	var result
	
	db.query("select * from NhanKhau where MaNhanKhau = " + text + ";")
	result = db.query_result
	if result.size() == 0:
		return false
	return true


#Chon ho khau
func set_chon_ho_khau(chon_ma_ho_khau):
	chon_ma_ho_khau.clear()
	chon_ma_ho_khau.add_separator("Chọn hộ khẩu")
	
	var query = "select HoKhau.MaHoKhau, NhanKhau.HoVaTen, HoKhau.SoNha, HoKhau.DuongPho, HoKhau.ThiTran, HoKhau.QuanHuyen, HoKhau.TinhThanh from HoKhau join NhanKhau on HoKhau.MaChuHo = NhanKhau.MaNhanKhau;"
	
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	db.query(query)
	var result = db.query_result
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

func check_ma_ho_khau(text: String) -> bool:
	if Effect.is_numeric(text) == false:
		return false
	var db = SQLite.new()
	db.path = DB.db_name
	db.open_db()
	var result
	
	db.query("select * from HoKhau where MaHoKhau = " + text + ";")
	result = db.query_result
	if result.size() == 0:
		return false
	return true













