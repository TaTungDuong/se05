extends Node2D

##NhanKhau
#entry.1025688313: MaNhanKhau
#entry.2035152205: HoVaTen
#entry.1718051719: GioiTinh
#entry.2033788359: NgaySinh
#entry.1657923921: SDT
#entry.2101273969: QueQuan
#entry.956166893: DanToc
#entry.28263729: NgheNghiep
#entry.2037629525: CMND
#entry.630180045: MaHoKhau
#entry.1924808652: GhiChu
const url_submit = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSfjDy1MuKNskg_qeb0Vp9lkCa7l5uH8caSDg0Qx-z3o9HmzAA/formResponse"
const headers = ["Content-Type: application/x-www-form-urlencoded"]
var client = HTTPClient.new()

func update():
	pass

func insert(info):
	var http = HTTPRequest.new()
	add_child(http)
	
	var data = client.query_string_from_dict({
		"entry.1025688313": info["MaNhanKhau"],
		"entry.2035152205": info["HoVaTen"],
		"entry.1718051719": info["GioiTinh"],
		"entry.2033788359": info["NgaySinh"],
		"entry.1657923921": info["SDT"],
		"entry.2101273969": info["QueQuan"],
		"entry.956166893": info["DanToc"],
		"entry.28263729": info["NgheNghiep"],
		"entry.2037629525": info["CMND"],
		"entry.630180045": info["MaHoKhau"],
		"entry.1924808652": info["GhiChu"],
	})
	var err = http.request(url_submit, headers, HTTPClient.METHOD_POST, data)
	if err:
		print(err)

















