USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Report_DailySalesInfo]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Finds the days' sales. Inserts them into report table.
/*
select top 10 * from eventq order by id desc
select * from report_dailysales

insert eventq(datetoprocess, attemptsremaining, creatorname, context, verb, oldvalue)
values(getdate(), 3, 'testing', 'Report','Report_Mailer_Daily','2/2/2008')

exec [tx_Report_DailySalesInfo] '1/1/2008 3pm', 0, 1 
*/

-- =============================================

CREATE PROC [dbo].[tx_Report_DailySalesInfo](

	@applicationId	UNIQUEIDENTIFIER,
	@dateOfSales	DATETIME,
	@reportVenue	BIT,
	@reportAct		BIT

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	DECLARE	@startDate	DATETIME,
			@endDate	DATETIME

	--set dates
	SET	@startDate = CAST(CONVERT(VARCHAR, @dateOfSales, 101) AS DATETIME)
	SET @endDate = DATEADD(ss, -1, DATEADD(dd, 1, @startDate))

	--create a table to hold the items
	CREATE TABLE #tmpItems(
	
		vcContext		VARCHAR(256),
		ItemId			INT,
		[Description]	VARCHAR(1000) DEFAULT '',
		MiniDesc		VARCHAR(500) DEFAULT '',
		Alloted			INT Default 0,
		Sold			INT Default 0,
		TotalSold		INT Default 0,
		Available		INT Default 0
	)

	--gather items sold
	INSERT	#tmpItems ([vcContext], [ItemId], [Sold])
	SELECT	ii.[vcContext], 
			CASE 
				WHEN (TShowTicketId IS NOT NULL) THEN TShowTicketId 
				WHEN (TMerchId IS NOT NULL) THEN TMerchId 
				ELSE 0 END AS ItemId,
			SUM(ii.[iQuantity]) AS Sold
	FROM	[InvoiceItem] ii, [Invoice] i
	WHERE	i.[ApplicationId] = @applicationId 
			AND i.[dtInvoiceDate] BETWEEN @startDate AND @endDate 
			AND i.[InvoiceStatus] <> 'NotPaid' 
			AND ii.[TInvoiceId] = i.[Id] 
			AND ii.[PurchaseAction] = 'Purchased'
	GROUP BY ii.[vcContext], CASE 
				WHEN (TShowTicketId IS NOT NULL) THEN TShowTicketId 
				WHEN (TMerchId IS NOT NULL) THEN TMerchId 
				ELSE 0 END 

	--get currently available TICKETS not in the above list
	INSERT	#tmpItems ([vcContext], [ItemId], [Sold])
	SELECT	'ticket', st.[Id], 0
	FROM	[ShowTicket] st, [ShowDate] sd, [Show] s
	WHERE	s.[ApplicationId] = @applicationId 
			AND s.[bActive] = 1 
			AND sd.[TShowId] = s.[Id] 
			AND sd.[bActive] = 1 
			AND st.[TShowDateId] = sd.[Id] 
			AND st.[Id] NOT IN (SELECT [ItemId] FROM #tmpItems WHERE [vcContext] = 'ticket') 
			AND st.[dtDateOfShow] >= @endDate 			

	--set TICKET desc and availability totals, etc
	UPDATE	#tmpItems
	SET		[Description] = CAST(DATEPART(yyyy, st.[dtDateOfShow]) AS VARCHAR) + '/' + 
				CAST(DATEPART(mm, st.[dtDateOfShow]) AS VARCHAR) + '/' +
				CAST(DATEPART(dd, st.[dtDateOfShow]) AS VARCHAR) + 
				+ ' ' + SUBSTRING(s.[Name], 23, LEN(s.[Name])),
			[MiniDesc] = CAST(DATEPART(mm, st.[dtDateOfShow]) AS VARCHAR) + '/' +
				CAST(DATEPART(dd, st.[dtDateOfShow]) AS VARCHAR) + 
				CASE WHEN @reportVenue = 1 THEN ' ' + RTRIM(SUBSTRING(v.[NameRoot], 1, 4)) ELSE '' END,
			[Alloted] = st.[iAllotment],
			[TotalSold] = st.[iSold],
			[Available] = st.[iAvailable]
	FROM	[#tmpItems] t, [ShowTicket] st, 
			[Show] s 
			LEFT OUTER JOIN [Venue] v 
				ON s.[TVenueId] = v.[Id] 
	WHERE   t.[vcContext] = 'ticket' 
			AND t.[ItemId] = st.[Id] 
			AND st.[TShowId] = s.[Id]
	
	IF(@reportAct = 1) 
	BEGIN

		UPDATE	#tmpItems
		SET		[MiniDesc] = t.[MiniDesc] + ' ' + RTRIM(SUBSTRING(a.[NameRoot], 1, 5))
		FROM	[#tmpItems] t, [ShowTicket] st, [ShowDate] sd, [JShowAct] j 
				LEFT OUTER JOIN [Act] a 
					ON j.[TActId] = a.[Id]
		WHERE   t.[vcContext] = 'ticket' 
				AND t.[ItemId] = st.[Id] 
				AND st.[TShowDateId] = sd.[Id] 
				AND j.[TShowDateId] = sd.[Id] 
				AND j.[iDisplayOrder] = 0
				
	END

	--set MERCH desc and availability
	--name comes from parent
	UPDATE	#tmpItems
	SET		[Description] = ISNULL(m.[Name],'') + ' '
	FROM	[#tmpItems] t, [Merch] m
	WHERE   t.[vcContext] = 'merch' 
			AND t.[ItemId] = m.[Id] 
			AND m.[tParentListing] IS NULL

	--be certain of name
	UPDATE	#tmpItems
	SET		[Description] = t.[Description] + ISNULL(parent.[Name],'') + ' '
	FROM	[#tmpItems] t, [Merch] m, [Merch] parent
	WHERE   t.[vcContext] = 'merch' 
			AND t.[ItemId] = m.[Id] 
			AND m.[tParentListing] IS NOT NULL 
			AND m.[tParentListing] = parent.[Id]

	--style color and size and availabilty, totals, etc
	UPDATE	#tmpItems
	SET		[Description] = t.[Description] + LTRIM(RTRIM(ISNULL(m.[Style],'') + ' ' + ISNULL(m.[Size],'') + ' ' + ISNULL(m.[Color],''))),
			[MiniDesc] = RTRIM(SUBSTRING(t.[Description], 1, 10)) + 
				CASE WHEN m.[Style] IS NOT NULL THEN ' ' + LTRIM(RTRIM(SUBSTRING(m.[Style], 1, 5))) ELSE '' END + 
				CASE WHEN m.[Color] IS NOT NULL THEN ' ' + LTRIM(RTRIM(SUBSTRING(m.[Color], 1, 4))) ELSE '' END + 
				CASE WHEN m.[Size] IS NOT NULL THEN ' ' + LTRIM(RTRIM(SUBSTRING(m.[Size], 1, 3))) ELSE '' END,
			[Alloted] = m.[iAllotment],
			[TotalSold] = m.[iSold],
			[Available] = m.[iAvailable]
	FROM	[#tmpItems] t, [Merch] m
	WHERE   t.[vcContext] = 'merch' 
			AND t.[ItemId] = m.[Id] 

	DECLARE @reportDate	DATETIME
	SET		@reportDate = @startDate

	BEGIN TRANSACTION

		--do not update the alloted,totalsales or available - keep those originally set
		UPDATE	Report_DailySales
		SET		[Description] = t.[Description],
				[MiniDesc] = t.[MiniDesc],
				[Sold] = t.[Sold]
		FROM	[Report_DailySales] r, [#tmpItems] t
		WHERE	r.[ApplicationId] = @applicationId 
				AND r.[ReportDate] = @reportDate 
				AND r.[vcContext] = t.[vcContext] 
				AND r.[ItemId] = t.[ItemId]

		INSERT	Report_DailySales ([ApplicationId], [ReportDate], [vcContext], [ItemId], [Description], [MiniDesc], 
					[Alloted], [Sold], [TotalSold], [Available])
		SELECT	@applicationId, @reportDate, t.[vcContext], t.[ItemId], t.[Description], t.[MiniDesc], 
					t.[Alloted], t.[Sold], t.[TotalSold], t.[Available]
		FROM	[#tmpItems] t
		WHERE	t.[vcContext] + CAST(t.[ItemId] AS VARCHAR) NOT IN 
					(SELECT r.[vcContext] + CAST(r.[ItemId] AS VARCHAR) 
					FROM [Report_DailySales] r 
					WHERE r.[ApplicationId] = @applicationId AND r.[ReportDate] = @reportDate)

	COMMIT TRANSACTION

	SELECT	r.*, ISNULL(st.[CriteriaText],'') AS CriteriaText
	FROM	[Report_DailySales] r 
			LEFT OUTER JOIN [ShowTicket] st 
				ON r.[vcContext] = 'ticket' AND r.[ItemId] = st.[Id]
	WHERE	r.[ApplicationId] = @applicationId 
			AND r.[ReportDate] = @reportDate
	ORDER BY [vcContext] DESC, [Description] ASC

END
GO
