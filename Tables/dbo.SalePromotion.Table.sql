USE [Sts9Store]
GO
/****** Object:  Table [dbo].[SalePromotion]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SalePromotion](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[dtStamp] [datetime] NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[bActive] [bit] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[iBannerTimeoutMsecs] [int] NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[DisplayText] [varchar](1000) NULL,
	[AdditionalText] [varchar](500) NULL,
	[tShowTicketId] [int] NULL,
	[RequiredPromotionCode] [varchar](50) NULL,
	[tRequiredParentShowTicketId] [int] NULL,
	[tRequiredParentShowDateId] [int] NULL,
	[iRequiredParentQty] [int] NOT NULL,
	[mPrice] [money] NOT NULL,
	[mDiscountAmount] [money] NOT NULL,
	[iDiscountPercent] [int] NOT NULL,
	[vcDiscountContext] [varchar](256) NULL,
	[mMinMerch] [money] NOT NULL,
	[mMinTicket] [money] NOT NULL,
	[mMinTotal] [money] NOT NULL,
	[BannerUrl] [varchar](256) NULL,
	[BannerClickUrl] [varchar](256) NULL,
	[bDisplayAtParent] [bit] NOT NULL,
	[bBannerMerch] [bit] NOT NULL,
	[bBannerTicket] [bit] NOT NULL,
	[bBannerCartEdit] [bit] NOT NULL,
	[bBannerCheckout] [bit] NOT NULL,
	[bBannerShipping] [bit] NOT NULL,
	[ShipOfferMethod] [varchar](256) NULL,
	[UnlockCode] [varchar](256) NULL,
	[dtStartDate] [datetime] NULL,
	[dtEndDate] [datetime] NULL,
	[iMaxPerOrder] [int] NOT NULL,
	[mMaxValue] [money] NULL,
	[mWeight] [money] NOT NULL,
	[bDeactivateOnNoInventory] [bit] NOT NULL,
	[iMaxUsesPerUser] [int] NOT NULL,
	[vcTriggerList_Merch] [varchar](500) NULL,
	[bAllowMultSelections] [bit] NULL,
	[bAllowPromoTotalInMinimum] [bit] NULL,
	[jsonMeta] [nvarchar](1024) NULL,
 CONSTRAINT [PK_MerchPromotion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'For internal use only' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SalePromotion', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Perhaps we could say some thing here such as: while supplies last - 1 per customer -notvalid with any other offer, etc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SalePromotion', @level2type=N'COLUMN',@level2name=N'AdditionalText'
GO
ALTER TABLE [dbo].[SalePromotion]  WITH CHECK ADD  CONSTRAINT [FK_SalePromotion_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[SalePromotion] CHECK CONSTRAINT [FK_SalePromotion_aspnet_Applications]
GO
ALTER TABLE [dbo].[SalePromotion]  WITH CHECK ADD  CONSTRAINT [FK_SalePromotion_ShowDate] FOREIGN KEY([tRequiredParentShowDateId])
REFERENCES [dbo].[ShowDate] ([Id])
GO
ALTER TABLE [dbo].[SalePromotion] CHECK CONSTRAINT [FK_SalePromotion_ShowDate]
GO
ALTER TABLE [dbo].[SalePromotion]  WITH CHECK ADD  CONSTRAINT [FK_SalePromotion_ShowTicket] FOREIGN KEY([tShowTicketId])
REFERENCES [dbo].[ShowTicket] ([Id])
GO
ALTER TABLE [dbo].[SalePromotion] CHECK CONSTRAINT [FK_SalePromotion_ShowTicket]
GO
ALTER TABLE [dbo].[SalePromotion]  WITH CHECK ADD  CONSTRAINT [FK_SalePromotion_ShowTicket1] FOREIGN KEY([tRequiredParentShowTicketId])
REFERENCES [dbo].[ShowTicket] ([Id])
GO
ALTER TABLE [dbo].[SalePromotion] CHECK CONSTRAINT [FK_SalePromotion_ShowTicket1]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_MerchPromotion_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_iDisplayOrder_1]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_iBannerTimeoutMsecs_1]  DEFAULT ((2400)) FOR [iBannerTimeoutMsecs]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_iRequiredTicketQty]  DEFAULT ((1)) FOR [iRequiredParentQty]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_mPrice]  DEFAULT ((0)) FOR [mPrice]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_mDiscount]  DEFAULT ((0)) FOR [mDiscountAmount]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_mDiscountPercent]  DEFAULT ((0)) FOR [iDiscountPercent]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_Table_1_mMinimumMerchAmount]  DEFAULT ((0)) FOR [mMinMerch]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_Table_1_mMinTicketAmount]  DEFAULT ((0)) FOR [mMinTicket]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_MerchPromotion_mMinTotal]  DEFAULT ((0)) FOR [mMinTotal]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_bDisplayAtParent]  DEFAULT ((0)) FOR [bDisplayAtParent]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_MerchPromotion_bBannerMerch]  DEFAULT ((0)) FOR [bBannerMerch]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_MerchPromotion_bBannerTicket]  DEFAULT ((0)) FOR [bBannerTicket]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_bBannerCartEdit_1]  DEFAULT ((0)) FOR [bBannerCartEdit]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_bBannerCheckout_1]  DEFAULT ((0)) FOR [bBannerCheckout]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_bBannerShipping_1]  DEFAULT ((0)) FOR [bBannerShipping]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_iMaxPerOrder]  DEFAULT ((1)) FOR [iMaxPerOrder]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_mWeight]  DEFAULT ((0)) FOR [mWeight]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_bDeactivateOnNoInventory]  DEFAULT ((1)) FOR [bDeactivateOnNoInventory]
GO
ALTER TABLE [dbo].[SalePromotion] ADD  CONSTRAINT [DF_SalePromotion_iMaxUsesPerUser]  DEFAULT ((0)) FOR [iMaxUsesPerUser]
GO
