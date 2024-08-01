CREATE TABLE Storage (
    StorageID NVARCHAR(20) PRIMARY KEY,
    Model NVARCHAR (100),    
    Manufacturer NVARCHAR(100),    
    Capacity NVARCHAR(100),    
    InterfaceType NVARCHAR(100), 
    CompatibleDevice NVARCHAR(MAX)
);

CREATE SEQUENCE StorageIDSequence
    START WITH 1000
    INCREMENT BY 1;

GO

CREATE TRIGGER GenerateStorageID
ON Storage
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StorageID NVARCHAR(20);
    SELECT @StorageID = 'STO-' + RIGHT('00000' + CAST(NEXT VALUE FOR StorageIDSequence AS NVARCHAR(5)), 5) FROM inserted;
    INSERT INTO Storage (StorageID,Model,Manufacturer,Capacity,InterfaceType,CompatibleDevice)
    SELECT @StorageID,Model,Manufacturer,Capacity,InterfaceType,CompatibleDevice
    FROM inserted;
END;