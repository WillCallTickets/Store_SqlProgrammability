USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MerchJoinCat]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MerchJoinCat](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[tMerchId] [int] NOT NULL,
	[tMerchCategorieId] [int] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_MerchandiseCat] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MerchJoinCat]  WITH NOCHECK ADD  CONSTRAINT [FK_MerchJoinCat_Merch] FOREIGN KEY([tMerchId])
REFERENCES [dbo].[Merch] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MerchJoinCat] CHECK CONSTRAINT [FK_MerchJoinCat_Merch]
GO
ALTER TABLE [dbo].[MerchJoinCat]  WITH CHECK ADD  CONSTRAINT [FK_MerchJoinCat_MerchCategorie] FOREIGN KEY([tMerchCategorieId])
REFERENCES [dbo].[MerchCategorie] ([Id])
GO
ALTER TABLE [dbo].[MerchJoinCat] CHECK CONSTRAINT [FK_MerchJoinCat_MerchCategorie]
GO
ALTER TABLE [dbo].[MerchJoinCat] ADD  CONSTRAINT [DF_MerchJoinCat_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
ALTER TABLE [dbo].[MerchJoinCat] ADD  CONSTRAINT [DF_MerchandiseCat_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
