USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetTicketCountsCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	The count of rows in the simple report for current ticket inventory and recent sales. 
-- =============================================

CREATE	PROC [dbo].[tx_GetTicketCountsCount](

	@applicationId	UNIQUEIDENTIFIER,
	@StartDate		VARCHAR(50),
	@EndDate		VARCHAR(50)

)
AS

SET NOCOUNT ON

SET DEADLOCK_PRIORITY LOW

BEGIN

	SELECT	COUNT(DISTINCT(sd.[Id]))
	FROM	[ShowDate] sd, [Show] s
	WHERE	s.[ApplicationId] = @applicationId 
			AND s.[Id] = sd.[tShowId] 
			AND sd.[bActive] = 1 
			AND sd.[dtDateOfShow] BETWEEN  @StartDate AND @EndDate
END
GO
