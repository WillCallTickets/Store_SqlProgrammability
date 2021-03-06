USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MerchColor]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MerchColor](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[ImageUrl] [varchar](256) NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_MerchColor_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MerchColor]  WITH CHECK ADD  CONSTRAINT [FK_MerchColor_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[MerchColor] CHECK CONSTRAINT [FK_MerchColor_Aspnet_Applications]
GO
ALTER TABLE [dbo].[MerchColor] ADD  CONSTRAINT [DF_MerchColor_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
ALTER TABLE [dbo].[MerchColor] ADD  CONSTRAINT [DF_MerchColor_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
