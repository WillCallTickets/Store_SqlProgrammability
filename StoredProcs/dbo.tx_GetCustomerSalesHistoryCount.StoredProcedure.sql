USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetCustomerSalesHistoryCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05 
-- Description:	Retrieves the count of customer's invoices. 
/*
	exec [tx_GetCustomerSalesHistoryCount] 'WILLCALL', 'rob@kurtz.net'
*/
-- =============================================

CREATE	PROC [dbo].[tx_GetCustomerSalesHistoryCount](

	@ApplicationName	VARCHAR(256),
	@UserName 			VARCHAR(256)

)
AS

BEGIN

	DECLARE @UserId			UNIQUEIDENTIFIER
    DECLARE @ApplicationId	UNIQUEIDENTIFIER
    SELECT  @ApplicationId	= NULL
    
    SELECT  @ApplicationId = ApplicationId 
    FROM	dbo.aspnet_Applications     
	WHERE	LOWER(@ApplicationName) = LoweredApplicationName
	
    IF (@ApplicationId IS NULL)
        RETURN 0

	SELECT	@UserId = u.UserId
    FROM	dbo.aspnet_Users u
    WHERE	u.ApplicationId = @ApplicationId 
			AND u.UserName = LOWER(@UserName)

	SELECT	Count(DISTINCT(i.[Id]))
	FROM	Invoice i
	WHERE	i.[UserId] = @UserId 
			AND i.[InvoiceStatus] <> 'NotPaid'

END
GO
