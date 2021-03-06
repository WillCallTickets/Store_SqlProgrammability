USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_StoreCredit_ValidateGiftCertificateRedemption]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz>
-- Create date: 09/05/22>
-- Description:	Determines if the code has been redeemed yet. 
--	If the code is new, it gathers the amount from the original 
--	purchase (checks to see if purchase is still valid - not returned). 
--	Returns the value of the gift certificate if found and 0 if not found 
-- exec [tx_StoreCredit_ValidateGiftCertificateRedemption] '67f3c778-ec5e-4ad4-b7da-af1a3154cf8d'
-- =============================================

CREATE PROCEDURE [dbo].[tx_StoreCredit_ValidateGiftCertificateRedemption](

	@applicationId	UNIQUEIDENTIFIER,
	@code			UNIQUEIDENTIFIER

)
AS 

BEGIN

	DECLARE	@amount	MONEY
	DECLARE @dateOfRedemption DATETIME

	--only examine valid credits
	--credit transactions can be removed and would be 'PurchasedThenRemoved'
	SELECT	@dateOfRedemption = [dtStamp] 
	FROM	[StoreCredit] 
	WHERE	[RedemptionId] = @code 

	IF (@dateOfRedemption IS NOT NULL) 
	BEGIN
		
		SELECT 'This code ' + cast(@code as VARCHAR(50)) + ' was redeemed on ' + CONVERT(VARCHAR, @dateOfRedemption, 101)
		RETURN

	END

	SET		@amount = 0

	SELECT	@amount = CASE WHEN ii.[mLineItemTotal] > 0 THEN ii.[mLineItemTotal] ELSE ii.[iQuantity] * child.[mPrice] END
	FROM	[Invoice] i, 
			[InvoiceItem] ii 
			LEFT OUTER JOIN [Merch] child 
				ON child.[Id] = ii.[tMerchId]
			LEFT OUTER JOIN [Merch] parent 
				ON child.[tParentListing] = parent.[Id]
	WHERE	i.[ApplicationId] = @applicationId 
			AND i.[Id] = ii.[tInvoiceid] 
			AND ii.[Guid] = @code 
			AND ii.[vcContext] = 'merch' 
			AND ii.[PurchaseAction] = 'Purchased'	
			AND ((child.[vcDeliveryType] IS NOT NULL AND child.[vcDeliveryType] = 'giftcertificate') 
				OR parent.[vcDeliveryType] = 'giftcertificate')

	SELECT @amount

END
GO
