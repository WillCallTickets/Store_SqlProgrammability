USE [Sts9Store]
GO
/****** Object:  Table [dbo].[InvoiceBillShip]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceBillShip](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[tInvoiceId] [int] NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[CustomerId] [int] NOT NULL,
	[blCompany] [varchar](100) NOT NULL,
	[blFirstName] [varchar](50) NOT NULL,
	[blLastName] [varchar](50) NOT NULL,
	[blAddress1] [varchar](60) NOT NULL,
	[blAddress2] [varchar](60) NULL,
	[blCity] [varchar](40) NOT NULL,
	[blStateProvince] [varchar](40) NOT NULL,
	[blPostalCode] [varchar](20) NOT NULL,
	[blCountry] [varchar](60) NOT NULL,
	[blPhone] [varchar](25) NOT NULL,
	[bSameAsBilling] [bit] NOT NULL,
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
	[TrackingInformation] [varchar](500) NULL,
	[ReferenceNumber] [uniqueidentifier] NULL,
	[mActualShipping] [money] NULL,
	[mHandlingComputed] [money] NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_InvoiceShipping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[InvoiceBillShip]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceBillShip_aspnet_Users1] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[InvoiceBillShip] CHECK CONSTRAINT [FK_InvoiceBillShip_aspnet_Users1]
GO
ALTER TABLE [dbo].[InvoiceBillShip]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceBillShip_Invoice] FOREIGN KEY([tInvoiceId])
REFERENCES [dbo].[Invoice] ([Id])
GO
ALTER TABLE [dbo].[InvoiceBillShip] CHECK CONSTRAINT [FK_InvoiceBillShip_Invoice]
GO
ALTER TABLE [dbo].[InvoiceBillShip] ADD  CONSTRAINT [DF_InvoiceBillShip_bSameAsShipping]  DEFAULT ((1)) FOR [bSameAsBilling]
GO
ALTER TABLE [dbo].[InvoiceBillShip] ADD  CONSTRAINT [DF_InvoiceBillShip_ReferenceNumber]  DEFAULT (newid()) FOR [ReferenceNumber]
GO
ALTER TABLE [dbo].[InvoiceBillShip] ADD  CONSTRAINT [DF_InvoiceBillShip_mActualShipping]  DEFAULT ((0)) FOR [mActualShipping]
GO
ALTER TABLE [dbo].[InvoiceBillShip] ADD  CONSTRAINT [DF_InvoiceBillShip_mHandlingComputed]  DEFAULT ((0)) FOR [mHandlingComputed]
GO
ALTER TABLE [dbo].[InvoiceBillShip] ADD  CONSTRAINT [DF_InvoiceShipping_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
