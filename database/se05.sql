BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS "NguoiDung" (
	"MaNguoiDung"	INTEGER UNIQUE,
	"TenDangNhap"	TEXT NOT NULL UNIQUE,
	"HoVaTen"	TEXT NOT NULL,
	"MatKhau"	TEXT NOT NULL,
	"GioiTinh"	INTEGER NOT NULL,
	"NgaySinh"	NUMERIC NOT NULL,
	"ChucVu"	INTEGER NOT NULL,
	"MaNhanKhau"	INTEGER,
	"GhiChu"	TEXT,
	"NhoTaiKhoan"	INTEGER DEFAULT 0,
	PRIMARY KEY("MaNguoiDung" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "ChucVu" (
	"ChucVu"	INTEGER,
	"TenChucVu"	TEXT
);

CREATE TABLE IF NOT EXISTS "NhanKhau" (
	"MaNhanKhau"	INTEGER UNIQUE,
	"HoVaTen"	TEXT NOT NULL,
	"GioiTinh"	TEXT NOT NULL,
	"NgaySinh"	NUMERIC NOT NULL,
	"SDT"	TEXT,
	"QueQuan"	TEXT,
	"DanToc"	TEXT,
	"NgheNghiep"	TEXT,
	"CMND"	TEXT UNIQUE,
	"MaHoKhau"	TEXT,
	"QuanHeVoiChuHo"	TEXT,
	"GhiChu"	TEXT,
	PRIMARY KEY("MaNhanKhau" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "LichSuNhanKhau" (
	"MaLichSuNhanKhau"	INTEGER UNIQUE,
	"MaNhanKhau"	INTEGER NOT NULL,
	"HoVaTen"	TEXT,
	"GioiTinh"	TEXT,
	"NgaySinh"	NUMERIC,
	"SDT"	TEXT,
	"QueQuan"	TEXT,
	"DanToc"	TEXT,
	"NgheNghiep"	TEXT,
	"CMND"	TEXT,
	"MaHoKhau"	TEXT,
	"QuanHeVoiChuHo"	TEXT,
	"GhiChu"	TEXT,
	"NgayThem"	NUMERIC NOT NULL,
	"SuaDoiLanCuoi"	NUMERIC NOT NULL,
	"HoatDong"	TEXT NOT NULL,
	PRIMARY KEY("MaLichSuNhanKhau" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "HoKhau" (
	"MaHoKhau"	INTEGER UNIQUE,
	"MaChuHo"	INTEGER,
	"SoNha"	INTEGER,
	"DuongPho"	TEXT NOT NULL,
	"ThiTran"	TEXT NOT NULL,
	"QuanHuyen"	TEXT NOT NULL,
	"TinhThanh"	TEXT NOT NULL,
	"GhiChu"	TEXT,
	PRIMARY KEY("MaHoKhau" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "LichSuHoKhau" (
	"MaLichSuHoKhau"	INTEGER UNIQUE,
	"MaHoKhau"	INTEGER,
	"MaChuHo"	INTEGER,
	"SoNha"	INTEGER,
	"DuongPho"	TEXT,
	"ThiTran"	TEXT,
	"QuanHuyen"	TEXT,
	"TinhThanh"	TEXT,
	"GhiChu"	TEXT,
	"NgayThem"	NUMERIC NOT NULL,
	"SuaDoiLanCuoi"	NUMERIC NOT NULL,
	"HoatDong"	TEXT NOT NULL,
	PRIMARY KEY("MaLichSuHoKhau" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "TamVang" (
	"MaTamVang"	INTEGER UNIQUE,
	"MaNhanKhau"	INTEGER NOT NULL,
	"SoNhaTamTru"	TEXT,
	"DuongPhoTamTru"	TEXT,
	"ThiTranTamTru"	TEXT NOT NULL,
	"QuanHuyenTamTru"	TEXT NOT NULL,
	"TinhThanhTamTru"	TEXT NOT NULL,
	"ThoiDiemDi"	NUMERIC NOT NULL,
	"ThoiDiemVe"	NUMERIC NOT NULL,
	"LyDo"	TEXT NOT NULL,
	"GhiChu"	TEXT,
	PRIMARY KEY("MaTamVang" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "LichSuTamVang" (
	"MaLichSuTamVang"	INTEGER UNIQUE,
	"MaTamVang"	INTEGER,
	"MaNhanKhau"	INTEGER,
	"SoNhaTamTru"	TEXT,
	"DuongPhoTamTru"	TEXT,
	"ThiTranTamTru"	TEXT,
	"QuanHuyenTamTru"	TEXT,
	"TinhThanhTamTru"	TEXT,
	"ThoiDiemDi"	NUMERIC,
	"ThoiDiemVe"	NUMERIC,
	"LyDo"	TEXT,
	"GhiChu"	TEXT,
	"NgayThem"	NUMERIC,
	"SuaDoiLanCuoi"	NUMERIC,
	"HoatDong"	NUMERIC,
	PRIMARY KEY("MaLichSuTamVang" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "TamTru" (
	"MaTamTru"	INTEGER UNIQUE,
	"HoVaTen"	TEXT NOT NULL,
	"NgaySinh"	NUMERIC NOT NULL,
	"CMND"	TEXT UNIQUE,
	"SoNhaTamTru"	TEXT,
	"DuongPhoTamTru"	TEXT,
	"ThiTranTamTru"	TEXT NOT NULL,
	"QuanHuyenTamTru"	TEXT NOT NULL,
	"TinhThanhTamTru"	TEXT NOT NULL,
	"ThoiDiemDi"	NUMERIC NOT NULL,
	"ThoiDiemVe"	NUMERIC NOT NULL,
	"LyDo"	TEXT NOT NULL,
	"GhiChu"	TEXT,
	PRIMARY KEY("MaTamTru" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "LichSuTamTru" (
	"MaLichSuTamTru"	INTEGER UNIQUE,
	"MaTamTru"	INTEGER,
	"HoVaTen"	TEXT,
	"NgaySinh"	NUMERIC,
	"CMND"	TEXT,
	"SoNhaTamTru"	TEXT,
	"DuongPhoTamTru"	TEXT,
	"ThiTranTamTru"	TEXT,
	"QuanHuyenTamTru"	TEXT,
	"TinhThanhTamTru"	TEXT,
	"ThoiDiemDi"	NUMERIC,
	"ThoiDiemVe"	NUMERIC,
	"LyDo"	TEXT,
	"GhiChu"	TEXT,
	"NgayThem"	NUMERIC,
	"SuaDoiLanCuoi"	NUMERIC,
	"HoatDong"	NUMERIC,
	PRIMARY KEY("MaLichSuTamTru" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "LichSuTachHo" (
	"MaLichSuTachHo"	INTEGER UNIQUE,
	"MaHoKhauA"	INTEGER,
	"MaHoKhauB"	INTEGER,
	"NgayThem"	NUMERIC,
	"HoatDong"	TEXT,
	PRIMARY KEY("MaLichSuTachHo" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "ThuPhi" (
	"MaThuPhi"	INTEGER UNIQUE,
	"MaNhanKhau"	INTEGER NOT NULL,
	"MaHoKhau"	INTEGER NOT NULL,
	"BatBuoc"	INTEGER NOT NULL,
	"SoTien"	INTEGER NOT NULL,
	"KhoanThu"	TEXT NOT NULL,
	"HanThu"	NUMERIC,
	"NgayThu"	NUMERIC,
	"GhiChu"	TEXT,
	PRIMARY KEY("MaThuPhi" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "LichSuThuPhi" (
	"MaLichSuThuPhi"	INTEGER UNIQUE,
	"MaThuPhi"	INTEGER NOT NULL,
	"MaNhanKhau"	INTEGER NOT NULL,
	"MaHoKhau"	INTEGER,
	"BatBuoc"	INTEGER NOT NULL,
	"SoTien"	INTEGER NOT NULL,
	"KhoanThu"	TEXT NOT NULL,
	"HanThu"	NUMERIC,
	"NgayThu"	NUMERIC,
	"GhiChu"	TEXT,
	"NgayThem"	NUMERIC NOT NULL,
	"SuaDoiLanCuoi"	NUMERIC NOT NULL,
	"HoatDong"	TEXT NOT NULL,
	PRIMARY KEY("MaLichSuThuPhi" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "ChiPhi" (
	"MaChiPhi"	INTEGER UNIQUE,
	"SoTien"	INTEGER NOT NULL,
	"MucDich"	TEXT NOT NULL,
	"NgayChi"	NUMERIC NOT NULL,
	"NguoiChiuTrachNhiem"	TEXT NOT NULL,
	"MaNhanKhau"	INTEGER NOT NULL,
	"GhiChu"	TEXT,
	PRIMARY KEY("MaChiPhi" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "LichSuChiPhi" (
	"MaLichSuChiPhi"	INTEGER UNIQUE,
	"MaChiPhi"	INTEGER,
	"SoTien"	INTEGER,
	"MucDich"	TEXT,
	"NgayChi"	NUMERIC NOT NULL,
	"NguoiChiuTrachNhiem"	TEXT,
	"MaNhanKhau"	INTEGER,
	"GhiChu"	TEXT,
	"NgayThem"	NUMERIC NOT NULL,
	"SuaDoiLanCuoi"	NUMERIC NOT NULL,
	"HoatDong"	TEXT NOT NULL,
	PRIMARY KEY("MaLichSuChiPhi" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "PhanThuongDipDacBiet" (
	"MaPhanThuongDipDacBiet"	INTEGER,
	"DipDacBiet"	TEXT,
	"Nam"	INTEGER,
	"MaNhanKhau"	INTEGER,
	"MaHoKhau"	INTEGER,
	"PhanThuong"	TEXT,
	"SoTien"	INTEGER,
	"DaNhan"	INTEGER,
	"GhiChu"	INTEGER,
	PRIMARY KEY("MaPhanThuongDipDacBiet" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "LichSuPhanThuongDipDacBiet" (
	"MaLichSuPhanThuongDipDacBiet"	INTEGER,
	"MaPhanThuongDipDacBiet"	INTEGER,
	"DipDacBiet"	TEXT,
	"Nam"	INTEGER,
	"MaNhanKhau"	INTEGER,
	"MaHoKhau"	INTEGER,
	"PhanThuong"	TEXT,
	"SoTien"	INTEGER,
	"DaNhan"	INTEGER,
	"GhiChu"	INTEGER,
	"NgayThem"	NUMERIC NOT NULL,
	"SuaDoiLanCuoi"	NUMERIC NOT NULL,
	"HoatDong"	TEXT NOT NULL,
	PRIMARY KEY("MaLichSuPhanThuongDipDacBiet" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "PhanThuongCuoiNamHoc" (
	"MaPhanThuongCuoiNamHoc"	INTEGER UNIQUE,
	"NamHoc"	TEXT,
	"MaNhanKhau"	INTEGER,
	"MaHoKhau"	INTEGER,
	"Lop"	INTEGER,
	"Truong"	TEXT,
	"DanhHieu"	INTEGER,
	"PhanThuong"	INTEGER,
	"SoTien"	INTEGER,
	"DaNhan"	INTEGER,
	"GhiChu"	TEXT,
	PRIMARY KEY("MaPhanThuongCuoiNamHoc" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "LichSuPhanThuongCuoiNamHoc" (
	"MaLichSuPhanThuongCuoiNamHoc"	INTEGER UNIQUE,
	"MaPhanThuongCuoiNamHoc"	INTEGER,
	"NamHoc"	TEXT,
	"MaNhanKhau"	INTEGER,
	"MaHoKhau"	INTEGER,
	"Lop"	INTEGER,
	"Truong"	TEXT,
	"DanhHieu"	INTEGER,
	"PhanThuong"	INTEGER,
	"SoTien"	INTEGER,
	"DaNhan"	INTEGER,
	"GhiChu"	TEXT,
	"NgayThem"	NUMERIC NOT NULL,
	"SuaDoiLanCuoi"	NUMERIC NOT NULL,
	"HoatDong"	TEXT NOT NULL,
	PRIMARY KEY("MaLichSuPhanThuongCuoiNamHoc" AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS "CongViec" (
	"MaCongViec"	INTEGER,
	"MaNguoiDung"	INTEGER,
	"NoiDung"	TEXT,
	"ThoiDiem"	NUMERIC,
	"NguoiThucHien"	TEXT,
	"GhiChu"	INTEGER,
	PRIMARY KEY("MaCongViec" AUTOINCREMENT)
);
CREATE TABLE "LichSuCongViec" (
	"MaLichSuCongViec"	INTEGER,
	"MaCongViec"	INTEGER,
	"MaNguoiDung"	INTEGER,
	"NoiDung"	TEXT,
	"ThoiDiem"	NUMERIC,
	"NguoiThucHien"	TEXT,
	"GhiChu"	INTEGER,
	"NgayThem"	NUMERIC NOT NULL,
	"SuaDoiLanCuoi"	NUMERIC NOT NULL,
	"HoatDong"	TEXT NOT NULL,
	PRIMARY KEY("MaLichSuCongViec" AUTOINCREMENT)
);

INSERT INTO "ChucVu" VALUES (0,'Quản trị viên');
INSERT INTO "ChucVu" VALUES (1,'Nhân viên');
INSERT INTO "ChucVu" VALUES (2,'Người dùng');
INSERT INTO NguoiDung (TenDangNhap, HoVaTen, MatKhau, GioiTinh, NgaySinh, ChucVu, MaNhanKhau, GhiChu, NhoTaiKhoan)
VALUES ('se05','Admin','123',0,'2003-02-16',0,56,'Dev',1);
COMMIT;
