USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MailerTemplateSubstitution]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailerTemplateSubstitution](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[tMailerTemplateContentId] [int] NOT NULL,
	[TagName] [varchar](256) NOT NULL,
	[TagValue] [varchar](2000) NOT NULL,
 CONSTRAINT [PK_MailerTemplateSubstitution] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MailerTemplateSubstitution]  WITH CHECK ADD  CONSTRAINT [FK_MailerTemplateSubstitution_MailerTemplateContent] FOREIGN KEY([tMailerTemplateContentId])
REFERENCES [dbo].[MailerTemplateContent] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailerTemplateSubstitution] CHECK CONSTRAINT [FK_MailerTemplateSubstitution_MailerTemplateContent]
GO
ALTER TABLE [dbo].[MailerTemplateSubstitution] ADD  CONSTRAINT [DF_MailerTemplateSubstitution_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
