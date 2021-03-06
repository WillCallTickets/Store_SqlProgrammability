USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ShowTicket]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShowTicket](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[TVendorId] [int] NOT NULL,
	[dtDateOfShow] [datetime] NOT NULL,
	[CriteriaText] [varchar](300) NULL,
	[SalesDescription] [varchar](300) NULL,
	[TShowDateId] [int] NOT NULL,
	[TShowId] [int] NOT NULL,
	[TAgeId] [int] NOT NULL,
	[bActive] [bit] NOT NULL,
	[bSoldOut] [bit] NOT NULL,
	[Status] [varchar](500) NULL,
	[bDosTicket] [bit] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[PriceText] [varchar](300) NULL,
	[mPrice] [money] NULL,
	[DosText] [varchar](300) NULL,
	[mDosPrice] [money] NULL,
	[mServiceCharge] [money] NULL,
	[bAllowShipping] [bit] NOT NULL,
	[bAllowWillCall] [bit] NOT NULL,
	[bHideShipMethod] [bit] NOT NULL,
	[dtShipCutoff] [datetime] NOT NULL,
	[bOverrideSellout] [bit] NOT NULL,
	[bUnlockActive] [bit] NOT NULL,
	[UnlockCode] [varchar](256) NULL,
	[dtUnlockDate] [datetime] NULL,
	[dtUnlockEndDate] [datetime] NULL,
	[dtPublicOnsale] [datetime] NULL,
	[dtEndDate] [datetime] NULL,
	[iMaxQtyPerOrder] [int] NULL,
	[iAllotment] [int] NOT NULL,
	[iPending] [int] NOT NULL,
	[iSold] [int] NOT NULL,
	[iAvailable]  AS (([iAllotment]-[iPending])-[iSold]),
	[iRefunded] [int] NOT NULL,
	[mFlatShip] [money] NULL,
	[vcFlatMethod] [varchar](256) NULL,
	[dtBackorder] [datetime] NULL,
	[bShipSeparate] [bit] NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_ShowTickets] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Simply a placeholder to denote how many have been refunded. Does not affect inventory. When items are refunded, they are taken out of sold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ShowTicket', @level2type=N'COLUMN',@level2name=N'iRefunded'
GO
ALTER TABLE [dbo].[ShowTicket]  WITH CHECK ADD  CONSTRAINT [FK_ShowTicket_ShowDate] FOREIGN KEY([TShowDateId])
REFERENCES [dbo].[ShowDate] ([Id])
GO
ALTER TABLE [dbo].[ShowTicket] CHECK CONSTRAINT [FK_ShowTicket_ShowDate]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_bSoldOut]  DEFAULT ((0)) FOR [bSoldOut]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_bIsDos]  DEFAULT ((0)) FOR [bDosTicket]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_mPrice]  DEFAULT ((0)) FOR [mPrice]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_bAllowShipping]  DEFAULT ((1)) FOR [bAllowShipping]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_bAllowWillCall]  DEFAULT ((1)) FOR [bAllowWillCall]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_bHideShipMethod_1]  DEFAULT ((0)) FOR [bHideShipMethod]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_bOverrideSellout]  DEFAULT ((0)) FOR [bOverrideSellout]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_bUnlockActive]  DEFAULT ((0)) FOR [bUnlockActive]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_iAllotment]  DEFAULT ((0)) FOR [iAllotment]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_iPending]  DEFAULT ((0)) FOR [iPending]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_iSold]  DEFAULT ((0)) FOR [iSold]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_iRefunded]  DEFAULT ((0)) FOR [iRefunded]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTicket_bShipSeparate]  DEFAULT ((0)) FOR [bShipSeparate]
GO
ALTER TABLE [dbo].[ShowTicket] ADD  CONSTRAINT [DF_ShowTickets_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
