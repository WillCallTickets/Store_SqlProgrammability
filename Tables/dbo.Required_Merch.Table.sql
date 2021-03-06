USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Required_Merch]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Required_Merch](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[tMerchId] [int] NOT NULL,
	[tRequiredId] [int] NOT NULL,
	[bLimitQtyToPastQty] [bit] NOT NULL,
 CONSTRAINT [PK_Required_Merch] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'this will go to lesser of maxAllowed in current purchase or how many were purchased in the past' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Required_Merch', @level2type=N'COLUMN',@level2name=N'bLimitQtyToPastQty'
GO
ALTER TABLE [dbo].[Required_Merch]  WITH CHECK ADD  CONSTRAINT [FK_Required_Merch_Merch] FOREIGN KEY([tMerchId])
REFERENCES [dbo].[Merch] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Required_Merch] CHECK CONSTRAINT [FK_Required_Merch_Merch]
GO
ALTER TABLE [dbo].[Required_Merch]  WITH CHECK ADD  CONSTRAINT [FK_Required_Merch_Required] FOREIGN KEY([tRequiredId])
REFERENCES [dbo].[Required] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Required_Merch] CHECK CONSTRAINT [FK_Required_Merch_Required]
GO
ALTER TABLE [dbo].[Required_Merch] ADD  CONSTRAINT [DF_Required_Merch_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[Required_Merch] ADD  CONSTRAINT [DF_Required_Merch_bLimitQtyToPastQty]  DEFAULT ((0)) FOR [bLimitQtyToPastQty]
GO
