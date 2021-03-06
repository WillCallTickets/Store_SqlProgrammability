USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Inventory_Bundle_GetChildItemCount]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 11/05/31
-- Description:	Retrieves inventory for a given bundleid.
/*
	exec tx_Inventory_Bundle_GetChildItemCount 10011
*/
-- =============================================

CREATE PROCEDURE [dbo].[tx_Inventory_Bundle_GetChildItemCount](

	@BundleId	INT

)
AS 

-- https://msdn.microsoft.com/en-us/library/ms186736.aspx
SET DEADLOCK_PRIORITY LOW 

BEGIN


	DECLARE	@sum INT
	SET		@sum = 0
	
	
	SELECT	mbi.[tMerchBundleId], 
			SUM(CASE WHEN m.[Id] IS NULL THEN 0 ELSE m.[iAvailable] END) AS 'Available'
	INTO	#tmpBundleSums
	FROM	[MerchBundleItem] mbi 
			LEFT OUTER JOIN [Merch] m 
				ON mbi.[TMerchId] = m.[Id]
	WHERE	mbi.[tMerchBundleId] = @BundleId 
			AND mbi.[bActive] = 1 
			AND	m.[bActive] = 1 
			AND m.[iAvailable] > 0
	GROUP BY mbi.[tMerchBundleId]

	IF EXISTS(SELECT * FROM #tmpBundleSums WHERE [tMerchBundleId] = @BundleId) 
	BEGIN

		SELECT	@sum = Available 
		FROM	#tmpBundleSums 
		WHERE	[tMerchBundleId] = @BundleId
		
	END

	SELECT @sum AS [BundleSum]
	
	DROP TABLE #tmpBundleSums

END
GO
