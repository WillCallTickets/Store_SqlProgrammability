USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ServiceCharge]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceCharge](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[mMaxValue] [money] NOT NULL,
	[mCharge] [money] NOT NULL,
	[mPercentage] [money] NOT NULL,
 CONSTRAINT [PK_ServiceCharge] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ServiceCharge] ADD  CONSTRAINT [DF_ServiceCharge_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[ServiceCharge] ADD  CONSTRAINT [DF_ServiceCharge_mCharge]  DEFAULT ((0)) FOR [mCharge]
GO
ALTER TABLE [dbo].[ServiceCharge] ADD  CONSTRAINT [DF_ServiceCharge_mPercentage]  DEFAULT ((0)) FOR [mPercentage]
GO
