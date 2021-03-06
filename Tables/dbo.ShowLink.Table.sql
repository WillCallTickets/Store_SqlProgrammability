USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ShowLink]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShowLink](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[LinkUrl] [varchar](300) NOT NULL,
	[DisplayText] [varchar](200) NOT NULL,
	[TShowId] [int] NOT NULL,
	[bActive] [bit] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_ShowLink] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ShowLink]  WITH NOCHECK ADD  CONSTRAINT [FK_ShowLink_Show] FOREIGN KEY([TShowId])
REFERENCES [dbo].[Show] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ShowLink] CHECK CONSTRAINT [FK_ShowLink_Show]
GO
ALTER TABLE [dbo].[ShowLink] ADD  CONSTRAINT [DF_ShowLink_bActive]  DEFAULT ((0)) FOR [bActive]
GO
ALTER TABLE [dbo].[ShowLink] ADD  CONSTRAINT [DF_ShowLink_iDisplayOrder]  DEFAULT ((0)) FOR [iDisplayOrder]
GO
ALTER TABLE [dbo].[ShowLink] ADD  CONSTRAINT [DF_ShowLink_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
