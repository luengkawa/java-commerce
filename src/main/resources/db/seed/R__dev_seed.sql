-- 开发/测试数据。只在 local profile 的 Flyway locations 中加载，prod 不执行。
-- 使用固定主键 + INSERT IGNORE：重复执行不会产生重复行，也不会覆盖本地已修改的数据。
-- 注意：固定主键 1~5 在开发库中保留给本文件，业务测试不要占用这些 ID。

INSERT IGNORE INTO app_user (id, username, display_name, status) VALUES
    (1, 'alice', 'Alice 开发账号', 'ACTIVE'),
    (2, 'bob', 'Bob 开发账号', 'ACTIVE');

INSERT IGNORE INTO product (id, name, description, status) VALUES
    (1, '机械键盘', '87 键热插拔机械键盘', 'ON_SALE'),
    (2, '无线鼠标', '2.4G 无线鼠标', 'ON_SALE'),
    (3, '27 英寸 4K 显示器', '已下架商品，用于验证不可售商品不能创建订单', 'OFF_SALE'),
    (4, '库存清零演示商品', '库存为 0，用于验证库存不足时整单回滚', 'ON_SALE');

INSERT IGNORE INTO sku (id, product_id, sku_code, spec, price, status) VALUES
    (1, 1, 'KB-87-BLACK', '配色:黑色;轴体:红轴', 399.00, 'ON_SALE'),
    (2, 1, 'KB-87-WHITE', '配色:白色;轴体:茶轴', 419.00, 'ON_SALE'),
    (3, 2, 'MS-WL-BLACK', '配色:黑色', 129.00, 'ON_SALE'),
    (4, 3, 'MON-27-4K', '尺寸:27 英寸;分辨率:3840x2160', 1999.00, 'OFF_SALE'),
    (5, 4, 'ZERO-STOCK', '用途:库存不足测试', 9.90, 'ON_SALE');

INSERT IGNORE INTO inventory (sku_id, available_quantity, reserved_quantity) VALUES
    (1, 100, 0),
    (2, 50, 0),
    (3, 200, 0),
    (4, 5, 0),
    (5, 0, 0);

INSERT IGNORE INTO inventory_log
    (id, sku_id, order_id, change_type, available_delta, reserved_delta,
     available_after, reserved_after, reason)
VALUES
    (1, 1, NULL, 'INIT', 100, 0, 100, 0, '开发数据初始化'),
    (2, 2, NULL, 'INIT', 50, 0, 50, 0, '开发数据初始化'),
    (3, 3, NULL, 'INIT', 200, 0, 200, 0, '开发数据初始化'),
    (4, 4, NULL, 'INIT', 5, 0, 5, 0, '开发数据初始化'),
    (5, 5, NULL, 'INIT', 0, 0, 0, 0, '开发数据初始化');
