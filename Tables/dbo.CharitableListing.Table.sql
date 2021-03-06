USE [Sts9Store]
GO
/****** Object:  Table [dbo].[CharitableListing]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CharitableListing](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[tCharitableOrgId] [int] NOT NULL,
	[iDisplayOrder] [int] NOT NULL,
	[bAvailableForContribution] [bit] NOT NULL,
	[bTopBilling] [bit] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_CharitableListing] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CharitableListing]  WITH CHECK ADD  CONSTRAINT [FK_CharitableListing_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[CharitableListing] CHECK CONSTRAINT [FK_CharitableListing_aspnet_Applications]
GO
ALTER TABLE [dbo].[CharitableListing]  WITH CHECK ADD  CONSTRAINT [FK_CharitableListing_Org] FOREIGN KEY([tCharitableOrgId])
REFERENCES [dbo].[CharitableOrg] ([Id])
GO
ALTER TABLE [dbo].[CharitableListing] CHECK CONSTRAINT [FK_CharitableListing_Org]
GO
ALTER TABLE [dbo].[CharitableListing] ADD  CONSTRAINT [DF_CharitableListing_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[CharitableListing] ADD  CONSTRAINT [DF_CharitableListing_bAvailableForDonation]  DEFAULT ((1)) FOR [bAvailableForContribution]
GO
