USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_JOB_GetBatch_EventData]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	see: http://www.codeproject.com/KB/architecture/DatabaseMailQueue.aspx
--	for implementation details. Thanks Dan!
--	Firstly, this procedure removes old SENT mails into the MailQueueArchive
--	It then gathers events in queue that have not been processed or have possibly
--	errored in an attempt.
-- Returns:		<EventQCollection>
-- =============================================

CREATE PROCEDURE [dbo].[tx_JOB_GetBatch_EventData](
	
	@applicationId		UNIQUEIDENTIFIER,
	@threadGuid			UNIQUEIDENTIFIER,
	@batchSize			INT,
	@retrySeconds		INT,
	@archiveAfterDays	INT
	
)
AS

BEGIN

	SET NOCOUNT ON

	--BEGIN ARCHIVAL
	BEGIN TRANSACTION

	--remove after @archiveAfterDays
	--avoid paused eeventss (paused have attempts remaining at -10000)
	CREATE	TABLE #tmpRemoveOld(Id INT)
	
	INSERT	#tmpRemoveOld(Id)
	SELECT  TOP (@batchSize) q.[Id]
	FROM	[EventQ] q 
	WHERE	q.[ApplicationId]= @applicationId 
			AND q.[DateProcessed] IS NOT NULL 
			AND (q.[Status] = 'Success' 
				--only process remaining atempts within the timeframe
				OR (q.[AttemptsRemaining] IS NULL OR (q.[AttemptsRemaining] <= 0 AND q.[AttemptsRemaining] > -10000))
				)
			AND (q.[DateProcessed] < DATEADD(dd, -@archiveAfterDays, getDate()))	

	--COPY EventQ to archive
	INSERT	EventQArchive([Id], [dtStamp], [DateToProcess], [DateProcessed], [Status], 
			[Threadlock], [AttemptsRemaining], [iPriority], [CreatorId], [CreatorName],
			[UserId], [UserName], [Context], [Verb], [OldValue], [NewValue], [Description], [Ip], [ApplicationId] )
	SELECT	q.[Id], q.[dtStamp], q.[DateToProcess], q.[DateProcessed], q.[Status], 
			q.[Threadlock], q.[AttemptsRemaining], q.[iPriority], q.[CreatorId], q.[CreatorName],
			q.[UserId], q.[UserName], q.[Context], q.[Verb], q.[OldValue], q.[NewValue], q.[Description], 
			q.[Ip], q.[ApplicationId]
	FROM	[EventQ] q, [#tmpRemoveOld] t
	WHERE	t.[Id] = q.[Id] 
			AND q.[Id] NOT IN 
				(SELECT qa.[Id] FROM [EventQArchive] qa WHERE qa.[ApplicationId] = @applicationId)
			
	--DELETE the Queue rows 
	DELETE	FROM [EventQ] 
	WHERE	[Id] IN 
				(SELECT t.[Id] FROM [#tmpRemoveOld] t)

	COMMIT TRANSACTION

	DROP TABLE #tmpRemoveOld
	--END ARCHIVAL

	BEGIN TRANSACTION

		 -- retry any old events that failed
		UPDATE	[EventQ]
		SET		[ThreadLock] = NULL
		WHERE	[ApplicationId] = @applicationId 
				AND [ThreadLock] IS NOT NULL
				AND [DateProcessed] < DATEADD( SECOND, @retrySeconds, GETDATE() )
				AND [Status] IS NULL OR [Status] <> 'Success'

		--uses less cpu and less reads
		CREATE	TABLE #tmpRows(Id INT)
		
		INSERT	#tmpRows(Id)
		SELECT	TOP (@batchSize) q.[Id]
		FROM	[EventQ] q
		WHERE	q.[ApplicationId] = @applicationId 
				AND q.[ThreadLock] IS NULL
				AND q.[DateProcessed] IS NULL 
				AND q.[DateToProcess] < GETDATE()
				AND (q.[Status] IS NULL OR q.[Status] <> 'Success')
				AND q.[AttemptsRemaining] > 0
		ORDER BY q.[iPriority] ASC, q.[Id] ASC

		 -- update to lock them
		UPDATE	[EventQ]
		SET		[ThreadLock] = @threadGuid,
				[DateProcessed] = GETDATE()
		FROM	[#tmpRows] r
		WHERE	r.[ID] = [EventQ].[ID]
				AND [EventQ].[ThreadLock] IS NULL
				AND [EventQ].[DateProcessed] IS NULL 
				AND [EventQ].[DateToProcess] < GETDATE()
				AND ([EventQ].[Status] IS NULL OR [EventQ].[Status] <> 'Success')
				AND [EventQ].[AttemptsRemaining] > 0

	COMMIT TRANSACTION

	 -- select affected rows
	SELECT	*
	FROM	[EventQ]
	WHERE	[ApplicationId] = @applicationId 
			AND [ThreadLock] = @threadGuid

END
GO
