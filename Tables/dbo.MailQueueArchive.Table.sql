USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MailQueueArchive]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailQueueArchive](
	[Id] [int] NOT NULL,
	[dtStamp] [datetime] NULL,
	[DateToProcess] [datetime] NULL,
	[DateProcessed] [datetime] NULL,
	[FromName] [varchar](80) NULL,
	[FromAddress] [varchar](300) NULL,
	[ToAddress] [varchar](300) NULL,
	[CC] [varchar](300) NULL,
	[BCC] [varchar](300) NULL,
	[Status] [varchar](1000) NULL,
	[TEmailLetterId] [int] NULL,
	[TSubscriptionEmailId] [int] NULL,
	[Priority] [int] NULL,
	[bMassMailer] [bit] NULL,
	[ThreadLock] [uniqueidentifier] NULL,
	[AttemptsRemaining] [int] NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_MailQueueArchive] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
