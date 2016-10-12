USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Picture_Update]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/11/19
-- Description:	Updates the width and height columns on the given context table row.
-- =============================================

CREATE PROCEDURE [dbo].[tx_Picture_Update](

	@Idx		INT,
	@Context	VARCHAR(256), 
	@Width		INT,
	@Height		INT

)
AS 

BEGIN

	IF (@Context = 'Act') 
	BEGIN
	 
		UPDATE	[Act] 
		SET		[iPicWidth] = @Width, [iPicHeight] = @Height 
		FROM	[Act] a 
		WHERE	a.[Id] = @Idx
	
	END
	ELSE IF (@Context = 'Show') 
	BEGIN
		
		UPDATE	[Show] 
		SET		[iPicWidth] = @Width, [iPicHeight] = @Height 
		FROM	[Show] a 
		WHERE	a.[Id] = @Idx
	
	END
	ELSE IF(@Context = 'Venue') 
	BEGIN
	
		UPDATE	[Venue] 
		SET		[iPicWidth] = @Width, [iPicHeight] = @Height 
		FROM	[Venue] a 
		WHERE	a.[Id] = @Idx
	
	END

END
GO
