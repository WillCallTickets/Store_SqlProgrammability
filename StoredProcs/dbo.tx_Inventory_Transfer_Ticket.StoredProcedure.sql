USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Inventory_Transfer_Ticket]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/12/15
-- Description:	Transfers inventory from one ticket to another. Pending amounts are not transferred 
--	and are left for the ReservationCleanup proc to deal with. This proc returns the  
--	amount transferred AS well AS the number of pending tickets 
-- DO NOT TRANSFER TICKET PKGS!
-- =============================================

CREATE PROCEDURE [dbo].[tx_Inventory_Transfer_Ticket](

	@parentId		INT,
	@transferToId	INT

)
AS 

BEGIN
	
	SET NOCOUNT ON

	DECLARE @amtToTransfer		INT, 
			@transferred		INT, 
			@pending			INT, 
			@parentAllotment	INT, 
			@childAllotment		INT

	SET	@amtToTransfer		= 0
	SET	@pending			= 0
	SET	@parentAllotment	= 0
	SET	@childAllotment		= 0

	
	--tickets in question must be active and parent must be parent and transfer to must be DOS
	IF EXISTS (	SELECT	* 
				FROM	[ShowTicket] p 
				WHERE	p.[Id] = @parentId 
						AND p.[bActive] = 1 
						AND p.[bDosTicket] = 0) 
	BEGIN
	
		IF EXISTS (SELECT * FROM [ShowTicket] t WHERE t.[Id] = @transferToId AND t.[bActive] = 1 AND t.[bDosTicket] = 1) 
		BEGIN

			--determine amount to transfer
			SELECT	@parentAllotment = p.[iAllotment], 
					@pending = ISNULL(pending.[iQty], 0),
					@amtToTransfer = p.[iAllotment] - ISNULL(pending.[iQty], 0) - p.[iSold]
			FROM	[ShowTicket] p 
					LEFT OUTER JOIN fn_PendingStock('ticket') pending 
						ON pending.[idx] = p.[Id]
			WHERE	p.[Id] = @parentId

			IF (@amtToTransfer > 0) 
			BEGIN

				--update the parent - reset inventory
				UPDATE	ShowTicket
				SET		iAllotment = iAllotment - @amtToTransfer
				WHERE	[Id] = @parentId

				DECLARE	@nowDate datetime
				SET		@nowDate = GETDATE()

				INSERT	[HistoryInventory](dtStamp, tShowTicketId, dtAdjusted, iCurrentlyAllotted, iAdjustment, vcContext)
				VALUES	(@nowDate, @parentId, @nowDate, @parentAllotment, -@amtToTransfer, 'Allotment')

				SELECT	@childAllotment = c.[iAllotment]
				FROM	[ShowTicket] c 
				WHERE	c.[Id] = @transferToId

				--update the dos ticket
				UPDATE	ShowTicket
				SET		[iAllotment] = [iAllotment] + @amtToTransfer
				WHERE	[Id] = @transferToId

				INSERT	[HistoryInventory](dtStamp, tShowTicketId, dtAdjusted, iCurrentlyAllotted, iAdjustment, vcContext)
				VALUES	(@nowDate, @transferToId, @nowDate, @childAllotment, @amtToTransfer, 'Allotment')

			END 
			ELSE IF (@amtToTransfer = 0 AND @pending = 0) 
			BEGIN
		
				--reset some column to track if we are done transferring
				UPDATE	ShowTicket
				SET		vcFlatMethod = 'all transferred'
				WHERE	[Id] = @transferToId

			END
			ELSE IF (@amtToTransfer < 0) 
			BEGIN
			
				SET		@amtToTransfer = 0
				
			END
		END
	END

	SELECT	ISNULL(@amtToTransfer, 0) AS Transferred, 
			ISNULL(@pending, 0) AS Pending, 
			ISNULL(st.[iAllotment], 0) AS Allotment 
	FROM	[ShowTicket] st
	WHERE	st.[Id] = @transferToId

	RETURN

END
GO
