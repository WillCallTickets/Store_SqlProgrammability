USE [Sts9Store]
GO
/****** Object:  StoredProcedure [dbo].[tx_ChargeStatement_Edit]    Script Date: 10/02/2016 18:14:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Kurtz
-- Create date: 08/02/01
-- Title:		[tx_ChargeStatement_Edit]
-- Description:	Creates a charge statement for the time period indicated. 
/*
	exec tx_ChargeStatement_Edit 'foxtheatre', 1, 2008, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
*/
-- =============================================

CREATE	PROC [dbo].[tx_ChargeStatement_Edit]

	@appName			VARCHAR(256),
	@month				INT,
	@year				INT,
	@perSales			MONEY,
	@perRefund	    	MONEY,
	@grossThreshhold	MONEY,
	@grossPct			MONEY,
	@ticketInvoicePct	MONEY,
	@ticketUnitPct		MONEY,
	@ticketSalesPct		MONEY,
	@merchInvoicePct	MONEY,
	@merchUnitPct		MONEY,
	@merchSalesPct		MONEY,
	@perTktShip 		MONEY,
	@pctTktShipSales	MONEY,
	@perSubscription	MONEY,
	@perMailSent		DECIMAL(18,0),
	@useCurrentValues	BIT

AS

SET NOCOUNT ON

