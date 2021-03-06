USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_CustomerSearch_InvoiceNumber]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Finds UserNames from aspnet_Users that match the UserId of an invoice that (like) matches 
--	the invoiceNumber provided - UniqueId 
/* 
	exec tx_CustomerSearch_InvoiceNumber 'WillCall', '8'
	select uniqueid from invoice
*/
-- =============================================

CREATE PROCEDURE [dbo].[tx_CustomerSearch_InvoiceNumber](

	@applicationName	VARCHAR(256),
	@invoiceNumber		VARCHAR(256)

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

	SELECT	DISTINCT m.[LoweredEmail] AS 'UserName', 
			LTRIM(ISNULL(dbo.fn_GetProfileValue(m.userId, 'FirstName'), '') + ' ' + ISNULL(dbo.fn_GetProfileValue(m.userId, 'LastName'), '')) as 'Name' 
	FROM	[Invoice] i, [aspnet_Membership] m
	WHERE	i.[UniqueId] LIKE (@invoiceNumber + '%') 
			AND i.[UserId] = m.[UserId] 
			AND m.[Email] NOT LIKE '%terminal%' 
			AND m.[ApplicationId] = @applicationId
	ORDER BY m.[LoweredEmail]

END
GO
