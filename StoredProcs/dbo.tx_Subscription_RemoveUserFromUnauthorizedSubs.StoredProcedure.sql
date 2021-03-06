USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Subscription_RemoveUserFromUnauthorizedSubs]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 09/01/25
-- Description:	Gets the allowed (by Aspnet_Roles) SUbscriptions for the given username and appId.
--	Also returns subscriptions that they may be subscribed to and not necessarily allowed
/*
declare @username VARCHAR(256)
set @username = 'rob@kurtz.net'
declare @userid UNIQUEIDENTIFIER
select @userid = userid from aspnet_users where username = @username
select * from aspnet_users where username = @username
select * from subscriptionuser where userid = @userid
select * from subscription

--trying to return 22901
declare @appId UNIQUEIDENTIFIER
declare @username VARCHAR(256)
SET		@username = 'rob@kurtz.net'
SET		@appId = '83C1C3F6-C539-41D7-815D-143FBD40E41F'
*/
-- =============================================

CREATE	PROC [dbo].[tx_Subscription_RemoveUserFromUnauthorizedSubs](

	@appId		UNIQUEIDENTIFIER,
	@userName	VARCHAR(256)

)
AS

BEGIN
	
	SET NOCOUNT ON

	DECLARE	@userid UNIQUEIDENTIFIER
	SET		@userId = NULL

	SELECT	@userid = u.[UserId] 
	FROM	[Aspnet_Users] u 
	WHERE	u.[UserName] = @username 
			AND u.[ApplicationId] = @appId
	
	SELECT	su.[Id] AS 'Idx', s.[Id] AS 'SubId'
	INTO	#tmpIds
	FROM	[SubscriptionUser] su, [Subscription] s
	WHERE	su.[UserId] = @userId 
			AND su.[TSubscriptionId] = s.[Id] 
			AND s.[RoleId] NOT IN (
				SELECT uir.[RoleId] 
				FROM [Aspnet_UsersInRoles] uir 
				WHERE [UserId] = @userId)

	DELETE	FROM [SubscriptionUser] 
	WHERE	[Id] IN (
				SELECT [Idx] 
				FROM #tmpIds)

	SELECT	* 
	FROM	[Subscription] 
	WHERE	[Id] IN (
				SELECT [SubId] 
				FROM #tmpIds)

END
GO
