USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Shipping_BatchUndo]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Kurtz, Robert>
-- Create date: 110805>
-- Description:	First cleans up entity values (which hold recorded physical ticket 
--	numbers by criteria) and then it will update the related ticket InvoiceItems 
--	(setting the ship date to null). 
--	The next step is to clean up all the related rows...
--	InvoiceShipmentItems -> InvoiceShipment -> ShipmentBatch_InvoiceShipment
--	and finally the batch itself.
--	The client should emphatically approve this operation!!
-- =============================================

CREATE PROCEDURE [dbo].[tx_Shipping_BatchUndo](
	
	@delbatchId	INT
	
)
AS
BEGIN

	SET NOCOUNT ON;
    
	--don't worry about invoicebill ship on the undo
	--even if there is a recorded shipdate for the IBS - it will be overwritten
	--on the creation of a new batch/shipment

	--PART I
	--establish a list of invoiceitems affected
	--**do not use an or clause - very slow performance
	--delete any entity values tied to those invoiceitems
	--update the shipping dates on the items to null
	--drop any temp tables

	--get invoice shipments in batch
	SELECT	[tShipItemId] 
	INTO	#tmpShipIds
	FROM	[InvoiceShipment] 
	WHERE	[Id] IN (
				SELECT [tInvoiceShipmentId] 
				FROM [ShipmentBatch_InvoiceShipment] 
				WHERE tShipmentBatchId = @delbatchId)

	--add shipping items to list of items
	SELECT	ii.[Id] AS [InvItemId]
	INTO	#tmpItemIds
	FROM	[InvoiceItem] ii, [#tmpShipIds] ts 
	WHERE	ts.[tShipItemId] = ii.[Id]

	--add items with a matching shipid
	INSERT	#tmpItemIds (InvItemId)
	SELECT	ii.[Id] 
	FROM	[InvoiceItem] ii, [#tmpShipIds] ts
	WHERE	ts.[tShipItemId] = ii.[tShipItemId]

	--update entityvalues
	DELETE	FROM	[EntityValue] 
	WHERE	[vcTableRelation] = 'InvoiceItem' 
			AND [vcValueContext] = 'TicketNumbers' 
			AND [tParentId] IN 
				(SELECT InvItemId FROM #tmpItemIds)
		
	--update invoiceitems
	UPDATE	InvoiceItem
	SET		[dtShipped] = NULL
	WHERE	[Id] IN 
				(SELECT InvItemId FROM #tmpItemIds)

	--clean temps
	DROP TABLE #tmpItemIds
	DROP TABLE #tmpShipIds

	--PART II
	--delete batch relations in reverse

	--invoiceshipmentitems
	DELETE	FROM [InvoiceShipmentItem] 
	WHERE	tInvoiceShipmentId IN (
				SELECT tInvoiceShipmentId 
				FROM [ShipmentBatch_InvoiceShipment] 
				WHERE tShipmentBatchId = @delbatchid )

	--invoiceshipment
	DELETE	FROM [InvoiceShipment] 
	WHERE	Id IN (
				SELECT tInvoiceShipmentId 
				FROM [ShipmentBatch_InvoiceShipment] 
				WHERE tShipmentBatchId = @delbatchid )

	--this is somewhat unnecessary as it is cascaded from InvoiceShipment
	--but things may change...
	--shipmentbatch_invoiceshipment
	DELETE	FROM [ShipmentBatch_InvoiceShipment]
	WHERE	tShipmentBatchId = @delbatchid

	--FInally, delete the actual batch
	DELETE	FROM [ShipmentBatch] 
	WHERE	Id = @delbatchid

END
GO
