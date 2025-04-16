--This script create views in Gold Layer 
--The data can use directly for analysis and reporting

--Dim Customers
CREATE or alter VIEW gold.dim_customers AS
SELECT ROW_NUMBER() OVER (ORDER BY ci.cst_id) as customer_key
	  ,ci.[cst_id] as customer_id
      ,ci.[cst_key] as customer_number
      ,ci.[cst_firstname] as customer_firstname
      ,ci.[cst_lastname] as customer_lastname
	  ,la.cntry as country
      ,ci.[cst_marital_status] as customer_marital_status
      ,case when ci.cst_gndr != 'n/a' then ci.cst_gndr
		else COALESCE(ca.gen,'n/a')
		END as gender
	,ca.bdate as birthdate
      ,ci.[cst_create_date] as create_date
  FROM [sliver].[crm_cust_info] ci
	left join sliver.erp_cust_az12 ca on ci.cst_key = ca.cid
	left join sliver.erp_loc_a101 la on ci.cst_key = la.cid


--Dim Products
create or alter view gold.dim_products as
SELECT 
		ROW_NUMBER() OVER (Order by pn.prd_start_dt, pn.prd_key) as product_key
	  ,pn.[prd_id] as product_id
      ,pn.[prd_key] as product_number
	  ,pn.[prd_nm] as product_name
      ,pn.[cat_id] as category_id
	  ,pc.cid as category_name
	  ,pc.subcat as subcategory
	  ,pc.maintenance
      ,pn.[prd_cost] as cost
      ,pn.[prd_line] as product_line
      ,pn.[prd_start_dt] as start_date
  FROM [sliver].[crm_prd_info] pn 
	left join sliver.erp_px_cat_g1v2 pc on pn.cat_id = pc.id
  where pn.prd_end_dt is null		--Filter out all historical data

--Fact Sales
create or alter view gold.fact_sales as
SELECT sd.[sls_ord_num] as order_number
	  ,pr.product_key 
	  ,cu.customer_key
      ,sd.[sls_order_dt] as order_date
      ,sd.[sls_ship_dt] as shipping_date
      ,sd.[sls_due_dt] as due_date
      ,sd.[sls_sales] as sales_amount
      ,sd.[sls_quantity] as quantity
      ,sd.[sls_price] as price
  FROM [sliver].[crm_sales_details] sd
  left join gold.dim_products pr on sd.sls_prd_key = pr.product_number
  left join gold.dim_customers cu on sd.sls_cust_id = cu.customer_id
