USE [MaintenanceInventory]
GO

/****** Object:  Table [dbo].[Device]    Script Date: 7/31/2024 11:07:12 AM ******/

DROP TABLE [dbo].[Cpu]
DROP TABLE [dbo].[Device]
DROP TABLE [dbo].[Memory]
DROP TABLE [dbo].[Motherboard]
DROP TABLE [dbo].[Networkcard]
DROP TABLE [dbo].[Storage]
DROP SEQUENCE [dbo].[CpuIDSequence]
DROP SEQUENCE [dbo].[DeviceIDSequence]
DROP SEQUENCE [dbo].[MemoryIDSequence]
DROP SEQUENCE [dbo].[MotherboardIDSequence]
DROP SEQUENCE [dbo].[NetworkcardIDSequence]
DROP SEQUENCE [dbo].[StrorageIDSequence]
DROP TRIGGER [dbo].[GenerateDeviceID]
DROP TRIGGER [dbo].[GenerateCpuID]
DROP TRIGGER [dbo].[GenerateMemoryID]
DROP TRIGGER [dbo].[GenerateMotherboardID]
DROP TRIGGER [dbo].[GenerateNetworkcardID]
DROP TRIGGER [dbo].[GenerateStorageID]
GO


