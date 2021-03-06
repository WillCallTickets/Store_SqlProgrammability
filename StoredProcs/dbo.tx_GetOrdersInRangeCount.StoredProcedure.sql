USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetOrdersInRangeCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Gets the count of purchases that are within context (all,tickets,merch) and within the date range specifed.
-- =============================================

CREATE PROCEDURE [dbo].[tx_GetOrdersInRangeCount](

	@applicationId	UNIQUEIDENTIFIER,
	@Context		VARCHAR(256),
	@StartDate		VARCHAR(50),
	@EndDate		VARCHAR(50)
	
)
AS

SET DEADLOCK_PRIORITY LOW

BEGIN

	SET NOCOUNT ON

	--Note that invoice can be listed in both categories - depends on items in invoice
	IF @Context = 'ticket'	
	BEGIN
	
		SELECT	COUNT(DISTINCT (i.[Id]) )
		FROM	Invoice i, Authorizenet a
		WHERE	i.[ApplicationId] = @applicationId 
				AND i.[InvoiceStatus] IS NOT NULL 
				AND i.[InvoiceStatus] <> 'NotPaid' 
				AND i.[UniqueId] = a.[InvoiceNumber] 
				AND a.[TransactionType] = 'auth_capture' 
				AND a.[bAuthorized] = 1 
				AND (CHARINDEX('c,',ISNULL(i.[vcProducts],'')) > 0 OR CHARINDEX('t,',ISNULL(i.[vcProducts],'')) > 0) 
				AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate 
		RETURN
		
	END
	
	ELSE IF @Context = 'merch'	
	BEGIN
	
		SELECT	COUNT(DISTINCT (i.[Id]) )
		FROM	Invoice i, Authorizenet a
		WHERE	i.[ApplicationId] = @applicationId 
				AND i.[InvoiceStatus] IS NOT NULL 
				AND i.[InvoiceStatus] <> 'NotPaid' 
				AND i.[UniqueId] = a.[InvoiceNumber] 
				AND a.[TransactionType] = 'auth_capture' 
				AND a.[bAuthorized] = 1 
				AND (CHARINDEX('m,',ISNULL(i.[vcProducts],'')) > 0 OR CHARINDEX('g,',ISNULL(i.[vcProducts],'')) > 0) 
				AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate 
		RETURN
		
	END
	ELSE
	
		SELECT	COUNT(DISTINCT (i.[Id]) ) 
		FROM	Invoice i, Authorizenet a 
		WHERE	i.[ApplicationId] = @applicationId 
				AND i.[InvoiceStatus] IS NOT NULL 
				AND i.[InvoiceStatus] <> 'NotPaid' 
				AND i.[UniqueId] = a.[InvoiceNumber] 
				AND a.[TransactionType] = 'auth_capture' 
				AND a.[bAuthorized] = 1 
				AND ((CHARINDEX('c,',ISNULL(i.[vcProducts],'')) > 0) OR (CHARINDEX('t,',ISNULL(i.[vcProducts],'')) > 0) OR
					(CHARINDEX('m,',ISNULL(i.[vcProducts],'')) > 0) OR (CHARINDEX('g,',ISNULL(i.[vcProducts],'')) > 0)) 
				AND i.[dtInvoiceDate] BETWEEN @StartDate AND @EndDate 
END
GO
