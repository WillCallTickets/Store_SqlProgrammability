USE [Sts9Store]
GO
/****** Object:  Table [dbo].[SalePromotionAward]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalePromotionAward](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[bActive] [bit] NOT NULL,
	[TSalePromotionId] [int] NOT NULL,
	[TParentMerchId] [int] NULL,
 CONSTRAINT [PK_SalePromoAwardItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SalePromotionAward]  WITH CHECK ADD  CONSTRAINT [FK_SalePromotionAward_Merch] FOREIGN KEY([TParentMerchId])
REFERENCES [dbo].[Merch] ([Id])
GO
ALTER TABLE [dbo].[SalePromotionAward] CHECK CONSTRAINT [FK_SalePromotionAward_Merch]
GO
ALTER TABLE [dbo].[SalePromotionAward]  WITH CHECK ADD  CONSTRAINT [FK_SalePromotionAward_SalePromotion] FOREIGN KEY([TSalePromotionId])
REFERENCES [dbo].[SalePromotion] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SalePromotionAward] CHECK CONSTRAINT [FK_SalePromotionAward_SalePromotion]
GO
ALTER TABLE [dbo].[SalePromotionAward] ADD  CONSTRAINT [DF_SalePromoAwardItem_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[SalePromotionAward] ADD  CONSTRAINT [DF_SalePromoAwardItem_bActive]  DEFAULT ((1)) FOR [bActive]
GO
