USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MerchCategorie]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MerchCategorie](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[tMerchDivisionId] [int] NOT NULL,
	[bInternalOnly] [bit] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[Description] [varchar](2000) NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_MerchCategorie] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MerchCategorie]  WITH CHECK ADD  CONSTRAINT [FK_MerchCategorie_MerchDivision] FOREIGN KEY([tMerchDivisionId])
REFERENCES [dbo].[MerchDivision] ([Id])
GO
ALTER TABLE [dbo].[MerchCategorie] CHECK CONSTRAINT [FK_MerchCategorie_MerchDivision]
GO
ALTER TABLE [dbo].[MerchCategorie] ADD  CONSTRAINT [DF_MerchCategorie_bInternalOnly]  DEFAULT ((0)) FOR [bInternalOnly]
GO
ALTER TABLE [dbo].[MerchCategorie] ADD  CONSTRAINT [DF_MerchCategorie_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
