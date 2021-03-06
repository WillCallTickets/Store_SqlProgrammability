USE [Sts9Store]
GO
/****** Object:  UserDefinedFunction [dbo].[SPLIT]    Script Date: 10/02/2016 18:15:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Md. Marufuzzaman
-- Create date: 
-- Description: Split an expression. 
-- Note: If you are using SQL Server 2000, You need to change the 
-- length (MAX) to your maximum expression length of each datatype.
-- http://www.codeproject.com/Articles/38843/An-Easy-But-Effective-Way-to-Split-a-String-using
/*
	SELECT * FROM [dbo].[SPLIT] (';','I love codeProject;!!!;Your development resources')
*/
-- =============================================

CREATE FUNCTION [dbo].[SPLIT] (  

	@DELIMITER VARCHAR(5), 
    @LIST      VARCHAR(MAX) 
   
) 
RETURNS @TABLEOFVALUES TABLE (  
	
	ROWID   SMALLINT IDENTITY(1,1), 
    [VALUE] VARCHAR(MAX) 
    
) 
AS 

BEGIN

	DECLARE @LENSTRING INT 

	WHILE LEN( @LIST ) > 0 
	BEGIN 
 
		SELECT @LENSTRING = 
		(
			CASE CHARINDEX( @DELIMITER, @LIST ) 
				WHEN 0 THEN LEN( @LIST ) 
				ELSE ( CHARINDEX( @DELIMITER, @LIST ) -1 )
			END
       ) 
                        
		INSERT INTO @TABLEOFVALUES 
		SELECT SUBSTRING( @LIST, 1, @LENSTRING )
        
		SELECT @LIST = 
		   (CASE ( LEN( @LIST ) - @LENSTRING ) 
			   WHEN 0 THEN '' 
			   ELSE RIGHT( @LIST, LEN( @LIST ) - @LENSTRING - 1 ) 
			END
		   ) 
	END
  
	RETURN 
  
END
GO
