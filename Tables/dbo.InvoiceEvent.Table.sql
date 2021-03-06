USE [Sts9Store]
GO
/****** Object:  Table [dbo].[InvoiceEvent]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceEvent](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[TInvoiceId] [int] NOT NULL,
	[TEventQId] [int] NOT NULL,
	[dtStamp] [datetime] NULL,
 CONSTRAINT [PK_InvoiceEvent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvoiceEvent]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceEvent_Invoice] FOREIGN KEY([TInvoiceId])
REFERENCES [dbo].[Invoice] ([Id])
GO
ALTER TABLE [dbo].[InvoiceEvent] CHECK CONSTRAINT [FK_InvoiceEvent_Invoice]
GO
ALTER TABLE [dbo].[InvoiceEvent] ADD  CONSTRAINT [DF_InvoiceEvent_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
