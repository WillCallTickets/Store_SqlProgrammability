USE [Sts9Store]
GO
/****** Object:  Table [dbo].[AuthorizeNet]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AuthorizeNet](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[InvoiceNumber] [varchar](20) NULL,
	[bAuthorized] [bit] NULL,
	[TInvoiceId] [int] NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[CustomerId] [int] NULL,
	[ProcessorId] [varchar](50) NULL,
	[Method] [varchar](10) NULL,
	[TransactionType] [varchar](20) NULL,
	[mAmount] [money] NULL,
	[mTaxAmount] [money] NULL,
	[mFreightAmount] [money] NULL,
	[Description] [varchar](1000) NULL,
	[iDupeSeconds] [int] NULL,
	[iResponseCode] [int] NULL,
	[ResponseSubcode] [varchar](10) NULL,
	[iResponseReasonCode] [int] NULL,
	[bMd5Match] [bit] NULL,
	[ResponseReasonText] [varchar](255) NULL,
	[ApprovalCode] [varchar](6) NULL,
	[AVSResultCode] [varchar](10) NULL,
	[CardCodeResponseCode] [varchar](10) NULL,
	[Email] [varchar](255) NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[NameOnCard] [varchar](50) NULL,
	[Company] [varchar](50) NULL,
	[BillingAddress] [varchar](60) NULL,
	[City] [varchar](40) NULL,
	[State] [varchar](40) NULL,
	[Zip] [varchar](20) NULL,
	[Country] [varchar](60) NULL,
	[Phone] [varchar](25) NULL,
	[IpAddress] [varchar](15) NULL,
	[ShipToFirstName] [varchar](50) NULL,
	[ShipToLastName] [varchar](50) NULL,
	[ShipToCompany] [varchar](50) NULL,
	[ShipToAddress] [varchar](60) NULL,
	[ShipToCity] [varchar](40) NULL,
	[ShipToState] [varchar](40) NULL,
	[ShipToZip] [varchar](20) NULL,
	[ShipToCountry] [varchar](60) NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AuthNetOrder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[AuthorizeNet]  WITH CHECK ADD  CONSTRAINT [FK_AuthorizeNet_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[AuthorizeNet] CHECK CONSTRAINT [FK_AuthorizeNet_Aspnet_Applications]
GO
ALTER TABLE [dbo].[AuthorizeNet]  WITH CHECK ADD  CONSTRAINT [FK_AuthorizeNet_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[AuthorizeNet] CHECK CONSTRAINT [FK_AuthorizeNet_aspnet_Users]
GO
ALTER TABLE [dbo].[AuthorizeNet]  WITH NOCHECK ADD  CONSTRAINT [FK_AuthorizeTrans_Invoice] FOREIGN KEY([TInvoiceId])
REFERENCES [dbo].[Invoice] ([Id])
GO
ALTER TABLE [dbo].[AuthorizeNet] CHECK CONSTRAINT [FK_AuthorizeTrans_Invoice]
GO
ALTER TABLE [dbo].[AuthorizeNet] ADD  CONSTRAINT [DF_AuthNetOrder_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
