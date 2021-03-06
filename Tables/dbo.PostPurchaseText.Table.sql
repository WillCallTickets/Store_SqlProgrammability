USE [Sts9Store]
GO
/****** Object:  Table [dbo].[PostPurchaseText]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PostPurchaseText](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[tMerchId] [int] NULL,
	[tShowTicketId] [int] NULL,
	[bActive] [bit] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[InProcessDescription] [varchar](1500) NULL,
	[PostText] [varchar](max) NOT NULL,
 CONSTRAINT [PK_PostPurchaseText] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[PostPurchaseText]  WITH CHECK ADD  CONSTRAINT [FK_PostPurchaseText_Merch] FOREIGN KEY([tMerchId])
REFERENCES [dbo].[Merch] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PostPurchaseText] CHECK CONSTRAINT [FK_PostPurchaseText_Merch]
GO
ALTER TABLE [dbo].[PostPurchaseText]  WITH CHECK ADD  CONSTRAINT [FK_PostPurchaseText_ShowTicket] FOREIGN KEY([tShowTicketId])
REFERENCES [dbo].[ShowTicket] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PostPurchaseText] CHECK CONSTRAINT [FK_PostPurchaseText_ShowTicket]
GO
ALTER TABLE [dbo].[PostPurchaseText] ADD  CONSTRAINT [DF_PostPurchaseText_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[PostPurchaseText] ADD  CONSTRAINT [DF_PostPurchaseText_bActive_1]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[PostPurchaseText] ADD  CONSTRAINT [DF_PostPurchaseText_iDisplayOrder_1]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
