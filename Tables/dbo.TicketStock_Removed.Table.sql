USE [Sts9Store]
GO
/****** Object:  Table [dbo].[TicketStock_Removed]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TicketStock_Removed](
	[Id] [int] NOT NULL,
	[GUID] [uniqueidentifier] NOT NULL,
	[SessionId] [varchar](256) NOT NULL,
	[TInvoiceId] [int] NULL,
	[UserName] [varchar](256) NOT NULL,
	[tShowTicketId] [int] NOT NULL,
	[iQty] [int] NOT NULL,
	[dtTTL] [datetime] NOT NULL,
	[dtRemoved] [datetime] NOT NULL,
	[ProcName] [varchar](100) NOT NULL,
	[dtStamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[TicketStock_Removed] ADD  CONSTRAINT [DF_TicketStock_Removed_SessionId]  DEFAULT ('null') FOR [SessionId]
GO
ALTER TABLE [dbo].[TicketStock_Removed] ADD  CONSTRAINT [DF_TicketStock_Removed_UserName]  DEFAULT ('') FOR [UserName]
GO
