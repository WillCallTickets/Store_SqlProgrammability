USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Subscription_GetSubsForUser]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 09/01/25
-- Description:	Gets the allowed (by Aspnet_Roles) SUbscriptions for the given username and appId.
--	Also returns subscriptions that they may be subscribed to and not necessarily allowed 
-- =============================================

CREATE	PROC [dbo].[tx_Subscription_GetSubsForUser](

	@appId		UNIQUEIDENTIFIER,
	@userName	VARCHAR(256)

)
AS

BEGIN
	
	SET NOCOUNT ON

	DECLARE	@userid UNIQUEIDENTIFIER
	SET		@userId = null

	SELECT	@userid = u.[UserId] 
	FROM	[Aspnet_Users] u 
	WHERE	u.[UserName] = @username 
			AND u.[ApplicationId] = @appId

	SELECT	sub.*
	FROM	[Subscription] sub, [Aspnet_UsersInRoles] uir 
	WHERE	sub.[bActive] = 1 
			AND uir.[UserId] = @userId 
			AND uir.[RoleId] = sub.[RoleId]
	
	UNION	--!!!!!!UNION RETURNS DISTINCT
	
	SELECT	sub.*
	FROM	[Subscription] sub, [SubscriptionUser] su
	WHERE	sub.[bActive] = 1 
			AND su.[UserId] = @userId 
			AND su.[TSubscriptionId] = sub.[Id]

END
GO
