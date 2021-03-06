USE [Sts9Store]
GO
/****** Object:  Table [dbo].[SaleRule]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SaleRule](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](50) NULL,
	[DisplayText] [varchar](2000) NOT NULL,
	[vcContext] [varchar](50) NOT NULL,
	[bActive] [bit] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_SaleRule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[SaleRule]  WITH CHECK ADD  CONSTRAINT [FK_SaleRule_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[SaleRule] CHECK CONSTRAINT [FK_SaleRule_Aspnet_Applications]
GO
ALTER TABLE [dbo].[SaleRule] ADD  CONSTRAINT [DF_SaleRule_vcContext]  DEFAULT ('Tickets') FOR [vcContext]
GO
ALTER TABLE [dbo].[SaleRule] ADD  CONSTRAINT [DF_SaleRule_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[SaleRule] ADD  CONSTRAINT [DF_SaleRule_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
ALTER TABLE [dbo].[SaleRule] ADD  CONSTRAINT [DF_SaleRule_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
