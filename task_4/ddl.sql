CREATE SCHEMA IF NOT EXISTS shop;
CREATE SCHEMA IF NOT EXISTS mgmt;
SET search_path TO shop;

CREATE TABLE "customers"  (
  "customer_id" SERIAL PRIMARY KEY,
  "customer_full_name" varchar,
  "customer_email" varchar,
  "postal_code" varchar,
  "street_id" int,
  "customer_address" varchar
);

CREATE TABLE "products" (
  "product_id" SERIAL PRIMARY KEY,
  "manufacter_id" int,
  "category_id" int,
  "product_name" varchar,
  "product_price" money,
  "product_weigth" float,
  "product_quantity" int
);

CREATE TABLE "images" (
  "image_id" SERIAL PRIMARY KEY,
  "product_id" int,
  "image_data" bytea
);

CREATE TABLE "category" (
  "category_id" SERIAL PRIMARY KEY,
  "category_parent_id" int,
  "category_name" varchar
);

CREATE TABLE mgmt.supply (
  "supply_id" SERIAL PRIMARY KEY,
  "supply_name" varchar,
  "postal_code" varchar,
  "street_id" int,
  "supply_address" varchar
);

CREATE TABLE mgmt.supply_phones (
  "phone_id" SERIAL PRIMARY KEY,
  "phone_number" varchar,
  "supply_id" int
);

CREATE TABLE "manufacters" (
  "manufacter_id" SERIAL PRIMARY KEY,
  "manufacter_name" varchar
);

CREATE TABLE mgmt.products_supply_prices (
  "price_id" SERIAL PRIMARY KEY,
  "supply_id" int,
  "product_id" int,
  "supply_price" money
);

CREATE TABLE "orders" (
  "order_id" SERIAL PRIMARY KEY,
  "order_date" date,
  "order_status" varchar,
  "customer_id" int,
  "point_id" int,
  "delivery_to_customer_address" bool,
  "delivery_to_customer_price" money
);

CREATE TABLE "order_product" (
  "order_product_id" SERIAL PRIMARY KEY,
  "product_id" int,
  "order_id" int
);

CREATE TABLE "customer_phones" (
  "phone_id" SERIAL PRIMARY KEY,
  "phone_number" varchar,
  "customer_id" int
);

CREATE TABLE "delivery" (
  "delivery_id" SERIAL PRIMARY KEY,
  "delivery_name" varchar,
  "delivery_type" varchar,
  "delivery_contact_info" varchar
);

CREATE TABLE "delivery_points" (
  "point_id" SERIAL PRIMARY KEY,
  "delivery_id" int,
  "street_id" int,
  "point_address" varchar,
  "point_price" money,
  "point_price_min" money
);

CREATE TABLE mgmt.supply_categories (
  "supply_categories_id" SERIAL PRIMARY KEY,
  "supply_id" int,
  "category_id" int
);

CREATE TABLE "countries" (
  "country_id" SERIAL PRIMARY KEY,
  "country_name" varchar
);

CREATE TABLE "state" (
  "state_id" SERIAL PRIMARY KEY,
  "country_id" int,
  "state_name" varchar
);

CREATE TABLE "cities" (
  "city_id" SERIAL PRIMARY KEY,
  "state_id" int,
  "city_name" varchar
);

CREATE TABLE "streets" (
  "street_id" SERIAL PRIMARY KEY,
  "city_id" int,
  "street_name" varchar
);

CREATE TABLE "postal_codes" (
  "postal_code" varchar PRIMARY KEY,
  "city_id" int
);

ALTER TABLE "products" ADD FOREIGN KEY ("manufacter_id") REFERENCES "manufacters" ("manufacter_id");
ALTER TABLE "products" ADD FOREIGN KEY ("category_id") REFERENCES "category" ("category_id");
ALTER TABLE mgmt.products_supply_prices ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");
ALTER TABLE mgmt.products_supply_prices ADD FOREIGN KEY ("supply_id") REFERENCES mgmt.supply ("supply_id");
ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");
ALTER TABLE "order_product" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");
ALTER TABLE "order_product" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id");
ALTER TABLE "images" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");
ALTER TABLE "customer_phones" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");
ALTER TABLE mgmt.supply_phones ADD FOREIGN KEY ("supply_id") REFERENCES mgmt.supply ("supply_id");
ALTER TABLE "delivery_points" ADD FOREIGN KEY ("delivery_id") REFERENCES "delivery" ("delivery_id");
ALTER TABLE mgmt.supply ADD FOREIGN KEY ("supply_id") REFERENCES mgmt.supply ("supply_id");
ALTER TABLE mgmt.supply_categories ADD FOREIGN KEY ("category_id") REFERENCES "category" ("category_id");
ALTER TABLE "orders" ADD FOREIGN KEY ("point_id") REFERENCES "delivery_points" ("point_id");
ALTER TABLE "state" ADD FOREIGN KEY ("country_id") REFERENCES "countries" ("country_id");
ALTER TABLE "cities" ADD FOREIGN KEY ("state_id") REFERENCES "state" ("state_id");
ALTER TABLE "streets" ADD FOREIGN KEY ("city_id") REFERENCES "cities" ("city_id");
ALTER TABLE mgmt.supply ADD FOREIGN KEY ("postal_code") REFERENCES "postal_codes" ("postal_code");
ALTER TABLE mgmt.supply ADD FOREIGN KEY ("street_id") REFERENCES "streets" ("street_id");
ALTER TABLE "customers" ADD FOREIGN KEY ("street_id") REFERENCES "streets" ("street_id");
ALTER TABLE "customers" ADD FOREIGN KEY ("postal_code") REFERENCES "postal_codes" ("postal_code");
ALTER TABLE "delivery_points" ADD FOREIGN KEY ("street_id") REFERENCES "streets" ("street_id");

DROP ROLE IF EXISTS "shop_admins";
DROP ROLE IF EXISTS "shop_managers";
DROP ROLE IF EXISTS "shop_backend";

DROP ROLE IF EXISTS "test_admin";
DROP ROLE IF EXISTS "test_manager";

CREATE ROLE "shop_admins";
CREATE ROLE "shop_managers";
CREATE ROLE "shop_backend" LOGIN PASSWORD '2345';

GRANT ALL ON DATABASE otus TO GROUP shop_admins;
GRANT USAGE ON SCHEMA mgmt TO shop_admins;
GRANT USAGE ON SCHEMA shop TO shop_admins;
GRANT USAGE ON SCHEMA mgmt TO shop_managers;
GRANT USAGE ON SCHEMA shop TO shop_managers;
GRANT USAGE ON SCHEMA shop TO shop_backend;
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA "mgmt" TO shop_managers;
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA "shop" TO shop_backend;
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA "shop" TO shop_managers;

CREATE ROLE test_admin WITH LOGIN PASSWORD '12345';
GRANT shop_admins TO test_admin;
CREATE ROLE test_manager WITH LOGIN PASSWORD '123';
GRANT shop_managers TO test_manager;



