USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetShipmentsInRangeCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 09/11/12
-- Description:	Gets the count of InvoiceShipments that are within context (all,tickets,merch) and within the date range specifed. 
-- Returns Int
-- =============================================

CREATE	PROC [dbo].[tx_GetShipmentsInRangeCount]

	@applicationId	UNIQUEIDENTIFIER,
	@Context		VARCHAR(256),--all,merch,ticket
	@StartDate		VARCHAR(50),
	@EndDate		VARCHAR(50)

AS

SET DEADLOCK_PRIORITY LOW

SET NOCOUNT ON

BEGIN

	SELECT	COUNT( DISTINCT (invs.[Id]) ) 
	FROM	[InvoiceShipment] invs, [Invoice] i
	WHERE	i.[ApplicationId] = @applicationId 
			AND i.[InvoiceStatus] <> 'NotPaid' 
			AND i.[Id] = invs.[tInvoiceId] 
			AND 
			CASE @Context
				WHEN 'merch' THEN 
					CASE WHEN invs.[vcContext] IS NOT NULL AND invs.[vcContext] = 'merch' THEN 1 
						ELSE 0 
					END 
				WHEN 'ticket' THEN
					CASE WHEN invs.[vcContext] IS NOT NULL AND invs.[vcContext] = 'ticket' THEN 1 
						ELSE 0 
					END 
				ELSE 1
			END = 1 
			AND invs.[dtCreated] BETWEEN  @StartDate AND @EndDate
END
GO
