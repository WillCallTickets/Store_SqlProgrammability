USE [Sts9Store]
GO
/****** Object:  Table [dbo].[InvoiceFee]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InvoiceFee](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[bActive] [bit] NOT NULL,
	[bOverride] [bit] NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[Description] [varchar](300) NOT NULL,
	[mPrice] [money] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_InvoiceFee] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[InvoiceFee]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceFee_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[InvoiceFee] CHECK CONSTRAINT [FK_InvoiceFee_Aspnet_Applications]
GO
ALTER TABLE [dbo].[InvoiceFee] ADD  CONSTRAINT [DF_InvoiceFee_bActive]  DEFAULT ((0)) FOR [bActive]
GO
ALTER TABLE [dbo].[InvoiceFee] ADD  CONSTRAINT [DF_InvoiceFee_bOverride]  DEFAULT ((0)) FOR [bOverride]
GO
ALTER TABLE [dbo].[InvoiceFee] ADD  CONSTRAINT [DF_InvoiceFee_DtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
