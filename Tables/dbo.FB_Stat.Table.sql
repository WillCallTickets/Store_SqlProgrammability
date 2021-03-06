USE [Sts9Store]
GO
/****** Object:  Table [dbo].[FB_Stat]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FB_Stat](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[EntityId] [int] NULL,
	[Url] [varchar](500) NOT NULL,
	[ApiFunction] [varchar](50) NOT NULL,
	[Total] [int] NOT NULL,
	[dtModified] [datetime] NOT NULL,
 CONSTRAINT [PK_FB_Stat] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FB_Stat]  WITH CHECK ADD  CONSTRAINT [FK_FB_Stat_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FB_Stat] CHECK CONSTRAINT [FK_FB_Stat_aspnet_Applications]
GO
ALTER TABLE [dbo].[FB_Stat] ADD  CONSTRAINT [DF_FB_Stat_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[FB_Stat] ADD  CONSTRAINT [DF_FB_Stat_Total]  DEFAULT ((0)) FOR [Total]
GO
ALTER TABLE [dbo].[FB_Stat] ADD  CONSTRAINT [DF_FB_Stat_dtModified]  DEFAULT (getdate()) FOR [dtModified]
GO
