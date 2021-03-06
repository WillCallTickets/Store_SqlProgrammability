USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Inventory_ClearCart_ReturnItemNotification]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: Jan 14 2009
-- Description:	Matches items in GUIDS(shopping cart items) and clears them out of stock table.
--	see below for examples
-- =============================================

CREATE PROC [dbo].[tx_Inventory_ClearCart_ReturnItemNotification](

	@context			VARCHAR(50),
	@notifyThreshold	INT,
	@guids				VARCHAR(4000),
	@incSales			BIT

)
AS

BEGIN

	
	-- this table holds the ids of the contextual items that are below or at threshhold
	-- it is returned to the client
	IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[#tmpNotify]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN
	
		CREATE TABLE #tmpNotify (
			context	VARCHAR(256),
			idx		INT NOT NULL
		)
	END

	-- holds the info from the ticket stock table pertaining to the cleared objects
	IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[#removingStock]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN
	
		CREATE TABLE #removingStock (
			
			productIdx	INT,
			iQty		INT
		)
		
	END

	IF (@context = 'ticket') 
	BEGIN	

		-- this table is created to split up the passed in guids
		-- in this vase item is a the guid from the stock table
		IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[#tmpRes]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		BEGIN
		
			CREATE TABLE #stockGuids (
			
				[Id]	INT NOT NULL,
				[guid]	VARCHAR(256) NOT NULL
				
			)
			
		END
			
		-- split input guids into separate guids
		INSERT	#stockGuids( [Id], [guid] )
		SELECT	ti.[Id], ti.[ListItem] AS 'guid'
		FROM	fn_ListToTable( @guids ) ti	
	
		-- if this is a check out and we are recording the sales...
		IF (@incSales = 1) 
		BEGIN 

			-- retrieve matching items in stock
			INSERT	#removingStock([productIdx], [iQty])
			SELECT	stock.[tShowTicketId] AS 'productIdx', stock.[iQty]
			FROM	[TicketStock] stock, [#stockGuids] guids
			WHERE	stock.[GUID] = CONVERT( UNIQUEIDENTIFIER, guids.[guid] )
			
			--**TICKET PKGS **--
			-- if the tickets are in a package
			-- first we build a table that has the sum of all tickets in a given pkg in the same order
			CREATE TABLE #groupedQty([GroupIdentifier] UNIQUEIDENTIFIER, iQty INT)
			
			INSERT	#groupedQty([GroupIdentifier], iQty)
			SELECT	GroupIdentifier, SUM(Linked.[iQty]) AS iQty
			FROM	(
						SELECT	DISTINCT remove.[ProductIdx], link.[GroupIdentifier], remove.[iQty] AS iQty
						FROM	[#removingStock] remove
						LEFT OUTER JOIN [ShowTicketPackageLink] link 
							ON link.[ParentShowTicketId] = remove.[productIdx]
					) AS Linked
			GROUP BY [GroupIdentifier]

			-- if we have tickets in pkgs - then update the removing stock table with the total qty of pkg tix
			IF EXISTS (SELECT * FROM [#groupedQty]) 
			BEGIN

				-- add in other tickets in the pkg that are not in this order - but need to be updated/synced AS well
				-- we have already matched on parent ids - so get linked ids only
				INSERT	[#removingStock] ([ProductIdx], [iQty])
				SELECT	DISTINCT link.[LinkedShowTicketId] AS ProductIdx, 0 AS iQty
				FROM	[#removingStock] remove, [ShowTicketPackageLink] link 
				WHERE	remove.[ProductIdx] = link.[ParentShowTicketId] 
						AND link.[LinkedShowTicketId] NOT IN 
							(SELECT [ProductIdx] FROM [#removingStock])

				UPDATE	[#removingStock]
				SET		[iQty] = grouped.[iQty]
				FROM	[#removingStock] remove
						LEFT OUTER JOIN [ShowTicketPackageLink] link 
							ON link.[ParentShowTicketId] = remove.[productIdx], [#groupedQty] grouped
				WHERE	link.[GroupIdentifier] = grouped.[GroupIdentifier]

			END
			--**END OF TICKET PKGS **--

			-- this updates the showtickets ticketids and the amount to increment sold for each ticket - pkg safe
			UPDATE	[ShowTicket]
			SET		[iSold] = ent.[iSold] + remove.[iQty]
			FROM	[ShowTicket] ent, [#removingStock] remove
			WHERE	ent.[Id] = remove.[ProductIdx]

			IF(@notifyThreshold > 0) 
			BEGIN
			
				--find products that are at threshhold that were affected by this transaction
				--so if the item = threshhold, then we send a notice - inventory is affected by changes made to the items
				INSERT	#tmpNotify(context, idx)
				SELECT	'threshold', st.[Id]
				FROM	[ShowTicket] st, [TicketStock] stock
				WHERE	stock.[GUID] IN 
							(SELECT CONVERT( UNIQUEIDENTIFIER, guids.[guid] ) FROM [#stockGuids] guids) 
						AND	st.[Id] = stock.[tShowTicketId] 
						AND (st.[iAllotment] - st.[iSold] + stock.[iQty]) > @notifyThreshold 
						AND (st.[iAllotment] - st.[iSold]) <= @notifyThreshold
						
			END

			/*ALWAYS NOTIFY SOLD OUT*/
			INSERT	#tmpNotify(context, idx)
			SELECT	'soldout', st.[Id]
			FROM	[ShowTicket] st, [TicketStock] stock
			WHERE	stock.[GUID] IN 
						(SELECT CONVERT( UNIQUEIDENTIFIER, guids.[guid] ) FROM [#stockGuids] guids) 
					AND st.[Id] = stock.[tShowTicketId] 
					AND st.[iAllotment] <= st.[iSold]
					
		END 

		INSERT	TicketStock_Removed( [Id], [GUID], [SessionId], 
				[TInvoiceId], [UserName], [tShowTicketId], [iQty], 
				[dtTTL], [dtRemoved], [ProcName], [dtStamp])
		SELECT 	[Id], [GUID], [SessionId], 
				[TInvoiceId], [UserName], [tShowTicketId], [iQty], 
				[dtTTL], getDate() AS dtRemoved, 
				CASE WHEN @incSales=1 THEN 'ClearForSale' 
					ELSE 'ClearCart'
				END AS ProcName, 
				[dtStamp]
		FROM	[TicketStock] 
		WHERE	[GUID] IN 
					(SELECT CONVERT( UNIQUEIDENTIFIER, guids.[guid] ) FROM [#stockGuids] guids)

		-- Now we remove the pendings from the stock table
		DELETE	FROM [TicketStock] 
		WHERE	[GUID] IN 
					(SELECT CONVERT( UNIQUEIDENTIFIER, guids.[guid] ) FROM [#stockGuids] guids)	

		SELECT 'SUCCESS'

		IF EXISTS (SELECT * FROM #tmpNotify)
			SELECT * FROM #tmpNotify

		RETURN
		
		DROP TABLE [#stockGuids]

	END -- END TICKETS-----------------------------------------------------

	--MERCH-----------------------------------------------------------
	ELSE IF (@context = 'merch') 
	BEGIN	
				
		-- split input guids into separate guids from name-value pairs
		INSERT	#removingStock( [productIdx], [iQty] )
		SELECT	CONVERT(int, SUBSTRING(ti.[ListItem], 1, (CHARINDEX('=', ti.[ListItem]) - 1))) AS 'productIdx', 
				CONVERT(int, SUBSTRING(ti.[ListItem], CHARINDEX('=', ti.[ListItem]) + 1, LEN(ti.[ListItem]))) AS 'iQty'
		FROM	fn_ListToTable( @guids ) ti		

		IF(@incSales = 1) 
		BEGIN

			UPDATE	Merch
			SET		[iSold] = [iSold] + remove.[iQty] 
			FROM	[Merch] m, [#removingStock] remove
			WHERE	m.[Id] = remove.[productIdx]	

			IF(@notifyThreshold > 0) 
			BEGIN
			
				--find products that are at threshhold that were affected by this transaction
				--so if the item = threshhold, then we send a notice - inventory is affected by changes made to the items
				INSERT	#tmpNotify(context, idx)
				SELECT	'threshold', merch.[Id]
				FROM	[Merch] merch, [#removingStock] remove
				WHERE	merch.[Id] = remove.[productIdx] 
						AND (merch.[iAllotment] - merch.[iDamaged] - merch.[iSold] + remove.[iQty]) > @notifyThreshold 
						AND (merch.[iAllotment] - merch.[iDamaged] - merch.[iSold]) <= @notifyThreshold
						
			END

			/*ALWAYS NOTIFY SOLD OUT*/
			INSERT	#tmpNotify(context, idx)
			SELECT	'soldout', merch.[Id]
			FROM	[Merch] merch, [#removingStock] remove
			WHERE	merch.[Id] = remove.[productIdx] AND 
					merch.[iAllotment] - merch.[iDamaged] <= merch.[iSold]

		END -- incsales
		
		SELECT 'SUCCESS'

		IF EXISTS (SELECT * FROM #tmpNotify)
			SELECT * FROM #tmpNotify

		RETURN
		
		DROP TABLE	#stockMerch

	END -- END merchandise
	
	DROP TABLE [#removingStock]
	DROP TABLE [#tmpNotify]

END




/*

declare @guid UNIQUEIDENTIFIER;select @guid = newid()
exec tx_Inventory_AddUpdate @guid, 'session', 'user', 12704, 1, 'Feb  5 2007  8:37:58:080PM', 'ticket'

declare @guid UNIQUEIDENTIFIER;select @guid = newid()
exec tx_Inventory_AddUpdate @guid, 'session', 'user', 12705, 4, 'Feb  5 2007  8:37:58:080PM', 'ticket'

declare @guid UNIQUEIDENTIFIER;select @guid = newid()
exec tx_Inventory_AddUpdate @guid, 'session', 'user', 12632, 2, 'Feb  5 2007  8:37:58:080PM', 'ticket'

declare @guid UNIQUEIDENTIFIER;select @guid = newid()
exec tx_Inventory_AddUpdate @guid, 'session', 'user', 12622, 3, 'Feb  5 2007  8:37:58:080PM', 'ticket'

declare @guid UNIQUEIDENTIFIER;select @guid = newid()
exec tx_Inventory_AddUpdate @guid, 'session', 'user', 12570, 1, 'Feb  5 2007  8:37:58:080PM', 'ticket'

declare @guid UNIQUEIDENTIFIER;select @guid = newid()
exec tx_Inventory_AddUpdate @guid, 'session', 'user', 12572, 2, 'Feb  5 2007  8:37:58:080PM', 'ticket'

update showticket set bactive = 1, iallotment= 60 where id in (12569,12570,12571,12572)

select * from [ShowTicketPackageLink]

select id, bactive, iallotment, ipending, isold, iavailable from showticket where id in 
	(12704,12705,12632,12622,12569,12570,12571,12572)

select id, bactive, iallotment, ipending, isold, iavailable from showticket where id in 
	(12704,12705,12632,12622,12569,12570,12571,12572)

BEGIN TRANSACTION

UPDATE	[ShowTicket]
SET		[iSold] = st.[iSold] + pkg.[QtySummed]
--SELECT	st.[Id], pkg.[QtySummed] -- leave here for testing
FROM	[ShowTicket] st, [ShowTicketPackageLink] link --[#tmpPkgQuantity] pkg, 
		LEFT OUTER JOIN 
		(
			SELECT	link.[GroupIdentifier] AS 'GroupIdentifier', 
			CASE WHEN link.[GroupIdentifier] IS NULL THEN stock.[tShowTicketId] ELSE 0 END AS 'tShowTicketId', 

			SUM(stock.[iQty]) AS 'QtySummed'
			FROM	[TicketStock] stock LEFT OUTER JOIN [ShowTicketPackageLink] link ON link.[ParentShowTicketId] = stock.[tShowTicketId]
			GROUP BY link.[GroupIdentifier], 
				CASE WHEN link.[GroupIdentifier] IS NULL THEN stock.[tShowTicketId] ELSE 0 END

		) AS pkg ON (1 = 1)
--WHERE	pkg.[GroupIdentifier] = link.[GroupIdentifier] AND st.[Id] = link.[ParentShowTicketId]
WHERE	CASE WHEN pkg.[tShowTicketId] = 0 THEN 

			CASE WHEN pkg.[GroupIdentifier] = link.[GroupIdentifier] AND 
				st.[Id] = link.[ParentShowTicketId] THEN 1 ELSE 0 
			END 

		ELSE

			CASE WHEN pkg.[tShowTicketId] = st.[Id] THEN 1 ELSE 0 
			END

		END = 1

--GROUP BY st.[Id], pkg.[QtySummed] ORDER BY st.[Id] -- leave here for testing - use with select statement


select * from ticketstock
select id, bactive, iallotment, ipending, isold, iavailable from showticket where id in 
	(12704,12705,12632,12622,12569,12570,12571,12572)


ROLLBACK
*/
GO
