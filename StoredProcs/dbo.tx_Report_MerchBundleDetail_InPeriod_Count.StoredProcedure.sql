USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Report_MerchBundleDetail_InPeriod_Count]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 11/05/27
-- Description:	Count of MerchBundle rows within criteria
-- =============================================

CREATE PROC [dbo].[tx_Report_MerchBundleDetail_InPeriod_Count](

	@appId			UNIQUEIDENTIFIER,
	@category		VARCHAR(50),
	@activeStatus	VARCHAR(5)
	
)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW 

BEGIN

	SET @activeStatus = LOWER(@activeStatus)
	
	--get a list of bundle items - get the sale figs later
	CREATE TABLE #tmpBundle ( Idx INT )
	
	IF(@category = 'all' OR @category = 'ticket') 
	BEGIN
	
		INSERT	#tmpBundle(Idx)
		SELECT	mb.[Id] AS [Idx] 
		FROM	[MerchBundle] mb 
				LEFT OUTER JOIN [ShowTicket] st 
					ON st.[Id] = mb.[TShowTicketId] 
				LEFT OUTER JOIN [Show] s 
					ON s.[ApplicationId] = @appId AND s.[Id] = st.[TShowId]
		WHERE	mb.[TShowTicketId] IS NOT NULL 
				AND 
				CASE @ActiveStatus
					WHEN 'true' THEN 
						CASE WHEN (mb.[bActive] IS NULL OR (mb.[bActive] IS NOT NULL AND mb.[bActive] = 1)) THEN 1 ELSE 0 END
					WHEN 'false' THEN 
						CASE WHEN (mb.[bActive] IS NOT NULL AND mb.[bActive] = 0) THEN 1 ELSE 0 END
					ELSE 1 
				END = 1
	END
	
	IF(@category = 'all' OR @category = 'merch') 
	BEGIN
	
		INSERT	#tmpBundle(Idx)
		SELECT	mb.[Id] 
		FROM	[MerchBundle] mb 
				LEFT OUTER JOIN [Merch] m 
				ON m.[Id] = mb.[TMerchId] AND m.[ApplicationId] = @appId
		WHERE	mb.[TMerchId] IS NOT NULL 
				AND 
				CASE @ActiveStatus
					WHEN 'true' THEN 
						CASE WHEN (mb.[bActive] IS NULL OR (mb.[bActive] IS NOT NULL AND mb.[bActive] = 1)) THEN 1 ELSE 0 END
					WHEN 'false' THEN 
						CASE WHEN (mb.[bActive] IS NOT NULL AND mb.[bActive] = 0) THEN 1 ELSE 0 END
					ELSE 1 
				END = 1
	END
	
	SELECT	COUNT(tb.[Idx]) 
	FROM	#tmpBundle tb
	
	DROP TABLE #tmpBundle
	
END
GO
