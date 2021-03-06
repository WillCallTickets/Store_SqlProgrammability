USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ProductAccess]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProductAccess](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[bActive] [bit] NOT NULL,
	[CampaignName] [varchar](512) NOT NULL,
	[CampaignCode] [varchar](50) NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_ProductAccess] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ProductAccess]  WITH CHECK ADD  CONSTRAINT [FK_ProductAccess_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[ProductAccess] CHECK CONSTRAINT [FK_ProductAccess_aspnet_Applications]
GO
ALTER TABLE [dbo].[ProductAccess] ADD  CONSTRAINT [DF_ProductAccess_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[ProductAccess] ADD  CONSTRAINT [DF_ProductAccess_bActive]  DEFAULT ((0)) FOR [bActive]
GO
ALTER TABLE [dbo].[ProductAccess] ADD  CONSTRAINT [DF_ProductAccess_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
