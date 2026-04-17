-- 1. Tranzaksiya bloki (Xatolik bo'lsa hamma amal bekor bo'ladi)
START TRANSACTION;

INSERT INTO Orders (cust_id, order_date, total_amount) 
VALUES (1, NOW(), 5000.00);

SET @NewOrderID = LAST_INSERT_ID();

INSERT INTO OrderDetails (order_id, prod_id, quantity, unit_price)
SELECT @NewOrderID, prod_id, 2, price FROM Products WHERE prod_id = 2;

UPDATE Products 
SET stock_quantity = stock_quantity - 2 
WHERE prod_id = 2 AND stock_quantity >= 2;

-- Agar yangilanish amalga oshmasa (stock yetmasa), ROLLBACK qilish kerak
COMMIT;

-- 2. Ma'lumotlarni qidirishni tezlashtirish uchun Indekslar
CREATE INDEX idx_order_date ON Orders(order_date);
CREATE INDEX idx_customer_region ON Customers(region);

-- 3. Rahbarlar uchun hisobot ko'rinishi (View)
CREATE OR REPLACE VIEW Management_Dashboard AS
SELECT 
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    SUM(e.salary) AS monthly_payroll,
    (SELECT SUM(total_amount) FROM Orders) AS total_company_revenue
FROM Departments d
LEFT JOIN Employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Viewni tekshirish
SELECT * FROM Management_Dashboard;
