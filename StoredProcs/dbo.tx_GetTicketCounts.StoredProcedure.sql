USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetTicketCounts]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	A simple report for current ticket inventory and recent sales. 
-- Returns:		Wcss.TicketCountRow
-- =============================================

CREATE	PROC [dbo].[tx_GetTicketCounts](

	@applicationId	UNIQUEIDENTIFIER,
	@StartDate		VARCHAR(50),
	@EndDate		VARCHAR(50),
	@StartRowIndex  INT,
	@PageSize       INT

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW

BEGIN

	--used to calculate past sales and today sales
	DECLARE @now VARCHAR(256)
	SET		@now = CONVERT(VARCHAR(256), GETDATE(), 101)

	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForShowDates(
        IndexId		INT IDENTITY (1, 1) NOT NULL,
        ShowDateId	INT
    )

	--get showdates that are greater than yesterday
	INSERT INTO #PageIndexForShowDates (ShowDateId)
	SELECT ShowDateId FROM
	(	
		SELECT	DISTINCT(sd.[Id]) AS ShowDateId, sd.[dtDateOfShow],
				ROW_NUMBER() OVER (ORDER BY sd.[dtDateOfShow]) AS RowNum
		FROM	[ShowDate] sd, [Show] s
		WHERE	s.[ApplicationId] = @applicationId 
				AND s.[Id] = sd.[tShowId] 
				AND sd.[bActive] = 1 
				AND sd.[dtDateOfShow] BETWEEN  @StartDate AND @EndDate
	) ShowDates
	WHERE	ShowDates.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
	ORDER BY RowNum

	--get aggregates of sales
	CREATE TABLE #tmpCounts( ShowDateId int, _5 int, _4 int, _3 int, _2 int, _1 int, today int )
    INSERT	#tmpCounts(ShowDateId, _5, _4, _3, _2, _1, today)
	SELECT	p.[ShowDateId], 
			SUM(CASE WHEN ii.[dtStamp] BETWEEN dateadd(dd, -5, @now) AND dateadd(dd, -4, @now) 
				THEN ii.[iQuantity] ELSE 0 END) AS _5, 
			SUM(CASE WHEN ii.[dtStamp] BETWEEN dateadd(dd, -4, @now) AND dateadd(dd, -3, @now) 
				THEN ii.[iQuantity] ELSE 0 END) AS _4, 
			SUM(CASE WHEN ii.[dtStamp] BETWEEN dateadd(dd, -3, @now) AND dateadd(dd, -2, @now) 
				THEN ii.[iQuantity] ELSE 0 END) AS _3, 
			SUM(CASE WHEN ii.[dtStamp] BETWEEN dateadd(dd, -2, @now) AND dateadd(dd, -1, @now) 
				THEN ii.[iQuantity] ELSE 0 END) AS _2, 
			SUM(CASE WHEN ii.[dtStamp] BETWEEN dateadd(dd, -1, @now) AND @now THEN ii.[iQuantity] ELSE 0 END) AS _1, 
			SUM(CASE WHEN ii.[dtStamp] BETWEEN @now AND getDate() THEN ii.[iQuantity] ELSE 0 END) AS today
	FROM	#PageIndexForShowDates p, 
			ShowTicket st 
			LEFT OUTER JOIN InvoiceItem ii 
				ON	ii.[tShowTicketId] = st.[Id] 
					AND ii.[vcContext] = 'Ticket' 
					AND ii.[PurchaseAction] = 'Purchased'
	WHERE	p.[ShowDateId] = st.[tShowDateId]
	GROUP BY p.[ShowDateId]

	--get ticket counts	
	CREATE TABLE #tmpDates( 
		ShowDateId	INT, 
		ShowDate	DATETIME, 
		ShowName	VARCHAR(512), 
		allotment	INT, 
		pending		INT, 
		sold		INT, 
		available	INT, 
		refunded	INT 
	)
	
    INSERT	#tmpDates( ShowDateId, ShowDate, ShowName, allotment, pending, sold, available, refunded )
	SELECT	sd.[Id] AS ShowDateId, 
			sd.[dtDateOfShow] AS ShowDate, 
			SUBSTRING(s.[Name], 23, LEN(s.[Name])) AS ShowName,
			SUM(CASE WHEN st.[iAllotment] IS NOT NULL THEN st.[iAllotment] ELSE 0 END) AS allotment, 
			SUM(ISNULL(pending.[iQty], 0)) AS pending, 
			SUM(CASE WHEN st.[iSold] IS NOT NULL THEN st.[iSold] ELSE 0 END) AS sold, 
			SUM(CASE WHEN st.[iAvailable] IS NOT NULL THEN st.[iAvailable] ELSE 0 END) AS available, 
			SUM(CASE WHEN st.[iRefunded] IS NOT NULL THEN st.[iRefunded] ELSE 0 END) AS refunded
	FROM	#PageIndexForShowDates p, 
			Show s, 
			ShowDate sd 
			LEFT OUTER JOIN ShowTicket st 
				ON st.[tShowDateId] = sd.[Id] 
			LEFT OUTER JOIN fn_PendingStock('ticket') pending 
				ON pending.[idx] = st.[Id]
	WHERE	p.[ShowDateId] = sd.[Id] 
			AND sd.[tShowId] = s.[Id]
	GROUP BY sd.[Id], sd.[dtDateOfShow], s.[Name]

	--combine aggs and counts
	SELECT	d.[ShowDateId], d.[ShowDate], d.[ShowName], 
			CASE WHEN c.[_5] IS NOT NULL THEN c.[_5] ELSE 0 END AS _5, 
			CASE WHEN c.[_4] IS NOT NULL THEN c.[_4] ELSE 0 END AS _4, 
			CASE WHEN c.[_3] IS NOT NULL THEN c.[_3] ELSE 0 END AS _3, 
			CASE WHEN c.[_2] IS NOT NULL THEN c.[_2] ELSE 0 END AS _2, 
			CASE WHEN c.[_1] IS NOT NULL THEN c.[_1] ELSE 0 END AS _1, 
			CASE WHEN c.[today] IS NOT NULL THEN c.[today] ELSE 0 END AS today, 
			d.[allotment], 
			d.[pending], 
			d.[sold], 
			d.[available], 
			d.[refunded]
	FROM	#PageIndexForShowDates p 
			LEFT OUTER JOIN #tmpDates d 
				ON d.[ShowDateId] = p.[ShowDateId]
			LEFT OUTER JOIN #tmpCounts c 
				ON c.[ShowDateId] = d.[ShowDateId]
	ORDER BY d.[ShowDate]

END
GO
