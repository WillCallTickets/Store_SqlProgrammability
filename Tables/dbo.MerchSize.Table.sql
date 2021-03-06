USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MerchSize]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MerchSize](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_MerchSize_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MerchSize]  WITH CHECK ADD  CONSTRAINT [FK_MerchSize_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[MerchSize] CHECK CONSTRAINT [FK_MerchSize_Aspnet_Applications]
GO
ALTER TABLE [dbo].[MerchSize] ADD  CONSTRAINT [DF_MerchSize_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
ALTER TABLE [dbo].[MerchSize] ADD  CONSTRAINT [DF_MerchSize_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
