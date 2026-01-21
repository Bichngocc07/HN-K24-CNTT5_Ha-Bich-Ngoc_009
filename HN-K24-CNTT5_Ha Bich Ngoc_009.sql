CREATE DATABASE book_shippers;
USE book_shippers;

-- 1.Thiết kế bảng--
CREATE TABLE Shippers( 
	Shipper_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone_name VARCHAR(20) NOT NULL,
    type_license VARCHAR(100) NOT NULL,
    point_review INT DEFAULT 0
);

CREATE TABLE Vehicle_Details ( 
	Vehicle_code INT AUTO_INCREMENT PRIMARY KEY,
    shippers_id VARCHAR(10) NOT NULL UNIQUE,
    licese_plate VARCHAR(100) NOT NULL,
    vehicle_type ENUM('Tải', 'Xe máy' , 'Container')
	CONSTRAINT maximum_load CHECK (price_per_night > 0)
);

CREATE TABLE Shipments ( 
	Tracking_number INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    actual_weight 
    CONSTRAINT value_goods CHECK (price_per_night > 0)
    shipments_status ENUM('In Transit', 'Delivered', 'Returned') NOT NULL,
);

CREATE TABLE Delivery_Orders ( 
	Dispatch_voucher INT AUTO_INCREMENT PRIMARY KEY,
    shippers_id VARCHAR(100) NOT NULL,
    driver_charge VARCHAR(100) NOT NULL,
    coordination_time VARCHAR(100) NOT NULL,
    shipping_fee VARCHAR(100) NOT NULL,
    status_ticket ENUM('Pending', 'Processing', 'Finished') NOT NULL,
);

CREATE TABLE Delivery_Log ( 
	Log_code INT AUTO_INCREMENT PRIMARY KEY,
    dispatch_voucher INT NOT NULL
    current_location VARCHAR(100) ,
    recording_time VARCHAR(100) NOT NULL,
    Delivery_note VARCHAR(100) NOT NULL,
);

-- 2.DML
INSERT INTO Shippers (Shippers_id, full_name, phone_number, type_license, point_review) VALUE
(1, 'Nguyen Van An', '0901234567', 'C', 4.8)
(2, 'Tran Thi Binh', '0912345678', 'A2', 5.0)
(3, 'Le Hoang Nam', '0983456789', 'FC', 4.2)
(4, 'Pham Minh Duc', '0354567890', 'B2', 4.9)
(5, 'Hoang Quoc Viet', '0775678901', 'C', 4.7)
INSERT INTO Vehicle_Details (Vehicle_code, shippers_id, licese_plate, vehicle_type, maximum_load) VALUE
(101, '1', '29C-123.45', 'Tải', 3500)
(102, '2', '59A-888.88', 'Xe máy', 500)
(103, '3', '15R-999.99', 'Container', 32000)
(104, '4', '30F-111.22', 'Tải', 1500)
(105, '5', '43C-444.55', 'Tải', 5000)
INSERT INTO Shipments (Tracking_number, product_name, actual_weight, value_goods, shipments_status) VALUE
(5001, 'Smart TV Samsung 55 inch', '25.5', 15000000, 'In Transit')
(5002, 'Laptop Dell XPS', '2.0', 35000000, 'Delivered')
(5003, 'Máy nén khí công nghiệp', '450.0', 120000000, 'In Transit')
(5004, 'Thùng trái cây nhập khẩu', '15.0', 2500000, 'Returned')
(5005, 'Máy giặt LG Inverter', '70.0', 9500000, 'In Transit')
INSERT INTO Delivery_Orders (Dispatch_voucher, shippers_id, driver_charge, coordination_time, shipping_fee, status_ticket) VALUE
(9001, '5001', '1', '2024-05-20 08:00:00', 2000000, 'Processing')
(9002, '5002', '2', '2024-05-20 09:30:00', 3500000, 'Finished')
(9003, '5003', '3', '2024-05-20 10:15:00', 2500000, 'Processing')
(9004, '5004', '5', '2024-05-21 07:00:00', 1500000, 'Finished')
(9005, '5005', '4', '2024-05-21 08:45:00', 2500000, 'Pending')
INSERT INTO Delivery_Log (Log_code, dispatch_voucher, current_location, recording_time, Delivery_note) VALUE
(1, '9001', 'Kho tổng (Hà Nội)', 2021-05-15 08:15:00, 'Rời kho')
(2, '9002', 'Trạm thu phí Phủ Lý', 2021-05-17 10:00:00, 'Đang giao')
(3, '9003', 'Quận 1, TP.HCM', 2024-05-19 10:30:00, 'Đã đến điểm đích')
(4, '9004', 'Cảng Hải Phòng', 2024-05-20 11:00:00, 'Rời kho')
(5, '9005', 'Kho hoàn hàng (Đà Nẵng)', 2024-05-21 14:00:00, 'Đã nhập kho trả hàng')

-- 1. Viết câu lệnh tăng phí vận chuyển thêm 10% cho tất cả các 
-- phiếu điều phối có trạng thái 'Finished' và có trọng lượng hàng hóa lớn hơn 100kg.

  -- 2. Viết câu lệnh xóa các bản ghi trong nhật ký di chuyển (Delivery_Log) 
  -- có thời điểm ghi nhận trước ngày 17/05/2024.




