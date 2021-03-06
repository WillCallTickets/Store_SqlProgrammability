USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Shipping_BatchListingCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/10
-- Description:	Returns rows of invoices and items that are in the psecified batch 
-- Returns:		Wcss.QueryRow.ShippingFulfillment
-- exec [dbo].[tx_Shipping_BatchListing] 10028, @sortMethod='FirstNameLastName',@filterMethod='all',@StartRowIndex=0,@PageSize=10000
-- exec [dbo].[tx_Shipping_BatchListing] 10028, @sortMethod='FirstNameLastName',@filterMethod='notyetprintedonly',@StartRowIndex=0,@PageSize=10000
-- =============================================

CREATE	PROC [dbo].[tx_Shipping_BatchListingCount](

	@batchId	INT

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	SELECT	COUNT( ( i.[Id] ) )
	FROM	[ShipmentBatch_InvoiceShipment] sbis, 
			[InvoiceShipment] invs, 
			[Invoice] i 
	WHERE	sbis.[tShipmentBatchId] = @batchId 
			AND sbis.[tInvoiceShipmentId] = invs.[Id] 
			AND invs.[tInvoiceId] = i.[Id] 
			AND invs.[vcContext] = 'ticket' 
			AND i.[InvoiceStatus] <> 'NotPaid'

END
GO
