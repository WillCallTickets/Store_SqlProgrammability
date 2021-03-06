USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Cashew]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Cashew](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[eNumber] [varchar](75) NOT NULL,
	[eMonth] [varchar](75) NOT NULL,
	[eYear] [varchar](75) NOT NULL,
	[eName] [varchar](75) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[CustomerId] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_Cassius] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Cashew]  WITH CHECK ADD  CONSTRAINT [FK_Cashew_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Cashew] CHECK CONSTRAINT [FK_Cashew_aspnet_Users]
GO
ALTER TABLE [dbo].[Cashew] ADD  CONSTRAINT [DF_Cassius_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
