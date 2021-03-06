USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Subscription_RestartMailerInQueue]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/02/12
-- Description:	Restarts a subscription email in the queue by setting it's remaining attempts back to 3.
-- =============================================

CREATE	PROC [dbo].[tx_Subscription_RestartMailerInQueue](

	@subscriptionEmailId INT

)
AS

BEGIN

	UPDATE	[MailQueue]	
	SET		[AttemptsRemaining] = 3
	WHERE	[TSubscriptionEmailId] = @subscriptionEmailId 
			AND [AttemptsRemaining] = -10000

END
GO
