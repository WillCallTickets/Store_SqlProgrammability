USE [Sts9Store]
GO
/****** Object:  Table [dbo].[SubscriptionEmail]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SubscriptionEmail](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[TSubscriptionId] [int] NOT NULL,
	[TEmailLetterId] [int] NOT NULL,
	[PostedFileName] [varchar](256) NOT NULL,
	[CssFile] [varchar](256) NULL,
	[dtLastSent] [datetime] NULL,
	[Constructed_Html] [text] NULL,
	[Constructed_Text] [text] NULL,
 CONSTRAINT [PK_SubscriptionEmail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[SubscriptionEmail]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionEmail_EmailLetter] FOREIGN KEY([TEmailLetterId])
REFERENCES [dbo].[EmailLetter] ([Id])
GO
ALTER TABLE [dbo].[SubscriptionEmail] CHECK CONSTRAINT [FK_SubscriptionEmail_EmailLetter]
GO
ALTER TABLE [dbo].[SubscriptionEmail]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionEmail_Subscription] FOREIGN KEY([TSubscriptionId])
REFERENCES [dbo].[Subscription] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SubscriptionEmail] CHECK CONSTRAINT [FK_SubscriptionEmail_Subscription]
GO
ALTER TABLE [dbo].[SubscriptionEmail] ADD  CONSTRAINT [DF_SubscriptionEmail_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
