USE [Sts9Store]
GO
/****** Object:  Table [dbo].[HistorySubscriptionEmail]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HistorySubscriptionEmail](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[TSubscriptionEmailId] [int] NOT NULL,
	[dtSent] [datetime] NOT NULL,
	[iRecipients] [int] NOT NULL,
 CONSTRAINT [PK_HistorySubscriptionEmail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistorySubscriptionEmail]  WITH CHECK ADD  CONSTRAINT [FK_HistorySubscriptionEmail_SubscriptionEmail] FOREIGN KEY([TSubscriptionEmailId])
REFERENCES [dbo].[SubscriptionEmail] ([Id])
GO
ALTER TABLE [dbo].[HistorySubscriptionEmail] CHECK CONSTRAINT [FK_HistorySubscriptionEmail_SubscriptionEmail]
GO
ALTER TABLE [dbo].[HistorySubscriptionEmail] ADD  CONSTRAINT [DF_HistorySubscriptionEmail_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
