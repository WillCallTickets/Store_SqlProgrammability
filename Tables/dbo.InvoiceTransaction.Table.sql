USE [Sts9Store]
GO
/****** Object:  Table [dbo].[InvoiceTransaction]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceTransaction](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[ProcessorId] [varchar](50) NOT NULL,
	[TInvoiceId] [int] NOT NULL,
	[PerformedBy] [varchar](20) NOT NULL,
	[Admin] [varchar](50) NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[CustomerId] [int] NULL,
	[TInvoiceItemId] [int] NULL,
	[TransType] [varchar](50) NOT NULL,
	[FundsType] [varchar](50) NOT NULL,
	[FundsProcessor] [varchar](50) NOT NULL,
	[BatchId] [varchar](50) NULL,
	[mAmount] [money] NOT NULL,
	[NameOnCard] [varchar](50) NULL,
	[LastFourDigits] [varchar](4) NULL,
	[UserIp] [varchar](50) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_InvoiceTransaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[InvoiceTransaction]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceTransaction_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[InvoiceTransaction] CHECK CONSTRAINT [FK_InvoiceTransaction_aspnet_Users]
GO
ALTER TABLE [dbo].[InvoiceTransaction]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceTransaction_Invoice] FOREIGN KEY([TInvoiceId])
REFERENCES [dbo].[Invoice] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceTransaction] CHECK CONSTRAINT [FK_InvoiceTransaction_Invoice]
GO
ALTER TABLE [dbo].[InvoiceTransaction] ADD  CONSTRAINT [DF_InvoiceTransaction_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
