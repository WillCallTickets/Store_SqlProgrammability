USE [Sts9Store]
GO
/****** Object:  Table [dbo].[HintQuestion]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HintQuestion](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Text] [varchar](256) NOT NULL,
	[ShortText] [varchar](100) NULL,
	[iDisplayOrder] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_HintQuestion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[HintQuestion]  WITH CHECK ADD  CONSTRAINT [FK_HintQuestion_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[HintQuestion] CHECK CONSTRAINT [FK_HintQuestion_Applications]
GO
ALTER TABLE [dbo].[HintQuestion] ADD  CONSTRAINT [DF_HintQuestion_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
