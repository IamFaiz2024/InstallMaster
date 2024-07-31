/*
CREATE TRIGGER GenerateDeviceID
ON Device
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DeviceID NVARCHAR(20);
    SELECT @DeviceID = 'DEV-' + RIGHT('00000' + CAST(NEXT VALUE FOR DeviceIDSequence AS NVARCHAR(5)), 5) FROM inserted;

    INSERT INTO Device (DeviceID, Model, Manufacturer, PartNumber, DeviceType, Category, ModelYear)
    SELECT @DeviceID, Model, Manufacturer, PartNumber, DeviceType, Category, ModelYear
END;

CREATE TRIGGER GenerateMemoryID
ON Memory
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MemoryID NVARCHAR(20);
    SELECT @MemoryID = 'MEM-' + RIGHT('00000' + CAST(NEXT VALUE FOR MemoryIDSequence AS NVARCHAR(5)), 5) FROM inserted;

    INSERT INTO Memory (MemoryID, Model, Manufacturer, PartNumber, Speed, Capacity, MemoryType, Category)
    SELECT @MemoryID, Model, Manufacturer, PartNumber, Speed, Capacity, MemoryType,Category  FROM Memory
END;

CREATE TRIGGER GenerateMotherboardID
ON Motherboard
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MotherboardID NVARCHAR(20);
    SELECT @MotherboardID = 'MBB-' + RIGHT('00000' + CAST(NEXT VALUE FOR MotherboardIDSequence AS NVARCHAR(5)), 5) FROM inserted;

    INSERT INTO Motherboard (MotherboardID, Model, Manufacturer, PartNumber, LatestBiosVersion, Category)
    SELECT @MotherboardID, Model, Manufacturer, PartNumber, LatestBiosVersion, Category
END;


CREATE TRIGGER GenerateNetworkworkcardID
ON Networkworkcard
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NetworkworkcardID NVARCHAR(20);
    SELECT @NetworkworkcardID = 'NET-' + RIGHT('00000' + CAST(NEXT VALUE FOR NetworkworkcardIDSequence AS NVARCHAR(5)), 5) FROM inserted;

    INSERT INTO Networkworkcard (NetworkworkcardID, MACAddress, Model, Manufacturer, ConnectionType, Category)
    SELECT @NetworkworkcardID, MACAddress, Model, Manufacturer, ConnectionType, Category
END;

CREATE TRIGGER GenerateStorageID
ON Storage
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StorageID NVARCHAR(20);
    SELECT @StorageID = 'STO-' + RIGHT('00000' + CAST(NEXT VALUE FOR StorageIDSequence AS NVARCHAR(5)), 5) FROM inserted;

    INSERT INTO Storage (StorageID, SerialNumber, Model, Manufacturer, InterfaceType, Capacity, Category)
    SELECT @StorageID, SerialNumber, Model, Manufacturer, InterfaceType, Capacity, Category
END;

CREATE TRIGGER GenerateCpuID
ON Cpu
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CpuID NVARCHAR(20);
    SELECT @CpuID = 'CPU-' + RIGHT('00000' + CAST(NEXT VALUE FOR CpuIDSequence AS NVARCHAR(5)), 5) FROM inserted;

    INSERT INTO Cpu (CpuID, SerialNumber, Model, Manufacturer, InterfaceType, Capacity, Category)
    SELECT @CpuID, SerialNumber, Model, Manufacturer, InterfaceType, Capacity, Category
END;
*/