USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetMerchSalesInRange]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Retrieves purchases that match the criteria. 
-- Returns Wcss.CustomerInvoiceRow
-- =============================================

CREATE	PROC [dbo].[tx_GetMerchSalesInRange] (

	@applicationId				UNIQUEIDENTIFIER,
	@ParentId					INT,
	@Style						VARCHAR(256),
	@Color						VARCHAR(256),
	@Size						VARCHAR(256),
	@ActiveStatus				VARCHAR(5),
	@EmailOnly					BIT,
	@IncludeInvoiceIdWithEmail	BIT,
	@StartDate					VARCHAR(50),
	@EndDate					VARCHAR(50),
	@StartRowIndex				INT,--this is based on what we get from the grid view control
	@PageSize					INT

)
AS

SET DEADLOCK_PRIORITY LOW

SET NOCOUNT ON

BEGIN

	SET @Style			= ISNULL(@Style,'');
	SET @Color			= ISNULL(@Color,'');
	SET @Size			= ISNULL(@Size,'');
	SET @ActiveStatus	= LOWER(@ActiveStatus)

	--get merches in range
	CREATE TABLE #tmpMerch ( merchId INT )

	IF EXISTS (SELECT * FROM Merch m WHERE m.[Id] = @parentId AND tParentListing IS NULL) 
	BEGIN

		INSERT	#tmpMerch(merchId)
		SELECT	m.[Id] AS merchId
		FROM	Merch m 
		WHERE	m.[ApplicationId] = @applicationId 
				AND m.[tParentListing] = @parentId 
				AND 
				CASE @Style WHEN '' THEN 1 ELSE 
					CASE WHEN m.[Style] = @Style THEN 1 
						ELSE 0 
					END 
				END = 1 
				AND 
				CASE @Color WHEN '' THEN 1 ELSE 
					CASE WHEN m.[Color] = @Color THEN 1 
						ELSE 0 
					END 
				END = 1 
				AND 
				CASE @Size WHEN '' THEN 1 ELSE 
					CASE WHEN m.[Size] = @Size THEN 1 
						ELSE 0
					END 
				END = 1 
				AND 
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
	
	END 
	
	ELSE 
	BEGIN -- return the only row in question
		
		INSERT	#tmpMerch(merchId)
		SELECT	m.[Id] AS merchId
		FROM	Merch m 
		WHERE	m.[ApplicationId] = @applicationId 
				AND m.[Id] = @parentId
		
	END


	--get corresponding invoice in date range
	-- Create a temp table TO store the select results
    CREATE TABLE #AllMatchingInvoices  (
        IndexId			INT IDENTITY (0, 1) NOT NULL,
        InvoiceId		INT,
		AuthorizeNetId	INT
    )
    
	CREATE TABLE #PageIndexForInvoices  (
        IndexId			INT IDENTITY (1, 1) NOT NULL,
        InvoiceId		INT,
		AuthorizeNetId	INT
    )

	INSERT	#AllMatchingInvoices (InvoiceId, AuthorizeNetId)
	SELECT	Distinct(i.[Id]) AS InvoiceId, MIN(a.[Id]) AS AuthorizeNetId
	FROM	Invoice i 
			LEFT OUTER JOIN InvoiceItem ii 
				ON ii.[tInvoiceId] = i.[Id], 
			AuthorizeNet a, 
			#tmpMerch t
	WHERE	i.[InvoiceStatus] <> 'NotPaid' 
			AND i.[UniqueId] = a.[InvoiceNumber] 
			AND a.[TransactionType] = 'auth_capture' 
			AND a.[bAuthorized] = 1 
			AND (ii.[tMerchId] IS NOT NULL AND ii.[tMerchId] = t.[merchId]) 
			AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate
	GROUP BY i.[Id]

	--get the subset that will fit into our page index range
	--order by invoice id keeps in order of entry
	INSERT	INTO #PageIndexForInvoices (InvoiceId, AuthorizeNetId)
	SELECT	InvoiceId, AuthorizeNetId 
	FROM	(
				SELECT	Distinct(mi.[InvoiceId]) AS InvoiceId, mi.[AuthorizeNetId] AS AuthorizeNetId,
						ROW_NUMBER() OVER (ORDER BY mi.[InvoiceId] DESC) AS RowNum
				FROM	#AllMatchingInvoices mi 
				
			) Invoices
	WHERE	Invoices.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
	ORDER BY [InvoiceId] DESC

	IF (@EmailOnly = 1) 
	BEGIN
		
		IF (@IncludeInvoiceIdWithEmail = 1) 
		BEGIN
		
			SELECT	a.[InvoiceNumber] AS UniqueId, a.[Email] AS PurchaserEmail
			FROM	#PageIndexForInvoices p, AuthorizeNet a
			WHERE	a.Id = p.AuthorizeNetId
			ORDER BY a.[Email] 
			
		END 
		ELSE BEGIN
		
			SELECT	DISTINCT(a.[Email]) AS PurchaserEmail
			FROM	#PageIndexForInvoices p, AuthorizeNet a
			WHERE	a.Id = p.AuthorizeNetId
			ORDER BY a.[Email] 
		END

	END
	ELSE BEGIN 


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
				i.[mNetPaid], a.[TransactionType]
		FROM	Invoice i, 
				#PageIndexForInvoices p, 
				AuthorizeNet a
		WHERE	i.Id = p.InvoiceId 
				AND a.Id = p.AuthorizeNetId 
		ORDER BY i.[Id] DESC

	END

END
GO
