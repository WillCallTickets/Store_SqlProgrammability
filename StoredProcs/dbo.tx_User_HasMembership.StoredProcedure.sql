USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_User_HasMembership]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/10/01
-- Description:	Determines if a user is a subscriber only. If a user has a userid but no 
--	membership than return true.
-- =============================================

CREATE	PROC [dbo].[tx_User_HasMembership](

	@applicationId			UNIQUEIDENTIFIER,
	@userName			 	VARCHAR(256)

)
AS

BEGIN
	
	SET NOCOUNT ON
	
	DECLARE	@UserId	UNIQUEIDENTIFIER	

	IF EXISTS (SELECT * FROM Aspnet_Users a WHERE a.[ApplicationId] = @applicationId AND a.[UserName] = @userName)
	BEGIN

		SELECT	@UserId = a.[UserId] 
		FROM	Aspnet_Users a 
		WHERE	a.[ApplicationId] = @applicationId 
				AND a.[UserName] = @userName

		IF EXISTS (SELECT * FROM Aspnet_Membership m WHERE m.[UserId] = @UserId)
		BEGIN
		
			SELECT 'true'
			
		END

	END	ELSE
	BEGIN
	
		SELECT 'nouser'
		
	END

	SELECT 'false'

END
GO
