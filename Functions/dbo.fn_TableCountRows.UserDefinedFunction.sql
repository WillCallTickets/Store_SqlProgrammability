USE [Sts9Store]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TableCountRows]    Script Date: 10/02/2016 18:15:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Author:      
-- CreateDate:	?
-- Title:		[fn_TableCountRows]
-- Description: Returns a count of rows in the table
-- =============================================


CREATE FUNCTION [dbo].[fn_TableCountRows] (
	
	@tableName VARCHAR(200)
	
) 
RETURNS INT
AS

BEGIN

	DECLARE	@rows INT
	
	SELECT	@rows = i.Rows
	FROM 	sysobjects s, sysindexes i
	WHERE	s.name = @tableName 
			AND s.Id = i.Id 
			AND indid < 2

	RETURN	@rows
	
END
GO
