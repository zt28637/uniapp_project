-- 用户操作日志表
CREATE TABLE IF NOT EXISTS user_operation_log (
                                                  id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                                  user_id BIGINT NOT NULL,
                                                  username VARCHAR(50) NOT NULL,
                                                  operation_type VARCHAR(50) NOT NULL,
                                                  operation_desc TEXT,
                                                  ip_address VARCHAR(45),
                                                  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                                  INDEX idx_user_id (user_id),
                                                  INDEX idx_create_time (create_time),
                                                  INDEX idx_user_op_time (user_id, create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- 清空旧数据（可选）
TRUNCATE TABLE user_operation_log;

-- 设置时区
SET time_zone = '+08:00';

-- 定义变量：固定日期为2025-10-28，确保数据范围是10-22到10-28（共7天）
SET @today = '2025-10-28';

-- 插入数据
INSERT INTO user_operation_log
(user_id, username, operation_type, operation_desc, ip_address, create_time)
VALUES

-- 第 7 天（最远的一天）
('1001', 'user1', 'search', '搜索了"Spring Boot 教程"', '192.168.1.11', @today - INTERVAL 6 DAY + INTERVAL 9 HOUR + INTERVAL 10 MINUTE),
('1001', 'user1', 'view_page', '浏览首页', '192.168.1.11', @today - INTERVAL 6 DAY + INTERVAL 10 HOUR + INTERVAL 30 MINUTE),
('1002', 'user2', 'download', '下载文件 report.pdf', '192.168.1.12', @today - INTERVAL 6 DAY + INTERVAL 14 HOUR + INTERVAL 20 MINUTE),
('1003', 'user3', 'click_button', '点击提交按钮', '192.168.1.13', @today - INTERVAL 6 DAY + INTERVAL 16 HOUR + INTERVAL 5 MINUTE),

-- 第 6 天
('1001', 'user1', 'search', '搜索了"MySQL优化"', '192.168.1.11', @today - INTERVAL 5 DAY + INTERVAL 9 HOUR + INTERVAL 15 MINUTE),
('1004', 'user4', 'view_page', '查看帮助文档', '192.168.1.14', @today - INTERVAL 5 DAY + INTERVAL 11 HOUR + INTERVAL 25 MINUTE),
('1003', 'user3', 'download', '下载教程 video.mp4', '192.168.1.13', @today - INTERVAL 5 DAY + INTERVAL 13 HOUR + INTERVAL 40 MINUTE),
('1001', 'user1', 'click_button', '点赞文章', '192.168.1.11', @today - INTERVAL 5 DAY + INTERVAL 15 HOUR + INTERVAL 10 MINUTE),
('1005', 'user5', 'search', '查找订单记录', '192.168.1.15', @today - INTERVAL 5 DAY + INTERVAL 18 HOUR + INTERVAL 30 MINUTE),

-- 第 5 天
('1006', 'user6', 'view_page', '访问个人中心', '192.168.1.16', @today - INTERVAL 4 DAY + INTERVAL 10 HOUR),
('1002', 'user2', 'search', '如何重置密码？', '192.168.1.12', @today - INTERVAL 4 DAY + INTERVAL 12 HOUR + INTERVAL 20 MINUTE),
('1007', 'user7', 'download', '下载模板 template.xlsx', '192.168.1.17', @today - INTERVAL 4 DAY + INTERVAL 14 HOUR + INTERVAL 50 MINUTE),
('1007', 'user7', 'click_button', '分享到微信', '192.168.1.17', @today - INTERVAL 4 DAY + INTERVAL 20 HOUR + INTERVAL 10 MINUTE),

-- 第 4 天
('1001', 'user1', 'search', 'ECharts 配置项详解', '192.168.1.11', @today - INTERVAL 3 DAY + INTERVAL 9 HOUR + INTERVAL 30 MINUTE),
('1008', 'user8', 'view_page', '阅读新闻资讯', '192.168.1.18', @today - INTERVAL 3 DAY + INTERVAL 10 HOUR + INTERVAL 15 MINUTE),
('1003', 'user3', 'download', '下载SDK包', '192.168.1.13', @today - INTERVAL 3 DAY + INTERVAL 13 HOUR + INTERVAL 25 MINUTE),
('1009', 'user9', 'click_button', '提交反馈', '192.168.1.19', @today - INTERVAL 3 DAY + INTERVAL 16 HOUR + INTERVAL 40 MINUTE),
('1010', 'user10', 'search', '忘记密码怎么办', '192.168.1.20', @today - INTERVAL 3 DAY + INTERVAL 21 HOUR + INTERVAL 5 MINUTE),

-- 第 3 天
('1004', 'user4', 'view_page', '查看公告', '192.168.1.14', @today - INTERVAL 2 DAY + INTERVAL 8 HOUR + INTERVAL 50 MINUTE),
('1005', 'user5', 'search', 'API 文档', '192.168.1.15', @today - INTERVAL 2 DAY + INTERVAL 11 HOUR + INTERVAL 10 MINUTE),
('1001', 'user1', 'download', '下载开发手册.pdf', '192.168.1.11', @today - INTERVAL 2 DAY + INTERVAL 14 HOUR + INTERVAL 30 MINUTE),
('1006', 'user6', 'click_button', '修改头像', '192.168.1.16', @today - INTERVAL 2 DAY + INTERVAL 17 HOUR + INTERVAL 20 MINUTE),
('1002', 'user2', 'search', '上传文件失败', '192.168.1.12', @today - INTERVAL 2 DAY + INTERVAL 19 HOUR + INTERVAL 45 MINUTE),

-- 第 2 天
('1007', 'user7', 'search', 'Docker 部署教程', '192.168.1.17', @today - INTERVAL 1 DAY + INTERVAL 9 HOUR + INTERVAL 20 MINUTE),
('1008', 'user8', 'view_page', '浏览商品列表', '192.168.1.18', @today - INTERVAL 1 DAY + INTERVAL 10 HOUR + INTERVAL 5 MINUTE),
('1009', 'user9', 'download', '下载合同模板.doc', '192.168.1.19', @today - INTERVAL 1 DAY + INTERVAL 12 HOUR + INTERVAL 30 MINUTE),
('1010', 'user10', 'click_button', '申请试用', '192.168.1.20', @today - INTERVAL 1 DAY + INTERVAL 15 HOUR + INTERVAL 40 MINUTE),
('1003', 'user3', 'search', '权限配置说明', '192.168.1.13', @today - INTERVAL 1 DAY + INTERVAL 18 HOUR + INTERVAL 10 MINUTE),

-- 昨天
('1001', 'user1', 'search', 'UniApp 打包发布', '192.168.1.11', @today + INTERVAL 9 HOUR + INTERVAL 15 MINUTE),
('1002', 'user2', 'view_page', '查看个人资料', '192.168.1.12', @today + INTERVAL 10 HOUR + INTERVAL 25 MINUTE),
('1004', 'user4', 'download', '下载发票.pdf', '192.168.1.14', @today + INTERVAL 13 HOUR + INTERVAL 35 MINUTE),
('1005', 'user5', 'click_button', '收藏页面', '192.168.1.15', @today + INTERVAL 16 HOUR + INTERVAL 50 MINUTE);