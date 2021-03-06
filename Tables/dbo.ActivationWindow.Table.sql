USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ActivationWindow]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ActivationWindow](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[DtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[vcContext] [varchar](256) NOT NULL,
	[TParentId] [int] NOT NULL,
	[bUseCode] [bit] NOT NULL,
	[Code] [varchar](256) NULL,
	[dtCodeStart] [datetime] NULL,
	[dtCodeEnd] [datetime] NULL,
	[dtPublicStart] [datetime] NULL,
	[dtPublicEnd] [datetime] NULL,
 CONSTRAINT [PK_ActivationWindow] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ActivationWindow]  WITH CHECK ADD  CONSTRAINT [FK_ActivationWindow_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[ActivationWindow] CHECK CONSTRAINT [FK_ActivationWindow_aspnet_Applications]
GO
ALTER TABLE [dbo].[ActivationWindow] ADD  CONSTRAINT [DF_ActivationWindow_DtStamp]  DEFAULT (getdate()) FOR [DtStamp]
GO
ALTER TABLE [dbo].[ActivationWindow] ADD  CONSTRAINT [DF_ActivationWindow_bCodeActive]  DEFAULT ((0)) FOR [bUseCode]
GO
