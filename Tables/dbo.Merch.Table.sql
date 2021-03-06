USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Merch]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Merch](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[Style] [varchar](256) NULL,
	[Color] [varchar](256) NULL,
	[Size] [varchar](256) NULL,
	[tParentListing] [int] NULL,
	[bActive] [bit] NOT NULL,
	[bInternalOnly] [bit] NOT NULL,
	[bTaxable] [bit] NOT NULL,
	[bFeaturedItem] [bit] NOT NULL,
	[ShortText] [varchar](300) NULL,
	[vcDisplayTemplate] [varchar](50) NULL,
	[Description] [varchar](max) NULL,
	[bUnlockActive] [bit] NOT NULL,
	[UnlockCode] [varchar](256) NULL,
	[dtUnlockDate] [datetime] NULL,
	[dtUnlockEndDate] [datetime] NULL,
	[dtStartDate] [datetime] NULL,
	[dtEndDate] [datetime] NULL,
	[mPrice] [money] NULL,
	[bUseSalePrice] [bit] NULL,
	[mSalePrice] [money] NULL,
	[vcDeliveryType] [varchar](50) NULL,
	[bLowRateQualified] [bit] NULL,
	[mWeight] [money] NULL,
	[mFlatShip] [money] NULL,
	[vcFlatMethod] [varchar](256) NULL,
	[dtBackorder] [datetime] NULL,
	[bShipSeparate] [bit] NULL,
	[bSoldOut] [bit] NULL,
	[iMaxQtyPerOrder] [int] NOT NULL,
	[iAllotment] [int] NOT NULL,
	[iDamaged] [int] NOT NULL,
	[iPending] [int] NOT NULL,
	[iSold] [int] NOT NULL,
	[iAvailable]  AS ((([iAllotment]-[iDamaged])-[iPending])-[iSold]),
	[iRefunded] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_MerchListing] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Simply a placeholder to denote how many have been refunded. Does not affect inventory. When items are refunded, they are taken out of sold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Merch', @level2type=N'COLUMN',@level2name=N'iRefunded'
GO
ALTER TABLE [dbo].[Merch]  WITH CHECK ADD  CONSTRAINT [FK_Merch_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[Merch] CHECK CONSTRAINT [FK_Merch_Aspnet_Applications]
GO
ALTER TABLE [dbo].[Merch]  WITH NOCHECK ADD  CONSTRAINT [FK_MerchListing_MerchListing] FOREIGN KEY([tParentListing])
REFERENCES [dbo].[Merch] ([Id])
GO
ALTER TABLE [dbo].[Merch] CHECK CONSTRAINT [FK_MerchListing_MerchListing]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_bInternalOnly]  DEFAULT ((0)) FOR [bInternalOnly]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_bTaxable]  DEFAULT ((0)) FOR [bTaxable]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_MerchListing_bFeaturedItem]  DEFAULT ((0)) FOR [bFeaturedItem]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_bUnlockActive]  DEFAULT ((0)) FOR [bUnlockActive]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_bUseSalePrice]  DEFAULT ((0)) FOR [bUseSalePrice]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_mSalePrice]  DEFAULT ((0)) FOR [mSalePrice]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_bShipSeparate]  DEFAULT ((0)) FOR [bShipSeparate]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_bSoldOut]  DEFAULT ((0)) FOR [bSoldOut]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_iMaxQtyPerOrder]  DEFAULT ((8)) FOR [iMaxQtyPerOrder]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_iAllotment]  DEFAULT ((0)) FOR [iAllotment]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_iDamaged]  DEFAULT ((0)) FOR [iDamaged]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_iPending]  DEFAULT ((0)) FOR [iPending]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_iSold]  DEFAULT ((0)) FOR [iSold]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_Merch_iRefunded]  DEFAULT ((0)) FOR [iRefunded]
GO
ALTER TABLE [dbo].[Merch] ADD  CONSTRAINT [DF_MerchListing_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
