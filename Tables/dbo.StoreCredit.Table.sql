USE [Sts9Store]
GO
/****** Object:  Table [dbo].[StoreCredit]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StoreCredit](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[mAmount] [money] NOT NULL,
	[RedemptionId] [uniqueidentifier] NULL,
	[tInvoiceTransactionId] [int] NULL,
	[Comment] [varchar](1000) NULL,
	[UserId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_StoreCredit] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[StoreCredit]  WITH CHECK ADD  CONSTRAINT [FK_StoreCredit_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[StoreCredit] CHECK CONSTRAINT [FK_StoreCredit_aspnet_Applications]
GO
ALTER TABLE [dbo].[StoreCredit]  WITH CHECK ADD  CONSTRAINT [FK_StoreCredit_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[StoreCredit] CHECK CONSTRAINT [FK_StoreCredit_aspnet_Users]
GO
ALTER TABLE [dbo].[StoreCredit]  WITH CHECK ADD  CONSTRAINT [FK_StoreCredit_InvoiceTransaction] FOREIGN KEY([tInvoiceTransactionId])
REFERENCES [dbo].[InvoiceTransaction] ([Id])
GO
ALTER TABLE [dbo].[StoreCredit] CHECK CONSTRAINT [FK_StoreCredit_InvoiceTransaction]
GO
ALTER TABLE [dbo].[StoreCredit] ADD  CONSTRAINT [DF_StoreCredit_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
