USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_JOB_CleanupCashew]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Kurtz, Robert
-- Create date: 11-04-08
-- Updated:		15-02-08
-- Description:	
-- 15-02-08 greatly simplified the process
-- Now we just find any old invoices and remove the correspoding cashews
-- also check cashew for stragglers
-- exec [dbo].[tx_JOB_CleanupCashew]
-- =============================================

CREATE PROCEDURE [dbo].[tx_JOB_CleanupCashew]

AS

BEGIN

	SET NOCOUNT ON
	
	DECLARE @cutoffDate DATETIME
	SET		@cutoffDate = DATEADD(m, -6, GETDATE())

	CREATE TABLE #tmpPool (Id INT NOT NULL, Cnt INT, maxDate DATETIME)
	CREATE TABLE #tmpDelete (Id INT NOT NULL, maxDate DATETIME)
	
	--do most recent first - easier for tracking
	INSERT	#tmpPool([Id], [Cnt], [maxDate])
	SELECT	i.[tCashewid] AS [Id], COUNT(i.id) AS [Cnt], MAX(i.dtinvoicedate) AS [maxDate]	
	FROM	Invoice i
	WHERE	i.tcashewid IS NOT NULL
	GROUP BY i.tcashewid
	ORDER BY MAX(i.dtinvoicedate) DESC

	--from those cashews, only process those that are not tied to recent invoices	
	INSERT	#tmpDelete(Id)
	SELECT	TOP 100 p.[Id]
	FROM	#tmpPool p
	WHERE	p.[maxDate] < @cutoffDate
	ORDER BY p.[maxDate] DESC
	
	--now update any of those invoices that are in the matching set
	UPDATE	Invoice
	SET		[TCashewId] = NULL
	FROM	#tmpDelete t
	WHERE	TCashewId = t.[Id]
			
	--and finally delete the cashew
	DELETE	FROM Cashew 
	WHERE	Id IN 
				(SELECT Id FROM #tmpDelete)	
	
	DROP TABLE #tmpPool
	DROP TABLE #tmpDelete	
	
	DECLARE @now DATETIME
	SET		@now = GETDATE()
	
	DECLARE @appId UNIQUEIDENTIFIER
	SELECT	@appId = ApplicationId
	FROM	aspnet_Applications
	WHERE	ApplicationName = 'WILLCALL'
		
	INSERT	EventQ(DateToProcess, DateProcessed, Status, 
			CreatorName, Context, Verb, NewValue, 
			IP, dtStamp, ApplicationId)
	VALUES (@now, @now, 'Success', 
			'tx_JOB_CleanupCashew', 'AdminNotification', '_Update', 'CashewCleanup',
			'127.0.0.1', @now, @appId)
	
END
GO
