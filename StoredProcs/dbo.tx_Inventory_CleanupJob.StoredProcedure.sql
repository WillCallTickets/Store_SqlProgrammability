USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Inventory_CleanupJob]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Finds expired items in stock tables and resets pending amounts in showticket or merch table. 
--	This proc is run AS a SQL job by the Sql Server agent every 10 minutes. This is not run in the 
--	solution, although this may be run if sql server agent is not available, in a windows app.
--
-- exec [tx_Inventory_CleanupJob] 'FoxTheatre',4,1,120
-- exec [tx_Inventory_CleanupJob] 'WillCall',4,1,120
-- =============================================

CREATE PROC [dbo].[tx_Inventory_CleanupJob](

	@appName			VARCHAR(256),
	@pastDueMinutes		INT,
	@logToRemoveTable	BIT,
	@dateOffsetMinutes	INT

)
AS

SET DEADLOCK_PRIORITY LOW

BEGIN

	--WORK WITH EXPIRED ROWS
	DECLARE @expiryDate 	DATETIME,
			@rowsAffected	INT

	--if past due is null set it to 10 minutes
	SET		@expiryDate = DATEADD(mi,-(ISNULL(@pastDueMinutes,10)),GETDATE())
	SET		@rowsAffected = 0

	
	--TICKETS 
	-- select expired items from ticket stock
	-- these rows will be deleted from the stock table
	CREATE TABLE #tmpBaseExpired(
		Id				INT, 
		tShowTicketID	INT, 
		iQty			INT
	)
	
	INSERT	#tmpBaseExpired(Id, tShowTicketID, iQty)
	SELECT  [Id], [tShowTicketId] AS tShowTicketId, [iQty] AS Quantity
	FROM 	[TicketStock] ts
	WHERE	ts.[dtTTL] < @expiryDate

	--LOG the rows we are going to delete
	IF	@logToRemoveTable = 1
	BEGIN
	
		INSERT	TicketStock_Removed ( [Id], [GUID], [SessionId], [TInvoiceId], 
				[UserName], [tShowTicketId], [iQty], [dtTTL], [dtStamp], 
				[dtRemoved], [ProcName])
		SELECT 	ts.[Id], ts.[GUID], ts.[SessionId], ts.[TInvoiceId], 
				ts.[UserName], ts.[tShowTicketId], ts.[iQty], ts.[dtTTL], ts.[dtStamp],  
				GETDATE() AS dtRemoved, 'tx_Reservation_Cleanup' AS ProcName
		FROM	[TicketStock] ts 
		WHERE	ts.[Id] IN 
					(SELECT [Id] FROM #tmpBaseExpired)
					
	END

	-- DELETE ROWS FROM TICKET STOCK FROM THE INFO WE HAVE JUST GATHERED (note these rows are a snapshot in time)
	-- do this quickly so that nothing else can come in and update the same rows
	-- we also need to do this for the sync operation to work correctly a little while later on
	DELETE	FROM [TicketStock] 
	WHERE	[Id] IN 
				(SELECT [Id] FROM #tmpBaseExpired)

	--SET the return value
	SET @rowsAffected = @@ROWCOUNT

	--Cleanup
	DROP TABLE #tmpBaseExpired

END

/* 100924
	We are no longer doing merch AS a pending item

	--MERCH
	CREATE TABLE #tmpExpiredMerch(Id int, MerchId int, Quantity int)
	INSERT	#tmpExpiredMerch(Id, MerchId, Quantity)
	SELECT  ts.[Id], ts.[tMerchId] AS MerchId, iQty AS Quantity
	FROM 	[MerchStock] ts
	WHERE	ts.[dtTTL] < @expiryDate

	--LOG the rows we are going to delete
	IF	@logToRemoveTable = 1
	BEGIN
	
		INSERT	MerchStock_Removed ( [Id], [GUID], [SessionId], [UserName], [tMerchId], [iQty], [dtTTL], [dtStamp], [dtRemoved], [ProcName])
		SELECT 	ms.[Id], ms.[GUID], ms.[SessionId], ms.[UserName], ms.[tMerchId], ms.[iQty], ms.[dtTTL], ms.[dtStamp], 
				getDate() AS dtRemoved, 'tx_Reservation_Cleanup' AS ProcName
		FROM	[MerchStock] ms WHERE ms.[Id] in (SELECT [Id] FROM #tmpExpiredMerch)
		
	END

	DELETE	FROM MerchStock WHERE [Id] in (SELECT [Id] FROM #tmpExpiredMerch)

	SET @rowsAffected = @rowsAffected + @@ROWCOUNT

	DROP TABLE #tmpExpiredMerch


	--Return the number of rows affected - both merch and tickets
	SELECT @rowsAffected -- this should be returned with nocount on not specified
*/
GO
