USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ShipmentBatch_InvoiceShipment]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShipmentBatch_InvoiceShipment](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtstamp] [datetime] NOT NULL,
	[tShipmentBatchId] [int] NOT NULL,
	[tInvoiceShipmentId] [int] NOT NULL,
 CONSTRAINT [PK_ShipmentBatch_InvoiceShipment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShipmentBatch_InvoiceShipment]  WITH CHECK ADD  CONSTRAINT [FK_ShipmentBatch_InvoiceShipment_InvoiceShipment] FOREIGN KEY([tInvoiceShipmentId])
REFERENCES [dbo].[InvoiceShipment] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ShipmentBatch_InvoiceShipment] CHECK CONSTRAINT [FK_ShipmentBatch_InvoiceShipment_InvoiceShipment]
GO
ALTER TABLE [dbo].[ShipmentBatch_InvoiceShipment]  WITH CHECK ADD  CONSTRAINT [FK_ShipmentBatch_InvoiceShipment_ShipmentBatch] FOREIGN KEY([tShipmentBatchId])
REFERENCES [dbo].[ShipmentBatch] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ShipmentBatch_InvoiceShipment] CHECK CONSTRAINT [FK_ShipmentBatch_InvoiceShipment_ShipmentBatch]
GO
ALTER TABLE [dbo].[ShipmentBatch_InvoiceShipment] ADD  CONSTRAINT [DF_ShipmentBatch_InvoiceShipment_dtstamp]  DEFAULT (getdate()) FOR [dtstamp]
GO
