USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MerchDivision]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MerchDivision](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[bInternalOnly] [bit] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[Description] [varchar](2000) NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_MerchDivision] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MerchDivision]  WITH CHECK ADD  CONSTRAINT [FK_MerchDivision_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[MerchDivision] CHECK CONSTRAINT [FK_MerchDivision_Aspnet_Applications]
GO
ALTER TABLE [dbo].[MerchDivision] ADD  CONSTRAINT [DF_MerchDivision_bInternalOnly]  DEFAULT ((0)) FOR [bInternalOnly]
GO
ALTER TABLE [dbo].[MerchDivision] ADD  CONSTRAINT [DF_MerchDivision_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
