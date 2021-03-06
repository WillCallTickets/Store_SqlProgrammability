USE [Sts9Store]
GO
/****** Object:  Table [dbo].[InvoiceItemPostPurchaseText]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceItemPostPurchaseText](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[TInvoiceItemId] [int] NOT NULL,
	[TPostPurchaseTextId] [int] NOT NULL,
	[PostText] [varchar](max) NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceItemPostPurchaseText] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[InvoiceItemPostPurchaseText]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItemPostPurchaseText_InvoiceItem] FOREIGN KEY([TInvoiceItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
GO
ALTER TABLE [dbo].[InvoiceItemPostPurchaseText] CHECK CONSTRAINT [FK_InvoiceItemPostPurchaseText_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceItemPostPurchaseText] ADD  CONSTRAINT [DF_InvoiceItemPostPurchaseText_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[InvoiceItemPostPurchaseText] ADD  CONSTRAINT [DF_InvoiceItemPostPurchaseText_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
