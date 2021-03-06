USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Mailer]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Mailer](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[tMailerTemplateId] [int] NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[Subject] [varchar](256) NULL,
 CONSTRAINT [PK_Mailer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Mailer]  WITH CHECK ADD  CONSTRAINT [FK_Mailer_MailerTemplate] FOREIGN KEY([tMailerTemplateId])
REFERENCES [dbo].[MailerTemplate] ([Id])
GO
ALTER TABLE [dbo].[Mailer] CHECK CONSTRAINT [FK_Mailer_MailerTemplate]
GO
ALTER TABLE [dbo].[Mailer] ADD  CONSTRAINT [DF_Mailer_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
