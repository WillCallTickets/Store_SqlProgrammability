USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetCustomerSalesHistory]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/10
-- Description:	Retrieves the customer's invoices. 
-- Returns:		Wcss.CustomerInvoiceRow
/*
exec [tx_GetCustomerSalesHistory] 'WILLCALL', 'rob@robkurtz.net', 0, 100
*/
-- =============================================

CREATE	PROC [dbo].[tx_GetCustomerSalesHistory] (

	@ApplicationName	varchar(256),
	@UserName 			varchar(256),
	@StartRowIndex      int,
	@PageSize           int

)
AS

SET DEADLOCK_PRIORITY LOW

SET NOCOUNT ON

BEGIN

	DECLARE @UserId			UNIQUEIDENTIFIER
    DECLARE @ApplicationId	UNIQUEIDENTIFIER
    SELECT  @ApplicationId	= NULL

    SELECT  @ApplicationId = ApplicationId 
	FROM	dbo.aspnet_Applications 
	WHERE	LOWER(@ApplicationName) = LoweredApplicationName
	
    IF (@ApplicationId IS NULL)
        RETURN 0

	SELECT	@UserId = u.UserId
    FROM	dbo.aspnet_Users u
    WHERE	u.ApplicationId = @ApplicationId 
			AND u.UserName = LOWER(@UserName)

    -- Create a temp table to store the select results
    CREATE TABLE #PageIndexForInvoices (
    
        IndexId			INT IDENTITY (1, 1) NOT NULL,
        InvoiceId		INT,
		AuthorizeNetId	INT
		
    )

    INSERT INTO #PageIndexForInvoices (InvoiceId, AuthorizeNetId)	
	SELECT InvoiceId, AuthorizeNetId FROM
	(
		SELECT	i.[Id] AS InvoiceId, MIN(a.[id]) AS AuthorizeNetId, 
				ROW_NUMBER() OVER (ORDER BY i.[Id] DESC) AS RowNum
		FROM	Invoice i 
				LEFT OUTER JOIN InvoiceShipment ship 
					ON ship.[tInvoiceId] = i.[Id], 
				AuthorizeNet a
		WHERE	i.[UserId] = @UserId 
				AND i.[InvoiceStatus] <> 'NotPaid' 
				AND i.[UniqueId] = a.[InvoiceNumber] 
				AND a.[TransactionType] = 'auth_capture' 
				AND a.[bAuthorized] = 1
		GROUP BY i.[Id]
	) Invoices
	WHERE	Invoices.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
	ORDER BY Invoices.[RowNum] ASC	

	SELECT	i.[Id] AS InvoiceId, 
			i.[UniqueId] AS UniqueId, 
			a.[Id] AS AuthNetId, 
			i.[dtInvoiceDate], 
			i.[InvoiceStatus], 
			ISNULL(i.[vcProducts],'') AS ProductList, 
			a.[Description], 
			UPPER(a.[LastName] + ', ' + a.[FirstName]) AS PurchaserName, 
			a.[Email] AS PurchaserEmail,
			i.[mTotalPaid], 
			i.[mTotalRefunds] AS mTotalRefunds, 
			ISNULL(a.[mTaxAmount],0) AS TaxAmount, 
			ISNULL(a.[mFreightAmount],0) AS FreightAmount, 
			i.[mNetPaid], 
			a.[TransactionType]
	FROM	Invoice i, 
			#PageIndexForInvoices p, 
			AuthorizeNet a
    WHERE	i.Id = p.InvoiceId 
			AND a.Id = p.AuthorizeNetId
	ORDER BY i.[Id] DESC

END
GO
