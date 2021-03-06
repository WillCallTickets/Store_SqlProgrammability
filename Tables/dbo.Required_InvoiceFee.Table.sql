USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Required_InvoiceFee]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Required_InvoiceFee](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[tInvoiceFeeId] [int] NOT NULL,
	[tRequiredId] [int] NOT NULL,
 CONSTRAINT [PK_Required_InvoiceFee] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Required_InvoiceFee]  WITH CHECK ADD  CONSTRAINT [FK_Required_InvoiceFee_InvoiceFee] FOREIGN KEY([tInvoiceFeeId])
REFERENCES [dbo].[InvoiceFee] ([Id])
GO
ALTER TABLE [dbo].[Required_InvoiceFee] CHECK CONSTRAINT [FK_Required_InvoiceFee_InvoiceFee]
GO
ALTER TABLE [dbo].[Required_InvoiceFee]  WITH CHECK ADD  CONSTRAINT [FK_Required_InvoiceFee_Required] FOREIGN KEY([tRequiredId])
REFERENCES [dbo].[Required] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Required_InvoiceFee] CHECK CONSTRAINT [FK_Required_InvoiceFee_Required]
GO
ALTER TABLE [dbo].[Required_InvoiceFee] ADD  CONSTRAINT [DF_Required_InvoiceFee_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
