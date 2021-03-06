USE [Sts9Store]
GO
/****** Object:  UserDefinedFunction [dbo].[RemoveNonAlphaCharacters]    Script Date: 10/02/2016 18:15:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      
-- CreateDate:	?
-- Title:		RemoveNonAlphaCharacters
-- Description: removes chars from a string based on a regex pattern
--	note that this is th same functionality as fn_StripCharacters
--	but has been customized to strip out non-alpha chars specifically
-- =============================================

CREATE	FUNCTION [dbo].[RemoveNonAlphaCharacters](
	
	@Temp VARCHAR(2000)
	
)
RETURNS VARCHAR(2000)
AS

BEGIN

    DECLARE	@KeepValues VARCHAR(50)
    SET		@KeepValues = '%[^a-z]%'
    
    WHILE	PATINDEX(@KeepValues, @Temp) > 0
        SET @Temp = STUFF(@Temp, PATINDEX(@KeepValues, @Temp), 1, '')

    RETURN	@Temp
    
END
GO
