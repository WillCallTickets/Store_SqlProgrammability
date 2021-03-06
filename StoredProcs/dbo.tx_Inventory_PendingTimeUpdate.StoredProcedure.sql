USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Inventory_PendingTimeUpdate]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/11/05
-- Description:	 Updates the time to live for the @guid row. As of 
-- right now (081105), I believe that the @guid is the only identifier 
-- necessary.
-- =============================================

CREATE PROC [dbo].[tx_Inventory_PendingTimeUpdate](
	
	@guid		UNIQUEIDENTIFIER,
	@context	VARCHAR(256),
	@newTime	DATETIME

)
AS

BEGIN

	IF(@context IS NOT NULL AND @context = 'ticket')	
	BEGIN

		UPDATE	TicketStock
		SET		dtTTL = @newTime
		WHERE	[GUID] = @guid

	END 
	ELSE IF (@context = 'merch') BEGIN

		UPDATE	MerchStock
		SET		dtTTL = @newTime
		WHERE	[GUID] = @guid

	END

	SELECT @@ROWCOUNT

END
GO
