USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetBillShipsOfMerchItem]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 13/09/25
-- Description:	Gets the Billing and shipping info of matching invoices. 
/*

these should be the same as there is only one inventory item
exec [tx_GetBillShipsOfMerchItem] '83C1C3F6-C539-41D7-815D-143FBD40E41F', 11598, 1, 1,
	0, 10, '1/1/2008', '10/1/2013 12AM'

exec [tx_GetBillShipsOfMerchItem] '83C1C3F6-C539-41D7-815D-143FBD40E41F', 11599, 1, 1
*/
-- =============================================


CREATE	PROC [dbo].[tx_GetBillShipsOfMerchItem](

	@applicationId	UNIQUEIDENTIFIER,
	@merchId		INT,
	@exclusive		BIT,
	@minQty			INT,	
	@StartRowIndex	INT,
	@PageSize		INT,
	@dtStart		DATETIME,
	@dtEnd			DATETIME

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	IF(@StartRowIndex = 0)
		SET @StartRowIndex = 1
	
	CREATE TABLE #PageIndex
    (
        Id INT IDENTITY (1, 1) NOT NULL,
        IndexedId INT
    )
	
	INSERT INTO #PageIndex (IndexedId)
	SELECT IndexedId FROM
	(
		SELECT fn.[idx] AS [IndexedId],
			ROW_NUMBER() OVER ( ORDER BY ibs.[blLastName], ibs.[blFirstName] ) AS RowNum
		FROM   dbo.fn_InvoicesWithSpecifiedMerch
				(@applicationId, @merchId, @exclusive, @minQty,
					@dtStart, @dtEnd) fn
			LEFT OUTER JOIN	[InvoiceBillShip] ibs 
				ON fn.[idx] = ibs.[tinvoiceId]
	) Indices 
	WHERE	Indices.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
	ORDER BY RowNum
	
	SELECT	
		ibs.[tInvoiceId] AS [InvoiceId], 
		fn.[qty] AS [QtyPurchased], 
		fn.[purchaseEmail] AS [PurchaserEmail], 
		blFirstName AS [BillingFirstName], 
		blLastName AS [BillingLastName],
		blPhone AS [BillingPhone],
		CASE WHEN bSameAsBilling = 1 THEN blFirstName ELSE FirstName END AS [FirstName],
		CASE WHEN bSameAsBilling = 1 THEN blLastName ELSE LastName END AS [LastName],
		CASE WHEN bSameAsBilling = 1 THEN blAddress1 ELSE Address1 END AS [Address1],
		CASE WHEN bSameAsBilling = 1 THEN blAddress2 ELSE Address2 END AS [Address2],
		CASE WHEN bSameAsBilling = 1 THEN blCity ELSE City END AS [City],
		CASE WHEN bSameAsBilling = 1 THEN blStateProvince ELSE StateProvince END AS [StateProvince],
		CASE WHEN bSameAsBilling = 1 THEN blPostalCode ELSE PostalCode END AS [PostalCode],
		CASE WHEN bSameAsBilling = 1 THEN blCountry ELSE Country END AS [Country],
		CASE WHEN bSameAsBilling = 1 THEN blPhone ELSE Phone END AS [Phone],
		ShipMessage,
		ROW_NUMBER() OVER ( ORDER BY ibs.[tInvoiceId] ) AS RowNum		
	 
	FROM	#PageIndex pg 
		LEFT OUTER JOIN dbo.fn_InvoicesWithSpecifiedMerch
			(@applicationId, @merchId, @exclusive, @minQty, @dtStart, @dtEnd) fn 
				ON pg.[IndexedId] = fn.[idx] 
		LEFT OUTER JOIN	[InvoiceBillShip] ibs 
			ON ibs.[tinvoiceId] = fn.[idx]
				
	ORDER BY [BillingLastName], [BillingFirstName]
		
END
GO
