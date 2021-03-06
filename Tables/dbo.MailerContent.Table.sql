USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MailerContent]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailerContent](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[tMailerId] [int] NOT NULL,
	[tMailerTemplateContentId] [int] NOT NULL,
	[bActive] [bit] NOT NULL,
	[vcTitle] [varchar](500) NULL,
	[vcContent] [varchar](4000) NULL,
 CONSTRAINT [PK_MailerContent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MailerContent]  WITH CHECK ADD  CONSTRAINT [FK_MailerContent_Mailer] FOREIGN KEY([tMailerId])
REFERENCES [dbo].[Mailer] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailerContent] CHECK CONSTRAINT [FK_MailerContent_Mailer]
GO
ALTER TABLE [dbo].[MailerContent]  WITH CHECK ADD  CONSTRAINT [FK_MailerContent_MailerTemplateContent] FOREIGN KEY([tMailerTemplateContentId])
REFERENCES [dbo].[MailerTemplateContent] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailerContent] CHECK CONSTRAINT [FK_MailerContent_MailerTemplateContent]
GO
ALTER TABLE [dbo].[MailerContent] ADD  CONSTRAINT [DF_MailerContent_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[MailerContent] ADD  CONSTRAINT [DF_MailerContent_bActive]  DEFAULT ((1)) FOR [bActive]
GO
