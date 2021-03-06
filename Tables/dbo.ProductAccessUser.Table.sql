USE [Sts9Store]
GO
/****** Object:  Table [dbo].[ProductAccessUser]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProductAccessUser](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[TProductAccessId] [int] NOT NULL,
	[UserName] [varchar](256) NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[iQuantityAllowed] [int] NOT NULL,
	[Referral] [varchar](512) NULL,
	[Instructions] [varchar](512) NULL,
 CONSTRAINT [PK_ProductAccessUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'May refer to an employee who granted access. Friend of someone, etc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductAccessUser', @level2type=N'COLUMN',@level2name=N'Referral'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'May describe any other notes for the Access. Backstage passes, VIP passes, etc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductAccessUser', @level2type=N'COLUMN',@level2name=N'Instructions'
GO
ALTER TABLE [dbo].[ProductAccessUser]  WITH CHECK ADD  CONSTRAINT [FK_ProductAccessUser_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[ProductAccessUser] CHECK CONSTRAINT [FK_ProductAccessUser_aspnet_Users]
GO
ALTER TABLE [dbo].[ProductAccessUser]  WITH CHECK ADD  CONSTRAINT [FK_ProductAccessUser_ProductAccess] FOREIGN KEY([TProductAccessId])
REFERENCES [dbo].[ProductAccess] ([Id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[ProductAccessUser] CHECK CONSTRAINT [FK_ProductAccessUser_ProductAccess]
GO
ALTER TABLE [dbo].[ProductAccessUser] ADD  CONSTRAINT [DF_ProductAccessUser_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[ProductAccessUser] ADD  CONSTRAINT [DF_ProductAccessUser_iQuantityAllowed]  DEFAULT ((0)) FOR [iQuantityAllowed]
GO
