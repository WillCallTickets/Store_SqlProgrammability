USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetShipmentsInRange]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 09/11/12
-- Description:	Gets InvoiceShipments that are within context (all,tickets,merch) and within the date range specifed. 
-- Returns Wcss.InvoiceShipment Collection
-- =============================================

CREATE	PROC [dbo].[tx_GetShipmentsInRange](

	@applicationId	UNIQUEIDENTIFIER,
	@Context		VARCHAR(256),		--all,merch,ticket
	@StartDate		VARCHAR(50),
	@EndDate		VARCHAR(50),
	@StartRowIndex  INT,
	@PageSize       INT

)
AS

SET DEADLOCK_PRIORITY LOW

SET NOCOUNT ON

BEGIN

	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForShipments(
		IndexId				INT IDENTITY (1, 1) NOT NULL,
        InvoiceShipmentId	INT
    )

	INSERT INTO #PageIndexForShipments (InvoiceShipmentId)
	SELECT InvoiceShipmentId FROM
	(	
		SELECT	Distinct(invs.[Id]) AS InvoiceShipmentId,
				ROW_NUMBER() OVER (ORDER BY invs.[dtCreated] DESC) AS RowNum
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
	) InvoiceShipments
	WHERE	InvoiceShipments.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)

	--As we are converting the results to an InvoiceShipment Collection - select all cols
	SELECT	invs.*
	FROM	[InvoiceShipment] invs, [#PageIndexForShipments] p
    WHERE	invs.[Id] = p.[InvoiceShipmentId]
	ORDER BY invs.[dtCreated] DESC

END
GO
