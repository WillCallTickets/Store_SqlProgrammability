USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetMerchInventoryInRange]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Retrieves the merchandise inventory that match the search criteria. 
/*
presuppose that a style, color or size will never be = 'All'

exec tx_GetMerchInventoryInRange @parentId=0,@Style=NULL,@Color=NULL,@Size=NULL,@ActiveStatus=N'all',
	@StartDate=N'08/06/2007 12:00AM',@EndDate=N'11/06/2007 12:00AM',@StartRowIndex=1,@PageSize=10

exec tx_GetMerchInventoryInRange @parentId=10111,@Style=NULL,@Color=N'All',@Size=N'All',@ActiveStatus=N'all',
	@StartDate=N'08/16/2007 12:00AM',@EndDate=N'11/06/2007 12:00AM',@StartRowIndex=1,@PageSize=10

exec tx_GetMerchInventoryInRange @parentId=10117,@Style=NULL,@Color=NULL,@Size=NULL,@ActiveStatus=N'all',
	@StartDate=N'08/06/2007 12:00AM',@EndDate=N'11/14/2007 12:00AM',@StartRowIndex=1,@PageSize=10

exec tx_GetMerchInventoryInRange @parentId=10045,@Style=NULL,@Color=N'silver with red',@Size=N'M',
	@ActiveStatus=N'true',@StartDate=N'08/06/2007 12:00AM',@EndDate=N'11/06/2007 12:00AM',@StartRowIndex=1,@PageSize=10

exec tx_GetMerchInventoryInRange @parentId=10045,@Style=NULL,@Color=N'silver with red',@Size=NULL,@ActiveStatus=N'true',
	@StartDate=N'08/06/2007 12:00AM',@EndDate=N'11/06/2007 12:00AM',@StartRowIndex=1,@PageSize=10

exec tx_GetMerchInventoryInRange_Count @parentId=10045,@Style=NULL,@Color=N'silver with red',@Size=NULL,@ActiveStatus=N'true',
	@StartDate=N'08/06/2007 12:00AM',@EndDate=N'11/06/2007 12:00AM'

SELECT * FROM Merch m WHERE m.[Id] = 10117 AND tParentListing IS NULL
*/
-- =============================================

CREATE	PROC [dbo].[tx_GetMerchInventoryInRange](

	@applicationId	UNIQUEIDENTIFIER,
	@parentId		INT,
	@Style			VARCHAR(256),
	@Color			VARCHAR(256),
	@Size			VARCHAR(256),
	@ActiveStatus	VARCHAR(5),
	@StartRowIndex  INT,--this is based on what we get from the grid view control
	@PageSize       INT

)
AS

SET DEADLOCK_PRIORITY LOW

SET NOCOUNT ON

BEGIN

	SET @Style			= ISNULL(@Style,'');
	SET @Color			= ISNULL(@Color,'');
	SET @Size			= ISNULL(@Size,'');
	SET @ActiveStatus	= LOWER(@ActiveStatus)

	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForInventory (
        IndexId		INT IDENTITY (1, 1) NOT NULL,
        InventoryId INT
    )

	--if we are dealing with a parent object...
	IF EXISTS (SELECT * FROM Merch m WHERE m.[Id] = @parentId AND tParentListing IS NULL) BEGIN

		INSERT INTO #PageIndexForInventory (InventoryId)
		SELECT InventoryId FROM
		(
			SELECT	m.[Id] AS InventoryId, 
					ROW_NUMBER() OVER (ORDER BY (ISNULL(m.[Style],'') + ISNULL(m.[Color],'') + ISNULL(m.[Size],'')) ) AS RowNum
			FROM	Merch m 
			WHERE	m.[ApplicationId] = @applicationId 
					AND m.[tParentListing] = @parentId 
					AND 
					CASE @Style 
						WHEN '' THEN 1 
						ELSE 
						CASE WHEN m.[Style] = @Style THEN 1 
							ELSE 0 
						END 
					END = 1 
					AND 
					CASE @Color 
						WHEN '' THEN 1 
						ELSE 
						CASE WHEN m.[Color] = @Color THEN 1 
							ELSE 0 
						END 
					END = 1 
					AND 
					CASE @Size 
						WHEN '' THEN 1 
						ELSE 
						CASE WHEN m.[Size] = @Size THEN 1 
							ELSE 0 
						END 
					END = 1 AND 
					CASE @ActiveStatus
						WHEN 'true' THEN 
							CASE WHEN (m.[bActive] IS NULL OR (m.[bActive] IS NOT NULL AND m.[bActive] = 1)) THEN 1 
								ELSE 0 
							END
						WHEN 'false' THEN 
							CASE WHEN (m.[bActive] IS NOT NULL AND m.[bActive] = 0) THEN 1 
								ELSE 0 
							END
						ELSE 1 
					END = 1
		) Inventory 
		WHERE	Inventory.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
		ORDER BY RowNum
	
	END ELSE 
	BEGIN -- return the only row in question
		
		INSERT	#PageIndexForInventory (InventoryId)
		SELECT	m.[Id] AS InventoryId
		FROM	Merch m 
		WHERE	m.[ApplicationId] = @applicationId 
				AND m.[Id] = @parentId
				
	END

	--start and end date are for aggregates
	SELECT	m.[Id] AS MerchId, 
			ISNULL(m.[tParentListing],0)			AS ParentId, 
			SUBSTRING(ISNULL(m.[Style],''),1,50)	AS Style, 
			ISNULL(m.[Color],'')					AS Color, 
			ISNULL(m.[Size],'')						AS Size, 
			ISNULL(m.[bActive],1)					AS IsActive, 
			ISNULL(m.[bTaxable],0)					AS IsTaxable, 
			ISNULL(m.[bFeaturedItem],0)				AS IsFeatured, 
			ISNULL(m.[bSoldOut],0)					AS IsSoldOut, 
			m.[mPrice]								AS mPrice, 
			m.[bUseSalePrice]						AS bUseSalePrice, 
			m.[mSalePrice]							AS mSalePrice, 
			m.[vcDeliveryType]						AS vcDeliveryType, 
			m.[mWeight]								AS mWeight, 
			m.[iAllotment]							AS Allot, 
			m.[iDamaged]							AS Dmg, 
			m.[iPending]							AS Pend, 
			m.[iSold]								AS Sold, 
			m.[iAvailable]							AS Avail, 
			m.[iRefunded]							AS Refund,
			0										AS SalesPend, 
			0										AS SalesSold, 
			0										AS SalesRefund
	FROM	Merch m, #PageIndexForInventory p
    WHERE	m.[Id] = p.[InventoryId]
	ORDER BY (ISNULL(m.[Style],'') + ISNULL(m.[Color],'') + ISNULL(m.[Size],''))

END
GO
