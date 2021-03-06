USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Invoice]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Invoice](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[UniqueId] [varchar](20) NOT NULL,
	[TVendorId] [int] NOT NULL,
	[PurchaseEmail] [varchar](256) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[CustomerId] [int] NOT NULL,
	[dtInvoiceDate] [datetime] NOT NULL,
	[Creator] [varchar](50) NULL,
	[OrderType] [varchar](50) NOT NULL,
	[vcProducts] [varchar](1500) NULL,
	[mBalanceDue] [money] NOT NULL,
	[mTotalPaid] [money] NOT NULL,
	[mTotalRefunds] [money] NOT NULL,
	[mNetPaid]  AS ([mTotalPaid]-[mTotalRefunds]),
	[InvoiceStatus] [varchar](50) NOT NULL,
	[TCashewId] [int] NULL,
	[MarketingKeys] [varchar](100) NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_Aspnet_Applications]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_aspnet_Users1] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_aspnet_Users1]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Cashew] FOREIGN KEY([TCashewId])
REFERENCES [dbo].[Cashew] ([Id])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_Cashew]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_Vendor] FOREIGN KEY([TVendorId])
REFERENCES [dbo].[Vendor] ([Id])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK_Invoice_Vendor]
GO
ALTER TABLE [dbo].[Invoice] ADD  CONSTRAINT [DF_Invoice_BalanceDue]  DEFAULT ((0)) FOR [mBalanceDue]
GO
ALTER TABLE [dbo].[Invoice] ADD  CONSTRAINT [DF_Invoice_TotalPaid]  DEFAULT ((0)) FOR [mTotalPaid]
GO
ALTER TABLE [dbo].[Invoice] ADD  CONSTRAINT [DF_Invoice_TotalRefunds]  DEFAULT ((0)) FOR [mTotalRefunds]
GO
ALTER TABLE [dbo].[Invoice] ADD  CONSTRAINT [DF_Invoice_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
