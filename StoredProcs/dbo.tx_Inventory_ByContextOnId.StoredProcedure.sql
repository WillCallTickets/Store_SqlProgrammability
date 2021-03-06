USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Inventory_ByContextOnId]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/12/15
-- Description:	Retrieves inventory for a given id. When dealing with items that may have children, 
--	it will only retrieve the active inventory. It uses the Enum.InventoryCheck_Context 
--	as its context. Returns an InventoryCheckRow to the caller 
-- =============================================


CREATE PROCEDURE [dbo].[tx_Inventory_ByContextOnId](

	@Context	VARCHAR(50),
	@Idx		INT

)
AS 

SET DEADLOCK_PRIORITY LOW 

BEGIN

	IF(@Context = 'Merch') 
	BEGIN
		
		--if it is a parent
		IF EXISTS(SELECT * FROM [Merch] WHERE [Id] = @Idx AND [tParentListing] IS NULL) 
		BEGIN
			
			CREATE TABLE #merchChildren (idx INT)
			
			INSERT	#merchChildren (idx)
			SELECT	m.[Id] 
			FROM	[Merch] m 
			WHERE	m.[tParentListing] IS NOT NULL 
					AND m.[tParentListing] = @Idx

			SELECT	SUM(m.[iAllotment]) AS Allotment, 
					SUM(m.[iDamaged]) AS Damaged, 
					0 AS Pending, 
					SUM(m.[iSold]) AS Sold, 
					SUM(m.[iAvailable]) AS Available, 
					SUM(m.[iRefunded]) AS Refunded
			FROM	[Merch] m
			WHERE	m.[tParentListing] = @Idx 
					AND m.[bActive] = 1
			
			RETURN

		END	ELSE 
		BEGIN -- we have a child
		
			SELECT	ISNULL(m.[iAllotment],0) AS Allotment, 
					ISNULL(m.[iDamaged],0) AS Damaged, 
					0 AS Pending, 
					ISNULL(m.[iSold],0) AS Sold, 
					ISNULL(m.[iAvailable],0) AS Available, 
					ISNULL(m.[iRefunded],0) AS Refunded
			FROM	[Merch] m
			WHERE	m.[Id] = @Idx 
			
			RETURN
	
		END
		
		
	END

	--this does not check pending
	ELSE IF(@Context = 'MerchPromo') 
	BEGIN

		SELECT	SUM(m.[iAllotment]) AS Allotment, 
				SUM(m.[iDamaged]) AS Damaged, 
				0 AS Pending, 
				SUM(m.[iSold]) AS Sold, 
				SUM(m.[iAvailable]) AS Available, 
				SUM(m.[iRefunded]) AS Refunded
		FROM	[SalePromotionAward] sa, [Merch] m
		WHERE	sa.[TSalePromotionId] = @Idx 
				AND	sa.[TParentMerchId] = m.[tParentListing] 
				AND m.[bActive] = 1

		RETURN 

	END
	
	--this does not check pending
	ELSE IF(@Context = 'TicketPromo') 
	BEGIN

		SELECT	0 AS Allotment,	0 AS Damaged, 
				0 AS Pending,	0 AS Sold, 
				0 AS Available, 0 AS Refunded

		RETURN 

	END
	
	ELSE IF(@Context = 'Ticket') 
	BEGIN

		--Create a table to hold the tickets to be modified
		CREATE TABLE #addTickets ( ticketIdx INT )
		
		INSERT	#addTickets(ticketIdx) 
		SELECT	@Idx

		--Also add linked tickets - ticket packages are linked
		INSERT	#addTickets(ticketIdx)
		SELECT	DISTINCT link.[LinkedShowTicketId]
		FROM	[ShowTicketPackageLink] link, [ShowTicket] st
		WHERE	@idx = st.[Id] 
				AND link.[ParentShowTicketId] = st.[Id]

		SELECT	SUM(m.[iAllotment]) AS Allotment, 
				0 AS Damaged, 
				ISNULL(pendingStock.[iQty],0) AS Pending, 
				SUM(m.[iSold]) AS Sold, 
				SUM(m.[iAvailable]) AS Available, 
				SUM(m.[iRefunded]) AS Refunded
		FROM	[ShowTicket] m
				LEFT OUTER JOIN 
					(
						SELECT	SUM(CASE WHEN [iQty] <= 0 THEN 0 ELSE [iQty] END) AS iQty
						FROM	[TicketStock] stock, [#addTickets] at
						WHERE	stock.[tShowTicketId] = at.[ticketIdx]

					) AS pendingStock 
					ON (1 = 1)
		WHERE	m.[Id] = @Idx

		RETURN

	END
	
	ELSE 
	BEGIN
		
		SELECT	0 AS Allotment, 0 AS Damaged, 
				0 AS Pending,	0 AS Sold, 
				0 AS Available, 0 AS Refunded

		RETURN 

	END

END
GO
