USE [Sts9Store]
GO
/****** Object:  Table [dbo].[PendingOperation]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingOperation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[IdentifierId] [int] NOT NULL,
	[dtValidUntil] [datetime] NOT NULL,
	[vcContext] [varchar](256) NOT NULL,
	[UserName] [varchar](300) NOT NULL,
	[Criteria] [varchar](256) NULL,
 CONSTRAINT [PK_PendingOperation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[PendingOperation] ADD  CONSTRAINT [DF_PendingOperation_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
