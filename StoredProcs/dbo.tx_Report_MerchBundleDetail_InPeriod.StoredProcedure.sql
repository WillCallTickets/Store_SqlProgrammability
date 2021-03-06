USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Report_MerchBundleDetail_InPeriod]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 11/05/27
-- Description:	Returns MerchBundleRows with aggregates for given criteria.
-- Returns:		Wcss.SalesReportBundleRow
/*
exec [tx_Report_MerchBundleDetail_InPeriod] '83C1C3F6-C539-41D7-815D-143FBD40E41F', 'all', 'true',
	'7/1/2010','12/30/2011', 0, 10000, 'BundleId='
*/
-- =============================================

CREATE PROC [dbo].[tx_Report_MerchBundleDetail_InPeriod](

	@appId					UNIQUEIDENTIFIER,
	@category				VARCHAR(50),
	@activeStatus			VARCHAR(5),
	@StartDate				VARCHAR(50),
	@EndDate				VARCHAR(50),
	@StartRowIndex			INT,
	@PageSize				INT,
	@merchBundleIdConstant	VARCHAR(100)

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	SET @activeStatus = LOWER(@activeStatus)	
	
	--get a list of bundle items - get the sale figs later
	CREATE TABLE #tmpBundle ( Idx INT )
	
	IF(@category = 'all' OR @category = 'ticket') 
	BEGIN
	
		INSERT	#tmpBundle(Idx)
		SELECT	mb.[Id] AS [Idx] 
		FROM	[MerchBundle] mb 
				LEFT OUTER JOIN [ShowTicket] st 
					ON st.[Id] = mb.[TShowTicketId] 
				LEFT OUTER JOIN [Show] s 
					ON s.[ApplicationId] = @appId AND s.[Id] = st.[TShowId]
		WHERE	mb.[TShowTicketId] IS NOT NULL 
				AND 
				CASE @ActiveStatus
					WHEN 'true' THEN 
						CASE WHEN (mb.[bActive] IS NULL OR (mb.[bActive] IS NOT NULL AND mb.[bActive] = 1)) THEN 1 ELSE 0 END
					WHEN 'false' THEN 
						CASE WHEN (mb.[bActive] IS NOT NULL AND mb.[bActive] = 0) THEN 1 ELSE 0 END
					ELSE 1 
				END = 1
	END
	
	IF(@category = 'all' OR @category = 'merch') 
	BEGIN
	
		INSERT	#tmpBundle(Idx)
		SELECT	mb.[Id] 
		FROM	[MerchBundle] mb 
				LEFT OUTER JOIN [Merch] m 
					ON m.[Id] = mb.[TMerchId] AND m.[ApplicationId] = @appId
		WHERE	mb.[TMerchId] IS NOT NULL 
				AND 
				CASE @ActiveStatus
					WHEN 'true' THEN 
						CASE WHEN (mb.[bActive] IS NULL OR (mb.[bActive] IS NOT NULL AND mb.[bActive] = 1)) THEN 1 ELSE 0 END
					WHEN 'false' THEN 
						CASE WHEN (mb.[bActive] IS NOT NULL AND mb.[bActive] = 0) THEN 1 ELSE 0 END
					ELSE 1 
				END = 1
	END
	
	
	-- Create a temp table TO store the paged results
    CREATE TABLE #PageIndexForInventory (
    
        IndexId		INT IDENTITY (1, 1) NOT NULL,
        InventoryId INT
        
    )
    
	INSERT INTO #PageIndexForInventory (InventoryId)
	SELECT InventoryId FROM
	(
		SELECT	DISTINCT(mb.[Id]) AS InventoryId, 
				ROW_NUMBER() OVER ( ORDER BY mb.[Title] ) AS RowNum
		FROM	[#tmpBundle] tb 
				LEFT OUTER JOIN [MerchBundle] mb 
					ON tb.[Idx] = mb.[Id]
	) Inventory 
	WHERE	Inventory.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
	ORDER BY RowNum	
	
	-- Create a temp table TO store the matching invoices - we will whittle down by date of purchase
	-- and items that have MerchBundleId= in the criteria
    CREATE TABLE #ItemPool (
    
        IndexId			INT IDENTITY (0, 1) NOT NULL,
        InvoiceItemId	INT,
        vcContext		VARCHAR(256),
        Criteria		VARCHAR(300)
        
    )
    
	--SET	@likeFind = '%' + @merchBundleIdConstant + CAST(mb.[Id] AS VARCHAR) + '%'
	INSERT	#ItemPool (InvoiceItemId, vcContext, Criteria)
	SELECT	DISTINCT(ii.[Id]) AS [InvoiceItemId], ii.[vcContext], ii.[Criteria] 
	FROM	[MerchBundle] mb, 
			[InvoiceItem] ii 
			LEFT OUTER JOIN [Invoice] i 
				ON i.[Id] = ii.[TInvoiceId]
	WHERE	i.[ApplicationId] = @appId 
			AND i.[InvoiceStatus] <> 'NotPaid' 
			AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate 
			AND (ii.[vcContext] = 'bundle' OR ii.[vcContext] = 'merch') 
			AND ii.[PurchaseAction] <> 'NotYetPurchased' 
			AND ii.[Criteria] IS NOT NULL 
			AND CHARINDEX(@merchBundleIdConstant, ii.[Criteria]) > 0	
	
	CREATE TABLE #ReturnInventory (
	
        InventoryId			INT NOT NULL,        
        NumBundlesSold		INT DEFAULT 0,
        BundleSales			MONEY DEFAULT 0.0,
        NumBundlesRefunded	INT DEFAULT 0,
        BundleRefunds		MONEY DEFAULT 0.0,        
        NumItemsSold		INT DEFAULT 0,        
        NumItemsRefunded	INT DEFAULT 0
        
    )
   
	--now we compile our findings
	INSERT	#ReturnInventory (InventoryId, NumBundlesSold, BundleSales, 
			NumBundlesRefunded, BundleRefunds, NumItemsSold, NumItemsRefunded)
	SELECT	DISTINCT(mb.[InventoryId]) AS [InventoryId],
			ISNULL(SUM(CASE WHEN ii.[vcContext] = 'bundle' AND ii.[PurchaseAction] = 'Purchased' 
				THEN ii.[iQuantity] ELSE 0 END), 0) AS [NumBundlesSold],
			ISNULL(SUM(CASE WHEN ii.[vcContext] = 'bundle' AND ii.[PurchaseAction] = 'Purchased' 
				THEN ii.[mLineItemTotal] ELSE 0.0 END), 0.0) AS [BundleSales],					
			ISNULL(SUM(CASE WHEN ii.[vcContext] = 'bundle' AND ii.[PurchaseAction] = 'PurchasedThenRemoved' 
				THEN ii.[iQuantity] ELSE 0 END), 0) AS [NumBundlesRefunded],
			ISNULL(SUM(CASE WHEN ii.[vcContext] = 'bundle' AND ii.[PurchaseAction] = 'PurchasedThenRemoved' 
				THEN ii.[mLineItemTotal] ELSE 0.0 END), 0.0) AS [BundleRefunds],				
			ISNULL(SUM(CASE WHEN ii.[vcContext] = 'merch' AND ii.[PurchaseAction] = 'Purchased' 
				THEN ii.[iQuantity] ELSE 0 END), 0) AS [NumItemsSold],
			ISNULL(SUM(CASE WHEN ii.[vcContext] = 'merch' AND ii.[PurchaseAction] = 'PurchasedThenRemoved' 
				THEN ii.[iQuantity] ELSE 0 END), 0) AS [NumItemsRefunded]			
	FROM	[#PageIndexForInventory] mb 
			LEFT OUTER JOIN [#ItemPool] p 
				ON CHARINDEX(@merchBundleIdConstant + CAST(mb.[InventoryId] AS VARCHAR), p.[Criteria])> 0
			LEFT OUTER JOIN [InvoiceItem] ii 
			ON p.[InvoiceItemId] = ii.[Id]
	GROUP BY mb.[InventoryId]
	
	--And return the finding with appropriate info
	SELECT	mb.[Id], mb.[bActive], mb.[TMerchId], mb.[TShowTicketId], 	
			CASE WHEN m.[Id] IS NOT NULL THEN m.[Name] ELSE 			
				CASE WHEN st.[Id] IS NOT NULL AND s.[Id] IS NOT NULL 
					THEN (CONVERT(VARCHAR, ISNULL(st.[dtDateOfShow],''), 100) + SUBSTRING(s.[Name], 20, LEN(s.Name))) 				
					ELSE ''
					END
			END AS [ParentDescription],			
			mb.[Title], mb.[Comment], mb.[iRequiredParentQty], mb.[iMaxSelections], mb.[mPrice], mb.[bIncludeWeight],
			r.[NumBundlesSold], r.[BundleSales], 
			r.[NumBundlesRefunded], r.[BundleRefunds], r.[NumItemsSold], r.[NumItemsRefunded]			
	FROM	#ReturnInventory r 
			LEFT OUTER JOIN [MerchBundle] mb 
				ON mb.[Id] = r.[InventoryId]
			LEFT OUTER JOIN [Merch] m 
				ON m.[Id] = mb.[TMerchId]
			LEFT OUTER JOIN [ShowTicket] st 
				ON st.[Id] = mb.[TShowTicketId]
			LEFT OUTER JOIN [Show] s 
				ON s.[Id] = st.[TShowId]
	ORDER BY mb.[Title]	

	DROP TABLE #ItemPool
	DROP TABLE #tmpBundle
	DROP TABLE #PageIndexForInventory
	DROP TABLE #ReturnInventory

END
GO
