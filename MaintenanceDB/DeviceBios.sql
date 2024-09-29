CREATE SEQUENCE dbo.BiosIdSequence
    AS INT
    START WITH 1
    INCREMENT BY 1;
GO

CREATE TABLE [dbo].[DeviceBios](
    [BiosId] NVARCHAR(8) DEFAULT ('Bios' + RIGHT('0000' + CAST(NEXT VALUE FOR dbo.BiosIdSequence AS NVARCHAR), 4)) PRIMARY KEY,
    [Manufacturer] NVARCHAR(100) NOT NULL,
    [PartNumber] NVARCHAR(100) NOT NULL,
    [Model] NVARCHAR(100) NULL,
    [LatestBIOSVersion] NVARCHAR(100) NOT NULL,
    [ReleaseDate] DATETIME NOT NULL
)
GO