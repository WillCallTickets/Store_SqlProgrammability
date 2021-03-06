USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_ShowTicket_Update_AvoidRealTimeVars]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Updates a showticket row without affecting inventory with the exception of allotment.
--	This is necessary because Subsonic methods reset the nums. Note that this also avoids 
--	updating the DateOfShow - even though it is in the input list. 
/*
N'@Id INT,@dtDateOfShow DATETIME,@CriteriaText nVARCHAR(4000),@SalesDescription nVARCHAR(37),@TShowDateId INT,@TShowId INT,@TAgeId INT,@bActive BIT,	
@bSoldOut BIT,@Status nVARCHAR(4000),@bDosTicket BIT,@iDisplayOrder INT,@PriceText nVARCHAR(4000),@mPrice MONEY,@DosText nVARCHAR(4000),
@mDosPrice MONEY,@mServiceCharge MONEY,@bAllowShipping BIT, @bAllowWillCall BIT,@dtShipCutoff DATETIME,@bUnlockActive BIT,@UnlockCode nVARCHAR(4000),
@dtUnlockDate DATETIME,@dtUnlockEndDate DATETIME,@dtPublicOnsale DATETIME,@dtEndDate DATETIME,@iMaxQtyPerOrder INT,
@iAllotment INT,@iPending INT,@iSold INT,@iRefunded INT,@dtStamp datetime',

@Id=10018,@dtDateOfShow='2007-09-21 21:30:00:000',@CriteriaText=N'',@SalesDescription=N'Ticket price includes $1 band charity',
@TShowDateId=10043,@TShowId=10032,@TAgeId=10001,@bActive=0,@bSoldOut=0,@Status=N'',@bDosTicket=0,@iDisplayOrder=0,@PriceText=N'',
@mPrice=$20.0000,@DosText=N'',@mDosPrice=NULL,@mServiceCharge=$4.0000,@bAllowShipping=1,@bAllowWillCall=1,@dtShipCutoff=NULL,@bUnlockActive=0,
@UnlockCode=NULL,@dtUnlockDate=NULL,@dtUnlockEndDate=NULL,@dtPublicOnsale=NULL,@dtEndDate=NULL,@iMaxQtyPerOrder=4,@iAllotment=120,
@iPending=0,@iSold=120,@iRefunded=0,@dtStamp='1900-01-01 00:00:00:000'
*/
-- =============================================

CREATE PROCEDURE [dbo].[tx_ShowTicket_Update_AvoidRealTimeVars](

	@Id					INT, 
	@dtDateOfShow		DATETIME,
	@CriteriaText		VARCHAR(300),
	@SalesDescription	VARCHAR(300),
	@TAgeId				INT,
	@bActive			BIT,	
	@bSoldOut			BIT,
	@Status				VARCHAR(500),
	@bDosTicket			BIT,
	@PriceText			VARCHAR(300),
	@mPrice				MONEY,
	@DosText			VARCHAR(300),
	@mDosPrice			MONEY,
	@mServiceCharge		MONEY,
	@bAllowShipping		BIT,
	@bAllowWillCall		BIT,
	@bHideShipMethod	BIT,
	@dtShipCutoff		DATETIME,
	@bOverrideSellout	BIT,
	@bUnlockActive		BIT,
	@UnlockCode			VARCHAR(256),
	@dtUnlockDate		DATETIME,
	@dtUnlockEndDate	DATETIME,
	@dtPublicOnsale		DATETIME,
	@dtEndDate			DATETIME,
	@iMaxQtyPerOrder	INT,
	@iAllotment			INT,
	@mFlatShip			MONEY,
	@FlatMethod			VARCHAR(256),
	@dtBackorder		DATETIME,
	@bShipSeparate		BIT

)
AS 

BEGIN

	CREATE	TABLE #AllTickets ( idx INT )

	INSERT	#AllTickets (idx)
	SELECT	st.[Id] 
	FROM	ShowTicket st 
	WHERE	@Id = [Id]
	
	--insert linked tickets
	INSERT	#AllTickets (idx)
	SELECT	link.[LinkedShowTicketId]
	FROM	ShowTicketPackageLink link, ShowTicket st
	WHERE	@Id = st.[Id] AND link.[ParentShowTicketId] = st.[Id]

	--update all linked tickets
	UPDATE	[dbo].[ShowTicket] 
	SET		[CriteriaText] = @CriteriaText, 
			[SalesDescription] = @SalesDescription, 
			[TAgeId] = @TAgeId, 
			[bActive] = @bActive, 
			[bSoldOut] = @bSoldOut, 
			[Status] = @Status, 
			[bDosTicket] = @bDosTicket, 
			[PriceText] = @PriceText, 
			[mPrice] = @mPrice, 
			[DosText] = @DosText, 
			[mDosPrice] = @mDosPrice, 
			[mServiceCharge] = @mServiceCharge, 
			[bAllowShipping] = @bAllowShipping, 
			[bAllowWillCall] = @bAllowWillCall, 
			[bHideShipMethod] = @bHideShipMethod, 
			[dtShipCutoff] = @dtShipCutoff, 
			[bOverrideSellout] = @bOverrideSellout, 
			[bUnlockActive] = @bUnlockActive, 
			[UnlockCode] = @UnlockCode, 
			[dtUnlockDate] = @dtUnlockDate, 
			[dtUnlockEndDate] = @dtUnlockEndDate, 
			[dtPublicOnsale] = @dtPublicOnsale, 
			[dtEndDate] = @dtEndDate, 
			[iMaxQtyPerOrder] = @iMaxQtyPerOrder, 
			[iAllotment] = @iAllotment, 
			[mFlatShip] = @mFlatShip, 
			[vcFlatMethod] = CASE WHEN (@FlatMethod IS NULL OR LEN(LTRIM(RTRIM(@FlatMethod))) = 0) THEN null ELSE @FlatMethod END, 
			[dtBackorder] = @dtBackorder, 
			[bShipSeparate] = @bShipSeparate
	WHERE	[Id] IN 
				(SELECT idx FROM #AllTickets )

	DROP	TABLE	#AllTickets

	SELECT @Id AS id

END
GO
