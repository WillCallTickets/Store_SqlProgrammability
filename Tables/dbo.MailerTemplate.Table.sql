USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MailerTemplate]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailerTemplate](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[Description] [varchar](500) NULL,
	[Style] [varchar](500) NULL,
	[Header] [varchar](3250) NOT NULL,
	[Footer] [varchar](3250) NOT NULL,
 CONSTRAINT [PK_MailerTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MailerTemplate] ADD  CONSTRAINT [DF_MailerTemplate_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
