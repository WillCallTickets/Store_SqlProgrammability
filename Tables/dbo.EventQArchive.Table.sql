USE [Sts9Store]
GO
/****** Object:  Table [dbo].[EventQArchive]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EventQArchive](
	[Id] [int] NOT NULL,
	[dtStamp] [datetime] NULL,
	[DateToProcess] [datetime] NULL,
	[DateProcessed] [datetime] NULL,
	[Status] [varchar](2000) NULL,
	[Threadlock] [uniqueidentifier] NULL,
	[AttemptsRemaining] [int] NULL,
	[iPriority] [int] NULL,
	[CreatorId] [uniqueidentifier] NULL,
	[CreatorName] [varchar](256) NULL,
	[UserId] [uniqueidentifier] NULL,
	[UserName] [varchar](256) NULL,
	[Context] [varchar](50) NULL,
	[Verb] [varchar](50) NULL,
	[OldValue] [varchar](1500) NULL,
	[NewValue] [varchar](1500) NULL,
	[Description] [varchar](2000) NULL,
	[IP] [varchar](20) NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_EventQArchive] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
