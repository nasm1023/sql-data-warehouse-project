--Cleansing and Standardization Data sliver layer

create or alter procedure sliver.load_sliver AS
Begin
	Begin try
		DECLARE @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime
		PRINT '==========================='
		PRINT 'Loading Sliver Layer'
		PRINT '==========================='

		PRINT '---------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '---------------------------'
		--CRM
		SET @batch_start_time = GETDATE()
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: sliver.crm_cust_info';
		TRUNCATE TABLE sliver.crm_cust_info;
		PRINT '>> Inserting Data Into: sliver.crm_cust_info';
		insert into sliver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		)
		Select 
		cst_id,
		cst_key,
		trim(cst_firstname) cst_firstname,
		trim(cst_lastname) cst_lastname,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 ELSE 'n/a'
		END,
		CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 ELSE 'n/a'
		END,
		cst_create_date
		from (
		select *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		from bronze.crm_cust_info
		where cst_id is not null
		) t
		where flag_last = 1
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + Cast(Datediff(second,@start_time,@end_time) as nvarchar) + ' seconds.'
		PRINT '---------------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: sliver.crm_prd_info';
		TRUNCATE TABLE sliver.crm_prd_info;
		PRINT '>> Inserting Data Into: sliver.crm_prd_info';
		insert into sliver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT [prd_id]
			  ,replace(substring(prd_key,1,5),'-','_') as cat_id
			  ,substring(prd_key,7,len(prd_key)) as prd_key
			  ,[prd_nm]
			  ,ISNULL([prd_cost],0) as prd_cost
			  ,CASE UPPER(TRIM([prd_line]))
					WHEN 'M' THEN 'Moutain'
					WHEN 'R' THEN 'Road'
					WHEN 'S' THEN 'Other Sales'
					WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
				END as prd_line
			  ,[prd_start_dt]
			  ,Dateadd(day,-1,LEAD(prd_start_dt) OVER (PARTITION BY prd_key order by prd_start_dt)) as prd_end_dt
		  FROM [bronze].[crm_prd_info]
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + Cast(Datediff(second,@start_time,@end_time) as nvarchar) + ' seconds.'
		PRINT '---------------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: sliver.crm_sales_details';
		TRUNCATE TABLE sliver.crm_sales_details;
		PRINT '>> Inserting Data Into: sliver.crm_sales_details';
		insert into sliver.crm_sales_details(
				sls_ord_num ,
			sls_prd_key ,
			sls_cust_id ,
			sls_order_dt ,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quantity ,
			sls_price
		)
		SELECT [sls_ord_num]
			  ,[sls_prd_key]
			  ,[sls_cust_id]
			  ,CASE WHEN  [sls_order_dt] = 0 or len([sls_order_dt]) !=8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
				END AS sls_order_dt
			  ,CASE WHEN  [sls_ship_dt] = 0 or len([sls_ship_dt]) !=8 THEN NULL
				ELSE CAST(CAST([sls_ship_dt] AS VARCHAR) AS DATE)
				END AS [sls_ship_dt]
			  ,CASE WHEN  [sls_due_dt] = 0 or len([sls_due_dt]) !=8 THEN NULL
				ELSE CAST(CAST([sls_due_dt] AS VARCHAR) AS DATE)
				END AS [sls_due_dt]
			  ,CASE WHEN sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
			then sls_quantity * abs(sls_price)
			ELSE sls_sales
			END AS sls_sales
			  ,[sls_quantity]
			  ,case when sls_price is null or sls_price <= 0 
			then sls_sales / NULLIF(sls_quantity,0)
			else sls_price
			end as sls_price
		  FROM [bronze].[crm_sales_details]
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + Cast(Datediff(second,@start_time,@end_time) as nvarchar) + ' seconds.'
		PRINT '---------------------------'

		--ERP
		PRINT '---------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '---------------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: sliver.erp_cust_az12';
		TRUNCATE TABLE sliver.erp_cust_az12;
		PRINT '>> Inserting Data Into: sliver.erp_cust_az12';
		insert into sliver.erp_cust_az12
		(
			cid,
			bdate,
			gen
		)
		select
		CASE WHEN cid like 'NAS%' then substring(cid,4,len(cid))
			else cid
		end cid,
		case when bdate > GETDATE() then null
			else bdate
		end bdate,
		Case 
			when UPPER(TRIM(gen)) in ('M','Male') then 'Male'
			when UPPER(TRIM(gen)) in ('F','Female') then 'Female'
			else 'n/a'
		end gen
		from bronze.erp_cust_az12
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + Cast(Datediff(second,@start_time,@end_time) as nvarchar) + ' seconds.'
		PRINT '---------------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: sliver.erp_loc_a101';
		TRUNCATE TABLE sliver.erp_loc_a101;
		PRINT '>> Inserting Data Into: sliver.erp_loc_a101';
		insert into sliver.erp_loc_a101(
			cid,
			cntry
		)
		select 
		replace(cid,'-','') cid,
		Case when Trim(cntry) IN ('USA','US') then 'United States'
			when Trim(cntry) = 'DE' then 'Germany'
			when trim(cntry) is null or cntry = '' then 'n/a'
			else trim(cntry)
		end cntry
		from bronze.erp_loc_a101
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + Cast(Datediff(second,@start_time,@end_time) as nvarchar) + ' seconds.'
		PRINT '---------------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: sliver.erp_px_cat_g1v2';
		TRUNCATE TABLE sliver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: sliver.erp_px_cat_g1v2';
		insert into sliver.erp_px_cat_g1v2 (
		id,
		cid,
		subcat,
		maintenance
		)
		select 
		id,
		cid,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + Cast(Datediff(second,@start_time,@end_time) as nvarchar) + ' seconds.'
		PRINT '---------------------------'

		SET @batch_end_time = GETDATE()
		PRINT '==========================='
		PRINT '>> Total Load Duration' + Cast(Datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + ' seconds.'
		PRINT '==========================='
	END TRY
	BEGIN CATCH
		PRINT '==========================='
		PRINT 'ERROR OCCURED DURING LOADING SLIVER LAYER'
		PRINT '>> ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT '>> ERROR NUMBER' + CAST(ERROR_NUMBER() as nvarchar);
		PRINT '==========================='
	END CATCH
END
