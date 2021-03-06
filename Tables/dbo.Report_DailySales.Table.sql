USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Report_DailySales]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Report_DailySales](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[dtStamp] [datetime] NULL,
	[ReportDate] [datetime] NOT NULL,
	[vcContext] [varchar](256) NOT NULL,
	[ItemId] [int] NOT NULL,
	[Description] [varchar](1000) NULL,
	[MiniDesc] [varchar](500) NULL,
	[Alloted] [int] NOT NULL,
	[Sold] [int] NOT NULL,
	[TotalSold] [int] NOT NULL,
	[Available] [int] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Report_DailySales] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Report_DailySales]  WITH CHECK ADD  CONSTRAINT [FK_ReportDailySales_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[Report_DailySales] CHECK CONSTRAINT [FK_ReportDailySales_Aspnet_Applications]
GO
ALTER TABLE [dbo].[Report_DailySales] ADD  CONSTRAINT [DF_Report_DailySales_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[Report_DailySales] ADD  CONSTRAINT [DF_Report_DailySales_Alloted]  DEFAULT ((0)) FOR [Alloted]
GO
ALTER TABLE [dbo].[Report_DailySales] ADD  CONSTRAINT [DF_Report_DailySales_TotalSold]  DEFAULT ((0)) FOR [TotalSold]
GO
