USE [Sts9Store]
GO
/****** Object:  Table [dbo].[aspnet_Users_Old]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[aspnet_Users_Old](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[TCustomerId] [int] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[UserName] [varchar](300) NOT NULL,
	[oldPass] [varchar](256) NOT NULL,
	[dtUpdated] [datetime] NULL,
	[IpAddress] [varchar](25) NULL,
 CONSTRAINT [PK_aspnet_UsersOld] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[aspnet_Users_Old] ADD  CONSTRAINT [DF_aspnet_UsersOld_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
