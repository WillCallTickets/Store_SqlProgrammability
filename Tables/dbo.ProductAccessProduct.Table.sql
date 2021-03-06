USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ProductAccessProduct]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProductAccessProduct](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[TProductAccessId] [int] NOT NULL,
	[vcContext] [varchar](50) NOT NULL,
	[TParentId] [int] NOT NULL,
 CONSTRAINT [PK_ProductAccessProduct] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ProductAccessProduct]  WITH CHECK ADD  CONSTRAINT [FK_ProductAccessProduct_ProductAccess] FOREIGN KEY([TProductAccessId])
REFERENCES [dbo].[ProductAccess] ([Id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[ProductAccessProduct] CHECK CONSTRAINT [FK_ProductAccessProduct_ProductAccess]
GO
ALTER TABLE [dbo].[ProductAccessProduct] ADD  CONSTRAINT [DF_ProductAccessProduct_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
