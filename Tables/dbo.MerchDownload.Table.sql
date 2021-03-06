USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MerchDownload]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MerchDownload](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[TMerchId] [int] NOT NULL,
	[TDownloadId] [int] NOT NULL,
 CONSTRAINT [PK_MerchDownload] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MerchDownload]  WITH CHECK ADD  CONSTRAINT [FK_MerchDownload_Download] FOREIGN KEY([TDownloadId])
REFERENCES [dbo].[Download] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MerchDownload] CHECK CONSTRAINT [FK_MerchDownload_Download]
GO
ALTER TABLE [dbo].[MerchDownload]  WITH CHECK ADD  CONSTRAINT [FK_MerchDownload_Merch] FOREIGN KEY([TMerchId])
REFERENCES [dbo].[Merch] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MerchDownload] CHECK CONSTRAINT [FK_MerchDownload_Merch]
GO
ALTER TABLE [dbo].[MerchDownload] ADD  CONSTRAINT [DF_MerchDownload_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
