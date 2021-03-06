USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_ProductAccess_LookupData]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 09/21/11
-- Description:	Retrieves table data related to Product Access. The offset date is used to
--	gather rows that are set to come online at a future date.
/*
select dtpublicstart, DATEADD(hh, -@hourStartOffset, ISNULL(aw.[dtPublicStart], '1/1/1900')) from activationwindow aw

select * from productaccessproduct
select * from productaccessuser
*/
-- =============================================

CREATE	PROC [dbo].[tx_ProductAccess_LookupData](

	@appId				UNIQUEIDENTIFIER,
	@hourStartOffset	INT

)
AS

SET NOCOUNT ON

BEGIN

	DECLARE @dateNow		DATETIME, 
			@tableContext	VARCHAR(256)

	SET	@dateNow = GETDATE()
	SET	@tableContext = 'ProductAccess'
	SET @hourStartOffset = ISNULL(@hourStartOffset, 168) --default to one week
	
	SELECT	pa.[Id] as [ProductAccessId], ISNULL(aw.[Id], NULL) as [ActivationWindowId]
	INTO	#tmpAccess
	FROM	[ProductAccess] pa 
			LEFT OUTER JOIN [ActivationWindow] aw 
				ON aw.[vcContext] = @tableContext AND aw.[TParentId] = pa.[Id]
	WHERE	pa.[ApplicationId] = @appId 
			AND pa.[bActive] = 1 
			AND 
			CASE WHEN aw.[Id] IS NULL THEN 1
			ELSE
				CASE aw.[bUseCode] 
					WHEN 1 THEN --quals when date range is ok
						CASE WHEN @dateNow BETWEEN DATEADD(hh, -@hourStartOffset, ISNULL(aw.[dtCodeStart], '1/1/1900')) 
								AND ISNULL(aw.[dtCodeEnd], '1/1/2100') THEN 1 ELSE 0 END
					WHEN 0 THEN --if we ignore the code, public dates are in question
						CASE WHEN @dateNow BETWEEN DATEADD(hh, -@hourStartOffset, ISNULL(aw.[dtPublicStart], '1/1/1900') )
								AND ISNULL(aw.[dtPublicEnd], '1/1/2100') THEN 1 ELSE 0 END
					END 
				END = 1	
				
				
	SELECT	* 
	FROM	[ProductAccess] pa 
	WHERE	pa.[Id] IN 
				(SELECT [ProductAccessId] FROM #tmpAccess) 			
				
	SELECT	* 
	FROM	[ProductAccessProduct] pap 
	WHERE	pap.[TProductAccessId] IN 
				(SELECT [ProductAccessId] FROM #tmpAccess) 	

	SELECT	pau.[TProductAccessId], pau.[UserName]
	FROM	[ProductAccessUser] pau
	WHERE	pau.[TProductAccessId] IN 
				(SELECT [ProductAccessId] FROM #tmpAccess) 	

	RETURN		

END
GO
