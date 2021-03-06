USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MerchBundle]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MerchBundle](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[bActive] [bit] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[TMerchId] [int] NULL,
	[Title] [varchar](256) NOT NULL,
	[Comment] [varchar](500) NULL,
	[iRequiredParentQty] [int] NOT NULL,
	[iMaxSelections] [int] NOT NULL,
	[mPrice] [money] NOT NULL,
	[bPricedPerSelection] [bit] NULL,
	[bIncludeWeight] [bit] NOT NULL,
	[TShowTicketId] [int] NULL,
 CONSTRAINT [PK_MerchPackage] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MerchBundle]  WITH CHECK ADD  CONSTRAINT [FK_MerchBundle_Merch] FOREIGN KEY([TMerchId])
REFERENCES [dbo].[Merch] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MerchBundle] CHECK CONSTRAINT [FK_MerchBundle_Merch]
GO
ALTER TABLE [dbo].[MerchBundle]  WITH CHECK ADD  CONSTRAINT [FK_MerchBundle_ShowTicket] FOREIGN KEY([TShowTicketId])
REFERENCES [dbo].[ShowTicket] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MerchBundle] CHECK CONSTRAINT [FK_MerchBundle_ShowTicket]
GO
ALTER TABLE [dbo].[MerchBundle] ADD  CONSTRAINT [DF_MerchPackage_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[MerchBundle] ADD  CONSTRAINT [DF_MerchPackage_bActive]  DEFAULT ((0)) FOR [bActive]
GO
ALTER TABLE [dbo].[MerchBundle] ADD  CONSTRAINT [DF_MerchPackage_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
ALTER TABLE [dbo].[MerchBundle] ADD  CONSTRAINT [DF_MerchPackage_iRequiredParentQty]  DEFAULT ((1)) FOR [iRequiredParentQty]
GO
ALTER TABLE [dbo].[MerchBundle] ADD  CONSTRAINT [DF_MerchPackage_iSelections]  DEFAULT ((1)) FOR [iMaxSelections]
GO
ALTER TABLE [dbo].[MerchBundle] ADD  CONSTRAINT [DF_MerchPackage_mPrice]  DEFAULT ((0.0)) FOR [mPrice]
GO
ALTER TABLE [dbo].[MerchBundle] ADD  CONSTRAINT [DF_MerchBundle_bIncludeWeight]  DEFAULT ((0)) FOR [bIncludeWeight]
GO
