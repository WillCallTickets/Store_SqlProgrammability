USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MailQueue]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailQueue](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[TEmailLetterId] [int] NULL,
	[TSubscriptionEmailId] [int] NULL,
	[DateToProcess] [datetime] NULL,
	[DateProcessed] [datetime] NULL,
	[FromName] [varchar](80) NULL,
	[FromAddress] [varchar](300) NULL,
	[ToAddress] [varchar](300) NULL,
	[CC] [varchar](300) NULL,
	[BCC] [varchar](300) NULL,
	[Status] [varchar](1000) NULL,
	[Priority] [int] NOT NULL,
	[bMassMailer] [bit] NULL,
	[ThreadLock] [uniqueidentifier] NULL,
	[AttemptsRemaining] [int] NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_MailQueue] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MailQueue]  WITH CHECK ADD  CONSTRAINT [FK_MailQueue_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[MailQueue] CHECK CONSTRAINT [FK_MailQueue_Aspnet_Applications]
GO
ALTER TABLE [dbo].[MailQueue]  WITH NOCHECK ADD  CONSTRAINT [FK_MailQueue_EmailLetter] FOREIGN KEY([TEmailLetterId])
REFERENCES [dbo].[EmailLetter] ([Id])
GO
ALTER TABLE [dbo].[MailQueue] CHECK CONSTRAINT [FK_MailQueue_EmailLetter]
GO
ALTER TABLE [dbo].[MailQueue]  WITH CHECK ADD  CONSTRAINT [FK_MailQueue_SubscriptionEmail] FOREIGN KEY([TSubscriptionEmailId])
REFERENCES [dbo].[SubscriptionEmail] ([Id])
GO
ALTER TABLE [dbo].[MailQueue] CHECK CONSTRAINT [FK_MailQueue_SubscriptionEmail]
GO
ALTER TABLE [dbo].[MailQueue] ADD  CONSTRAINT [DF_MailQueue_Priority]  DEFAULT ((0)) FOR [Priority]
GO
ALTER TABLE [dbo].[MailQueue] ADD  CONSTRAINT [DF_MailQueue_AttemptsRemaining]  DEFAULT ((3)) FOR [AttemptsRemaining]
GO
ALTER TABLE [dbo].[MailQueue] ADD  CONSTRAINT [DF_MailQueue_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
