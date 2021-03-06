USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetInventoryTickets_DiscrepanciesCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05 
-- Description:	Gets the count of tickets in the selected range.
-- =============================================

CREATE    PROC [dbo].[tx_GetInventoryTickets_DiscrepanciesCount](

	@applicationId	UNIQUEIDENTIFIER,
	@StartDate		DATETIME,
	@EndDate		DATETIME

)
AS

SET DEADLOCK_PRIORITY LOW

BEGIN

	SET NOCOUNT ON;

	SELECT	COUNT(DISTINCT(st.[Id]))
	FROM	ShowTicket st, Show s
	WHERE	st.[dtDateOfShow] BETWEEN @StartDate AND @EndDate 
			AND st.[tShowId] = s.[Id] 
			AND s.[ApplicationId] = @applicationId

END
GO
