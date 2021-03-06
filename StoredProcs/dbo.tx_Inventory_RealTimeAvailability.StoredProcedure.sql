USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Inventory_RealTimeAvailability]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: Mar 13 2010
-- Description:	This method checks the showticket's availability in real time.
--				The first value returned is the available according to the showticket and ticketstock 
--					allotment - pendings(from ticketstock table) - sold
--				The secondvalue, if polled for, returns the actual sold from the invoiceitem table
/*
exec [tx_ShowTicket_RealTimeAvailability] 12704, 1 

select iallotment, ipending, isold from showticket where id = 12704
exec [tx_ShowTicket_RealTimeAvailability] 12704, 0

select iallotment, ipending, isold from showticket where id = 12632
exec [tx_ShowTicket_RealTimeAvailability] 12632, 0

select sum(iqty) from ticketstock where tshowticketid = 12704
select sum(iquantity) from invoiceitem where tshowticketid = 12704
*/
-- =============================================

CREATE   PROC [dbo].[tx_Inventory_RealTimeAvailability](

	@idx		INT,
	@context	VARCHAR(50)	--merch or ticket

)
AS

BEGIN

	DECLARE	@retVal	INT
	SET		@retVal	= 0

	IF(@context = 'ticket') 
	BEGIN
	
		SELECT	@retVal = (ent.[iAllotment] - ISNULL(stock.[iQty], 0) - ent.[iSold])
		FROM	[ShowTicket] ent 
				LEFT OUTER JOIN fn_PendingStock('ticket') stock 
					ON stock.[idx] = ent.[Id]
		WHERE	ent.[Id] = @idx 

	END --tickets

	ELSE IF (@context = 'merch') 
	BEGIN 

		SELECT	@retVal = (ent.[iAllotment] - ent.[iSold])
		FROM	[Merch] ent 
		WHERE	ent.[Id] = @idx 

	END


	RETURN @retVal

END
GO
