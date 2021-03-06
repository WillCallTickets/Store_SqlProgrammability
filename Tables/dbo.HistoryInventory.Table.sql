USE [Sts9Store]
GO
/****** Object:  Table [dbo].[HistoryInventory]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HistoryInventory](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[tMerchId] [int] NULL,
	[tShowTicketId] [int] NULL,
	[dtAdjusted] [datetime] NOT NULL,
	[iCurrentlyAllotted] [int] NOT NULL,
	[iAdjustment] [int] NOT NULL,
	[vcContext] [varchar](50) NOT NULL,
	[Description] [varchar](500) NULL,
 CONSTRAINT [PK_InventoryHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[HistoryInventory]  WITH CHECK ADD  CONSTRAINT [FK_HistoryInventory_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[HistoryInventory] CHECK CONSTRAINT [FK_HistoryInventory_aspnet_Users]
GO
ALTER TABLE [dbo].[HistoryInventory]  WITH CHECK ADD  CONSTRAINT [FK_HistoryInventory_Merch] FOREIGN KEY([tMerchId])
REFERENCES [dbo].[Merch] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HistoryInventory] CHECK CONSTRAINT [FK_HistoryInventory_Merch]
GO
ALTER TABLE [dbo].[HistoryInventory]  WITH CHECK ADD  CONSTRAINT [FK_HistoryInventory_ShowTicket] FOREIGN KEY([tShowTicketId])
REFERENCES [dbo].[ShowTicket] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HistoryInventory] CHECK CONSTRAINT [FK_HistoryInventory_ShowTicket]
GO
ALTER TABLE [dbo].[HistoryInventory] ADD  CONSTRAINT [DF_Table_1_dtTSamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[HistoryInventory] ADD  CONSTRAINT [DF_HistoryInventory_iCurrentAllotment]  DEFAULT ((0)) FOR [iCurrentlyAllotted]
GO
