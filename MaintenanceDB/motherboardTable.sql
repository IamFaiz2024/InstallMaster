CREATE TABLE Motherboard (
    MotherboardID NVARCHAR(20) PRIMARY KEY,
    Model NVARCHAR (100),    
    Manufacturer NVARCHAR(100),    
    Product NVARCHAR(30),
    BIOSVersion NVARCHAR(100),    
    Category NVARCHAR(30),
    CompatibleDevice NVARCHAR(MAX)    
);

CREATE SEQUENCE MotherboardIDSequence
    START WITH 1000
    INCREMENT BY 1;

GO

CREATE TRIGGER GenerateMotherboardID
ON Motherboard
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MotherboardID NVARCHAR(20);
    SELECT @MotherboardID = 'MBB-' + RIGHT('00000' + CAST(NEXT VALUE FOR MotherboardIDSequence AS NVARCHAR(5)), 5) FROM inserted;
    INSERT INTO Motherboard (MotherboardID,Model,Manufacturer,Product,BIOSVersion,Category,CompatibleDevice)
    SELECT @MotherboardID,Model,Manufacturer,Product,BIOSVersion,Category,CompatibleDevice
    FROM inserted;
END;