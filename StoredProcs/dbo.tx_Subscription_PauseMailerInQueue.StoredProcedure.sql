USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Subscription_PauseMailerInQueue]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/02/12
-- Description:	Pauses a subscription email in the queue by setting it's remaining attempts to -10000. 
-- =============================================

CREATE	PROC [dbo].[tx_Subscription_PauseMailerInQueue](

	@subscriptionEmailId INT

)
AS

BEGIN

	UPDATE	[MailQueue]	
	SET		[ThreadLock] = NULL,
			[AttemptsRemaining] = -10000
	WHERE	[TSubscriptionEmailId] = @subscriptionEmailId 
			AND ([Status] IS NULL OR [Status] <> 'Sent')

END
GO
