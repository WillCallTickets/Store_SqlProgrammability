USE [Sts9Store]
GO
/****** Object:  Table [dbo].[JShowPromoter]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[JShowPromoter](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[TPromoterId] [int] NOT NULL,
	[TShowId] [int] NOT NULL,
	[PreText] [varchar](300) NULL,
	[PromoterText] [varchar](300) NULL,
	[PostText] [varchar](300) NULL,
	[iDisplayOrder] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_JShowPromoter] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[JShowPromoter]  WITH NOCHECK ADD  CONSTRAINT [FK_JShowPromoter_Promoter] FOREIGN KEY([TPromoterId])
REFERENCES [dbo].[Promoter] ([Id])
GO
ALTER TABLE [dbo].[JShowPromoter] CHECK CONSTRAINT [FK_JShowPromoter_Promoter]
GO
ALTER TABLE [dbo].[JShowPromoter]  WITH NOCHECK ADD  CONSTRAINT [FK_JShowPromoter_Show] FOREIGN KEY([TShowId])
REFERENCES [dbo].[Show] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[JShowPromoter] CHECK CONSTRAINT [FK_JShowPromoter_Show]
GO
ALTER TABLE [dbo].[JShowPromoter] ADD  CONSTRAINT [DF_JShowPromoter_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
