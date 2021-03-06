USE [Sts9Store]
GO
/****** Object:  Table [dbo].[User_PreviousEmail]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User_PreviousEmail](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[EmailAddress] [varchar](256) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_User_PreviousEmail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[User_PreviousEmail] ADD  CONSTRAINT [DF_User_PreviousEmail_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
