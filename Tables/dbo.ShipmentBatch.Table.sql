USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ShipmentBatch]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShipmentBatch](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[BatchId] [varchar](50) NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[Description] [varchar](1000) NULL,
	[EventId] [int] NULL,
	[csvEventTix] [varchar](1000) NULL,
	[csvOtherTix] [varchar](1000) NULL,
	[csvMethods] [varchar](1000) NULL,
	[dtEstShipDate] [datetime] NULL,
 CONSTRAINT [PK_ShipmentBatch] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ShipmentBatch]  WITH CHECK ADD  CONSTRAINT [FK_ShipmentBatch_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[ShipmentBatch] CHECK CONSTRAINT [FK_ShipmentBatch_aspnet_Applications]
GO
ALTER TABLE [dbo].[ShipmentBatch] ADD  CONSTRAINT [DF_ShipmentBatch_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
