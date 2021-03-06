USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_GetCurrentObjects]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/10/24
-- Description:	Gets all future shows and all associated domain objects (based on @context). 
--	Client decides to display based on announceDate. 
--	Be careful when applying this to a single show scope - if the show has pkg 
--	tickets then the other shows need to be synced AS well
-- TODO this is one monolithic procedure - consider breaking into smaller pieces
--	although I am ont sure it is even used any longer
/*
Time must be in format of yyyy/MM/dd
exec [tx_GetSaleShowDates] '83C1C3F6-C539-41D7-815D-143FBD40E41F', '2008/12/15'--sts9
exec [tx_GetSaleShows] 'AC36EB0B-152E-4B69-8B39-BB4B6C9B01E6', '2008/10/23', '2008/12/12'--fox

*/
-- =============================================

CREATE	PROC [dbo].[tx_GetCurrentObjects](

	@appName			VARCHAR(256),
	@context			VARCHAR(256),			-- all, lookup, show
	@granularcontext	VARCHAR(256)	= null, --lookup table names reflect actual table names - NOT PLURAL
	@nowDate			DATETIME		= null,
	@showId				INT				= null	-- granular version for show

)
AS

SET NOCOUNT ON

BEGIN

	--Init possible null values
	SET	@nowDate			= ISNULL(@nowDate, DATEADD(hh, -48, getDate()))
	SET	@granularContext	= ISNULL(@granularContext,'')
	SET	@showId				= ISNULL(@showId,0)

	--keep a list of tables retrieved
	IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[#tablesRetrieved]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN  CREATE TABLE #tablesRetrieved ( idx INT IDENTITY(0,1), TableName VARCHAR(256) ) END

	CREATE TABLE #tmpSalePromos(
	
		Idx							INT, 
		tRequiredParentShowDateId	INT, 
		tRequiredParentShowTicketId INT
	)

	--Get the AppId from the provided appName
	DECLARE	@appId	UNIQUEIDENTIFIER
	
	SELECT	@appId = [ApplicationId] 
	FROM	[Aspnet_Applications] 
	WHERE	[ApplicationName] = @appName

	/*** LOOKUP TABLES ******************************************************************************/
	/***  Age, CharityListing, CharitableOrg, FaqCategorie, FaqItem, 
            HintQuestion, InvoiceFee, Merch_Division, MerchCategorie, MerchColor, MerchImage, MerchSize,
            SalePromotion, SaleRule,
            ServiceChargeTier, ShowStatus, SiteConfig, Subscription, Vendor***/
	--If we are dealing with lookups only - then do just these procs
	IF (@context = 'all' OR @context = 'lookup') 
	BEGIN 

		--if we are getting everything - ensure that we actually get everything
		IF (@context = 'all') 
		BEGIN 
		
			SET @granularContext = '' 
			
		END

		IF (@granularContext = '' OR @granularContext = 'ages') 
		BEGIN 
		
			SELECT	age.* 
			FROM	[Age] age 
			WHERE	age.[ApplicationId] = @appId 
			ORDER BY age.[Name] ASC 
			
			INSERT	#tablesRetrieved (TableName) 
			VALUES ('Ages')
			
		END

		IF (@granularContext = '' OR @granularContext = 'aspnetapplications') 
		BEGIN 
		
			SELECT	app.* 
			FROM	[Aspnet_Applications] app
			
			INSERT	#tablesRetrieved (TableName) 
			VALUES	('AspnetApplications')
			
		END
	
		--charity listings are tied to charitable orgs
		IF (@granularContext = '' OR @granularContext = 'charitylistings' OR @granularContext = 'charitableorgs') 
		BEGIN 
		
			SELECT	org.* 
			FROM	[CharitableOrg] org 
			WHERE	org.[ApplicationId] = @appId 
					AND org.[bActive] = 1 
			ORDER BY org.[NameRoot]
			
			SELECT	listing.* 
			FROM	[CharitableListing] listing, 
					(
						SELECT org.[Id] 
						FROM	[CharitableOrg] org 
						WHERE	org.[ApplicationId] = @appId 
								AND org.[bActive] = 1
					) orgs 
			WHERE	listing.[tCharitableOrgId] = orgs.[Id] 
			ORDER BY listing.[tCharitableOrgId], listing.[iDisplayOrder]
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('CharitableOrgs')
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('CharitableListings')
			
		END
		
		--faq items and faqcategories go together
		IF (@granularContext = '' OR @granularContext = 'faqcategories' OR @granularContext = 'faqitems') 
		BEGIN 
		
			SELECT	cat.* 
			FROM	[FaqCategorie] cat 
			WHERE	cat.[ApplicationId] = @appId 
			ORDER BY cat.[iDisplayOrder] ASC
			
			SELECT	item.* 
			FROM	[FaqItem] item, 
					(
						SELECT	cat.[Id] 
						FROM [FaqCategorie] cat 
						WHERE cat.[ApplicationId] = @appId
					) cats
			WHERE	item.[tFaqCategorieId] = cats.[Id] 
			ORDER BY item.[tFaqCategorieId], item.[iDisplayOrder] ASC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('FaqCategories')
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('FaqItems')
			
		END

		IF (@granularContext = '' OR @granularContext = 'hintquestions') 
		BEGIN 
		
			SELECT	hq.* 
			FROM	[HintQuestion] hq 
			WHERE	hq.[ApplicationId] = @appId 
			ORDER BY hq.[iDisplayOrder] ASC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('HintQuestions')
			
		END
		
		IF (@granularContext = '' OR @granularContext = 'invoicefees') 
		BEGIN 
		
			SELECT	fee.* 
			FROM	[InvoiceFee] fee 
			WHERE	fee.[ApplicationId] = @appId 
			ORDER BY fee.[Id] DESC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('InvoiceFees')
			
		END

		--merch categorie and merchdivision go together
		IF (@granularContext = '' OR @granularContext = 'merchcategories' OR @granularContext = 'merchdivisions') 
		BEGIN 
		
			SELECT	div.* 
			FROM	[MerchDivision] div 
			WHERE	div.[ApplicationId] = @appId 
			ORDER BY div.[iDisplayOrder] ASC
			
			SELECT	cat.* 
			FROM	[MerchCategorie] cat, 
					(
						SELECT	div.[Id] 
						FROM	[MerchDivision] div 
						WHERE	div.[ApplicationId] = @appId
					) divs
			WHERE	cat.[tMerchDivisionId] = divs.[Id] 
			ORDER BY cat.[tMerchDivisionId], cat.[iDisplayOrder] ASC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('MerchDivisions')
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('MerchCategories')
			
		END

		IF (@granularContext = '' OR @granularContext = 'merchcolors') 
		BEGIN
		
			SELECT	color.* 
			FROM	[MerchColor] color 
			WHERE	color.[ApplicationId] = @appId 
			ORDER BY color.[iDisplayOrder] ASC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('MerchColors')
			
		END

		IF (@granularContext = '' OR @granularContext = 'merchimages') 
		BEGIN
		
			SELECT	itm.* 
			FROM	[ItemImage] itm, [Merch] merch
			WHERE	itm.[tMerchId] = merch.[Id] 
					AND merch.[ApplicationId] = @appId 
					AND merch.[bActive] = 1
			ORDER BY itm.[iDisplayOrder]
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('MerchImages')
			
		END

		IF (@granularContext = '' OR @granularContext = 'merchsizes') 
		BEGIN
		
			SELECT	msize.* 
			FROM	[MerchSize] msize 
			WHERE	msize.[ApplicationId] = @appId 
			ORDER BY msize.[iDisplayOrder] ASC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('MerchSizes')
			
		END

		--sale promotion must retrieve its awards AS well
		IF (@granularContext = '' OR @granularContext = 'salepromotions' OR @granularContext = 'salepromotionawards') 
		BEGIN
		
			DECLARE @overlap datetime
			SET	@overlap = DATEADD(hh, -48, getDate())
			
			DECLARE @refresh datetime
			SET	@refresh = DATEADD(hh, 48, getDate())

			INSERT	#tmpSalePromos(Idx, tRequiredParentShowDateId, tRequiredParentShowTicketId)
			SELECT	sp.[Id]								AS 'Idx', 
					sp.[tRequiredParentShowDateId]		AS 'tRequiredParentShowDateId',
					sp.[tRequiredParentShowTicketId]	AS 'tRequiredParentShowTicketId'
			FROM	[SalePromotion] sp 
			WHERE	sp.[ApplicationId] = @appId  
					--allow promotions to start in context. Keep-alive in context
					AND (sp.[dtStartDate] IS NULL OR sp.[dtStartDate] < @refresh) 
					--don't bother with promotions that have ended
					AND (sp.[dtEndDate] IS NULL OR sp.[dtEndDate] > @overlap) 

			SELECT	* 
			FROM	[SalePromotion] sp, [#tmpSalePromos] promos 
			WHERE	sp.[Id] = promos.[Idx] 
			
			SELECT	award.* 
			FROM	[SalePromotionAward] award, [#tmpSalePromos] promo 
			WHERE	award.[tSalePromotionId] = promo.[Idx]

			INSERT  #tablesRetrieved (TableName) 
			VALUES  ('SalePromotions')
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('SalePromotionAwards')
			
		END

		IF (@granularContext = '' OR @granularContext = 'salerules') 
		BEGIN
		
			SELECT  sr.* 
			FROM	[SaleRule] sr 
			WHERE	sr.[ApplicationId] = @appId 
			ORDER BY sr.[iDisplayOrder] ASC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('SaleRules')
			
		END

		IF (@granularContext = '' OR @granularContext = 'servicecharges') 
		BEGIN
		
			SELECT  sc.* 
			FROM	[ServiceCharge] sc 
			WHERE	sc.[ApplicationId] = @appId 
			ORDER BY sc.[mMaxValue] ASC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('ServiceCharges')
			
		END

		IF	(@granularContext = '' OR @granularContext = 'showstatus' 
			OR @granularContext = 'showstatuss' OR @granularContext = 'showstatii') 
		BEGIN
		
			SELECT	ss.* 
			FROM	[ShowStatus] ss 
			ORDER BY ss.[Name] ASC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('ShowStatuss')
			
		END

		IF (@granularContext = '' OR @granularContext = 'siteconfigs') 
		BEGIN
		
			SELECT	sc.* 
			FROM	[SiteConfig] sc 
			WHERE	sc.[ApplicationId] = @appId 
			ORDER BY sc.[Name] ASC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('SiteConfigs')
			
		END

		IF (@granularContext = '' OR @granularContext = 'subscriptions') 
		BEGIN
		
			SELECT  sub.* 
			FROM	[Subscription] sub 
			WHERE	sub.[ApplicationId] = @appId 
			ORDER BY sub.[Id] DESC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('Subscriptions')
			
		END

		IF (@granularContext = '' OR @granularContext = 'vendors') 
		BEGIN
		
			SELECT	v.* 
			FROM	[Vendor] v 
			WHERE	v.[ApplicationId] = @appId 
			ORDER BY v.[Id] DESC
			
			INSERT  #tablesRetrieved (TableName) 
			VALUES	('Vendors')
			
		END

	END
	/*** END OF LOOKUPS ***/

	/*** SHOW DATE TABLES ***/
	IF (@context = 'all' OR @context = 'show') 
	BEGIN 

		/***************************************************************/
		/***************************************************************
		** If we are looking to refresh a single show and the show we are 
		**  trying to update has dates that contain
		**  ticket packages and are linked to other shows/dates/etc
		**  then we need to update those other shows AS well
		** First step is to establish a table with the ShowDates
		**
		** WE WILL BE BASING EVERYTHING OFF OF SHOWDATES NOT SHOWS!!!!!!
		**
		***************************************************************/
		/***************************************************************/

		--create a table to hold the showDateIds
		IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[#tmpDateIds]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
		BEGIN 
		
			CREATE TABLE #tmpDateIds ( 
				tShowDateId INT, 
				tShowId INT 
			) 
			
		END

		--if we have a show with dates that have tickets that are pkgs
		-- we need to include the showdate here because we are comparing to nowdate
		IF (@showId > 0) 
		BEGIN

			INSERT	[#tmpDateIds] ([tShowDateId], [tShowId])
			SELECT	DISTINCT TOP 100 PERCENT sd.[Id] AS 'tShowDateId', sd.[tShowId] AS 'tShowId'
			FROM	[ShowDate] sd, [Show] s
			WHERE	s.[ApplicationId] = @appId 
					AND s.[Id] = @ShowId 
					AND s.[Id] = sd.[tShowId]

		END ELSE 
		BEGIN

			INSERT	[#tmpDateIds] ([tShowDateId], [tShowId])
			SELECT	DISTINCT TOP 100 PERCENT sd.[Id] AS 'tShowDateId', sd.[tShowId] AS 'tShowId'
			FROM	[ShowDate] sd, [Show] s
			WHERE	s.[ApplicationId] = @appId 
					AND s.[Id] = sd.[tShowId] 
					AND sd.[dtDateOfShow] >= @nowDate

		END

		--now from those showdates - we need to make sure we have any showdates that are linked by a package
		INSERT	[#tmpDateIds] ([tShowDateId], [tShowId])
		SELECT	DISTINCT linked.[tShowDateId] AS 'tShowDateId', linked.[tShowId] AS 'tShowId'
		FROM	[#tmpDateIds] dates, 
				[ShowTicket] st, 
				[ShowTicketPackageLink] pkg, 
				[ShowTicket] linked
		WHERE	st.[tShowId] = dates.[tShowId] 
				AND pkg.[ParentShowTicketId] = st.[Id] 
				AND pkg.[LinkedShowTicketId] = linked.[Id] 
				AND linked.[tShowDateId] NOT IN (SELECT [tShowDateId] FROM [#tmpDateIds])
				
		-- and we also need to make sure we have any showdates linked by a sale promotion		
		-- and by required showdate
		INSERT	[#tmpDateIds] ([tShowDateId], [tShowId])
		SELECT	DISTINCT sd.[Id] AS 'tShowDateId', sd.[tShowId] AS 'tShowId'
		FROM	[#tmpSalePromos] promo, [ShowDate] sd
		WHERE	promo.[tRequiredParentShowDateId] IS NOT NULL 
				AND promo.[tRequiredParentShowDateId] > 0 
				AND promo.[tRequiredParentShowDateId] NOT IN (SELECT [tShowDateId] FROM [#tmpDateIds]) 
				AND promo.[tRequiredParentShowDateId] = sd.[Id]
				
		-- by required ticket
		INSERT	[#tmpDateIds] ([tShowDateId], [tShowId])
		SELECT	DISTINCT st.[tShowDateId] AS 'tShowDateId', st.[tShowId] AS 'tShowId'
		FROM	[#tmpSalePromos] promo, [ShowTicket] st
		WHERE	promo.[tRequiredParentShowTicketId] IS NOT NULL 
				AND promo.[tRequiredParentShowTicketId] > 0 
				AND promo.[tRequiredParentShowTicketId] NOT IN (SELECT [tShowDateId] FROM [#tmpDateIds]) 
				AND promo.[tRequiredParentShowTicketId] = st.[Id]


		/**********************************************************************/
		/*** WE NOW HAVE THE SHOWDATES TO FILL ALL OF THE OTHER TABLES FROM ***/
		/**********************************************************************/


		SELECT	DISTINCT show.* 
		FROM	[Show] show, [#tmpDateIds] dates 
		WHERE	dates.[tShowId] = show.[Id]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('Show')

		SELECT	DISTINCT ven.* 
		FROM	[Venue] ven, 
				[Show] show, 
				[#tmpDateIds] dates 
		WHERE	dates.[tShowId] = show.[Id] 
				AND show.[tVenueId] = ven.[Id]
				
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('Venue')

		SELECT	DISTINCT link.* 
		FROM	[ShowLink] link, [#tmpDateIds] dates 
		WHERE	dates.[tShowId] = link.[tShowId]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('ShowLink')

		SELECT	DISTINCT jp.* 
		FROM	[jShowPromoter] jp, [#tmpDateIds] dates 
		WHERE	dates.[tShowId] = jp.[tShowId]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('jShowPromoter')

		SELECT	DISTINCT promoter.* 
		FROM	[Promoter] promoter, 
				[jShowPromoter] jp, 
				[#tmpDateIds] dates 
		WHERE	dates.[tShowId] = jp.[tShowId] 
				AND jp.[tPromoterId] = promoter.[Id]
				
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('Promoter')

		SELECT	dt.* 
		FROM	[ShowDate] dt, [#tmpDateIds] dates 
		WHERE	dates.[tShowDateId] = dt.[Id] 
		ORDER BY dt.[dtDateOfShow]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('ShowDate')

		--establish which acts are in the scope of the data
		CREATE TABLE #tmpActIds(
			
			jShowActId	INT, 
			Idx			INT
		
		)
		
		INSERT	#tmpActIds(jShowActId, Idx)
		SELECT	DISTINCT ja.[Id] AS 'jShowActId', ja.[tActId] AS 'Idx'
		FROM	[jShowAct] ja, [#tmpDateIds] dates 
		WHERE	dates.[tShowDateId] = ja.[tShowDateId]

		SELECT	DISTINCT ja.* FROM [jShowAct] ja, [#tmpActIds] acts 
		WHERE	ja.[Id] = acts.[jShowActId]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('jShowAct')

		SELECT	DISTINCT act.* 
		FROM	[Act] act, [#tmpActIds] acts 
		WHERE	acts.Idx = act.[Id]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('Act')

		--establish tickets Ids for the show dates
		CREATE TABLE #tmpTickets ( tShowTicketId INT )
		
		
		INSERT	#tmpTickets (tShowTicketId)
		SELECT	DISTINCT ticket.[Id] AS 'tShowTicketId' 
		FROM	[ShowTicket] ticket, [#tmpDateIds] dates 
		WHERE	ticket.[tShowDateId] = dates.[tShowDateId]

		SELECT	DISTINCT ticket.* 
		FROM	[ShowTicket] ticket, [#tmpTickets] tix 
		WHERE	ticket.[Id] = tix.[tShowTicketId]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('ShowTicket')

		SELECT	DISTINCT dos.* 
		FROM	[ShowTicketDosTicket] dos, [#tmpTickets] tix 
		WHERE	dos.[ParentId] = tix.[tShowTicketId]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('ShowTicketDosTicket')

		SELECT	DISTINCT pkg.* 
		FROM	[ShowTicketPackageLink] pkg, [#tmpTickets] tix 
		WHERE	pkg.[ParentShowTicketId] = tix.[tShowTicketId]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('ShowTicketPackageLink')

		SELECT	DISTINCT pp.* 
		FROM	[Required_ShowTicket_PastPurchase] pp, [#tmpTickets] tix 
		WHERE	pp.[tShowTicketId] = tix.[tShowTicketId]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('Required_ShowTicket_PastPurchase')

		-- we dont need all of the ticketinfo from here AS we only be checking if a ticket id is within a list of ids
		SELECT	DISTINCT req.* 
		FROM	[Required] req, 
				[Required_ShowTicket_PastPurchase] pp, 
				[#tmpTickets] tix 
		WHERE	pp.[tShowTicketId] = tix.[tShowTicketId] 
				AND pp.[tRequiredId] = req.[Id]
				
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('Required')

		--note here that lottery requests are not shared info and unnecessary to retrieve here
		SELECT	lot.* 
		FROM	[Lottery] lot, [#tmpTickets] tix 
		WHERE	lot.[tShowTicketId] = tix.[tShowTicketId]
		
		INSERT  #tablesRetrieved (TableName) 
		VALUES	('Lottery')

		-- cleanup
		DROP TABLE [#tmpDateIds]

	END
	/*** END OF SHOW DATE ***/


	--send back list of retrieved table names
	INSERT  #tablesRetrieved (TableName) 
	VALUES	('TableNames')
	
	SELECT  ret.[TableName] 
	FROM	[#tablesRetrieved] ret 
	ORDER BY [idx] ASC

	DROP TABLE [#tablesRetrieved]	

END
GO
