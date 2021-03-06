USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Shipping_UpdateBatchListing]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 09/10/29
-- Description:	Apply changes top an entire batch 
/* 
exec [dbo].[tx_Shipping_UpdateBatchListing] @batchId=10034,@newDate=NULL,@actualShipping=7.5,
	@isPrinted=NULL,@filterMethod='notyetprintedonly'
select mshippingactual,* from invoiceshipment where dtstamp > '10/11/2009'
*/
-- =============================================

CREATE	PROC [dbo].[tx_Shipping_UpdateBatchListing](

	@batchId		INT,
	@newDate		DATETIME,
	@actualShipping MONEY
	
)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	--FILTER INVOICES
	SELECT	DISTINCT i.[Id] AS 'InvoiceId', i.[PurchaseEmail], invs.[Id] AS 'InvoiceShipmentId'			
	INTO	[#tmpAllBatchInvoice]
	FROM	[ShipmentBatch_InvoiceShipment] sbis, 
			[InvoiceShipment] invs, 
			[Invoice] i 
	WHERE	sbis.[tShipmentBatchId] = @batchId 
			AND sbis.[tInvoiceShipmentId] = invs.[Id] 
			AND invs.[tInvoiceId] = i.[Id] 
			AND invs.[vcContext] = 'ticket' 
			AND i.[InvoiceStatus] <> 'NotPaid'

	--UPDATE SHIPDATE
	IF (@newDate IS NOT NULL) 
	BEGIN
	
		--shipmentbatch
		UPDATE	[ShipmentBatch]
		SET		[dtEstShipDate] = @newDate
		WHERE	[Id] = @batchId
	
		--invoicebillship
		UPDATE	[InvoiceBillShip] 
		SET		[dtShipped] = @newDate 
		FROM	[InvoiceBillShip] ibs, [#tmpAllBatchInvoice] t 
		WHERE	ibs.[tInvoiceId] = t.[InvoiceId]
	
		--invoiceshipment
		UPDATE	[InvoiceShipment] 
		SET		[dtShipped] = @newDate 
		FROM	[InvoiceShipment] invs, [#tmpAllBatchInvoice] t 
		WHERE	invs.[Id] = t.[InvoiceShipmentId]
	
		--items
		UPDATE	[InvoiceItem] 
		SET		[dtShipped] = @newDate 
		FROM	[InvoiceItem] ii, 
				[InvoiceShipmentItem] isi, 
				[#tmpAllBatchInvoice] t 
		WHERE	isi.[tInvoiceShipmentId] = t.[InvoiceShipmentId] 
				AND isi.[tInvoiceItemId] = ii.[Id]

	END

	--UPDATE ACTUAL SHIPPING
	IF(@actualShipping IS NOT NULL) 
	BEGIN
	
		--invoiceshipment
		UPDATE	[InvoiceShipment] 
		SET		[mShippingActual] = @actualShipping 
		FROM	[InvoiceShipment] invs, [#tmpAllBatchInvoice] t 
		WHERE	invs.[Id] = t.[InvoiceShipmentId]
		
	END

	--CLEANUP
	DROP TABLE	[#tmpAllBatchInvoice]

END
GO
