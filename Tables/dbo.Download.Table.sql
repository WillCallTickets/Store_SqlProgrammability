USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Download]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Download](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[TrackNumber] [varchar](10) NULL,
	[Title] [varchar](500) NOT NULL,
	[vcFileContext] [varchar](50) NULL,
	[vcTrackContext] [varchar](50) NULL,
	[vcGenre] [varchar](50) NULL,
	[vcKeywords] [varchar](500) NULL,
	[TActId] [int] NULL,
	[BaseStoragePath] [varchar](500) NULL,
	[ApplicationName] [varchar](256) NOT NULL,
	[Compilation] [varchar](500) NULL,
	[Artist] [varchar](500) NULL,
	[Album] [varchar](500) NULL,
	[FileName] [varchar](256) NULL,
	[vcFormat] [varchar](50) NULL,
	[FileBinary] [image] NULL,
	[FileTime] [varchar](50) NULL,
	[iFileBytes] [int] NOT NULL,
	[SampleFile] [varchar](500) NULL,
	[SampleBinary] [varchar](500) NULL,
	[iSampleClick] [int] NOT NULL,
	[iAttempted] [int] NOT NULL,
	[iSuccessful] [int] NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[dtLastValidated] [datetime] NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Download] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Title of the track - should not include track number (usually)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'Title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tells us if it is a music file, data file, picture, report, etc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'vcFileContext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Refers to singletrack, fullalbum, side1, side2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'vcTrackContext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A comma separated list of applicable genres' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'vcGenre'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A comma separated list of keywords that are applicable to the download' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'vcKeywords'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Path to where downloads are stored - perhaps a dir off the virtual directory' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'BaseStoragePath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sometimes albums are sold as sets' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'Compilation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Could also be something like - random tunes 1998' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'Album'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'File name of the download' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'FileName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Csv, Mp3, Ogg Vorbis, jpg, tiff' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'vcFormat'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Only used if storing file in the db' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'FileBinary'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Length of a song - user supplied' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'FileTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of bytes in the file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'iFileBytes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A shortened version of the whole file - a snippet for "listen to" for sales' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'SampleFile'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Use if we are storing sample/file in db' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'SampleBinary'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'COunt of clicks for the sample - roughly how many times have people listened to this' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'iSampleClick'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Count of attempted downloads' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'iAttempted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Count of Successful downloads' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'iSuccessful'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'dtStamp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Holds a date for the last time file associations, etc were verified. Use for house keeping' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Download', @level2type=N'COLUMN',@level2name=N'dtLastValidated'
GO
ALTER TABLE [dbo].[Download]  WITH CHECK ADD  CONSTRAINT [FK_Download_Act] FOREIGN KEY([TActId])
REFERENCES [dbo].[Act] ([Id])
GO
ALTER TABLE [dbo].[Download] CHECK CONSTRAINT [FK_Download_Act]
GO
ALTER TABLE [dbo].[Download]  WITH CHECK ADD  CONSTRAINT [FK_Download_aspnet_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
ALTER TABLE [dbo].[Download] CHECK CONSTRAINT [FK_Download_aspnet_Applications]
GO
ALTER TABLE [dbo].[Download] ADD  CONSTRAINT [DF_Download_iFileBytes]  DEFAULT ((-1)) FOR [iFileBytes]
GO
ALTER TABLE [dbo].[Download] ADD  CONSTRAINT [DF_Table_1_iSampleClicks]  DEFAULT ((0)) FOR [iSampleClick]
GO
ALTER TABLE [dbo].[Download] ADD  CONSTRAINT [DF_Table_1_iAttempts]  DEFAULT ((0)) FOR [iAttempted]
GO
ALTER TABLE [dbo].[Download] ADD  CONSTRAINT [DF_Table_1_iSuccesses]  DEFAULT ((0)) FOR [iSuccessful]
GO
ALTER TABLE [dbo].[Download] ADD  CONSTRAINT [DF_Download_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
