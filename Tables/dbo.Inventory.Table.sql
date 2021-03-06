USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Inventory]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Inventory](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[vcParentContext] [varchar](1) NOT NULL,
	[iParentInventoryId] [int] NOT NULL,
	[Code] [varchar](25) NOT NULL,
	[Description] [varchar](250) NULL,
	[gSaleItemId] [uniqueidentifier] NULL,
	[tInvoiceItemId] [int] NULL,
	[dtSold] [datetime] NULL,
	[UserId] [uniqueidentifier] NULL,
	[dtRedeemed] [datetime] NULL,
	[ipRedeemed] [varchar](15) NULL,
 CONSTRAINT [PK_Inventory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Inventory]  WITH CHECK ADD  CONSTRAINT [FK_Inventory_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[Inventory] CHECK CONSTRAINT [FK_Inventory_aspnet_Users]
GO
ALTER TABLE [dbo].[Inventory]  WITH CHECK ADD  CONSTRAINT [FK_Inventory_InvoiceItem] FOREIGN KEY([tInvoiceItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
GO
ALTER TABLE [dbo].[Inventory] CHECK CONSTRAINT [FK_Inventory_InvoiceItem]
GO
ALTER TABLE [dbo].[Inventory] ADD  CONSTRAINT [DF_Inventory_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
