USE [Sts9Store]
GO
/****** Object:  Table [dbo].[MerchStock]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MerchStock](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[GUID] [uniqueidentifier] NOT NULL,
	[SessionId] [varchar](256) NOT NULL,
	[UserName] [varchar](256) NOT NULL,
	[tMerchId] [int] NOT NULL,
	[iQty] [int] NOT NULL,
	[dtTTL] [datetime] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_MerchStock] PRIMARY KEY CLUSTERED 
(
	[GUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[MerchStock] ADD  CONSTRAINT [DF_MerchStock_SessionId]  DEFAULT ('null') FOR [SessionId]
GO
ALTER TABLE [dbo].[MerchStock] ADD  CONSTRAINT [DF_MerchStock_UserName]  DEFAULT ('') FOR [UserName]
GO
ALTER TABLE [dbo].[MerchStock] ADD  CONSTRAINT [DF_MerchStock_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
