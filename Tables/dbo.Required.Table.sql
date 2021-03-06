USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Required]    Script Date: 10/02/2016 18:17:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Required](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NOT NULL,
	[bActive] [bit] NOT NULL,
	[bExclusive] [bit] NOT NULL,
	[dtStart] [datetime] NULL,
	[dtEnd] [datetime] NULL,
	[vcRequiredContext] [varchar](50) NOT NULL,
	[vcIdx] [varchar](100) NULL,
	[iRequiredQty] [int] NOT NULL,
	[mMinAmount] [money] NOT NULL,
	[Description] [varchar](500) NULL,
 CONSTRAINT [PK_Required] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If exclusive - the requirement can be the only item in the order. Ignored for shipping contexts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Required', @level2type=N'COLUMN',@level2name=N'bExclusive'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'A description(friendly) to show the user - what they need to meet the requirement' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Required', @level2type=N'COLUMN',@level2name=N'Description'
GO
ALTER TABLE [dbo].[Required] ADD  CONSTRAINT [DF_Required_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[Required] ADD  CONSTRAINT [DF_Required_bActive]  DEFAULT ((1)) FOR [bActive]
GO
ALTER TABLE [dbo].[Required] ADD  CONSTRAINT [DF_Required_bExclusive]  DEFAULT ((0)) FOR [bExclusive]
GO
ALTER TABLE [dbo].[Required] ADD  CONSTRAINT [DF_Required_iRequiredQty]  DEFAULT ((1)) FOR [iRequiredQty]
GO
ALTER TABLE [dbo].[Required] ADD  CONSTRAINT [DF_Required_mMinMerch]  DEFAULT ((0.0)) FOR [mMinAmount]
GO
