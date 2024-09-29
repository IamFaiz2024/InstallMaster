CREATE SEQUENCE dbo.CpuIdSequence
    AS INT
    START WITH 1
    INCREMENT BY 1;
GO

CREATE TABLE [dbo].[Cpu](
    [CpuId] NVARCHAR(8) DEFAULT ('CPU' + RIGHT('0000' + CAST(NEXT VALUE FOR dbo.CpuIdSequence AS NVARCHAR), 4)) PRIMARY KEY,
    [Model] NVARCHAR(100) NULL,
    [Manufacturer] NVARCHAR(100) NULL,
    [SocketType] NVARCHAR(100) NULL,
    [Category] NVARCHAR(30) NULL,
    [CompatibleDevice] NVARCHAR(MAX) NULL
)
GO