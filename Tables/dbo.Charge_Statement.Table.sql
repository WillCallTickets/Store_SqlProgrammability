USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Charge_Statement]    Script Date: 10/02/2016 18:17:19 ******/
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [dbo].[Charge_Statement](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[ChargeStatementId] [uniqueidentifier] NOT NULL,
	[iMonth] [int] NOT NULL,
	[iYear] [int] NOT NULL,
	[MonthYear]  AS ((CONVERT([varchar](2),[iMonth],(0))+'/')+CONVERT([varchar](4),[iYear],(0))),
	[SalesQty] [int] NOT NULL,
	[SalesQtyPct] [money] NOT NULL,
	[SalesQtyPortion]  AS ([SalesQty]*[SalesQtyPct]),
	[RefundQty] [int] NOT NULL,
	[RefundQtyPct] [money] NOT NULL,
	[RefundQtyPortion]  AS ([RefundQty]*[RefundQtyPct]),
	[Gross] [money] NOT NULL,
	[GrossPct] [money] NOT NULL,
	[GrossThreshhold] [money] NOT NULL,
	[GrossPortion]  AS (case when [Gross]>=[GrossThreshhold] then [Gross]*[GrossPct] else (0) end),
	[TicketInvoiceQty] [int] NOT NULL,
	[TicketInvoicePct] [money] NOT NULL,
	[TicketUnitQty] [int] NOT NULL,
	[TicketUnitPct] [money] NOT NULL,
	[TicketSales] [money] NOT NULL,
	[TicketSalesPct] [money] NOT NULL,
	[TicketPortion]  AS (([TicketInvoiceQty]*[TicketInvoicePct]+[TicketUnitQty]*[TicketUnitPct])+[TicketSales]*[TicketSalesPct]),
	[MerchInvoiceQty] [int] NOT NULL,
	[MerchInvoicePct] [money] NOT NULL,
	[MerchUnitQty] [int] NOT NULL,
	[MerchUnitPct] [money] NOT NULL,
	[MerchSales] [money] NOT NULL,
	[MerchSalesPct] [money] NOT NULL,
	[MerchPortion]  AS (([MerchInvoiceQty]*[MerchInvoicePct]+[MerchUnitQty]*[MerchUnitPct])+[MerchSales]*[MerchSalesPct]),
	[ShipUnitQty] [int] NOT NULL,
	[ShipUnitPct] [money] NOT NULL,
	[ShipSales] [money] NOT NULL,
	[ShipSalesPct] [money] NOT NULL,
	[ShipPortion]  AS ([ShipUnitQty]*[ShipUnitPct]+[ShipSales]*[ShipSalesPct]),
	[SubscriptionsSent] [int] NOT NULL,
	[PerSubscription] [money] NOT NULL,
	[MailSent] [int] NOT NULL,
	[PerMailSent] [decimal](18, 0) NOT NULL,
	[MailerPortion]  AS ([SubscriptionsSent]*[PerSubscription]+[MailSent]*[PerMailSent]),
	[HourlyPortion] [money] NOT NULL,
	[Discount] [money] NOT NULL,
	[LineTotal]  AS (((((((([SalesQty]*[SalesQtyPct]+[RefundQty]*[RefundQtyPct])+case when [Gross]>=[GrossThreshhold] then [Gross]*[GrossPct] else (0) end)+(([TicketInvoiceQty]*[TicketInvoicePct]+[TicketUnitQty]*[TicketUnitPct])+[TicketSales]*[TicketSalesPct]))+(([MerchInvoiceQty]*[MerchInvoicePct]+[MerchUnitQty]*[MerchUnitPct])+[MerchSales]*[MerchSalesPct]))+([ShipUnitQty]*[ShipUnitPct]+[ShipSales]*[ShipSalesPct]))+([SubscriptionsSent]*[PerSubscription]+[MailSent]*[PerMailSent]))+[HourlyPortion])-[Discount]),
	[AmountPaid] [money] NOT NULL,
	[dtPaid] [datetime] NULL,
	[CheckNumber] [varchar](50) NULL,
	[PayNotes] [varchar](2000) NULL,
 CONSTRAINT [PK_Payout] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Charge_Statement]  WITH CHECK ADD  CONSTRAINT [FK_Charge_Statement_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[Charge_Statement] CHECK CONSTRAINT [FK_Charge_Statement_aspnet_Applications]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_PayoutId]  DEFAULT (newid()) FOR [ChargeStatementId]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_Sales]  DEFAULT ((0)) FOR [SalesQty]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_SalesPct]  DEFAULT ((0)) FOR [SalesQtyPct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_RefundQty]  DEFAULT ((0)) FOR [RefundQty]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_RefundPct]  DEFAULT ((0)) FOR [RefundQtyPct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_Sales12]  DEFAULT ((0)) FOR [Gross]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_GrossPct]  DEFAULT ((0)) FOR [GrossPct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Charge_Statement_GrossThreshhold]  DEFAULT ((0)) FOR [GrossThreshhold]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_Sales10]  DEFAULT ((0)) FOR [TicketInvoiceQty]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_TicketPct]  DEFAULT ((0)) FOR [TicketInvoicePct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_Sales4]  DEFAULT ((0)) FOR [TicketUnitQty]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_TicketUnitPct]  DEFAULT ((0)) FOR [TicketUnitPct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_TicketSales]  DEFAULT ((0)) FOR [TicketSales]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_TicketSalesPct]  DEFAULT ((0)) FOR [TicketSalesPct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_TicketInvoiceQty1]  DEFAULT ((0)) FOR [MerchInvoiceQty]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_TicketInvoicePct1]  DEFAULT ((0)) FOR [MerchInvoicePct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_TicketUnitQty1]  DEFAULT ((0)) FOR [MerchUnitQty]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_TicketUnitPct1]  DEFAULT ((0)) FOR [MerchUnitPct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_MerchSales]  DEFAULT ((0)) FOR [MerchSales]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_MerchSalesPct]  DEFAULT ((0)) FOR [MerchSalesPct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_MerchUnitQty1]  DEFAULT ((0)) FOR [ShipUnitQty]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_MerchUnitPct1]  DEFAULT ((0)) FOR [ShipUnitPct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_MerchSales1]  DEFAULT ((0)) FOR [ShipSales]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Table_1_MerchSalesPct1]  DEFAULT ((0)) FOR [ShipSalesPct]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Charge_Statement_SubscriptionsSent]  DEFAULT ((0)) FOR [SubscriptionsSent]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Charge_Statement_PerSubscription]  DEFAULT ((0)) FOR [PerSubscription]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Charge_Statement_MailSent]  DEFAULT ((0)) FOR [MailSent]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Charge_Statement_PerMail]  DEFAULT ((0)) FOR [PerMailSent]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_HoursIncurred]  DEFAULT ((0)) FOR [HourlyPortion]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Charge_Statement_Discount]  DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE [dbo].[Charge_Statement] ADD  CONSTRAINT [DF_Payout_AmountPaid]  DEFAULT ((0)) FOR [AmountPaid]
GO
