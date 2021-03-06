USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_BulkInsert_InventoryCodes]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: ?
-- Title:		tx_BulkInsert_InventoryCodes
-- Description:	Some inventory items are given a code for redemption and identification.
--	This proc assigns the list of codes to inventory items
--	Uses InventoryUdt
-- =============================================



CREATE PROCEDURE [dbo].[tx_BulkInsert_InventoryCodes](
 
 @InventoryHeaders AS InventoryUdt READONLY

)
AS

BEGIN

	DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

	DECLARE @NumInserted   int
    SET @NumInserted = 0
    
    IF( @@TRANCOUNT = 0 )
    BEGIN
    
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
	    
    END
    ELSE 
    BEGIN
    
    	SET @TranStarted = 0
    		
		-- Bulk insert order header rows from TVP
		INSERT INTO [Inventory] (vcParentContext, iParentInventoryId, Code)
		
		SELECT * FROM @InventoryHeaders

		SET @NumInserted = @@ROWCOUNT

		IF( @@ERROR <> 0 )
		BEGIN
		
			SET @ErrorCode = -1
			GOTO Cleanup
			
		END
	    
		IF( @TranStarted = 1 )
		BEGIN
		
			SET @TranStarted = 0
			COMMIT TRANSACTION
			
		END

		RETURN @NumInserted
		
	END	
    
	
	Cleanup:

		IF( @TranStarted = 1 )
		BEGIN
	    
			SET @TranStarted = 0
    		ROLLBACK TRANSACTION
	    	
		END

		RETURN @ErrorCode
    
 END
GO
