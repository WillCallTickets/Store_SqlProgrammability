USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Search]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Search](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[vcContext] [varchar](50) NOT NULL,
	[Terms] [nvarchar](256) NOT NULL,
	[iResults] [int] NOT NULL,
	[EmailAddress] [varchar](256) NOT NULL,
	[IpAddress] [varchar](25) NOT NULL,
 CONSTRAINT [PK_Search] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Search]  WITH CHECK ADD  CONSTRAINT [FK_Search_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[Search] CHECK CONSTRAINT [FK_Search_aspnet_Applications]
GO
ALTER TABLE [dbo].[Search] ADD  CONSTRAINT [DF_Search_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[Search] ADD  CONSTRAINT [DF_Search_iResults]  DEFAULT ((0)) FOR [iResults]
GO
