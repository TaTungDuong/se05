extends PanelContainer

@onready var node_chucnang = $VBoxContainer/ChucNang
@onready var node_thanhcongcu = $VBoxContainer/ThanhCongCu

func _ready():
	_on_thong_tin_ca_nhan_pressed()
	_on_chuc_nang_tab_selected(0)

func _on_chuc_nang_tab_selected(tab):
	var current_tab = node_chucnang.get_child(tab)
	if current_tab.has_method("readDataFromDB"):
		current_tab.call_deferred("readDataFromDB", current_tab.query_select_all)
	if current_tab.has_method("reset_tables"):
		current_tab.call_deferred("reset_tables")

func update_toggle(button_name: String):
	for c in node_thanhcongcu.get_children():
		if c is Button:
			if c.name != button_name:
				c.button_pressed = false
			else:
				c.button_pressed = true

func _on_danh_sach_nguoi_dung_pressed():
	node_chucnang.current_tab = node_chucnang.get_tab_count() - 1
	update_toggle("DanhSachNguoiDung")
func _on_thong_tin_ca_nhan_pressed():
	node_chucnang.current_tab = 0
	update_toggle("ThongTinCaNhan")
func _on_doi_mat_khau_pressed():
	node_chucnang.current_tab = 1
	update_toggle("DoiMatKhau")














