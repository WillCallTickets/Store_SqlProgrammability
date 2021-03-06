USE [Sts9Store]
GO
/****** Object:  Table [dbo].[FaqItem]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FaqItem](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[bActive] [bit] NOT NULL,
	[Question] [varchar](896) NOT NULL,
	[Answer] [varchar](max) NULL,
	[iDisplayOrder] [int] NOT NULL,
	[tFaqCategorieId] [int] NOT NULL,
 CONSTRAINT [PK_FaqItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FaqItem]  WITH CHECK ADD  CONSTRAINT [FK_FaqItem_FaqCategorie] FOREIGN KEY([tFaqCategorieId])
REFERENCES [dbo].[FaqCategorie] ([Id])
GO
ALTER TABLE [dbo].[FaqItem] CHECK CONSTRAINT [FK_FaqItem_FaqCategorie]
GO
ALTER TABLE [dbo].[FaqItem] ADD  CONSTRAINT [DF_TicketFaq_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[FaqItem] ADD  CONSTRAINT [DF_Faq_bActive]  DEFAULT ((0)) FOR [bActive]
GO
