USE [Sts9Store]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ListToTable]    Script Date: 10/02/2016 18:15:38 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      CatInHat
-- CreateDate:	?
-- Title:		fn_ListToTable
-- Description: Builds a table and assigns ids to the elements from the given list 
-- =============================================

CREATE	FUNCTION [dbo].[fn_ListToTable]( 
	
	@ListIn VARCHAR(8000) 

)
RETURNS @lstTable TABLE ( 
	
	Id			INT NULL, 
	ListItem	VARCHAR(200) NULL

)
AS

BEGIN

	DECLARE	@List	VARCHAR(8000),
			@count	INT
			
	SET @List = @ListIn
	SET @count = 1

	DECLARE	@iNextToken INT	
	SET @iNextToken = CHARINDEX( ',', @List)

	WHILE @iNextToken > 0 BEGIN
	
		INSERT	@lstTable (Id, ListItem)
		VALUES	(@count, left( @List, @iNextToken - 1))
	
		SET @List = SUBSTRING( @List, @iNextToken + 1, LEN(@List))
		SET @iNextToken = CHARINDEX( ',', @List)
		SET @count = @count + 1
		
	END

	IF @List IS NOT NULL AND @List <> '' 
	BEGIN
	
		INSERT	@lstTable (Id, ListItem)
		VALUES	(@count, @List)
		
	END

	RETURN
END
GO
