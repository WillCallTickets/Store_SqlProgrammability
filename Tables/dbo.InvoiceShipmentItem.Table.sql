USE [Sts9Store]
GO
/****** Object:  Table [dbo].[InvoiceShipmentItem]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceShipmentItem](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[dtStamp] [datetime] NULL,
	[tInvoiceShipmentId] [int] NOT NULL,
	[tInvoiceItemId] [int] NOT NULL,
	[iQuantity] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceShipmentItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvoiceShipmentItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceShipmentItem_InvoiceItem] FOREIGN KEY([tInvoiceItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
GO
ALTER TABLE [dbo].[InvoiceShipmentItem] CHECK CONSTRAINT [FK_InvoiceShipmentItem_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceShipmentItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceShipmentItem_InvoiceShipment] FOREIGN KEY([tInvoiceShipmentId])
REFERENCES [dbo].[InvoiceShipment] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceShipmentItem] CHECK CONSTRAINT [FK_InvoiceShipmentItem_InvoiceShipment]
GO
ALTER TABLE [dbo].[InvoiceShipmentItem] ADD  CONSTRAINT [DF_InvoiceShipmentItem_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
