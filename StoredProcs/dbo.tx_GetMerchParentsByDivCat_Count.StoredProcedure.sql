USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetMerchParentsByDivCat_Count]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Retrieves a count of the parent merchandise rows that match the search criteria. 
-- exec [tx_GetAllMerchInventoryCount] 0,0
-- =============================================

CREATE PROCEDURE [dbo].[tx_GetMerchParentsByDivCat_Count]

	@applicationId		UNIQUEIDENTIFIER,
	@deliveryDefault	VARCHAR(50),
	@DeliveryType		VARCHAR(50),
	@DivId				INT,
	@CatId				INT,
	@ActiveStatus		VARCHAR(5) -- all, true, false

AS

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

BEGIN
	
	
	SET @DeliveryType = ISNULL(@DeliveryType,''); --allow for all selection
	SET @ActiveStatus = LOWER(@ActiveStatus)

	CREATE TABLE #Parents (
		IndexId INT IDENTITY (0, 1) NOT NULL,
		MerchId INT,
		Active	BIT
	)

	-- use cases
	-- if div = 0 then catId = 0 (get all cats)
	-- if div > 0 and cat = 0
	-- if div > 0 and cat > 0

	--select parent rows into table
	IF(@DivId > 0 AND @CatId = 0) 
	BEGIN

		INSERT INTO #Parents (MerchId, Active)
		SELECT	m.[Id] AS MerchId, m.[bActive] AS Active
		FROM	MerchJoinCat mjc, 
				MerchDivision div, 
				MerchCategorie cat, Merch m
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
	END
	
	ELSE IF(@DivId > 0 AND @CatId > 0) 
	BEGIN

		INSERT INTO #Parents (MerchId, Active)
		SELECT	m.[Id] AS MerchId, m.[bActive] AS Active
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
	END
	
	-- get by category
	ELSE IF(@DivId = 0 AND @CatId > 0) 
	BEGIN

		INSERT INTO #Parents (MerchId, Active)
		SELECT	m.[Id] AS MerchId, m.[bActive] AS Active
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

		INSERT INTO #Parents (MerchId, Active)
		SELECT	m.[Id] AS MerchId, m.[bActive] AS Active
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


	SELECT	COUNT(*) 
	FROM	#Parents p
	WHERE	CASE @ActiveStatus
				WHEN 'true' THEN 
					CASE WHEN (p.[Active] IS NULL OR (p.[Active] IS NOT NULL AND p.[Active] = 1)) THEN 1 
						ELSE 0 
					END
				WHEN 'false' THEN 
					CASE WHEN (p.[Active] IS NOT NULL AND p.[Active] = 0) THEN 1 
						ELSE 0 
					END
				ELSE 1 
			END = 1

END
GO
