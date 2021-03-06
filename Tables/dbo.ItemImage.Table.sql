USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ItemImage]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ItemImage](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[TMerchId] [int] NULL,
	[TFutureId] [int] NULL,
	[bItemImage] [bit] NULL,
	[bDetailImage] [bit] NULL,
	[bOverrideThumbnail] [bit] NULL,
	[DetailDescription] [varchar](2000) NULL,
	[StorageRemote] [varchar](256) NULL,
	[Path] [varchar](256) NOT NULL,
	[ImageName] [varchar](256) NOT NULL,
	[ImageHeight] [int] NOT NULL,
	[ImageWidth] [int] NOT NULL,
	[ThumbClass] [varchar](256) NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_ItemImage] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The path to the directory that stores the base image. The object will set the virtual path' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemImage', @level2type=N'COLUMN',@level2name=N'Path'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The name of the image   xxx.jpg, xxx.gif' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemImage', @level2type=N'COLUMN',@level2name=N'ImageName'
GO
ALTER TABLE [dbo].[ItemImage]  WITH CHECK ADD  CONSTRAINT [FK_ItemImage_Merch] FOREIGN KEY([TMerchId])
REFERENCES [dbo].[Merch] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ItemImage] CHECK CONSTRAINT [FK_ItemImage_Merch]
GO
ALTER TABLE [dbo].[ItemImage] ADD  CONSTRAINT [DF_ItemImage_bItemImage]  DEFAULT ((1)) FOR [bItemImage]
GO
ALTER TABLE [dbo].[ItemImage] ADD  CONSTRAINT [DF_ItemImage_bDetailImage]  DEFAULT ((0)) FOR [bDetailImage]
GO
ALTER TABLE [dbo].[ItemImage] ADD  CONSTRAINT [DF_ItemImage_bDoNotThumbnail]  DEFAULT ((0)) FOR [bOverrideThumbnail]
GO
ALTER TABLE [dbo].[ItemImage] ADD  CONSTRAINT [DF_ItemImage_ThumbClass]  DEFAULT ('') FOR [ThumbClass]
GO
ALTER TABLE [dbo].[ItemImage] ADD  CONSTRAINT [DF_ItemImage_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
