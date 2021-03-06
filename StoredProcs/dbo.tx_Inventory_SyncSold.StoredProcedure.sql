USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Inventory_SyncSold]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: Mar 13 2010
-- Description:	returns the actual sold of an item by looking at invoiceitems purchased
/*
	exec [tx_Inventory_SyncSold] 12704, 'ticket'
	select iallotment, ipending, isold from showticket where id = 12704
*/
-- =============================================

CREATE   PROC [dbo].[tx_Inventory_SyncSold](

	@idx			INT,
	@performUpdate	BIT,		-- do we perform sync
	@context		VARCHAR(50) -- merch or ticket

)
AS

BEGIN

	DECLARE @appId			UNIQUEIDENTIFIER
	
	DECLARE	@actualSold		INT
	DECLARE @recordedSold	INT
	DECLARE	@outOfSync		BIT

	SET		@actualSold		= 0
	SET		@outOfSync		= 0

	IF (@context = 'ticket' AND EXISTS (SELECT * FROM [ShowTicket] WHERE [Id] = @idx)) 
	BEGIN 

		SELECT	@actualSold = ISNULL(SUM(ii.[iQuantity]),0)
		FROM	[InvoiceItem] ii, [Invoice] i
		WHERE	ii.[tShowTicketId] IS NOT NULL 
				AND ii.[tShowTicketId] = @idx 
				AND ii.[tInvoiceId] = i.[Id] 
				AND (i.[InvoiceStatus] = 'Paid' OR i.[InvoiceStatus] = 'PartiallyRefunded') 
				AND ii.PurchaseAction = 'Purchased'

		-- ...TO NOTIFY ADMIN
		SELECT	@recordedSold = [iSold] 
		FROM	[ShowTicket] 
		WHERE	[Id] = @idx

		--Create a table to hold the tickets to be modified
		CREATE Table #addTickets ( idx INT )

		INSERT	#addTickets(idx) 
		SELECT	@idx

		--Also add linked tickets - ticket packages are linked
		INSERT	#addTickets(idx)
		SELECT	DISTINCT link.[LinkedShowTicketId]
		FROM	[ShowTicketPackageLink] link, [ShowTicket] ent
		WHERE	@idx = ent.[Id] 
				AND link.[ParentShowTicketId] = ent.[Id]

		--these 2 vars help us track if (in a pkg) the tickets are getting out of sync with each other
		--otherwise we are forced to treat all tix in pkg as whole for comparison
		--this way we can see if one or some haven "broken off from the pack"
		DECLARE	@tktCount		INT
		DECLARE	@outOfSyncCount	INT

		SELECT	@tktCount = COUNT(DISTINCT [idx]) 
		FROM	[#addTickets]

		IF EXISTS (SELECT * FROM [ShowTicket] st, [#addTickets] at WHERE st.[Id] = at.[idx] AND st.[iSold] <> @actualSold) 
		BEGIN

			SET	@outOfSync = 1
			
			SELECT	@outOfSyncCount = COUNT(DISTINCT st.[id]) 
			FROM	[ShowTicket] st, [#addTickets] at 
			WHERE	st.[Id] = at.[idx] 
					AND st.[iSold] <> @actualSold

			--in a pkg it is possible for one or more of the pkg tix to be out of sync
			-- so we check for a matching value
			IF (@outOfSyncCount <> @tktCount) 
			BEGIN

				SELECT	@recordedSold = MIN(st.[iSold])
				FROM	[ShowTicket] st, [#AddTickets] at
				WHERE	st.[Id] = at.[idx] 
						AND st.[iSold] <> @actualSold 
						AND st.[iSold] <> @recordedSold
				GROUP BY st.[Id]

			END

		END


		IF (@performUpdate = 1 AND @outOfSync = 1) 
		BEGIN

			UPDATE  ShowTicket 
			SET		[iSold] = @actualSold 
			FROM	[ShowTicket] st, [#addTickets] at
			WHERE	st.[Id] = at.[idx]
			
		END

		-- only notify if there is an actual discrepancy
		IF (@outOfSync = 1) 
		BEGIN 

			--notify admin
			-- get the appid from the show row
			SELECT	@appId = show.[ApplicationId]
			FROM	[ShowTicket] ent, [Show] show
			WHERE	@idx = ent.[Id] 
					AND ent.[tShowId] = show.[Id]

			--see EventQ EventJob.cs method for how params are set
			-- TODO record ip address or remove
			INSERT	EventQ([ApplicationId], [dtStamp], [DateToProcess], [AttemptsRemaining], [iPriority], 
					[Context], [Verb], 
					[OldValue], 
					[NewValue], 
					[Description], [Ip])
			SELECT	@appId, getDate(), getDate(), 3, 10, 
					'ShowTicket', 'InventoryError', 
					CAST(@recordedSold as VARCHAR), CAST(@actualSold as VARCHAR), 
					'TicketId: ' + CAST(@idx as VARCHAR) + ' sold discrepancy ' + 
					CASE WHEN (@performUpdate = 1) THEN 'UPDATED' ELSE 'NOT UPDATED!!!!!' END + ' - ' + 
					CASE WHEN (@tktCount = @outOfSyncCount) THEN 'All Rows' ELSE CAST(@outOfSyncCount as VARCHAR(50)) + ' out of ' + CAST(@tktCount as VARCHAR(50)) + ' rows' END ,
					'127.0.0.1'
					
		END

		DROP TABLE #addTickets

	END -- ticket
	
	ELSE IF (@context = 'merch' AND EXISTS (SELECT * FROM [Merch] WHERE [Id] = @idx))  
	BEGIN -- merch

		SELECT	@actualSold = ISNULL(SUM(ii.[iQuantity]),0)
		FROM	[InvoiceItem] ii, [Invoice] i
		WHERE	ii.[tMerchId] IS NOT NULL 
				AND ii.[tMerchId] = @idx 
				AND ii.[tInvoiceId] = i.[Id] 
				AND (i.[InvoiceStatus] = 'Paid' OR i.[InvoiceStatus] = 'PartiallyRefunded') 
				AND ii.PurchaseAction = 'Purchased'

		SELECT	@recordedSold = [iSold] 
		FROM	[Merch] 
		WHERE	[Id] = @idx

		IF EXISTS (SELECT * FROM [Merch] WHERE [Id] = @idx AND [iSold] <> @actualSold) 
		BEGIN
		
			SET	@outOfSync = 1
			
		END
			
		IF (@performUpdate = 1 AND @outOfSync = 1) 
		BEGIN

				UPDATE	Merch 
				SET		[iSold] = @actualSold 
				WHERE	[Id] = @idx

		END
		
		IF (@outOfSync = 1) 
		BEGIN
		
			-- only notify if there is an actual discrepancy
			--get appid from merch object
			SELECT	@appId = ent.[ApplicationId]
			FROM	[Merch] ent
			WHERE	@idx = ent.[Id] 

			--see EventQ EventJob.cs method for how params are set
			-- TODO record ip address or remove
			INSERT	EventQ([ApplicationId], [dtStamp], [DateToProcess], [AttemptsRemaining], [iPriority], 
					[Context], [Verb], 
					[OldValue], 
					[NewValue], 
					[Description], 
					[Ip])
			SELECT	@appId, getDate(), getDate(), 3, 10, 
					'Merch', 'InventoryError', 
					CAST(@recordedSold as VARCHAR), CAST(@actualSold as VARCHAR), 
					'MerchId: ' + CAST(@idx as VARCHAR) + ' sold discrepancy ' + 
					CASE WHEN (@performUpdate = 1) THEN 'UPDATED' ELSE 'NOT UPDATED!!!!!' END,
					'127.0.0.1'

		END 

	END

	SELECT @actualSold

	RETURN 

END
GO
