USE [Sts9Store]
GO
/****** Object:  UserDefinedTableType [dbo].[InventoryUdt]    Script Date: 10/02/2016 18:18:17 ******/
CREATE TYPE [dbo].[InventoryUdt] AS TABLE(
	[vcParentContext] [varchar](1) NULL,
	[iParentInventoryId] [int] NULL,
	[Code] [varchar](25) NULL
)
GO
