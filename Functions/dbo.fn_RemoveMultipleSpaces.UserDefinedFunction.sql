USE [Sts9Store]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_RemoveMultipleSpaces]    Script Date: 10/02/2016 18:15:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Amit Singh
-- http://codejotter.wordpress.com/2010/03/12/sql-function-to-remove-extra-multiple-spaces-from-string/
-- Title:		fn_RemoveMultipleSpaces
-- Description: Remove extra spaces from string
-- Usage:       SELECT dbo.RemoveSpaces('Code  Jotter')
-- =============================================


-- TODO: refactor for efficiency?
CREATE FUNCTION [dbo].[fn_RemoveMultipleSpaces](

    @str AS VARCHAR(MAX)
    
)
RETURNS VARCHAR(MAX)
AS

BEGIN

    RETURN
        REPLACE(REPLACE(REPLACE(@str,' ','{}'),'}{',''),'{}',' ')
        
END
GO
