USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetMerchInventoryInRange_Count]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Retrieves  a count of the merchandise inventory rows that match the search criteria. 
-- =============================================

CREATE PROCEDURE [dbo].[tx_GetMerchInventoryInRange_Count](

	@applicationId	UNIQUEIDENTIFIER,
	@parentId		INT,
	@Style			VARCHAR(256),
	@Color			VARCHAR(256),
	@Size			VARCHAR(256),
	@ActiveStatus	VARCHAR(5)
	
)
AS

SET DEADLOCK_PRIORITY LOW

SET NOCOUNT ON

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET @Style			= ISNULL(@Style,'');
	SET @Color			= ISNULL(@Color,'');
	SET @Size			= ISNULL(@Size,'');
	SET @ActiveStatus	= LOWER(@ActiveStatus)

	-- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForInventory(
        IndexId		INT IDENTITY (0, 1) NOT NULL,
        InventoryId INT
    )

	IF EXISTS (SELECT * FROM Merch m WHERE m.[Id] = @parentId AND tParentListing IS NULL) 
	BEGIN

		INSERT	#PageIndexForInventory (InventoryId)
		
		SELECT	m.[Id] AS InventoryId
		FROM	Merch m 
		WHERE	m.[ApplicationId] = @applicationId 
				AND m.[tParentListing] = @parentId 
				AND 
				CASE @Style 
					WHEN '' THEN 1 
					ELSE 
						CASE WHEN m.[Style] = @Style THEN 1 
						ELSE 0 
						END 
				END = 1 
				AND 
				CASE @Color 
					WHEN '' THEN 1 
					ELSE 
						CASE WHEN m.[Color] = @Color THEN 1 
						ELSE 0 
						END 
				END = 1 
				AND 
				CASE @Size 
					WHEN '' THEN 1 
					ELSE CASE WHEN m.[Size] = @Size THEN 1 
					ELSE 0 
					END 
				END = 1 
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
	
	END ELSE 
	BEGIN -- return the only row in question
		
		INSERT	#PageIndexForInventory (InventoryId)
		SELECT	m.[Id] AS InventoryId
		FROM	Merch m 
		WHERE	m.[ApplicationId] = @applicationId 
				AND m.[Id] = @parentId
						
	END

	SELECT	COUNT(*) 
	FROM	#PageIndexForInventory p

END
GO
