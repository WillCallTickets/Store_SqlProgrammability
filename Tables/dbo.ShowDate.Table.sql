USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ShowDate]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShowDate](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[dtDateOfShow] [datetime] NOT NULL,
	[ShowTime] [varchar](50) NULL,
	[bLateNightShow] [bit] NOT NULL,
	[TShowId] [int] NOT NULL,
	[bActive] [bit] NOT NULL,
	[ShowDateTitle] [varchar](500) NULL,
	[StatusText] [varchar](500) NULL,
	[PricingText] [varchar](500) NULL,
	[TicketUrl] [varchar](500) NULL,
	[DisplayNotes] [varchar](1000) NULL,
	[TAgeId] [int] NOT NULL,
	[TStatusId] [int] NOT NULL,
	[Billing] [varchar](300) NULL,
	[bAutoBilling] [bit] NOT NULL,
	[bPrivateShow] [bit] NOT NULL,
	[bUseFbRsvp] [bit] NOT NULL,
	[FbRsvpUrl] [varchar](256) NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_ShowDateTime] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ShowDate]  WITH CHECK ADD  CONSTRAINT [FK_ShowDate_Age] FOREIGN KEY([TAgeId])
REFERENCES [dbo].[Age] ([Id])
GO
ALTER TABLE [dbo].[ShowDate] CHECK CONSTRAINT [FK_ShowDate_Age]
GO
ALTER TABLE [dbo].[ShowDate]  WITH NOCHECK ADD  CONSTRAINT [FK_ShowDate_Show] FOREIGN KEY([TShowId])
REFERENCES [dbo].[Show] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ShowDate] CHECK CONSTRAINT [FK_ShowDate_Show]
GO
ALTER TABLE [dbo].[ShowDate]  WITH NOCHECK ADD  CONSTRAINT [FK_ShowDate_ShowStatus] FOREIGN KEY([TStatusId])
REFERENCES [dbo].[ShowStatus] ([Id])
GO
ALTER TABLE [dbo].[ShowDate] CHECK CONSTRAINT [FK_ShowDate_ShowStatus]
GO
ALTER TABLE [dbo].[ShowDate] ADD  CONSTRAINT [DF_ShowDate_bLateNightShow]  DEFAULT ((0)) FOR [bLateNightShow]
GO
ALTER TABLE [dbo].[ShowDate] ADD  CONSTRAINT [DF_ShowDate_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[ShowDate] ADD  CONSTRAINT [DF_ShowDate_TAgesId]  DEFAULT ((10000)) FOR [TAgeId]
GO
ALTER TABLE [dbo].[ShowDate] ADD  CONSTRAINT [DF_ShowDate_TStatusId]  DEFAULT ((10000)) FOR [TStatusId]
GO
ALTER TABLE [dbo].[ShowDate] ADD  CONSTRAINT [DF_ShowDate_bAutoBilling_1]  DEFAULT ((1)) FOR [bAutoBilling]
GO
ALTER TABLE [dbo].[ShowDate] ADD  CONSTRAINT [DF_ShowDate_bPrivateShow]  DEFAULT ((0)) FOR [bPrivateShow]
GO
ALTER TABLE [dbo].[ShowDate] ADD  CONSTRAINT [DF_ShowDate_bUseFbRsvp]  DEFAULT ((1)) FOR [bUseFbRsvp]
GO
ALTER TABLE [dbo].[ShowDate] ADD  CONSTRAINT [DF_ShowDateTime_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
