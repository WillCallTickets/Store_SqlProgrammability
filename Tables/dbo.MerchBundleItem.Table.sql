USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MerchBundleItem]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MerchBundleItem](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[bActive] [bit] NOT NULL,
	[TMerchBundleId] [int] NOT NULL,
	[TMerchId] [int] NULL,
	[iDisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_MerchPackageItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MerchBundleItem]  WITH CHECK ADD  CONSTRAINT [FK_MerchBundleItem_Merch] FOREIGN KEY([TMerchId])
REFERENCES [dbo].[Merch] ([Id])
GO
ALTER TABLE [dbo].[MerchBundleItem] CHECK CONSTRAINT [FK_MerchBundleItem_Merch]
GO
ALTER TABLE [dbo].[MerchBundleItem]  WITH CHECK ADD  CONSTRAINT [FK_MerchBundleItem_MerchBundle] FOREIGN KEY([TMerchBundleId])
REFERENCES [dbo].[MerchBundle] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MerchBundleItem] CHECK CONSTRAINT [FK_MerchBundleItem_MerchBundle]
GO
ALTER TABLE [dbo].[MerchBundleItem] ADD  CONSTRAINT [DF_MerchPackageItem_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[MerchBundleItem] ADD  CONSTRAINT [DF_MerchPackageItem_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[MerchBundleItem] ADD  CONSTRAINT [DF_MerchPackageItem_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
