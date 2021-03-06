USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ShowTicketDosTicket]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShowTicketDosTicket](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ParentId] [int] NOT NULL,
	[DosId] [int] NOT NULL,
 CONSTRAINT [PK_ShowTicketDosTicket] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShowTicketDosTicket]  WITH CHECK ADD  CONSTRAINT [FK_ShowTicketDosTicket_ShowTicket] FOREIGN KEY([ParentId])
REFERENCES [dbo].[ShowTicket] ([Id])
GO
ALTER TABLE [dbo].[ShowTicketDosTicket] CHECK CONSTRAINT [FK_ShowTicketDosTicket_ShowTicket]
GO
ALTER TABLE [dbo].[ShowTicketDosTicket]  WITH CHECK ADD  CONSTRAINT [FK_ShowTicketDosTicket_ShowTicket1] FOREIGN KEY([DosId])
REFERENCES [dbo].[ShowTicket] ([Id])
GO
ALTER TABLE [dbo].[ShowTicketDosTicket] CHECK CONSTRAINT [FK_ShowTicketDosTicket_ShowTicket1]
GO
ALTER TABLE [dbo].[ShowTicketDosTicket] ADD  CONSTRAINT [DF_ShowTicketDosTicket_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
