USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetSalePromotionsCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/03/24
-- Description:	Gets sale promotions that are within context (banners or not) 
-- Returns Wcss.SalePromotion
-- =============================================

CREATE	PROC [dbo].[tx_GetSalePromotionsCount](

	@applicationId	UNIQUEIDENTIFIER,
	@BannerContext	VARCHAR(256)

)
AS

SET NOCOUNT ON

BEGIN


	SELECT	COUNT(Distinct(ent.[Id]))
	FROM	SalePromotion ent
	WHERE	ent.[ApplicationId] = @applicationId 
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
END
GO
