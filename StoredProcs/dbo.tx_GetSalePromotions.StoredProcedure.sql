USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetSalePromotions]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/03/24
-- Description:	Gets sale promotions that are within context (all, future -or- current)
-- Returns Wcss.SalePromotion
-- =============================================

CREATE	PROC [dbo].[tx_GetSalePromotions](

	@ApplicationId	UNIQUEIDENTIFIER,
	@BannerContext	VARCHAR(256),
	@StartRowIndex  INT,	
	@PageSize       INT

)
AS

SET NOCOUNT ON

BEGIN

	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForCollection(
        IndexId		INT IDENTITY (1, 1) NOT NULL,
		EntityId	INT
    )

	INSERT INTO #PageIndexForCollection (EntityId)
	SELECT EntityId FROM
	(	
		SELECT	Distinct(ent.[Id]) as EntityId, ROW_NUMBER() OVER (ORDER BY ent.[Id] DESC) AS RowNum
		FROM	SalePromotion ent
		WHERE	ent.[ApplicationId] = @ApplicationId 
				AND 
				CASE @BannerContext  
					WHEN 'BannersOnly' THEN
						CASE WHEN	ent.[mPrice] = 0 
									AND ent.[mDiscountAmount] = 0 
									AND ent.[iDiscountPercent] = 0 
									AND ent.[ShipOfferMethod] IS NULL
							THEN 1 
							ELSE 0 
						END
					WHEN 'NoBanners' THEN
						CASE WHEN	ent.[mPrice] > 0 
									OR ent.[mDiscountAmount] > 0 
									OR ent.[iDiscountPercent] > 0
							THEN 1 
							ELSE 0 
						END 
					ELSE 1 
				END = 1
	) Entities
	WHERE	Entities.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
	ORDER BY [EntityId] DESC 

	SELECT	ent.*
	FROM	[#PageIndexForCollection] p, 
			[SalePromotion] ent 				
    WHERE	ent.[Id] = p.[EntityId]
	ORDER BY ent.[Id] DESC

END
GO
