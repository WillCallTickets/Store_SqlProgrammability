USE [Sts9Store]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_InvoicesWithSpecifiedMerch]    Script Date: 10/02/2016 18:15:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Rob Kurtz>
-- Title:		[fn_InvoicesWithSpecifiedMerch]
-- Create date: <13/09/25>
-- Description:	Gets the invoiceIds of orders containing the spcified item. 
--	Exclusive will indicate if that is the only item in the order. Also 
--	returns the quantity of the item in question. 
/*
SELECT * FROM dbo.fn_InvoicesWithSpecifiedMerch('83C1C3F6-C539-41D7-815D-143FBD40E41F', 11599, 1, 1,
				'1/1/2005 12 AM', getDate())
SELECT * FROM dbo.fn_InvoicesWithSpecifiedMerch('83C1C3F6-C539-41D7-815D-143FBD40E41F', 11598, 1, 1,
				'1/1/2005 12 AM', getDate())
SELECT * FROM dbo.fn_InvoicesWithSpecifiedMerch('83C1C3F6-C539-41D7-815D-143FBD40E41F', 11599, 0, 1,
				'1/1/2005 12 AM', getDate())
SELECT * FROM dbo.fn_InvoicesWithSpecifiedMerch('83C1C3F6-C539-41D7-815D-143FBD40E41F', 11598, 0, 1,
				'1/1/2005 12 AM', getDate())				
				
*/
-- =============================================

CREATE	FUNCTION [dbo].[fn_InvoicesWithSpecifiedMerch]( 
	
	@applicationId	UNIQUEIDENTIFIER, 
	@merchId		INT, 
	@exclusive		BIT, 
	@minQty			INT, 
	@dtStart		DATETIME, 
	@dtEnd			DATETIME

)
RETURNS @idxs TABLE ( 

	idx				INT NOT NULL, 
	qty				INT NOT NULL, 
	purchaseEmail	VARCHAR(256) NOT NULL 

)
AS 

BEGIN

	/* list of merch ids to include in the search*/
	DECLARE @tmpMerchIds TABLE ( merchId int)	
	/* list of ii ids that contain the merchIds*/
	DECLARE @tmpInvoiceItemIds TABLE ( invoiceId int, invoiceItemId	int, qty int )	
	/* list of invoice ids that contain the merchIds*/
	DECLARE @tmpOtherIds TABLE ( invoiceId int, otherMerchId int )	
	/* counts match line item counts - not qty*/
	DECLARE @tmpInvoiceIds TABLE ( invoiceId int, qty int, countMatching int, countOther int)		
	
	/* initially, only add merch children - if there is a match, none will be added in the next query*/
	INSERT	@tmpMerchIds (merchId)
	SELECT	DISTINCT m.[Id] FROM [Merch] m WHERE m.[Id] = @merchId AND m.[tParentListing] IS NOT NULL

	/* Add any inventory items - if a child items was specified, it will have no children*/
	INSERT	@tmpMerchIds (merchId)
	SELECT	DISTINCT m.[Id] FROM [Merch] m WHERE m.[tParentListing] = @merchId

	/* get all invoices that contain the items in question, than we can examine those 
		invoices to see if they have other items */
	INSERT	@tmpInvoiceItemIds (invoiceId, invoiceItemId, qty)
	SELECT	ii.[tInvoiceId], ii.[Id], ii.[iQuantity] 
	FROM	[InvoiceItem] ii 
		LEFT OUTER JOIN [Invoice] i 
			ON	i.[Id] = ii.[tInvoiceId] 
				AND i.[ApplicationId] = @applicationId
	WHERE	ii.[PurchaseAction] = 'Purchased' 
			AND ii.[tMerchId] IS NOT NULL
			AND ii.[tMerchId] IN 
				(SELECT mid.[merchId] FROM @tmpMerchIds mid)
			AND ii.[iQuantity] >= @minQty
			AND i.[dtInvoiceDate] BETWEEN @dtStart AND @dtEnd
			AND i.[InvoiceStatus] <> 'NotPaid' 
			
	/* establish matching count */
	INSERT	@tmpInvoiceIds (invoiceId, qty, countMatching, countOther)
	SELECT	ii.[invoiceId], SUM(ii.[qty]), COUNT(*), 0 FROM @tmpInvoiceItemIds ii
	GROUP BY ii.[invoiceId]
	HAVING COUNT(*) > 0


	/*update the other counts here only if we need an exclusive search*/
	IF (@exclusive = 1) 
	BEGIN
	
		/*establish other count - **cannot do an update with a group by, hence the extra step*/		
		INSERT	@tmpOtherIds (invoiceId, otherMerchId)
		SELECT	ii.[tInvoiceId], COUNT(ii.[tMerchId])
		FROM	@tmpInvoiceIds i 
			LEFT OUTER JOIN [InvoiceItem] ii 
				ON ii.[tInvoiceId] = i.[invoiceId]
		WHERE	ii.[tMerchId] IS NOT NULL
				AND ii.[tMerchId] NOT IN 
					(SELECT [merchId] FROM @tmpMerchIds)
				AND ii.[PurchaseAction] = 'Purchased'
		GROUP BY ii.[tInvoiceId]
		
		/*insert other counts into master table*/
		UPDATE	@tmpInvoiceIds
		SET		countOther = o.[otherMerchId]
		FROM	@tmpInvoiceIds i, @tmpOtherIds o
		WHERE	i.[invoiceId] = o.[invoiceId]
		
	END

	/*determine our desired list of invoice Ids*/
	INSERT @idxs(idx, qty, purchaseEmail)
	SELECT ti.[invoiceId] as [idx], ti.[qty] as [qty], i.[PurchaseEmail] as [purchaseEmail]
	FROM	@tmpInvoiceIds ti 
		LEFT OUTER JOIN [Invoice] i 
			ON i.[Id] = ti.[invoiceId] 
	WHERE ti.[countOther] = 0

	RETURN	
	
END
GO
