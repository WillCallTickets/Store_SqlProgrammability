USE [Sts9Store]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetDeliveryCode]    Script Date: 10/02/2016 18:15:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: ?
-- Title:		fn_GetDeliveryCode
-- Description:	takes in a piece of text, usually the criteria column from an invoiceitem and
--	returns null if no reference to 'GiftCode', etc. otherwise it strips out and returns the code portion only
-- =============================================
 
CREATE FUNCTION [dbo].[fn_GetDeliveryCode] (

	@criteria VARCHAR(2500)

) 
RETURNS VARCHAR(50)
AS
 
BEGIN
	
	DECLARE @result		VARCHAR(50)
	SET		@result		= NULL;

	IF (@criteria IS NULL)
	
		RETURN NULL
	
	ELSE BEGIN 
	
		DECLARE @codeName	VARCHAR(50)
		SET		@codeName = NULL;
		
		SELECT	@codeName = 
			CASE	WHEN CHARINDEX('DownloadCode=', @criteria) > 0	THEN 'DownloadCode=' 
					WHEN CHARINDEX('GiftCode=', @criteria) > 0		THEN 'GiftCode=' 
					ELSE NULL 
			END
		
		-- return if nothing in input
		IF (@codeName IS NULL)
	
			RETURN NULL
	
		ELSE BEGIN 

			-- this does a replace on the DownloadCode= and removes it from the string
			-- TODO refactor for efficiency
			SELECT	@result = 
				REPLACE(      
					SUBSTRING(
						@criteria, 
						CHARINDEX(@codeName, @criteria),
						CASE 
							WHEN CHARINDEX('&', @criteria, CHARINDEX(@codeName, @criteria)) > 0
								THEN (CHARINDEX('&', @criteria, CHARINDEX(@codeName, @criteria)) - CHARINDEX(@codeName, @criteria)) 
							ELSE LEN(@criteria) 
						END
					), 
					@codeName, 
					''
				)			
		
		END
		
	END
	
	RETURN @result
 
END
GO
