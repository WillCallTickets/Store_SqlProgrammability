USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Mailer_LetterStats]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 12/10/2010
-- Description:	Returns stats on an email letter in the queue.
/*
declare @1 int, @2 int, @3 int
exec [tx_Mailer_LetterStats] 'AC36EB0B-152E-4B69-8B39-BB4B6C9B01E6', '6/1/2009', '1/30/2011', 10282, 
	@1 OUTPUT, @2 OUTPUT, @3 OUTPUT

select @1, @2, @3
*/

-- =============================================

CREATE	PROC [dbo].[tx_Mailer_LetterStats](

	@appId		UNIQUEIDENTIFIER,
	@StartDate	VARCHAR(50),
	@EndDate	VARCHAR(50),
	@letterId	INT,
	@queued		INT	OUTPUT,
	@sent		INT	OUTPUT,
	@total		INT	OUTPUT

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	DECLARE @sentArchive	INT, 
			@totalArchive	INT

	SELECT	@queued = COUNT(DISTINCT Id) 
	FROM	MailQueue 
	WHERE	[TEmailLetterId] = @letterId 
			AND [ApplicationId] = @appId 
			AND ([Status] IS NULL OR ([Status] IS NOT NULL AND [Status] <> 'Sent')) 
			AND [dtStamp] BETWEEN @StartDate AND @EndDate

	SELECT	@sent = COUNT(DISTINCT Id) 
	FROM	MailQueue mq
	WHERE	[TEmailLetterId] = @letterId 
			AND [ApplicationId] = @appId 
			AND [Status] = 'Sent' 
			AND [dtStamp] BETWEEN @StartDate AND @EndDate
			
	SELECT	@sentArchive = COUNT(DISTINCT Id) 
	FROM	MailQueueArchive mq
	WHERE	[TEmailLetterId] = @letterId 
			AND [ApplicationId] = @appId 
			AND [Status] = 'Sent' 
			AND [dtStamp] BETWEEN @StartDate AND @EndDate
			
	SET		@sent = @sent + @sentArchive
			
	SELECT	@total = COUNT(DISTINCT Id) 
	FROM	MailQueue mq
	WHERE	[TEmailLetterId] = @letterId 
			AND [ApplicationId] = @appId 
			AND [dtStamp] BETWEEN @StartDate AND @EndDate
			
	SELECT	@totalArchive = COUNT(DISTINCT Id) 
	FROM	MailQueueArchive mq
	WHERE	[TEmailLetterId] = @letterId 
			AND [ApplicationId] = @appId 
			AND [dtStamp] BETWEEN @StartDate AND @EndDate
			
	SET		@total = @total + @totalArchive

END
GO
