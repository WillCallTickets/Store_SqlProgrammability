USE [Sts9Store]
GO
/****** Object:  Table [dbo].[Lottery]    Script Date: 10/02/2016 18:17:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Lottery](
	[Id] [int] IDENTITY(10000,1) NOT NULL,
	[dtStamp] [datetime] NULL,
	[TShowTicketId] [int] NOT NULL,
	[TShowDateId] [int] NOT NULL,
	[TShowId] [int] NOT NULL,
	[bActiveSignup] [bit] NOT NULL,
	[dtSignupStart] [datetime] NULL,
	[dtSignupEnd] [datetime] NULL,
	[Name] [varchar](50) NULL,
	[Description] [varchar](500) NULL,
	[DisplayText] [varchar](256) NULL,
	[Writeup] [varchar](max) NULL,
	[bActiveFulfillment] [bit] NOT NULL,
	[dtFulfillStart] [datetime] NULL,
	[dtFulfillEnd] [datetime] NULL,
	[iEstablishQty] [int] NOT NULL,
 CONSTRAINT [PK_Lottery] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Lottery]  WITH CHECK ADD  CONSTRAINT [FK_Lottery_ShowTicket] FOREIGN KEY([TShowTicketId])
REFERENCES [dbo].[ShowTicket] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Lottery] CHECK CONSTRAINT [FK_Lottery_ShowTicket]
GO
ALTER TABLE [dbo].[Lottery] ADD  CONSTRAINT [DF_Lottery_dtStamp]  DEFAULT (getdate()) FOR [dtStamp]
GO
ALTER TABLE [dbo].[Lottery] ADD  CONSTRAINT [DF_Lottery_bActive]  DEFAULT ((0)) FOR [bActiveSignup]
GO
ALTER TABLE [dbo].[Lottery] ADD  CONSTRAINT [DF_Lottery_bActiveFulfillment]  DEFAULT ((0)) FOR [bActiveFulfillment]
GO
ALTER TABLE [dbo].[Lottery] ADD  CONSTRAINT [DF_Lottery_iEstablishQty]  DEFAULT ((0)) FOR [iEstablishQty]
GO
