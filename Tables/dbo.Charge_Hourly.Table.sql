USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Charge_Hourly]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Charge_Hourly](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[TChargeStatementId] [int] NOT NULL,
	[dtPerformed] [datetime] NOT NULL,
	[ServiceDescription] [varchar](2000) NOT NULL,
	[Hours] [int] NOT NULL,
	[Rate] [money] NOT NULL,
	[FlatRate] [money] NOT NULL,
	[LineTotal]  AS ([Hours]*[Rate]+[FlatRate]),
 CONSTRAINT [PK_Charge_Hourly] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Charge_Hourly]  WITH CHECK ADD  CONSTRAINT [FK_Charge_Hourly_Charge_Statement] FOREIGN KEY([TChargeStatementId])
REFERENCES [dbo].[Charge_Statement] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Charge_Hourly] CHECK CONSTRAINT [FK_Charge_Hourly_Charge_Statement]
GO
ALTER TABLE [dbo].[Charge_Hourly] ADD  CONSTRAINT [DF_Charge_Hourly_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[Charge_Hourly] ADD  CONSTRAINT [DF_Charge_Hourly_Rate]  DEFAULT ((0)) FOR [Rate]
GO
ALTER TABLE [dbo].[Charge_Hourly] ADD  CONSTRAINT [DF_Charge_Hourly_FlatRate]  DEFAULT ((0)) FOR [FlatRate]
GO
