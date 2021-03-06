USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetBillShipsOfMerchItemCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 13/09/25
-- Description:	Gets the Count of matching invoices. 
/*

these should be the same as there is only one inventory item
exec [tx_GetBillShipsOfMerchItemCount] '83C1C3F6-C539-41D7-815D-143FBD40E41F', 11598, 1, 1,
	'1/1/2008', '10/1/2013 12AM'
*/
-- =============================================

CREATE	PROC [dbo].[tx_GetBillShipsOfMerchItemCount](

	@applicationId	UNIQUEIDENTIFIER,
	@merchId		INT,
	@exclusive		BIT,
	@minQty			INT,
	@dtStart		DATETIME,
	@dtEnd			DATETIME

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	SELECT COUNT(*)
	FROM   dbo.fn_InvoicesWithSpecifiedMerch
			(@applicationId, @merchId, @exclusive, @minQty, @dtStart, @dtEnd) 
						
END
GO
