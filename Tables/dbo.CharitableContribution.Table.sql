USE [Sts9Store]
GO
/****** Object:  Table [dbo].[CharitableContribution]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CharitableContribution](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[tInvoiceItemId] [int] NOT NULL,
	[tCharitableOrgId] [int] NOT NULL,
 CONSTRAINT [PK_CharitableContribution] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CharitableContribution]  WITH CHECK ADD  CONSTRAINT [FK_CharitableContribution_InvoiceItem] FOREIGN KEY([tInvoiceItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
GO
ALTER TABLE [dbo].[CharitableContribution] CHECK CONSTRAINT [FK_CharitableContribution_InvoiceItem]
GO
