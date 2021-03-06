USE [Sts9Store]
GO
/****** Object:  Table [dbo].[UserCouponRedemption]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserCouponRedemption](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[dtApplied] [datetime] NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[TSalePromotionId] [int] NOT NULL,
	[CouponCode] [varchar](256) NOT NULL,
	[CodeRoot]  AS (case when charindex('-',[CouponCode])=(-1) then [CouponCode] else substring([CouponCode],(1),charindex('-',[CouponCode])-(1)) end),
	[mDiscountAmount] [money] NOT NULL,
	[mInvoiceAmount] [money] NOT NULL,
 CONSTRAINT [PK_UserCouponRedemption] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[UserCouponRedemption]  WITH CHECK ADD  CONSTRAINT [FK_UserCouponRedemption_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[UserCouponRedemption] CHECK CONSTRAINT [FK_UserCouponRedemption_aspnet_Users]
GO
ALTER TABLE [dbo].[UserCouponRedemption]  WITH CHECK ADD  CONSTRAINT [FK_UserCouponRedemption_SalePromotion] FOREIGN KEY([TSalePromotionId])
REFERENCES [dbo].[SalePromotion] ([Id])
GO
ALTER TABLE [dbo].[UserCouponRedemption] CHECK CONSTRAINT [FK_UserCouponRedemption_SalePromotion]
GO
ALTER TABLE [dbo].[UserCouponRedemption] ADD  CONSTRAINT [DF_UserCouponRedemption_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[UserCouponRedemption] ADD  CONSTRAINT [DF_UserCouponRedemption_mDiscountAmount]  DEFAULT ((0)) FOR [mDiscountAmount]
GO
ALTER TABLE [dbo].[UserCouponRedemption] ADD  CONSTRAINT [DF_UserCouponRedemption_mInvoiceAmount]  DEFAULT ((0)) FOR [mInvoiceAmount]
GO
