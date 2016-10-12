USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetMerchSalesInRange_Count]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Retrieves the count of purchases that match the criteria. 
-- =============================================

CREATE	PROC [dbo].[tx_GetMerchSalesInRange_Count](

	@applicationId	UNIQUEIDENTIFIER,
	@ParentId		INT,
	@Style			VARCHAR(256),
	@Color			VARCHAR(256),
	@Size			VARCHAR(256),
	@ActiveStatus	VARCHAR(5),
	@StartDate		VARCHAR(50),
	@EndDate		VARCHAR(50)

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

		INSERT	INTO #tmpMerch(merchId)
		SELECT	m.[Id] AS 'merchId'
		FROM	Merch m 
		WHERE	m.[ApplicationId] = @applicationId 
				AND m.[tParentListing] = @parentId 
				AND 
				CASE @Style WHEN '' THEN 1 
					ELSE CASE WHEN m.[Style] = @Style THEN 1 
					ELSE 0 
					END 
				END = 1 
				AND 
				CASE @Color WHEN '' THEN 1 
					ELSE CASE WHEN m.[Color] = @Color THEN 1 
					ELSE 0 
					END 
				END = 1 
				AND 
				CASE @Size WHEN '' THEN 1 
					ELSE CASE WHEN m.[Size] = @Size THEN 1 
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
	
	END ELSE 
	
	BEGIN -- return the only row in question
		
		INSERT	INTO #tmpMerch(merchId)
		SELECT	m.[Id] AS 'merchId'
		FROM	Merch m 
		WHERE	m.[ApplicationId] = @applicationId 
				AND m.[Id] = @parentId		
	END

	--get corresponding invoice in date range
	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForInvoices (
        IndexId			INT IDENTITY (0, 1) NOT NULL,
        InvoiceId		INT,
		AuthorizeNetId	INT
    )

	INSERT INTO #PageIndexForInvoices (InvoiceId, AuthorizeNetId)
	SELECT InvoiceId, AuthorizeNetId FROM
	(
		SELECT	Distinct(i.[Id]) AS 'InvoiceId', MIN(a.[Id]) AS 'AuthorizeNetId',
				ROW_NUMBER() OVER (ORDER BY i.[Id] DESC) AS RowNum
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
	) Invoices

	SELECT	COUNT(*) 
	FROM	#PageIndexForInvoices

END
GO
