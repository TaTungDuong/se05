extends PanelContainer

@onready var node_chucnang = $VBoxContainer/ChucNang
@onready var node_thanhcongcu = $VBoxContainer/ThanhCongCu

func  _ready():
	_on_chuc_nang_tab_selected(0)

func _on_chuc_nang_tab_selected(tab):
	var current_tab = node_chucnang.get_child(tab)
	if current_tab.has_method("readDataFromDB"):
		current_tab.call_deferred("readDataFromDB", current_tab.query_select_all)
	if current_tab.has_method("reset_tables"):
		current_tab.call_deferred("reset_tables")

func update_toggle(button_name: String):
	for c in node_thanhcongcu.get_children():
		if c.name != button_name:
			c.button_pressed = false
		else:
			c.button_pressed = true

func _on_them_nhan_khau_pressed():
	node_chucnang.current_tab = 0
	update_toggle("ThemNhanKhau")
func _on_them_ho_khau_pressed():
	node_chucnang.current_tab = 1
	update_toggle("ThemHoKhau")
func _on_tach_ho_pressed():
	node_chucnang.current_tab = 2
	update_toggle("TachHo")
func _on_tam_tru_pressed():
	node_chucnang.current_tab = 3
	update_toggle("TamTru")
func _on_tam_vang_pressed():
	node_chucnang.current_tab = 4
	update_toggle("TamVang")
func _on_lich_su_pressed():
	node_chucnang.current_tab = 5
	update_toggle("LichSu")
func _on_thong_ke_pressed():
	node_chucnang.current_tab = node_chucnang.get_child_count() - 1
	update_toggle("ThongKe")

