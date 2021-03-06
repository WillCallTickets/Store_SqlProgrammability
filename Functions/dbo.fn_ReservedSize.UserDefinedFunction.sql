USE [Sts9Store]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ReservedSize]    Script Date: 10/02/2016 18:15:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Author:      ?
-- CreateDate:	?
-- Title:		fn_ReservedSize
-- Description: Returns KB size of table specified
--	not sure where I found it
-- =============================================

CREATE FUNCTION [dbo].[fn_ReservedSize] (
	
	@tableName VARCHAR(200)
	
)
RETURNS INT
AS

BEGIN

	DECLARE	@id INT
	DECLARE @type CHAR(2)
	DECLARE	@size VARCHAR(30)

	SELECT	@Id = id, @type = RTRIM(xtype)
	FROM	sysobjects
	WHERE	id = OBJECT_ID(@tableName)

	IF @type <> 'U'
	BEGIN
	
		RETURN (0)
		
	END

	SELECT	@size = CAST(LTRIM(STR(reserved * d.low / 1024.,15,0)) AS INT)
	FROM	sysindexes s, master.dbo.spt_values d
	WHERE	indid IN (0, 1, 255)
			AND id = @Id 
			AND d.type = 'e' 
			AND d.number = 1

	RETURN (@size)

END
GO
