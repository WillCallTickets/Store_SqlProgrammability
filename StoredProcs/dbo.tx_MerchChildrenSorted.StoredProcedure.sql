USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_MerchChildrenSorted]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Returns a table of merch inventory sorted by @sortDirection. @sortDirection specifies 
--	column to sort by. See sample query immediately below.
-- exec tx_MerchChildrenSorted 10003,'Style DESC'
-- exec tx_MerchChildrenSorted 10003,''
-- =============================================

CREATE PROCEDURE [dbo].[tx_MerchChildrenSorted](

	@tParentListing	INT,
	@sortDirection	VARCHAR(256)

)
AS

BEGIN

	SET NOCOUNT ON;

    IF @sortDirection = ''
	BEGIN
	
		SET @sortDirection = 'Style ASC'
		
	END

	EXEC (
		'CREATE TABLE #tmMerch ( idx INT IDENTITY (0, 1) NOT NULL, merchId INT, displayIdx INT ) ' + 
		'INSERT #tmMerch(merchId, displayIdx) ' + 
		'SELECT m.[Id], CASE WHEN ms.[iDisplayOrder] IS NULL THEN -1 ELSE ms.[iDisplayOrder] END ' + 
		'FROM Merch m LEFT OUTER JOIN [MerchSize] ms ON m.[Size] = ms.[Code] WHERE ([tParentListing] = ' + @tParentListing + ' ) ' + 
		'ORDER BY ' + @sortDirection + ', m.[Color], ms.[iDisplayOrder] ' + 

		'SELECT m.* FROM [Merch] m, #tmMerch t WHERE m.[Id] = t.[merchId] ORDER BY t.[idx] '	+ 
		'DROP TABLE #tmMerch '	
	)

END
GO
