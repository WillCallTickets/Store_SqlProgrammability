USE [Sts9Store]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ProfilePropertyValues]    Script Date: 10/02/2016 18:15:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Rob Kurtz
-- CreateDate:	?
-- Title:		fn_ProfilePropertyValues
-- Description: Returns the profile values for a user as a table
-- =============================================

CREATE	FUNCTION [dbo].[fn_ProfilePropertyValues]( 

	@UserId UNIQUEIDENTIFIER 

)
RETURNS @propTable TABLE ( 

	Id			INT NOT NULL, 
	PropName	VARCHAR(256), 
	PropType	VARCHAR(10), 
	PropValue	VARCHAR(2000) 

)
AS

BEGIN

	DECLARE	@List VARCHAR(8000), @rowCount INT, @iNextToken INT,
			@iPropName INT, @iPropType INT, @iStart INT, @iEnd INT

	SELECT	@List = propertynames 
	FROM	aspnet_profile 
	WHERE	userid = @UserId
	
	SET		@rowCount = 1
	SET		@iNextToken = CHARINDEX( ':', @List)

	WHILE	@iNextToken > 0 
	BEGIN

		SET		@iPropName = @iNextToken
		SET		@iPropType = CHARINDEX(':',@List, @iPropName+1)
		SET		@iStart = CHARINDEX(':',@List, @iPropType+1)
		SET		@iEnd = CHARINDEX(':',@List, @iStart+1)

		INSERT	@propTable ( [Id],[PropName],[PropType],[PropValue] )
		SELECT	@rowCount, 
				LEFT( @List, @iPropName-1 ), 
				SUBSTRING( @List, @iPropName + 1, @iPropType - @iPropName -1 ),
				SUBSTRING( 
					ap.[PropertyValuesString], 
					CAST( SUBSTRING( @List, @iPropType + 1, @iStart - @iPropType -1 )+1 AS INT), 
					CAST( SUBSTRING( @List, @iStart + 1, @iEnd - @iStart -1 ) AS INT ) 
				)
		FROM	Aspnet_Profile ap
		WHERE	ap.UserId = @userId

		SET		@List = SUBSTRING( @List, @iEnd + 1, LEN(@List))
		SET		@iNextToken = CHARINDEX( ':', @List)
		SET		@rowCount = @rowCount + 1		

	END

	RETURN

END
GO
