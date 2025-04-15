--This scripts create tables of sliver layer, and if tables are existed then it will drop and recreate.

IF OBJECT_ID ('sliver.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE sliver.crm_cust_info;
CREATE TABLE sliver.crm_cust_info (
	cst_id INT,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date,
	dwh_create datetime2 default getdate()
);

IF OBJECT_ID ('sliver.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE sliver.crm_prd_info;
CREATE TABLE sliver.crm_prd_info (
	prd_id INT,
	cat_id nvarchar(50),
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_dt date,
	prd_end_dt date,
	dwh_create datetime2 default getdate()
);

IF OBJECT_ID ('sliver.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE sliver.crm_sales_details;
CREATE TABLE sliver.crm_sales_details (
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id INT,
	sls_order_dt date,
	sls_ship_dt date,
	sls_due_dt date,
	sls_sales int,
	sls_quantity INT,
	sls_price int,
	dwh_create datetime2 default getdate()
);

IF OBJECT_ID ('sliver.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE sliver.erp_cust_az12;
CREATE TABLE sliver.erp_cust_az12(
	cid nvarchar(50),
	bdate date,
	gen nvarchar(50),
	dwh_create datetime2 default getdate()
);

IF OBJECT_ID ('sliver.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE sliver.erp_loc_a101;
CREATE TABLE sliver.erp_loc_a101(
	cid nvarchar(50),
	cntry nvarchar(50),
	dwh_create datetime2 default getdate()
);

IF OBJECT_ID ('sliver.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE sliver.erp_px_cat_g1v2;
CREATE TABLE sliver.erp_px_cat_g1v2(
	id nvarchar(50),
	cid nvarchar(50),
	subcat nvarchar(50),
	maintenance nvarchar(50),
	dwh_create datetime2 default getdate()
);
