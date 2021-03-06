USE [Sts9Store]
GO
/****** Object:  Table [dbo].[HeaderImage]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HeaderImage](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[bActive] [bit] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[bDisplayPriority] [bit] NOT NULL,
	[bExclusive] [bit] NOT NULL,
	[iTimeoutMsec] [int] NOT NULL,
	[FileName] [varchar](256) NOT NULL,
	[DisplayText] [varchar](1000) NULL,
	[NavigateUrl] [varchar](256) NULL,
	[tShowId] [int] NULL,
	[tMerchId] [int] NULL,
	[vcContext] [varchar](500) NULL,
	[UnlockCode] [varchar](256) NULL,
	[dtStart] [datetime] NULL,
	[dtEnd] [datetime] NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[dtModified] [datetime] NOT NULL,
 CONSTRAINT [PK_HeaderImage] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Moves the display order to a higher priority within its selected contexts' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HeaderImage', @level2type=N'COLUMN',@level2name=N'bDisplayPriority'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Specifies if this image shuold override any other images displayed within a context.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HeaderImage', @level2type=N'COLUMN',@level2name=N'bExclusive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This will also be the unique name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HeaderImage', @level2type=N'COLUMN',@level2name=N'FileName'
GO
ALTER TABLE [dbo].[HeaderImage]  WITH CHECK ADD  CONSTRAINT [FK_HeaderImage_Merch] FOREIGN KEY([tMerchId])
REFERENCES [dbo].[Merch] ([Id])
GO
ALTER TABLE [dbo].[HeaderImage] CHECK CONSTRAINT [FK_HeaderImage_Merch]
GO
ALTER TABLE [dbo].[HeaderImage]  WITH CHECK ADD  CONSTRAINT [FK_HeaderImage_Show] FOREIGN KEY([tShowId])
REFERENCES [dbo].[Show] ([Id])
GO
ALTER TABLE [dbo].[HeaderImage] CHECK CONSTRAINT [FK_HeaderImage_Show]
GO
ALTER TABLE [dbo].[HeaderImage] ADD  CONSTRAINT [DF_HeaderImage_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[HeaderImage] ADD  CONSTRAINT [DF_HeaderImage_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
ALTER TABLE [dbo].[HeaderImage] ADD  CONSTRAINT [DF_HeaderImage_bDisplayPriority]  DEFAULT ((0)) FOR [bDisplayPriority]
GO
ALTER TABLE [dbo].[HeaderImage] ADD  CONSTRAINT [DF_HeaderImage_bExclusive]  DEFAULT ((0)) FOR [bExclusive]
GO
ALTER TABLE [dbo].[HeaderImage] ADD  CONSTRAINT [DF_HeaderImage_iTimeoutMsec]  DEFAULT ((2400)) FOR [iTimeoutMsec]
GO
ALTER TABLE [dbo].[HeaderImage] ADD  CONSTRAINT [DF_HeaderImage_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[HeaderImage] ADD  CONSTRAINT [DF_HeaderImage_dtModified]  DEFAULT (getdate()) FOR [dtModified]
GO
