USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetSaleShowDateInventory]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/10/24
-- Description:	Gets all future shows. Client decides to display based on announceDate. 
/*
Time must be in format of yyyy/MM/dd
exec [tx_GetSaleShowDateInventory] '83C1C3F6-C539-41D7-815D-143FBD40E41F', '2010/04/01'--sts9
exec [tx_GetSaleShowDateInventory] 'AC36EB0B-152E-4B69-8B39-BB4B6C9B01E6', '2008/10/23', '2008/12/12'--fox
*/
-- =============================================

CREATE	PROC [dbo].[tx_GetSaleShowDateInventory](

	@applicationId	UNIQUEIDENTIFIER,
	@nowName		VARCHAR(50)

)
AS

SET NOCOUNT ON

BEGIN


	SELECT	TOP 100 PERCENT 
			sd.[Id], 
			SUM(ISNULL(tix.[iAvailable] ,0))
	FROM	[Show] s, 
			[ShowDate] sd 
			LEFT OUTER JOIN 
				(
					SELECT	[tShowDateId], CASE WHEN [bActive] = 0 THEN 0 ELSE st.[iAvailable] END as iAvailable 
					FROM	[ShowTicket] st
				) tix 
				ON sd.[Id] = tix.[tShowDateId]
	WHERE	s.[ApplicationId] = @applicationId 
			AND s.[Id] = sd.[tShowId] 
			AND sd.[dtDateOfShow] >= @nowName 
	GROUP BY sd.[Id]
	
END
GO
