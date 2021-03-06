USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetTicketSalesCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description: Returns the count of sales rows for current ticket or showdate. 
-- Returns:		Wcss.TicketSalesRow
/*
	exec tx_GetTicketIdStringSalesCount 0, '10787~10786~10784~10781', 'WillCall', 'All', 'Purchases', 'none'
*/
-- =============================================

CREATE PROCEDURE [dbo].[tx_GetTicketSalesCount](
	
	@ShowDateId			INT,
	@ShowTicketIds		VARCHAR(1024),
	@willCallText		VARCHAR(256),
	@ShipContext		VARCHAR(256),
	@PurchaseContext	VARCHAR(256)
	
)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	IF(@ShowDateId > 0) 
	BEGIN

		SELECT Count(ii.[Id])
		FROM	InvoiceItem ii, 
				ShowDate sd, 
				ShowTicket st, 
				AuthorizeNet auth
		WHERE	sd.[Id] = @ShowDateId 
				AND st.[TShowDateId] = @ShowDateId 
				AND ii.TShowTicketId = st.[Id] 
				AND ii.[vcContext] = 'Ticket' 
				AND ii.[tInvoiceId] = auth.[tInvoiceId] 
				AND auth.[transactiontype] = 'auth_capture' 
				AND auth.[bAuthorized] = 1 
				AND 
				CASE @ShipContext
					WHEN @willCallText THEN 
						CASE WHEN	(ii.[ShippingMethod] IS NULL OR (ii.[ShippingMethod] IS NOT NULL AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) = 0))
									OR
									(ii.[ShippingMethod] IS NOT NULL AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) > 0 
									AND ii.[ShippingMethod] = @willCallText) THEN 1 
							ELSE 0 
						END
					WHEN 'Shipped' THEN 
						CASE WHEN	ii.[ShippingMethod] IS NOT NULL 
									AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) > 0 
									AND ii.[ShippingMethod] <> @willCallText THEN 1 
							ELSE 0 
						END
					ELSE 1 
				END = 1 
				AND 
				CASE @PurchaseContext
					WHEN 'Purchases' THEN
						CASE WHEN ii.[PurchaseAction] = 'Purchased' THEN 1 
							ELSE 0 
						END
					WHEN 'Refunds' THEN
						CASE WHEN	ii.[PurchaseAction] = 'PurchasedThenRemoved' 
									AND ISNULL(CHARINDEX(ii.[Notes], 'EXCHANGED'),-1) = -1 THEN 1 
							ELSE 0 
						END
				END = 1  
	END
	ELSE IF (LEN(RTRIM(LTRIM(@ShowTicketIds))) > 0 AND @ShowTicketIds <> '0') 
	BEGIN

		SET @ShowTicketIds = REPLACE(@ShowTicketIds, '~', ',')

		SELECT	COUNT(ii.[Id])
		FROM	InvoiceItem ii, 
				ShowTicket st, 
				AuthorizeNet auth
		WHERE	st.[Id] IN (SELECT DISTINCT [ListItem] FROM fn_ListToTable(@ShowTicketIds)) 
				AND ii.TShowTicketId = st.[Id] 
				AND ii.[vcContext] = 'Ticket' 
				AND ii.[tInvoiceId] = auth.[tInvoiceId] 
				AND auth.[transactiontype] = 'auth_capture' 
				AND auth.[bAuthorized] = 1 
				AND 
				CASE @ShipContext
					WHEN @willCallText THEN 
						CASE WHEN 
							(ii.[ShippingMethod] IS NULL OR (ii.[ShippingMethod] IS NOT NULL AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) = 0))
							OR
							(ii.[ShippingMethod] IS NOT NULL AND LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) > 0 AND 
							ii.[ShippingMethod] = @willCallText) THEN 1 ELSE 0 END
					WHEN 'Shipped' THEN 
						CASE WHEN ii.[ShippingMethod] IS NOT NULL AND  LEN(LTRIM(RTRIM(ii.[ShippingMethod]))) > 0 AND 
							ii.[ShippingMethod] <> @willCallText THEN 1 ELSE 0 END
					ELSE 1 
				END = 1 
				AND 
				CASE @PurchaseContext
					WHEN 'Purchases' THEN
						CASE WHEN ii.[PurchaseAction] = 'Purchased' THEN 1 ELSE 0 END
					WHEN 'Refunds' THEN
						CASE WHEN ii.[PurchaseAction] = 'PurchasedThenRemoved' AND 
							ISNULL(CHARINDEX(ii.[Notes], 'EXCHANGED'),-1) = -1 THEN 1 ELSE 0 END
				END = 1 
	END

	ELSE SELECT 0

END
GO
