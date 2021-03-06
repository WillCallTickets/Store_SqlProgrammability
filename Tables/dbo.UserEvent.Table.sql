USE [Sts9Store]
GO
/****** Object:  Table [dbo].[UserEvent]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserEvent](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[TEventQId] [int] NOT NULL,
	[dtStamp] [datetime] NULL,
 CONSTRAINT [PK_CustomerEvent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserEvent] ADD  CONSTRAINT [DF_CustomerEvent_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
