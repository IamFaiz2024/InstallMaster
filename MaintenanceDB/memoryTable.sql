CREATE TABLE Memory (
    MemoryID NVARCHAR(20) PRIMARY KEY,
    Model NVARCHAR (100),    
    Manufacturer NVARCHAR(100),
    MemoryType NVARCHAR(100),
    PartNumber NVARCHAR(30),
    Speed NVARCHAR(50),
    Capacity NVARCHAR(30),    
    Category NVARCHAR(30),
    CompatibleDevice NVARCHAR(MAX)    
);

CREATE SEQUENCE MemoryIDSequence
    START WITH 1000
    INCREMENT BY 1;

GO

CREATE TRIGGER GenerateMemoryID
ON Memory
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MemoryID NVARCHAR(20);
    SELECT @MemoryID = 'MEM-' + RIGHT('00000' + CAST(NEXT VALUE FOR MemoryIDSequence AS NVARCHAR(5)), 5) FROM inserted;
    INSERT INTO Memory (MemoryID,Model,Manufacturer,MemoryType,PartNumber,Speed,Capacity,Category,CompatibleDevice)
    SELECT @MemoryID,Model,Manufacturer,MemoryType,PartNumber,Speed,Capacity,Category,CompatibleDevice
    FROM inserted;
END;