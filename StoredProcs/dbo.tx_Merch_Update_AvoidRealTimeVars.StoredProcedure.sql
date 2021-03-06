USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_Merch_Update_AvoidRealTimeVars]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 07/12/05
-- Description:	Updates a merch row without affecting inventory with the exception of allotment.
--	This is necessary because Subsonic methods reset the nums. 
/*
N'@Id int,@dtDateOfShow DATETIME,@CriteriaText nVARCHAR(4000),@SalesDescription nVARCHAR(37),@TShowDateId int,@TShowId int,@TAgeId int,@bActive BIT,	
@bSoldOut BIT,@Status nVARCHAR(4000),@bDosTicket BIT,@iDisplayOrder int,@PriceText nVARCHAR(4000),@mPrice MONEY,@DosText nVARCHAR(4000),
@mDosPrice MONEY,@mServiceCharge MONEY,@bAllowShipping BIT,@dtShipCutoff DATETIME,@bUnlockActive BIT,@UnlockCode nVARCHAR(4000),
@dtUnlockDate DATETIME,@dtUnlockEndDate DATETIME,@dtPublicOnsale DATETIME,@dtEndDate DATETIME,@iMaxQtyPerOrder int,
@iAllotment int,@iPending int,@iSold int,@iRefunded int,@dtStamp datetime',

@Id=10018,@dtDateOfShow='2007-09-21 21:30:00:000',@CriteriaText=N'',@SalesDescription=N'Ticket price includes $1 band charity',
@TShowDateId=10043,@TShowId=10032,@TAgeId=10001,@bActive=0,@bSoldOut=0,@Status=N'',@bDosTicket=0,@iDisplayOrder=0,@PriceText=N'',
@mPrice=$20.0000,@DosText=N'',@mDosPrice=NULL,@mServiceCharge=$4.0000,@bAllowShipping=1,@dtShipCutoff=NULL,@bUnlockActive=0,
@UnlockCode=NULL,@dtUnlockDate=NULL,@dtUnlockEndDate=NULL,@dtPublicOnsale=NULL,@dtEndDate=NULL,@iMaxQtyPerOrder=4,@iAllotment=120,
@iPending=0,@iSold=120,@iRefunded=0,@dtStamp='1900-01-01 00:00:00:000'
*/
-- =============================================

CREATE PROCEDURE [dbo].[tx_Merch_Update_AvoidRealTimeVars](

	@Id					INT, 
	@Name				VARCHAR(256),
	@Style				VARCHAR(256),
	@Color				VARCHAR(256),
	@Size				VARCHAR(256),
	@bActive			BIT,	
	@bInternalOnly		BIT,
	@bSoldOut			BIT,
	@bTaxable			BIT,
	@bFeaturedItem		BIT,
	@ShortText			VARCHAR(300),
	@vcDisplayTemplate	VARCHAR(50),
	@Description		VARCHAR(MAX),
	@bUnlockActive		BIT,
	@UnlockCode			VARCHAR(256),
	@dtUnlockDate		DATETIME,
	@dtUnlockEndDate	DATETIME,
	@dtStartDate		DATETIME,
	@dtEndDate			DATETIME,
	@mPrice				MONEY,
	@bUseSalePrice		BIT,
	@mSalePrice			MONEY,
	@vcDeliveryType		VARCHAR(50),
	@bLowRateQualified	BIT,
	@mWeight			MONEY,	
	@mFlatShip			MONEY,
	@FlatMethod			VARCHAR(256),
	@dtBackorder		DATETIME,
	@bShipSeparate		BIT,
	@iMaxQtyPerOrder	INT,
	@iAllotment			INT,
	@iDamaged			INT

)
AS 

BEGIN

	UPDATE	[dbo].[Merch] 
	SET		[Name] = @Name, 
			[Style] = @Style, 
			[Color] = @Color, 
			[Size] = @Size,  
			[bActive] = @bActive, 
			[bInternalOnly] = @bInternalOnly, 
			[bSoldOut] = @bSoldOut, 
			[bTaxable] = @bTaxable, 
			[bFeaturedItem] = @bFeaturedItem, 			
			[ShortText] = @ShortText, 
			[vcDisplayTemplate] = @vcDisplayTemplate, 
			[Description] = @Description, 
			[bUnlockActive] = @bUnlockActive, 
			[UnlockCode] = @UnlockCode, 
			[dtUnlockDate] = @dtUnlockDate, 
			[dtUnlockEndDate] = @dtUnlockEndDate, 
			[dtStartDate] = @dtStartDate, 
			[dtEndDate] = @dtEndDate, 
			[mPrice] = @mPrice,
			[bUseSalePrice] = @bUseSalePrice, 
			[mSalePrice] = @mSalePrice, 
			[vcDeliveryType] = @vcDeliveryType, 
			[bLowRateQualified] = @bLowRateQualified, 
			[mWeight] = @mWeight, 
			[mFlatShip] = @mFlatShip, 
			[vcFlatMethod] = CASE WHEN (@FlatMethod IS NULL OR LEN(LTRIM(RTRIM(@FlatMethod))) = 0) THEN NULL 
								ELSE @FlatMethod 
							END, 
			[dtBackorder] = @dtBackorder, 
			[bShipSeparate] = @bShipSeparate, 
			[iMaxQtyPerOrder] = @iMaxQtyPerOrder, 
			[iAllotment] = @iAllotment,
			[iDamaged] = CASE WHEN @iDamaged > -1 THEN [iDamaged] + @iDamaged 
							ELSE [iDamaged] 
						END
	WHERE	[Id] = @Id

	SELECT @Id AS id

END
GO
