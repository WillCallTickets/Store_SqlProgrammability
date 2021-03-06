USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Show]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Show](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](300) NOT NULL,
	[dtAnnounceDate] [datetime] NULL,
	[dtDateOnSale] [datetime] NULL,
	[bActive] [bit] NOT NULL,
	[bSoldOut] [bit] NOT NULL,
	[StatusText] [varchar](500) NULL,
	[VenuePreText] [varchar](256) NULL,
	[TVenueId] [int] NOT NULL,
	[VenuePostText] [varchar](256) NULL,
	[DisplayNotes] [varchar](1000) NULL,
	[InternalNotes] [varchar](500) NULL,
	[ShowTitle] [varchar](300) NULL,
	[DisplayUrl] [varchar](300) NULL,
	[iPicWidth] [int] NOT NULL,
	[iPicHeight] [int] NOT NULL,
	[TopText] [varchar](300) NULL,
	[MidText] [varchar](300) NULL,
	[bDisplayRichText] [bit] NOT NULL,
	[bHideAutoGenerated] [bit] NOT NULL,
	[BotText] [varchar](max) NULL,
	[bOverrideActBilling] [bit] NOT NULL,
	[ActBilling] [varchar](max) NULL,
	[bAllowFacebookLike] [bit] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[ExternalTixUrl] [varchar](500) NULL,
 CONSTRAINT [PK_Show] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Show]  WITH CHECK ADD  CONSTRAINT [FK_Show_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[Show] CHECK CONSTRAINT [FK_Show_Aspnet_Applications]
GO
ALTER TABLE [dbo].[Show]  WITH NOCHECK ADD  CONSTRAINT [FK_Show_Venue] FOREIGN KEY([TVenueId])
REFERENCES [dbo].[Venue] ([Id])
GO
ALTER TABLE [dbo].[Show] CHECK CONSTRAINT [FK_Show_Venue]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_bSoldOut]  DEFAULT ((0)) FOR [bSoldOut]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_TVenueId]  DEFAULT ((10000)) FOR [TVenueId]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_PicWidth_1]  DEFAULT ((0)) FOR [iPicWidth]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_PicHeight_1]  DEFAULT ((0)) FOR [iPicHeight]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_bDisplayRichText]  DEFAULT ((0)) FOR [bDisplayRichText]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_bHideAutoGenerated]  DEFAULT ((0)) FOR [bHideAutoGenerated]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_bOverrideActBilling_1]  DEFAULT ((0)) FOR [bOverrideActBilling]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_bAllowFacebookLike]  DEFAULT ((1)) FOR [bAllowFacebookLike]
GO
ALTER TABLE [dbo].[Show] ADD  CONSTRAINT [DF_Show_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
