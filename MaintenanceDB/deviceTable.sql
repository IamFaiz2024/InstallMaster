CREATE TABLE Device (
    DeviceID NVARCHAR(20) PRIMARY KEY,
    CurrentBIOSVersion NVARCHAR (100),
    Model NVARCHAR(100),
    Manufacturer NVARCHAR(100),
    PartNumber NVARCHAR(30),
    DeviceType NVARCHAR(30),
    Category NVARCHAR(30),
    ModelYear DATE
);

CREATE SEQUENCE DeviceIDSequence
    START WITH 1000
    INCREMENT BY 1;

GO

CREATE TRIGGER GenerateDeviceID
ON Device
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DeviceID NVARCHAR(20);
    SELECT @DeviceID = 'DEV-' + RIGHT('00000' + CAST(NEXT VALUE FOR DeviceIDSequence AS NVARCHAR(5)), 5) FROM inserted;
    INSERT INTO Device (DeviceID,CurrentBIOSVersion,Model,Manufacturer,PartNumber,DeviceType,Category,ModelYear)
    SELECT @DeviceID,CurrentBIOSVersion,Model,Manufacturer,PartNumber,DeviceType,Category,ModelYear
    FROM inserted;
END;