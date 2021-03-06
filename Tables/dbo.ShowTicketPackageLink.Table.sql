USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ShowTicketPackageLink]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShowTicketPackageLink](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[GroupIdentifier] [uniqueidentifier] NULL,
	[ParentShowTicketId] [int] NOT NULL,
	[LinkedShowTicketId] [int] NOT NULL,
	[dtStamp] [datetime] NULL,
 CONSTRAINT [PK_ShowTicketPackageLink] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShowTicketPackageLink]  WITH CHECK ADD  CONSTRAINT [FK_ShowTicketPackageLink_ShowTicket2] FOREIGN KEY([ParentShowTicketId])
REFERENCES [dbo].[ShowTicket] ([Id])
GO
ALTER TABLE [dbo].[ShowTicketPackageLink] CHECK CONSTRAINT [FK_ShowTicketPackageLink_ShowTicket2]
GO
ALTER TABLE [dbo].[ShowTicketPackageLink]  WITH CHECK ADD  CONSTRAINT [FK_ShowTicketPackageLink_ShowTicket3] FOREIGN KEY([LinkedShowTicketId])
REFERENCES [dbo].[ShowTicket] ([Id])
GO
ALTER TABLE [dbo].[ShowTicketPackageLink] CHECK CONSTRAINT [FK_ShowTicketPackageLink_ShowTicket3]
GO
ALTER TABLE [dbo].[ShowTicketPackageLink] ADD  CONSTRAINT [DF_ShowTicketPackageLink_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
