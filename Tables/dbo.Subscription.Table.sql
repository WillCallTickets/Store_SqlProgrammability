USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Subscription]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Subscription](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[bActive] [bit] NOT NULL,
	[bDefault] [bit] NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[Description] [varchar](500) NULL,
	[InternalDescription] [varchar](2000) NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_EmailSubscription] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Subscription]  WITH CHECK ADD  CONSTRAINT [FK_Subscription_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[Subscription] CHECK CONSTRAINT [FK_Subscription_Aspnet_Applications]
GO
ALTER TABLE [dbo].[Subscription]  WITH CHECK ADD  CONSTRAINT [FK_Subscription_aspnet_Roles] FOREIGN KEY([RoleId])
REFERENCES [dbo].[aspnet_Roles] ([RoleId])
GO
ALTER TABLE [dbo].[Subscription] CHECK CONSTRAINT [FK_Subscription_aspnet_Roles]
GO
ALTER TABLE [dbo].[Subscription] ADD  CONSTRAINT [DF_Subscription_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[Subscription] ADD  CONSTRAINT [DF_Subscription_bDefault]  DEFAULT ((0)) FOR [bDefault]
GO
ALTER TABLE [dbo].[Subscription] ADD  CONSTRAINT [DF_EmailSubscription_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
