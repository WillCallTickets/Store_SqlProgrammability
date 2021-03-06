USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Venue]    Script Date: 10/02/2016 18:17:20 ******/
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
SET ARITHABORT ON
GO
CREATE TABLE [dbo].[Venue](
	[Id] [int] IDENTITY(10000,1) NOT FOR REPLICATION NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[NameRoot]  AS (case when charindex('the ',[Name])<>(1) then upper([Name]) else upper(substring([Name],(5),len([Name]))) end),
	[DisplayName] [varchar](256) NULL,
	[iCapacity] [int] NULL,
	[PictureUrl] [varchar](300) NULL,
	[iPicWidth] [int] NOT NULL,
	[iPicHeight] [int] NOT NULL,
	[WebsiteUrl] [varchar](300) NULL,
	[ShortAddress] [varchar](500) NULL,
	[Address] [varchar](150) NULL,
	[City] [varchar](100) NULL,
	[State] [varchar](50) NULL,
	[ZipCode] [varchar](10) NULL,
	[Country] [varchar](256) NULL,
	[Latitude] [varchar](50) NULL,
	[Longitude] [varchar](50) NULL,
	[BoxOfficePhone] [varchar](100) NULL,
	[BoxOfficePhoneExt] [varchar](100) NULL,
	[BoxOfficeNotes] [varchar](500) NULL,
	[MainPhone] [varchar](100) NULL,
	[MainPhoneExt] [varchar](100) NULL,
	[Notes] [varchar](500) NULL,
	[dtStamp] [datetime] NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Venue] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Venue]  WITH CHECK ADD  CONSTRAINT [FK_Venue_Aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[Venue] CHECK CONSTRAINT [FK_Venue_Aspnet_Applications]
GO
ALTER TABLE [dbo].[Venue] ADD  CONSTRAINT [DF_Venue_PicWidth]  DEFAULT ((0)) FOR [iPicWidth]
GO
ALTER TABLE [dbo].[Venue] ADD  CONSTRAINT [DF_Venue_PicHeight]  DEFAULT ((0)) FOR [iPicHeight]
GO
ALTER TABLE [dbo].[Venue] ADD  CONSTRAINT [DF_Venue_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
