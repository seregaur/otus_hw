CREATE DATABASE IF NOT EXISTS `otus` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `otus`;

CREATE TABLE IF NOT EXISTS `category` (
  `category_id` int PRIMARY KEY AUTO_INCREMENT,
  `category_parent_id` int,
  `category_name` varchar(255)
);

CREATE TABLE IF NOT EXISTS `customers` (
  `customer_id` int PRIMARY KEY AUTO_INCREMENT,
  `customer_full_name` varchar(255),
  `customer_email` varchar(255),
  `postal_code` varchar(32),
  `street_id` int,
  `customer_address` varchar(255)
);

CREATE TABLE IF NOT EXISTS `products` (
  `product_id` int PRIMARY KEY AUTO_INCREMENT,
  `manufacter_id` int,
  `category_id` int,
  `product_name` varchar(255),
  `product_price` decimal(15,2),
  `product_weigth` float,
  `product_quantity` int
);

CREATE TABLE IF NOT EXISTS `images` (
  `image_id` int PRIMARY KEY AUTO_INCREMENT,
  `product_id` int,
  `image_data` binary
);

CREATE TABLE IF NOT EXISTS `supply` (
  `supply_id` int PRIMARY KEY AUTO_INCREMENT,
  `supply_name` varchar(255),
  `postal_code` varchar(32),
  `street_id` int,
  `supply_address` varchar(255)
);

CREATE TABLE IF NOT EXISTS `supply_phones` (
  `phone_id` int PRIMARY KEY AUTO_INCREMENT,
  `phone_number` varchar(255),
  `supply_id` int
);

CREATE TABLE IF NOT EXISTS `manufacters` (
  `manufacter_id` int PRIMARY KEY AUTO_INCREMENT,
  `manufacter_name` varchar(255)
);

CREATE TABLE IF NOT EXISTS `products_supply_prices` (
  `price_id` int PRIMARY KEY AUTO_INCREMENT,
  `supply_id` int,
  `product_id` int,
  `supply_price` double
);

CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` int PRIMARY KEY AUTO_INCREMENT,
  `order_date` date,
  `order_status` varchar(255),
  `customer_id` int,
  `point_id` int,
  `delivery_to_customer_address` bool,
  `delivery_to_customer_price` decimal(15,2)
);

CREATE TABLE IF NOT EXISTS `order_product` (
  `order_product_id` int PRIMARY KEY AUTO_INCREMENT,
  `product_id` int,
  `order_id` int
);

CREATE TABLE IF NOT EXISTS `customer_phones` (
  `phone_id` int PRIMARY KEY AUTO_INCREMENT,
  `phone_number` varchar(255),
  `customer_id` int
);

CREATE TABLE IF NOT EXISTS `delivery` (
  `delivery_id` int PRIMARY KEY AUTO_INCREMENT,
  `delivery_name` varchar(255),
  `delivery_type` varchar(255),
  `delivery_contact_info` varchar(255)
);

CREATE TABLE IF NOT EXISTS `delivery_points` (
  `point_id` int PRIMARY KEY AUTO_INCREMENT,
  `delivery_id` int,
  `street_id` int,
  `point_address` varchar(255),
  `point_price` decimal(15,2),
  `point_price_min` decimal(15,2)
);

CREATE TABLE IF NOT EXISTS `supply_categories` (
  `supply_categories_id` int PRIMARY KEY AUTO_INCREMENT,
  `supply_id` int,
  `category_id` int
);

CREATE TABLE IF NOT EXISTS `countries` (
  `country_id` int PRIMARY KEY AUTO_INCREMENT,
  `country_name` varchar(255)
);

CREATE TABLE IF NOT EXISTS `state` (
  `state_id` int PRIMARY KEY AUTO_INCREMENT,
  `country_id` int,
  `state_name` varchar(255)
);

CREATE TABLE IF NOT EXISTS `cities` (
  `city_id` int PRIMARY KEY AUTO_INCREMENT,
  `state_id` int,
  `city_name` varchar(255)
);

CREATE TABLE IF NOT EXISTS `streets` (
  `street_id` int PRIMARY KEY AUTO_INCREMENT,
  `city_id` int,
  `city_name` varchar(255)
);

CREATE TABLE IF NOT EXISTS `postal_codes` (
  `postal_code` varchar(32) PRIMARY KEY,
  `city_id` int
);
