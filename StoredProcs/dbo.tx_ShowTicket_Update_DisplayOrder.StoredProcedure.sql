USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_ShowTicket_Update_DisplayOrder]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Updates a ticket row's display order without affecting inventory.
--	This is necessary because Subsonic methods are timed so that the nums get reset and not updated.
--	It is a possible bug in utilizing a multi-col index on the colum
-- =============================================

CREATE PROCEDURE [dbo].[tx_ShowTicket_Update_DisplayOrder](

	@Id				INT,
	@iDisplayOrder	INT	

)
AS 

BEGIN

	--update all linked tickets
	UPDATE	[dbo].[ShowTicket] 
	SET		[iDisplayOrder] = @iDisplayOrder
	WHERE	[Id] = @Id

	SELECT @Id AS id

END
GO
