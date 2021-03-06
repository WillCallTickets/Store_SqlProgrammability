USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_CustomerSearch_ByProfileParam]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 11/08/11 
-- Description:	Finds UserNames and Name from aspnet_Users where
--	we can find a match in the profile of the user
/*
	exec tx_CustomerSearch_InvoiceNumber 'WillCall', '8'
	select uniqueid from invoice
*/
-- =============================================

CREATE PROCEDURE [dbo].[tx_CustomerSearch_ByProfileParam](

	@applicationName	VARCHAR(256),
	@ParamName			VARCHAR(256),
	@ParamValue			VARCHAR(256)

)
AS

BEGIN
	
	SET NOCOUNT ON

	DECLARE @ApplicationId UNIQUEIDENTIFIER
	
    SELECT  @ApplicationId = NULL
    
    SELECT  @ApplicationId = ApplicationId 
    FROM	dbo.aspnet_Applications 
	WHERE	LOWER(@applicationName) = LoweredApplicationName
    
	IF (@ApplicationId IS NULL) 
	BEGIN
	
		SELECT '' AS 'UserName', '' AS 'Name'
		RETURN
		
	END
        
	SELECT u.UserName,
			LTRIM(ISNULL(dbo.fn_GetProfileValue(u.userId, 'FirstName'), '') + ' ' + ISNULL(dbo.fn_GetProfileValue(u.userId, 'LastName'), '')) as 'Name' 
	FROM   dbo.aspnet_Users u
	WHERE  u.ApplicationId = @ApplicationId AND u.[UserName] NOT LIKE '%terminal%' 
		AND dbo.fn_getprofilevalue(u.userid, @ParamName) = @ParamValue
	ORDER BY u.UserName
	

END
GO
