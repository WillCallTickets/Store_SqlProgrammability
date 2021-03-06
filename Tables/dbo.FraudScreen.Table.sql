USE [Sts9Store]
GO
/****** Object:  Table [dbo].[FraudScreen]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FraudScreen](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[CreatedById] [uniqueidentifier] NOT NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[vcAction] [varchar](50) NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[FirstName] [varchar](256) NULL,
	[MI] [varchar](2) NULL,
	[LastName] [varchar](256) NULL,
	[FullName]  AS ((isnull([FirstName],'')+case when [MI] IS NOT NULL AND len([MI])>(0) then ' '+[MI] else '' end)+case when [LastName] IS NOT NULL AND len([LastName])>(0) then ' '+[LastName] else '' end),
	[NameOnCard] [varchar](256) NULL,
	[City] [varchar](100) NULL,
	[Zip] [varchar](25) NULL,
	[CreditCardNum] [varchar](50) NULL,
	[LastFourDigits] [char](4) NULL,
	[UserIp] [varchar](25) NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_FraudScreen] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[FraudScreen]  WITH CHECK ADD  CONSTRAINT [FK_FraudScreen_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[FraudScreen] CHECK CONSTRAINT [FK_FraudScreen_aspnet_Applications]
GO
ALTER TABLE [dbo].[FraudScreen]  WITH CHECK ADD  CONSTRAINT [FK_FraudScreen_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[FraudScreen] CHECK CONSTRAINT [FK_FraudScreen_aspnet_Users]
GO
ALTER TABLE [dbo].[FraudScreen]  WITH CHECK ADD  CONSTRAINT [FK_FraudScreen_aspnet_Users1] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[FraudScreen] CHECK CONSTRAINT [FK_FraudScreen_aspnet_Users1]
GO
ALTER TABLE [dbo].[FraudScreen] ADD  CONSTRAINT [DF_FraudScreen_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
