USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetOrdersInRange]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Gets purchases that are within context (all,tickets,merch) and within the date range specifed.
-- Returns Wcss.CustomerInvoiceRow
-- =============================================

CREATE	PROC [dbo].[tx_GetOrdersInRange](

	@applicationId	UNIQUEIDENTIFIER,
	@Context		VARCHAR(256),
	@StartDate		VARCHAR(50),
	@EndDate		VARCHAR(50),
	@StartRowIndex  INT,		--this is based on what we get from the grid view control
	@PageSize       INT

)
AS

SET DEADLOCK_PRIORITY LOW

SET NOCOUNT ON

BEGIN

	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForInvoices(
        IndexId			INT IDENTITY (1, 1) NOT NULL,
        InvoiceId		INT,
		AuthorizeNetId	INT
    )

	IF @Context = 'ticket'	
	BEGIN

		INSERT INTO #PageIndexForInvoices (InvoiceId, AuthorizeNetId)
		SELECT InvoiceId, AuthorizeNetId FROM
		(	
			SELECT	Distinct(i.[Id]) as InvoiceId, MIN(a.[Id]) as AuthorizeNetId,
					ROW_NUMBER() OVER (ORDER BY i.[Id] DESC) AS RowNum
			FROM	Invoice i, AuthorizeNet a
			WHERE	i.[ApplicationId] = @applicationId 
					AND i.[InvoiceStatus] <> 'NotPaid' 
					AND i.[UniqueId] = a.[InvoiceNumber] 
					AND a.[TransactionType] = 'auth_capture' 
					AND a.[bAuthorized] = 1 
					AND (CHARINDEX('c,',ISNULL(i.[vcProducts],'')) > 0 OR CHARINDEX('t,',ISNULL(i.[vcProducts],'')) > 0) 
					AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate 
			GROUP BY i.[Id]
		) Invoices
		WHERE	Invoices.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
		ORDER BY [InvoiceId] DESC

	END

	ELSE IF @Context = 'merch' 
	BEGIN

		INSERT INTO #PageIndexForInvoices (InvoiceId, AuthorizeNetId)
		SELECT InvoiceId, AuthorizeNetId FROM
		(
			SELECT	Distinct(i.[Id]) as InvoiceId, MIN(a.[Id]) as AuthorizeNetId,
					ROW_NUMBER() OVER (ORDER BY i.[Id] DESC) AS RowNum
			FROM	Invoice i, AuthorizeNet a
			WHERE	i.[ApplicationId] = @applicationId 
					AND i.[InvoiceStatus] <> 'NotPaid' 
					AND i.[UniqueId] = a.[InvoiceNumber] 
					AND a.[TransactionType] = 'auth_capture' 
					AND a.[bAuthorized] = 1 
					AND (CHARINDEX('m,',ISNULL(i.[vcProducts],'')) > 0 OR CHARINDEX('g,',ISNULL(i.[vcProducts],'')) > 0) 
					AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate 
			GROUP BY i.[Id]
		) Invoices
		WHERE	Invoices.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
		ORDER BY [InvoiceId] DESC

	END

	ELSE BEGIN

		INSERT INTO #PageIndexForInvoices (InvoiceId, AuthorizeNetId)
		SELECT InvoiceId, AuthorizeNetId FROM
		(
			SELECT	i.[Id] as InvoiceId, MIN(a.[Id]) as AuthorizeNetId,
					ROW_NUMBER() OVER (ORDER BY i.[Id] DESC) AS RowNum
			FROM	Invoice i, AuthorizeNet a
			WHERE	i.[ApplicationId] = @applicationId 
					AND i.[InvoiceStatus] <> 'NotPaid' AND i.[UniqueId] = a.[InvoiceNumber] 
					AND a.[TransactionType] = 'auth_capture' 
					AND a.[bAuthorized] = 1 
					AND ((CHARINDEX('c,',ISNULL(i.[vcProducts],'')) > 0) OR (CHARINDEX('t,',ISNULL(i.[vcProducts],'')) > 0) OR 
						(CHARINDEX('m,',ISNULL(i.[vcProducts],'')) > 0) OR (CHARINDEX('g,',ISNULL(i.[vcProducts],'')) > 0)) 
					AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate 
			GROUP BY i.[Id]

		) Invoices
		WHERE	Invoices.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
		ORDER BY [InvoiceId] DESC

	END

	SELECT	i.[Id] as InvoiceId, 
			i.[UniqueId] as UniqueId, 
			a.[Id] as AuthNetId, 
			i.[dtInvoiceDate], 
			i.[InvoiceStatus], 
			ISNULL(i.[vcProducts],'') as ProductList, 
			a.[Description], 
			UPPER(a.[LastName] + ', ' + a.[FirstName]) as PurchaserName, 
			a.[Email] as PurchaserEmail,
			i.[mTotalPaid], 
			i.[mTotalRefunds] as mTotalRefunds, 
			ISNULL(a.[mTaxAmount],0) as TaxAmount, 
			ISNULL(a.[mFreightAmount],0) as FreightAmount, 
			i.[mNetPaid], a.[TransactionType]
	FROM	Invoice i, 
			#PageIndexForInvoices p, 
			AuthorizeNet a
    WHERE	i.Id = p.InvoiceId 
			AND a.Id = p.AuthorizeNetId			 
	ORDER BY i.[Id] DESC

END
GO
