USE [Sts9Store]
GO
/****** Object:  Table [dbo].[LotteryRequest]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LotteryRequest](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[GUID] [uniqueidentifier] NOT NULL,
	[dtStamp] [datetime] NULL,
	[TLotteryId] [int] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[vcStatus] [varchar](50) NULL,
	[dtStatus] [datetime] NULL,
	[StatusBy] [varchar](256) NULL,
	[StatusNotes] [varchar](500) NULL,
	[dtFulfilled] [datetime] NULL,
	[iRequested] [int] NOT NULL,
	[iPurchased] [int] NOT NULL,
	[StatusIP] [varchar](25) NULL,
	[RequestIP] [varchar](25) NULL,
	[FulfillIP] [varchar](25) NULL,
 CONSTRAINT [PK_LotteryRequest] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'allows a unique key - helpful for random sorting' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LotteryRequest', @level2type=N'COLUMN',@level2name=N'GUID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'pending approved or denied' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LotteryRequest', @level2type=N'COLUMN',@level2name=N'vcStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'the date actually fulfilled' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LotteryRequest', @level2type=N'COLUMN',@level2name=N'dtFulfilled'
GO
ALTER TABLE [dbo].[LotteryRequest]  WITH CHECK ADD  CONSTRAINT [FK_LotteryRequest_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LotteryRequest] CHECK CONSTRAINT [FK_LotteryRequest_aspnet_Users]
GO
ALTER TABLE [dbo].[LotteryRequest]  WITH CHECK ADD  CONSTRAINT [FK_LotteryRequest_Lottery] FOREIGN KEY([TLotteryId])
REFERENCES [dbo].[Lottery] ([Id])
GO
ALTER TABLE [dbo].[LotteryRequest] CHECK CONSTRAINT [FK_LotteryRequest_Lottery]
GO
ALTER TABLE [dbo].[LotteryRequest] ADD  CONSTRAINT [DF_LotteryRequest_GUID]  DEFAULT (newid()) FOR [GUID]
GO
ALTER TABLE [dbo].[LotteryRequest] ADD  CONSTRAINT [DF_LotteryRequest_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[LotteryRequest] ADD  CONSTRAINT [DF_LotteryRequest_iRequested]  DEFAULT ((0)) FOR [iRequested]
GO
ALTER TABLE [dbo].[LotteryRequest] ADD  CONSTRAINT [DF_LotteryRequest_iPurchased]  DEFAULT ((0)) FOR [iPurchased]
GO
