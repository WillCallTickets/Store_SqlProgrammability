USE [Sts9Store]
GO
/****** Object:  Table [dbo].[CharitableOrg]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CharitableOrg](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[bActive] [bit] NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[NameRoot]  AS (case when charindex('the ',[Name])<>(1) then upper([Name]) else upper(substring([Name],(5),len([Name]))) end),
	[DisplayName] [varchar](256) NULL,
	[WebsiteUrl] [varchar](256) NULL,
	[PictureUrl] [varchar](256) NULL,
	[ShortDescription] [varchar](500) NULL,
	[Description] [varchar](max) NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_CharitableOrg] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[CharitableOrg]  WITH NOCHECK ADD  CONSTRAINT [FK_CharitableOrg_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[CharitableOrg] CHECK CONSTRAINT [FK_CharitableOrg_Applications]
GO
ALTER TABLE [dbo].[CharitableOrg] ADD  CONSTRAINT [DF_CharitableOrg_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[CharitableOrg] ADD  CONSTRAINT [DF_CharitableOrg_bActive]  DEFAULT ((0)) FOR [bActive]
GO
