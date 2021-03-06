USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetMerchParentsByDivCat]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Retrieves parent merchandise rows that match the search criteria. 
--	Note: we cannot have a case where we retrieve all categories without a specified division
-- =============================================

CREATE	PROC [dbo].[tx_GetMerchParentsByDivCat] (

	@applicationId		UNIQUEIDENTIFIER,
	@deliveryDefault	VARCHAR(50),
	@DeliveryType		VARCHAR(50),
	@DivId				INT,
	@CatId				INT,
	@ActiveStatus		VARCHAR(5), -- all, true, false
	@StartRowIndex      INT,		--this is based on what we get from the grid view control
	@PageSize           INT

)
AS

SET NOCOUNT ON

BEGIN

	SET @DeliveryType = ISNULL(@DeliveryType,'') --allow for 'all' selection
	SET @ActiveStatus = LOWER(@ActiveStatus)

	CREATE TABLE #Parents(
	
		IndexId		INT IDENTITY (1, 1) NOT NULL,
		DivId		INT,
		CatId		INT,
		MerchId		INT,
		ParentName	VARCHAR(256)
	)

	-- use cases
	-- if div = 0 then catId = 0 (get all cats)
	-- if div > 0 and cat = 0
	-- if div > 0 and cat > 0

	--select parent rows into table
	--get all cats for division
	IF(@DivId > 0 AND @CatId = 0) 
	BEGIN

		INSERT  #Parents (DivId, CatId, MerchId, ParentName)
		SELECT	div.[Id]	AS DivId, 
				cat.[Id]	AS CatId, 
				m.[Id]		AS MerchId, 
				m.[Name]	AS ParentName
		FROM	MerchJoinCat mjc, 
				MerchDivision div, 
				MerchCategorie cat, 
				Merch m
		WHERE	div.[ApplicationId] = @applicationId 
				AND div.[Id] = @DivId 
				AND cat.[TMerchDivisionId] = div.[Id] 
				AND mjc.[TMerchCategorieId] = cat.[Id] 
				AND m.[Id] = mjc.[TMerchid] 
				AND
				CASE @DeliveryType 
					WHEN '' THEN 1 ELSE 
					CASE WHEN ISNULL(m.[vcDeliveryType],@deliveryDefault) = @DeliveryType THEN 1 
						ELSE 0 
					END 
				END = 1
		ORDER BY div.[Name], cat.[Name], m.[Name]

	END
	
	--get selected cat from selected div
	ELSE IF(@DivId > 0 AND @CatId > 0) 
	BEGIN

		INSERT  #Parents (DivId, CatId, MerchId, ParentName)
		SELECT	div.[Id]	AS DivId, 
				cat.[Id]	AS CatId, 
				m.[Id]		AS MerchId, 
				m.[Name]	AS ParentName
		FROM	MerchJoinCat mjc, 
				MerchDivision div, 
				MerchCategorie cat, 
				Merch m
		WHERE	div.[ApplicationId] = @applicationId 
				AND div.[Id] = @DivId 
				AND cat.[Id] = @CatId 
				AND cat.[TMerchDivisionId] = div.[Id] 
				AND mjc.[TMerchCategorieId] = cat.[Id] 
				AND m.[Id] = mjc.[TMerchid] 
				AND 
				CASE @DeliveryType 
					WHEN '' THEN 1 ELSE 
					CASE WHEN ISNULL(m.[vcDeliveryType],@deliveryDefault) = @DeliveryType THEN 1 
						ELSE 0 
					END 
				END = 1
		ORDER BY div.[Name], cat.[Name], m.[Name]

	END
	
	--get by category
	ELSE IF(@DivId = 0 AND @CatId > 0) 
	BEGIN

		INSERT  #Parents (DivId, CatId, MerchId, ParentName)
		SELECT	div.[Id]	AS DivId, 
				cat.[Id]	AS CatId, 
				m.[Id]		AS MerchId, 
				m.[Name]	AS ParentName
		FROM	MerchJoinCat mjc, 
				MerchDivision div, 
				MerchCategorie cat, 
				Merch m
		WHERE	cat.[Id] = @CatId 
				AND cat.[TMerchDivisionId] = div.[Id] 
				AND div.[ApplicationId] = @applicationId 
				AND mjc.[TMerchCategorieId] = cat.[Id] 
				AND m.[Id] = mjc.[TMerchid] 
				AND 
				CASE @DeliveryType 
					WHEN '' THEN 1 ELSE 
					CASE WHEN ISNULL(m.[vcDeliveryType],@deliveryDefault) = @DeliveryType THEN 1 
						ELSE 0 
					END 
				END = 1
		ORDER BY div.[Name], cat.[Name], m.[Name]

	END
	
	-- get all
	ELSE IF(@DivId = 0 AND @CatId = 0) 
	BEGIN

		INSERT  #Parents (DivId, CatId, MerchId, ParentName)
		SELECT	div.[Id]	AS DivId, 
				cat.[Id]	AS CatId, 
				m.[Id]		AS MerchId, 
				m.[Name]	AS ParentName
		FROM	MerchJoinCat mjc, 
				MerchDivision div, 
				MerchCategorie cat, 
				Merch m
		WHERE	cat.[TMerchDivisionId] = div.[Id] 
				AND div.[ApplicationId] = @applicationId 
				AND mjc.[TMerchCategorieId] = cat.[Id] 
				AND m.[Id] = mjc.[TMerchid] 
				AND 
				CASE @DeliveryType 
					WHEN '' THEN 1 ELSE 
					CASE WHEN ISNULL(m.[vcDeliveryType],@deliveryDefault) = @DeliveryType THEN 1 
						ELSE 0 
					END 
				END = 1
		ORDER BY div.[Name], cat.[Name], m.[Name]

	END

	-- return parents and inventory
	SELECT * FROM
	(
		SELECT	p.[DivId] AS DivId, 
				p.[CatId] AS CatId,
				m.[Id] AS MerchId, 
				m.[TParentListing] AS ParentId, 
				p.[ParentName] AS ParentName,
				m.[Name] AS MerchName, 
				m.[Style], 
				m.[Color], 
				m.[Size], 
				m.[bActive] AS IsActive, 
				m.[bFeaturedItem] AS IsFeatured, 
				m.[bSoldOut] AS IsSoldOut, 
				m.[vcDeliveryType] AS vcDeliveryType, 
				ISNULL(m.[mWeight],0) AS mWeight, 
				ISNULL(m.[mPrice],0) AS mPrice, 
				CASE WHEN SUM(child.[iAllotment]) IS NOT NULL THEN SUM(child.[iAllotment]) 
					ELSE m.[iAllotment] 
				END AS	Allot,
				CASE 
					WHEN SUM(child.[idamaged]) IS NOT NULL THEN SUM(child.[iDamaged]) 
					ELSE m.[iDamaged] 
				END AS Dmg,
				SUM(ISNULL(pendingStock.[iQty],0)) AS Pend,
				CASE 
					WHEN SUM(child.[iSold]) IS NOT NULL THEN SUM(child.[iSold]) 
					ELSE m.[iSold] 
				END AS Sold,
				CASE 
					WHEN SUM(child.[iAvailable]) IS NOT NULL THEN SUM(child.[iAvailable]) 
					ELSE m.[iAvailable] 
				END AS Avail,
				ROW_NUMBER() OVER (ORDER BY p.[IndexId] ASC) AS RowNum
		FROM	#Parents p, 
				Merch m 
				LEFT OUTER JOIN Merch child 
					ON m.[Id] = child.[TParentListing]
				LEFT OUTER JOIN fn_PendingStock('merch') pendingStock 
					ON pendingStock.[idx] = child.[Id]
		WHERE	m.[Id] = p.[MerchId] 
				AND 
				CASE @ActiveStatus
					WHEN 'true' THEN 
						CASE WHEN (m.[bActive] IS NULL OR (m.[bActive] IS NOT NULL AND m.[bActive] = 1)) THEN 1 
							ELSE 0 
						END
					WHEN 'false' THEN 
						CASE WHEN (m.[bActive] IS NOT NULL AND m.[bActive] = 0) THEN 1 
							ELSE 0 
						END
					ELSE 1 
				END = 1

		GROUP BY p.[IndexId], 
				p.[DivId], 
				p.[CatId], 
				m.[TParentListing], 
				p.[ParentName], 
				m.[Id], 
				m.[Name], 
				m.[Style], 
				m.[Color], 
				m.[Size], 
				m.[bActive], 
				m.[bFeaturedItem], 
				m.[bSoldOut], 
				m.[vcDeliveryType], 
				m.[mWeight], 
				m.[mPrice], 
				m.[Description], 
				m.[iAllotment], 
				m.[iDamaged], 
				ISNULL(pendingStock.[iQty],0), 
				m.[iSold], m.[iAvailable]

	) Merches
	WHERE	Merches.RowNum BETWEEN (@StartRowIndex) AND (@StartRowIndex + @PageSize - 1)
	ORDER BY Merches.[RowNum] ASC

END
GO
