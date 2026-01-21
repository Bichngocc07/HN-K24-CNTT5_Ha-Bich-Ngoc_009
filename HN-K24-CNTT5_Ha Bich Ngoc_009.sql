CREATE DATABASE book_shippers;
USE book_shippers;

-- 1. Shippers
CREATE TABLE Shippers (
    shipper_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    type_license VARCHAR(10) NOT NULL,
    point_review DECIMAL(2,1) NOT NULL DEFAULT 5.0,
    CONSTRAINT chk_rating CHECK (point_review BETWEEN 0 AND 5)
);

-- 2. Vehicle_Details
CREATE TABLE Vehicle_Details (
    vehicle_code INT PRIMARY KEY,
    shipper_id INT NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type ENUM('Tải','Xe máy','Container') NOT NULL,
    maximum_load DECIMAL(10,1) NOT NULL,
    CONSTRAINT chk_max_load CHECK (maximum_load > 0),
    CONSTRAINT fk_vehicle_shipper FOREIGN KEY (shipper_id)
        REFERENCES Shippers(shipper_id)
);

-- 3. Shipments
CREATE TABLE Shipments (
    tracking_number INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    actual_weight DECIMAL(10,1) NOT NULL,
    value_goods DECIMAL(15,2) NOT NULL,
    shipments_status ENUM('In Transit','Delivered','Returned') NOT NULL,
    CONSTRAINT chk_weight CHECK (actual_weight > 0)
);

-- 4. Delivery_Orders
CREATE TABLE Delivery_Orders (
    dispatch_voucher INT PRIMARY KEY,
    tracking_number INT NOT NULL,
    shipper_id INT NOT NULL,
    coordination_time DATETIME NOT NULL DEFAULT NOW(),
    shipping_fee DECIMAL(15,2) NOT NULL,
    status_ticket ENUM('Pending','Processing','Finished') NOT NULL,
    CONSTRAINT fk_order_shipper FOREIGN KEY (shipper_id)
        REFERENCES Shippers(shipper_id),
    CONSTRAINT fk_order_shipment FOREIGN KEY (tracking_number)
        REFERENCES Shipments(tracking_number)
);

-- 5. Delivery_Log
CREATE TABLE Delivery_Log (
    log_code INT PRIMARY KEY,
    dispatch_voucher INT NOT NULL,
    current_location VARCHAR(255) NOT NULL,
    recording_time DATETIME NOT NULL DEFAULT NOW(),
    delivery_note VARCHAR(255) NOT NULL,
    CONSTRAINT fk_log_order FOREIGN KEY (dispatch_voucher)
        REFERENCES Delivery_Orders(dispatch_voucher)
);

-- 2.DML
INSERT INTO Shippers VALUES
(1,'Nguyen Van An','0901234567','C',4.8),
(2,'Tran Thi Binh','0912345678','A2',5.0),
(3,'Le Hoang Nam','0983456789','FC',4.2),
(4,'Pham Minh Duc','0354567890','B2',4.9),
(5,'Hoang Quoc Viet','0775678901','C',4.7);

INSERT INTO Vehicle_Details VALUES
(101,1,'29C-123.45','Tải',3500),
(102,2,'59A-888.88','Xe máy',500),
(103,3,'15R-999.99','Container',32000),
(104,4,'30F-111.22','Tải',1500),
(105,5,'43C-444.55','Tải',5000);

INSERT INTO Shipments VALUES
(5001,'Smart TV Samsung 55 inch',25.5,15000000,'In Transit'),
(5002,'Laptop Dell XPS',2.0,35000000,'Delivered'),
(5003,'Máy nén khí công nghiệp',450.0,120000000,'In Transit'),
(5004,'Thùng trái cây nhập khẩu',15.0,2500000,'Returned'),
(5005,'Máy giặt LG Inverter',70.0,9500000,'In Transit');

INSERT INTO Delivery_Orders VALUES
(9001,5001,1,'2024-05-20 08:00:00',2000000,'Processing'),
(9002,5002,2,'2024-05-20 09:30:00',3500000,'Finished'),
(9003,5003,3,'2024-05-20 10:15:00',2500000,'Processing'),
(9004,5004,5,'2024-05-21 07:00:00',1500000,'Finished'),
(9005,5005,4,'2024-05-21 08:45:00',2500000,'Pending');

