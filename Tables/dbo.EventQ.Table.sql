USE [Sts9Store]
GO
/****** Object:  Table [dbo].[EventQ]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EventQ](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[DateToProcess] [datetime] NULL,
	[DateProcessed] [datetime] NULL,
	[Status] [varchar](2000) NULL,
	[ThreadLock] [uniqueidentifier] NULL,
	[AttemptsRemaining] [int] NULL,
	[iPriority] [int] NOT NULL,
	[CreatorId] [uniqueidentifier] NULL,
	[CreatorName] [varchar](256) NULL,
	[UserId] [uniqueidentifier] NULL,
	[UserName] [varchar](256) NULL,
	[Context] [varchar](50) NOT NULL,
	[Verb] [varchar](50) NOT NULL,
	[OldValue] [varchar](1500) NULL,
	[NewValue] [varchar](1500) NULL,
	[Description] [varchar](2000) NULL,
	[IP] [varchar](20) NULL,
	[dtStamp] [datetime] NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_EventQ] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[EventQ]  WITH CHECK ADD  CONSTRAINT [FK_EventQ_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[EventQ] CHECK CONSTRAINT [FK_EventQ_Aspnet_Applications]
GO
ALTER TABLE [dbo].[EventQ] ADD  CONSTRAINT [DF_EventQ_AttemptsRemaining]  DEFAULT ((3)) FOR [AttemptsRemaining]
GO
ALTER TABLE [dbo].[EventQ] ADD  CONSTRAINT [DF_EventQ_iPriority]  DEFAULT ((0)) FOR [iPriority]
GO
ALTER TABLE [dbo].[EventQ] ADD  CONSTRAINT [DF_EventQ_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
