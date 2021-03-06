USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MailerTemplateContent]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailerTemplateContent](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[tMailerTemplateId] [int] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[vcTemplateAsset] [varchar](256) NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[Title] [varchar](256) NULL,
	[Template] [varchar](3250) NULL,
	[SeparatorTemplate] [varchar](500) NULL,
	[iMaxListItems] [int] NOT NULL,
	[iMaxSelections] [int] NOT NULL,
	[vcFlags] [varchar](500) NULL,
 CONSTRAINT [PK_MailerTemplateContent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MailerTemplateContent]  WITH CHECK ADD  CONSTRAINT [FK_MailerTemplateContent_MailerTemplate] FOREIGN KEY([tMailerTemplateId])
REFERENCES [dbo].[MailerTemplate] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MailerTemplateContent] CHECK CONSTRAINT [FK_MailerTemplateContent_MailerTemplate]
GO
ALTER TABLE [dbo].[MailerTemplateContent] ADD  CONSTRAINT [DF_MailerTemplateContent_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[MailerTemplateContent] ADD  CONSTRAINT [DF_MailerTemplateContent_iMaxListItems]  DEFAULT ((0)) FOR [iMaxListItems]
GO
ALTER TABLE [dbo].[MailerTemplateContent] ADD  CONSTRAINT [DF_MailerTemplateContent_iMaxSelections]  DEFAULT ((0)) FOR [iMaxSelections]
GO
