USE [Sts9Store]
GO
/****** Object:  Table [dbo].[InvoiceShipment]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceShipment](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[tInvoiceId] [int] NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[dtCreated] [datetime] NOT NULL,
	[ReferenceNumber] [uniqueidentifier] NOT NULL,
	[vcContext] [varchar](256) NOT NULL,
	[TShipItemId] [int] NULL,
	[bLabelPrinted] [bit] NOT NULL,
	[CompanyName] [varchar](100) NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[Address1] [varchar](60) NOT NULL,
	[Address2] [varchar](60) NULL,
	[City] [varchar](40) NOT NULL,
	[StateProvince] [varchar](40) NOT NULL,
	[PostalCode] [varchar](20) NOT NULL,
	[Country] [varchar](60) NOT NULL,
	[Phone] [varchar](25) NOT NULL,
	[ShipMessage] [varchar](1000) NULL,
	[dtShipped] [datetime] NULL,
	[bRTS] [bit] NULL,
	[Status] [varchar](50) NULL,
	[vcCarrier] [varchar](256) NOT NULL,
	[ShipMethod] [varchar](256) NOT NULL,
	[TrackingInformation] [varchar](500) NULL,
	[PackingList] [varchar](2000) NOT NULL,
	[PackingAdditional] [varchar](500) NULL,
	[mWeightCalculated] [money] NOT NULL,
	[mWeightActual] [money] NOT NULL,
	[mHandlingCalculated] [money] NOT NULL,
	[mShippingCharged] [money] NOT NULL,
	[mShippingActual] [money] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_InvoiceShipment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[InvoiceShipment]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceShipment_Invoice] FOREIGN KEY([tInvoiceId])
REFERENCES [dbo].[Invoice] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceShipment] CHECK CONSTRAINT [FK_InvoiceShipment_Invoice]
GO
ALTER TABLE [dbo].[InvoiceShipment]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceShipment_InvoiceItem] FOREIGN KEY([TShipItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
GO
ALTER TABLE [dbo].[InvoiceShipment] CHECK CONSTRAINT [FK_InvoiceShipment_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_dtCreated]  DEFAULT (getdate()) FOR [dtCreated]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_ReferenceNumber]  DEFAULT (newid()) FOR [ReferenceNumber]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_bLabelPrinted]  DEFAULT ((0)) FOR [bLabelPrinted]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_bRTS]  DEFAULT ((0)) FOR [bRTS]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_PackingList]  DEFAULT ('') FOR [PackingList]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_mWeight]  DEFAULT ((0)) FOR [mWeightCalculated]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_mWeightActual]  DEFAULT ((0)) FOR [mWeightActual]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_mHandlingComputed]  DEFAULT ((0)) FOR [mHandlingCalculated]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_mShippingCharged]  DEFAULT ((0)) FOR [mShippingCharged]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_mActualShipping]  DEFAULT ((0)) FOR [mShippingActual]
GO
ALTER TABLE [dbo].[InvoiceShipment] ADD  CONSTRAINT [DF_InvoiceShipment_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
