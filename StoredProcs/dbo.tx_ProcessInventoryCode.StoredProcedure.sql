USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_ProcessInventoryCode]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 2012/11/03 
-- Description:	note that the CodeDeliveryConstant includes the '='
-- Returns:		string with a unique inventory code
-- =============================================
/*
exec [dbo].[tx_ProcessInventoryCode] @invoiceItemId=194269,@productContext='m',
@productId=11301,@dateSold='2012-11-07 17:26:00.357',@defaultCode='d12934d266a99e7b',
@deliveryType='ActivationCode=',@useInventoryCodeList='ActivationCode=',@reportToInvoiceItem=1

DECLARE @invoiceItemId int
DECLARE @deliveryType VARCHAR(25)
DECLARE @workingCode VARCHAR(25)

SET @invoiceItemId = 194269
SET @deliveryType = 'ActivationCode='
SET @workingCode = 'newCode'

update invoiceitem set criteria = '' where id = 194269
--update invoiceitem set criteria = 'BundleId=10052&ParentId=194261&ActivationCode=skj' where id = 194269
--update invoiceitem set criteria = 'ActivationCode=skj' where id = 194269
--update invoiceitem set criteria = 'ActivationCode=skj&BundleId=10052&ParentId=194261' where id = 194269
--update invoiceitem set criteria = 'BundleId=10052&ActivationCode=skj&ParentId=194261' where id = 194269
*/

CREATE PROCEDURE [dbo].[tx_ProcessInventoryCode](
	
	@invoiceItemId			INT,
	@productContext			CHAR(1),	
	@productId				INT,
	@dateSold				DATETIME,	
	@defaultCode			VARCHAR(50), -- a backup to use just in case, either a guid or an interleaved string	
	@deliveryType			VARCHAR(50), --the CodeDeliveryConstant, note that this includes the '='
	@useInventoryCodeList	VARCHAR(256),--a list of deliverytypes where we should retrieve a code from the inventory table 
	@reportToInvoiceItem	BIT
	
)	
AS

BEGIN

	SET NOCOUNT ON	

	DECLARE @workingCode VARCHAR(50)
	
	--tofind, searchstring
	--if the current method is within the list of codes specified to use inventory codes...
	IF	(LEN(LTRIM(RTRIM(@deliveryType))) > 0 
		AND LEN(LTRIM(RTRIM(@useInventoryCodeList))) > 0 
		AND CHARINDEX(@deliveryType, @useInventoryCodeList) > 0) 
	BEGIN

		BEGIN TRANSACTION
		
			UPDATE	[Inventory]
			SET		[tInvoiceItemId] = @invoiceItemId,
					[dtSold] = @dateSold
			WHERE	[Id] IN (
						SELECT	TOP 1 [Id] 
						FROM	[Inventory] 
						WHERE	[vcParentContext] = @productContext 
								AND [iParentInventoryId] = @productId 
								AND [tInvoiceItemId] IS NULL ORDER BY [Id]
						)		
		
		COMMIT TRANSACTION

		-- select latest matched row - codes may need to be updated at some point
		SELECT	TOP 1 @workingCode = COALESCE([Code], @defaultCode)
		FROM	[Inventory]
		WHERE	[tInvoiceItemId] = @invoiceItemId
		ORDER BY [Id] DESC

	END
	
	--if we arent using inventory codes, then set working to provided code
	SET @workingCode = ISNULL(@workingCode, @defaultCode)
	
	IF (ISNULL(@reportToInvoiceItem,0) = 1) 
	BEGIN
	
		--construct codeString
		DECLARE	@codeString VARCHAR(500)
		SET		@codeString = @deliveryType + @workingCode
		
		DECLARE @newCriteria VARCHAR(500)
		SET		@newCriteria = ''
				
		--get current criteria
		DECLARE	@currentCriteria VARCHAR(500)
		SELECT	@currentCriteria = [Criteria] 
		FROM	[InvoiceItem] 
		WHERE	[Id] = @invoiceItemId		
		
		--if there is criteria
		IF (@currentCriteria IS NOT NULL AND LEN(LTRIM(RTRIM(@currentCriteria))) > 0) 
		BEGIN
		
			--check to see if the deliverycontext already exists - if so remove it
			IF(CHARINDEX(@deliveryType, @currentCriteria) > 0)	 
			BEGIN
			
				--get index of start
				DECLARE @boundary1 INT
				DECLARE @boundary2 INT
			
				--IF there is a string before the old value
				SET @boundary1 = CHARINDEX(@deliveryType, @currentCriteria)			
				IF(@boundary1 > 1)	
					SET @newCriteria = SUBSTRING(@currentCriteria, 1, @boundary1 - 1)
				
				--IF there is a string after the old value
				SET @boundary2 = CHARINDEX('&', @currentCriteria, @boundary1)				
				IF(@boundary2 > 0) 
				BEGIN
				
					DECLARE @adjustment INT
					SET @adjustment = 0	
									
					IF(@boundary1 = 1)
						SET @adjustment = 1
						
					SET @newCriteria = @newCriteria + 
						SUBSTRING(@currentCriteria, @boundary2 + @adjustment, LEN(@currentCriteria) - @boundary2 + 1)
						
				END
					
			END
			ELSE BEGIN
			
				--if not - then tack on the end
				SET @newCriteria = @currentCriteria
			
			END
			
			--IF we have text, then tack on as an additional value
			IF (LEN(RTRIM(LTRIM(@newCriteria))) > 0) 
				SET @newCriteria = @newCriteria + '&'
			
		END
		
		--FINALIZE - empty value will simply add code string
		SET @newCriteria = @newCriteria + @codeString
		
		--UPDATE
		UPDATE	[InvoiceItem] 
		SET		[Criteria] = @newCriteria 
		WHERE	[Id] = @invoiceItemId				
	
	END -- end of reporting
	
	--return the code
	SELECT @workingCode
	
	RETURN

END
GO