BEGIN

	DECLARE @appId	UNIQUEIDENTIFIER

	--retrieve appId
	SELECT	@appId = a.[ApplicationId] 
	FROM	[Aspnet_Applications] a 
	WHERE	a.[ApplicationName] = @appName

	--SET DATE BOUNDARIES
	DECLARE	@startDate	DATETIME,
			@endDate	DATETIME

	SET	@startDate = CAST(CAST(@month AS VARCHAR(2))+ '/1/' + CAST(@year AS VARCHAR(4)) AS DATETIME)
	SET	@endDate = DATEADD(ss,-1,(DATEADD(mm,1,@startDate)))

	CREATE	TABLE #InvoiceInRange (Idx INT)
	
	--retrieve invoices in question - get counts of refunds, etc later in process
	INSERT	#InvoiceInRange(Idx)
	SELECT	DISTINCT i.[Id] AS 'Idx' 	
	FROM	[Invoice] i
	WHERE	i.[dtInvoiceDate] BETWEEN @startDate AND @endDate 
			AND i.[InvoiceStatus] <> 'NotPaid'

	--TO CREATE OR UPDATE??
	DECLARE	@idx	INT

	IF EXISTS (
		SELECT	* 
		FROM	[Charge_Statement] cs 
		WHERE	cs.[ApplicationId] = @appId 
				AND cs.[iMonth] = @month 
				AND cs.[iYear] = @year
	) 
	BEGIN
		
		SELECT	@idx = cs.[Id] 
		FROM	[Charge_Statement] cs 
		WHERE	cs.[ApplicationId] = @appId 
				AND cs.[iMonth] = @month 
				AND cs.[iYear] = @year

	END
	ELSE 
	BEGIN --if not, do insert
	
		INSERT	Charge_Statement ([ApplicationId], [ChargeStatementId], [iMonth], [iYear])
		VALUES	(@appId, NEWID(), @month, @year)

		SET		@idx = SCOPE_IDENTITY()

	END

	--update invoice amounts and sales counts
	DECLARE	@salesQty			INT,
			@refundQty			INT,
			@gross				MONEY,
			@ticketInvoiceQty	INT,
			@ticketUnitQty		INT,
			@ticketSales		MONEY,
			@merchInvoiceQty	INT,
			@merchUnitQty		INT,
			@merchSales			MONEY,
			@shipUnitQty		INT,
			@shipSales			MONEY,
			@subscriptionsSent	INT,
			@mailSent			INT

	SELECT	@refundQty = COUNT(DISTINCT an.[Id])
	FROM	[#InvoiceInRange] r, [AuthorizeNet] an
	WHERE	r.[Idx] = an.[TInvoiceId] 
			AND an.[dtStamp] BETWEEN @startDate AND @endDate 
			AND an.[TransactionType] <> 'auth_capture' -- void or credit

	--ticket shipping has precedence over merch invoice
	SELECT	@salesQty = COUNT(i.Id), 
			@gross = SUM(i.[mTotalPaid]), 
			@merchInvoiceQty = 1, 
			@shipUnitQty = 1,
			@shipSales = 0
	FROM	[#InvoiceInRange] r, [Invoice] i
	WHERE	r.[Idx] = i.[Id]

	SET		@ticketInvoiceQty = @salesQty - @merchInvoiceQty	

	SELECT	@ticketUnitQty = SUM(ii.[iQuantity]), 
			@ticketSales = SUM(ii.[mLineItemTotal])
	FROM	[#InvoiceInRange] r, [InvoiceItem] ii
	WHERE	r.[Idx] = ii.[TInvoiceId] 
			AND ii.[vcContext] = 'ticket'

	SELECT	@merchUnitQty = SUM(ii.[iQuantity]), 
			@merchSales = SUM(ii.[mLineItemTotal])
	FROM	[#InvoiceInRange] r, [InvoiceItem] ii
	WHERE	r.[Idx] = ii.[TInvoiceId] 
			AND ii.[vcContext] = 'merch'

	--Mail #'s
	SET		@subscriptionsSent = 0

	--amount of mails sent in the time period
	DECLARE	@archiveCount	int,
			@currentCount	int
	SET		@archiveCount = 0
	SET		@currentCount = 0

	--subs first
	SELECT	@archiveCount = COUNT(DISTINCT q.[TSubscriptionEmailId]) 
	FROM	[MailQueueArchive] q 
	WHERE	q.[TSubscriptionEmailId] IS NOT NULL 
			AND q.[DateProcessed] BETWEEN @startDate AND @endDate

	SELECT	@currentCount = COUNT(DISTINCT q.[TSubscriptionEmailId]) 
	FROM	[MailQueue] q 
	WHERE	q.[TSubscriptionEmailId] IS NOT NULL 
			AND q.[DateProcessed] BETWEEN @startDate AND @endDate

	SET		@subscriptionsSent = @archiveCount + @currentCount

	--then mails
	SET		@archiveCount = 0
	SET		@currentCount = 0

	SELECT	@archiveCount = COUNT(q.[Id]) 
	FROM	[MailQueueArchive] q 
	WHERE	q.[Status] = 'Sent' 
			AND q.[DateProcessed] BETWEEN @startDate AND @endDate

	SELECT	@currentCount = COUNT(q.[Id]) 
	FROM	[MailQueue] q 
	WHERE	q.[Status] = 'Sent' 
			AND q.[DateProcessed] BETWEEN @startDate AND @endDate

	SET		@mailSent = @archiveCount + @currentCount

	---update
	UPDATE	Charge_Statement
	SET		[SalesQty]			= ISNULL(@salesQty, 0), 
			[RefundQty]			= ISNULL(@refundQty, 0),  
			[Gross]				= ISNULL(@gross, 0), 
			[TicketInvoiceQty]	= ISNULL(@ticketInvoiceQty, 0), 
			[TicketUnitQty]		= ISNULL(@ticketUnitQty, 0), 
			[TicketSales]		= ISNULL(@ticketSales, 0), 
			[MerchInvoiceQty]	= ISNULL(@merchInvoiceQty, 0), 
			[MerchUnitQty]		= ISNULL(@merchUnitQty, 0), 
			[MerchSales]		= ISNULL(@merchSales, 0), 
			[ShipUnitQty]		= ISNULL(@shipUnitQty, 0), 
			[ShipSales]			= ISNULL(@shipSales, 0),
			[SubscriptionsSent] = ISNULL(@subscriptionsSent, 0),
			[MailSent]			= ISNULL(@mailSent, 0)
	WHERE	[Id] = @idx

	--update rates
	IF(@useCurrentValues = 1) BEGIN

		UPDATE	Charge_Statement
		SET		[SalesQtyPct]		= @perSales, 
				[RefundQtyPct]		= @perRefund, 
				[GrossPct]			= @grossPct, 
				[GrossThreshhold]	= @grossThreshhold, 
				[TicketInvoicePct]	= @ticketInvoicePct, 
				[TicketUnitPct]		= @ticketUnitPct, 
				[TicketSalesPct]	= @ticketSalesPct, 
				[MerchInvoicePct]	= @merchInvoicePct, 
				[MerchUnitPct]		= @merchUnitPct, 
				[MerchSalesPct]		= @merchSalesPct, 
				[ShipUnitPct]		= @perTktShip, 
				[ShipSalesPct]		= @pctTktShipSales,
				[PerSubscription]	= @perSubscription,
				[PerMailSent]		= @perMailSent
		WHERE	[Id] = @idx

	END

	SELECT	*
	FROM	[Charge_Statement] cs
	WHERE	cs.[Id] = @idx

END
GO
