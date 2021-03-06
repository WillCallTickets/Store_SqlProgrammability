USE [Sts9Store]
GO
/****** Object:  Table [dbo].[EmailParam]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmailParam](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](8000) NOT NULL,
	[TMailQueueId] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_EmailParam] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[EmailParam]  WITH NOCHECK ADD  CONSTRAINT [FK_EmailParam_MailQueue] FOREIGN KEY([TMailQueueId])
REFERENCES [dbo].[MailQueue] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EmailParam] CHECK CONSTRAINT [FK_EmailParam_MailQueue]
GO
ALTER TABLE [dbo].[EmailParam] ADD  CONSTRAINT [DF_EmailParam_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