INSERT INTO Delivery_Log VALUES
(1,9001,'Kho tổng (Hà Nội)','2021-05-15 08:15:00','Rời kho'),
(2,9001,'Trạm thu phí Phủ Lý','2021-05-17 10:00:00','Đang giao'),
(3,9002,'Quận 1, TP.HCM','2024-05-19 10:30:00','Đã đến điểm đích'),
(4,9003,'Cảng Hải Phòng','2024-05-20 11:00:00','Rời kho'),
(5,9004,'Kho hoàn hàng (Đà Nẵng)','2024-05-21 14:00:00','Đã nhập kho trả hàng');
-- a.
UPDATE Delivery_Orders o
JOIN Shipments s ON s.tracking_number = o.tracking_number
SET o.shipping_fee = o.shipping_fee * 1.1
WHERE o.status_ticket = 'Finished'
  AND s.actual_weight > 100;
-- b.
DELETE FROM Delivery_Log
WHERE recording_time < '2024-05-17 00:00:00';

-- Câu 1
-- Tải trọng > 5000 HOẶC (Container nhưng < 2000)

SELECT license_plate, vehicle_type, maximum_load
FROM Vehicle_Details
WHERE maximum_load > 5000
   OR (vehicle_type = 'Container' AND maximum_load < 2000);

-- Câu 2
-- Điểm đánh giá 4.5–5.0 và số điện thoại bắt đầu “090”

SELECT full_name, phone_number
FROM Shippers
WHERE point_review BETWEEN 4.5 AND 5.0
  AND phone_number LIKE '090%';

-- Câu 3
-- Trang thứ 2, mỗi trang 2 đơn ⇒ OFFSET = 2, sắp xếp giảm dần theo Giá trị hàng hóa

SELECT tracking_number, product_name, actual_weight, value_goods, shipments_status
FROM Shipments
ORDER BY value_goods DESC
LIMIT 2 OFFSET 2;

-- Câu 1: Composite Index
CREATE INDEX idx_shipment_status_value
ON Shipments (shipments_status, value_goods);

-- Câu 2: View vw_driver_performance

CREATE OR REPLACE VIEW vw_driver_performance AS
SELECT
    s.full_name,
    COUNT(o.dispatch_voucher) AS total_trips,
    COALESCE(SUM(o.shipping_fee), 0) AS total_revenue
FROM Shippers s
LEFT JOIN Delivery_Orders o
    ON o.shipper_id = s.shipper_id
GROUP BY s.shipper_id, s.full_name;
-- Câu 1: Trigger trg_after_delivery_finish
CREATE TRIGGER trg_after_delivery_finish
AFTER UPDATE ON Delivery_Orders
FOR EACH ROW
BEGIN
    IF NEW.status_ticket = 'Finished' AND OLD.status_ticket <> 'Finished' THEN
        INSERT INTO Delivery_Log ( /* log_id nếu AUTO_INCREMENT thì bỏ */, dispatch_voucher, current_location, recording_time, delivery_note )
        VALUES (
            /* NULL nếu log_id AUTO_INCREMENT */,
            NEW.dispatch_voucher,
            'Tại điểm đích',
            NOW(),
            'Delivery Completed Successfully'
        );
    END IF;
END//

DELIMITER ;
-- Câu 2: Trigger trg_update_driver_rating
DROP TRIGGER IF EXISTS trg_update_driver_rating;
DELIMITER //

CREATE TRIGGER trg_update_driver_rating
AFTER INSERT ON Delivery_Orders
FOR EACH ROW
BEGIN
    IF NEW.status_ticket = 'Finished' THEN
        UPDATE Shippers
        SET point_review = LEAST(5.0, point_review + 0.1)
        WHERE shipper_id = NEW.shipper_id;
    END IF;
END//

DELIMITER ;
-- PHẦN 4: INDEX VÀ VIEW (10 ĐIỂM) - Câu 1 (5đ): Tạo một Composite Index tên
-- idx_shipment_status_value trên bảng Shipments gồm hai cột: Trạng thái và Giá trị hàng hóa.
CREATE INDEX idx_shipment_status_value
ON Shipments (shipments_status, value_goods);

