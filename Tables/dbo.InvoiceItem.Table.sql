USE [Sts9Store]
GO
/****** Object:  Table [dbo].[InvoiceItem]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceItem](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Guid] [uniqueidentifier] NOT NULL,
	[TInvoiceId] [int] NOT NULL,
	[vcContext] [varchar](256) NOT NULL,
	[TShowTicketId] [int] NULL,
	[TMerchId] [int] NULL,
	[TShowId] [int] NULL,
	[TShipItemId] [int] NULL,
	[TSalePromotionId] [int] NULL,
	[PurchaseName] [varchar](300) NULL,
	[dtDateOfShow] [datetime] NULL,
	[AgeDescription] [varchar](200) NULL,
	[MainActName] [varchar](305) NULL,
	[Criteria] [varchar](300) NULL,
	[Description] [varchar](300) NULL,
	[mPrice] [money] NOT NULL,
	[mServiceCharge] [money] NOT NULL,
	[mAdjustment] [money] NOT NULL,
	[mPricePerItem]  AS (([mPrice]+[mServiceCharge])+[mAdjustment]),
	[iQuantity] [int] NOT NULL,
	[mLineItemTotal]  AS ((([mPrice]+[mServiceCharge])+[mAdjustment])*[iQuantity]),
	[PurchaseAction] [varchar](50) NOT NULL,
	[Notes] [varchar](1500) NULL,
	[PickupName] [varchar](256) NULL,
	[bRTS] [bit] NULL,
	[dtShipped] [datetime] NULL,
	[ShippingNotes] [varchar](500) NULL,
	[ShippingMethod] [varchar](256) NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_InvoiceItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[InvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItem_Invoice] FOREIGN KEY([TInvoiceId])
REFERENCES [dbo].[Invoice] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceItem] CHECK CONSTRAINT [FK_InvoiceItem_Invoice]
GO
ALTER TABLE [dbo].[InvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItem_Merch] FOREIGN KEY([TMerchId])
REFERENCES [dbo].[Merch] ([Id])
GO
ALTER TABLE [dbo].[InvoiceItem] CHECK CONSTRAINT [FK_InvoiceItem_Merch]
GO
ALTER TABLE [dbo].[InvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItem_SalePromotion] FOREIGN KEY([TSalePromotionId])
REFERENCES [dbo].[SalePromotion] ([Id])
GO
ALTER TABLE [dbo].[InvoiceItem] CHECK CONSTRAINT [FK_InvoiceItem_SalePromotion]
GO
ALTER TABLE [dbo].[InvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItem_ShipItem] FOREIGN KEY([TShipItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
GO
ALTER TABLE [dbo].[InvoiceItem] CHECK CONSTRAINT [FK_InvoiceItem_ShipItem]
GO
ALTER TABLE [dbo].[InvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItem_ShowTicket] FOREIGN KEY([TShowTicketId])
REFERENCES [dbo].[ShowTicket] ([Id])
GO
ALTER TABLE [dbo].[InvoiceItem] CHECK CONSTRAINT [FK_InvoiceItem_ShowTicket]
GO
ALTER TABLE [dbo].[InvoiceItem] ADD  CONSTRAINT [DF_InvoiceItem_Guid_1]  DEFAULT (newid()) FOR [Guid]
GO
ALTER TABLE [dbo].[InvoiceItem] ADD  CONSTRAINT [DF_InvoiceItem_mServiceCharge]  DEFAULT ((0)) FOR [mServiceCharge]
GO
ALTER TABLE [dbo].[InvoiceItem] ADD  CONSTRAINT [DF_InvoiceItem_SandH]  DEFAULT ((0)) FOR [mAdjustment]
GO
ALTER TABLE [dbo].[InvoiceItem] ADD  CONSTRAINT [DF_InvoiceItem_bRTS]  DEFAULT ((0)) FOR [bRTS]
GO
ALTER TABLE [dbo].[InvoiceItem] ADD  CONSTRAINT [DF_InvoiceItem_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
