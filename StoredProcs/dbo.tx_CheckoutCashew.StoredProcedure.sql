USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_CheckoutCashew]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/06/25
-- Updated:		11/04/08 - added check for a job expired row
-- Description:	This procedure checks to see if there is an existing record of the card. If not found, it creates 
--				a new record. Note that all ePrefix values are encrypted
-- Returns:		The aspnet_user UserId and CustomerId and the Id of the Cashew
/*
select * from cashew--5890
select * from invoice--7362

select * from aspnet_users where username = 'rob@robkurtz.net'
select * from cashew where userid = '8D4AD888-97F7-4435-91CC-984B71EF319D'
select * from user_previousemail

exec tx_checkoutcashew '8D4AD888-97F7-4435-91CC-984B71EF319D', 
	'kCqIF1smdKB7wlRlSr9xWg==', 'rind/CwwmhWP5vvs8Hrfhw==', 
	'tNZf43mhs4zN8dtkIc7cKg==', 'nRduob2uDwrFoh1uLVMStg=='
*/
-- =============================================

CREATE PROCEDURE [dbo].[tx_CheckoutCashew] (

	@aspnetUserId	VARCHAR(256),
	@eCardName		VARCHAR(75), 
	@eCardNumber	VARCHAR(75),
	@eCardMonth		VARCHAR(75),
	@eCardYear		VARCHAR(75)

)
AS

BEGIN

	SET NOCOUNT ON

	DECLARE	@customerId		INT,
			@cashewId		INT

	SET		@cashewId = 0--init value

	--find the userid and customerid info from membership
	SELECT	@customerId = [CustomerId]
	FROM	[dbo].[aspnet_Users]
	WHERE	[UserId] = @aspnetUserId

	SELECT	TOP 1 @cashewId = [Id]
	FROM	Cashew
	WHERE	[eNumber]		<> '-1' AND 
			[CustomerId]	= @CustomerId AND 
			[eNumber]		= @eCardNumber AND
			[eMonth]		= @eCardMonth AND
			[eYear]			= @eCardYear AND
			[eName]			= @eCardName  
			
	--if no match, create new
	IF	(@cashewId = 0)	
	BEGIN

		INSERT INTO	Cashew([eNumber], [eMonth], [eYear], [eName], [UserId], [CustomerId])
		VALUES		(@eCardNumber, @eCardMonth, @eCardYear, @eCardName, @aspnetUserId, @customerId)
		SET			@cashewId = SCOPE_IDENTITY()
	    
	END

	SELECT	@customerId AS 'CustomerId', @cashewId AS 'CashewId'

END
GO
