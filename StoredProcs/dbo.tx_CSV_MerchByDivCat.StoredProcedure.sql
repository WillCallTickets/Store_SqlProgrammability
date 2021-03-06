USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_CSV_MerchByDivCat]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Retrieves parent merchandise rows that match the search criteria and 
--	provides a report of sales, inventory, etc
--	Note: we cannot have a case where we retrieve all categories without a specified division
/*
	exec tx_CSV_MerchByDivCat '83c1c3f6-c539-41d7-815d-143fbd40e41f', 'parcel', null, 0, 0, 'all'

	select * from merchdivision where id = 10000
	exec [dbo].[tx_CSV_MerchByDivCat] @applicationId='83C1C3F6-C539-41D7-815D-143FBD40E41F',
		@deliveryDefault='parcel',@DeliveryType='',@DivId=10000,@CatId=10019,@ActiveStatus='all'

	a-164, s=156, avail=8

	select * from merch where tparentlisting = 10446
*/
-- =============================================

CREATE	PROC [dbo].[tx_CSV_MerchByDivCat](

	@applicationId		UNIQUEIDENTIFIER,
	@deliveryDefault	VARCHAR(50),
	@DeliveryType		VARCHAR(50),
	@DivId				INT,
	@CatId				INT,
	@ActiveStatus		VARCHAR(5) -- all, true, false

)
AS

SET NOCOUNT ON

BEGIN

	CREATE TABLE #tmpParents (
	
		DivId			INT, 
		CatId			INT, 
		MerchId			INT, 
		ParentId		INT, 
		ParentName		VARCHAR(500), 
		MerchName		VARCHAR(500), 
		Style			VARCHAR(500), 
		Color			VARCHAR(500), 
		Size			VARCHAR(500), 
		IsActive		BIT, 
		IsFeatured		BIT, 
		IsSoldOut		BIT, 
		vcDeliveryType	VARCHAR(50), 
		mWeight			DECIMAL, 
		mPrice			DECIMAL, 
		Allot			INT, 
		Dmg				INT, 
		Pend			INT, 
		Sold			INT, 
		Avail			INT,
		RowNumber		INT
	
	)
	
	CREATE TABLE #tmpReport (
	
		DivId			INT, 
		CatId			INT, 
		MerchId			INT, 
		ParentId		INT, 
		ParentName		VARCHAR(500), 
		MerchName		VARCHAR(500), 
		Style			VARCHAR(500), 
		Color			VARCHAR(500), 
		Size			VARCHAR(500), 
		IsActive		BIT, 
		IsFeatured		BIT, 
		IsSoldOut		BIT, 
		vcDeliveryType	VARCHAR(50), 
		mWeight			DECIMAL, 
		mPrice			DECIMAL, 
		Allot			INT, 
		Dmg				INT, 
		Pend			INT, 
		Sold			INT, 
		Avail			INT,
		RowNumber		INT
	
	)

	-- call a stored proc to get the parent rows - form basic structure of table
	INSERT	#tmpParents(DivId, CatId, MerchId, 
				ParentId, ParentName, MerchName, 
				Style, Color, Size, IsActive, IsFeatured, IsSoldOut, 
				vcDeliveryType, mWeight, mPrice, 
				Allot, Dmg, Pend, Sold, Avail, RowNumber)
	EXEC	dbo.tx_GetMerchParentsByDivCat @applicationId, @deliveryDefault, @DeliveryType, 
				@DivId, @CatId, @ActiveStatus, 0, 100000	
	
	DECLARE	@maxRow	INT
	SET		@maxRow = 0
	
	SELECT	@maxRow = MAX(RowNumber) 
	FROM	#tmpParents
		
	DECLARE	@counter INT
	SET		@counter = 0

	-- loop thru rows and update inventory values
	WHILE (@counter < @maxRow) 
	BEGIN
	
		SET @counter = @counter + 1
		
		--insert parent
		INSERT	#tmpReport(DivId, CatId, MerchId, ParentId, ParentName, MerchName, 
					Style, Color, Size, IsActive, IsFeatured, IsSoldOut, 
					vcDeliveryType, mWeight, mPrice, 
					Allot, Dmg, Pend, Sold, Avail, RowNumber)
		SELECT	DivId, CatId, MerchId, ParentId, ParentName, MerchName, 
					Style, Color, Size, IsActive, IsFeatured, IsSoldOut, 
					vcDeliveryType, mWeight, mPrice, 
					Allot, Dmg, Pend, Sold, Avail, RowNumber
		FROM	#tmpParents
		WHERE	RowNumber = @counter
	
		DECLARE	@parentId	INT
		
		SELECT	@parentId = MerchId 
		FROM	#tmpParents
		WHERE	RowNumber = @counter
		
		--insert children		
		INSERT	#tmpReport(DivId, CatId, MerchId, ParentId, ParentName, MerchName, 
					Style, Color, Size, IsActive, IsFeatured, IsSoldOut, 
					vcDeliveryType, mWeight, mPrice, 
					Allot, Dmg, Pend, Sold, Avail, RowNumber)
		SELECT	p.[DivId]					AS DivId, 
				p.[CatId]					AS CatId,
				m.[Id]						AS MerchId, 
				m.[TParentListing]			AS ParentId, 
				p.[ParentName]				AS ParentName,
				m.[Name]					AS MerchName, 
				m.[Style], 
				m.[Color], 
				m.[Size], 
				m.[bActive]					AS IsActive, 
				m.[bFeaturedItem]			AS IsFeatured, 
				m.[bSoldOut]				AS IsSoldOut, 
				m.[vcDeliveryType]			AS vcDeliveryType, 
				ISNULL(m.[mWeight],0)		AS mWeight, 
				ISNULL(m.[mPrice], 0)		AS mPrice, 
				ISNULL(m.[iAllotment], 0)	AS Allot,
				ISNULL(m.[idamaged], 0)		AS Dmg,
				ISNULL(m.iPending, 0)		AS Pend,
				ISNULL(m.[iSold], 0)		AS Sold,
				ISNULL(m.[iAvailable], 0)	AS Avail,
				0							AS RowNumber
		FROM	Merch m, #tmpParents p
		WHERE	m.[tParentListing] = @parentId 
				AND p.[MerchId] = @parentId
		ORDER BY Style ASC, Color ASC, Size ASC
		
	END
	
	SELECT * FROM #tmpReport
	
END
GO
