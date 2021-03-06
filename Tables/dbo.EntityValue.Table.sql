USE [Sts9Store]
GO
/****** Object:  Table [dbo].[EntityValue]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EntityValue](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtCreated] [datetime] NOT NULL,
	[dtModified] [datetime] NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[iDisplayOrder] [int] NOT NULL,
	[vcContext] [varchar](256) NULL,
	[vcTableRelation] [varchar](256) NULL,
	[tParentId] [int] NULL,
	[vcValueContext] [varchar](150) NOT NULL,
	[vcValueType] [varchar](50) NOT NULL,
	[vcValue] [varchar](2000) NOT NULL,
 CONSTRAINT [PK_EntityValue] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'-1 also describes a non active member' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EntityValue', @level2type=N'COLUMN',@level2name=N'iDisplayOrder'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'for instance, if the row is to be used a a lookup member' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EntityValue', @level2type=N'COLUMN',@level2name=N'vcContext'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'null value indicates the default - of string' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EntityValue', @level2type=N'COLUMN',@level2name=N'vcValueType'
GO
ALTER TABLE [dbo].[EntityValue] ADD  CONSTRAINT [DF_Table_1_dtStamp]  DEFAULT (getdate()) FOR [dtCreated]
GO
ALTER TABLE [dbo].[EntityValue] ADD  CONSTRAINT [DF_EntityValue_iDisplayOrder]  DEFAULT ((-1)) FOR [iDisplayOrder]
GO
ALTER TABLE [dbo].[EntityValue] ADD  CONSTRAINT [DF_EntityValue_vcValueType]  DEFAULT ('string') FOR [vcValueType]
GO
