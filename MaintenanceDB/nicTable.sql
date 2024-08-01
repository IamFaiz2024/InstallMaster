CREATE TABLE NIC (
    NICID NVARCHAR(20) PRIMARY KEY,
    Model NVARCHAR (100),    
    Manufacturer NVARCHAR(100),    
    ConnectionType NVARCHAR(100),    
    CompatibleDevice NVARCHAR(MAX)    
);

CREATE SEQUENCE NICIDSequence
    START WITH 1000
    INCREMENT BY 1;

GO

CREATE TRIGGER GenerateNICID
ON NIC
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NICID NVARCHAR(20);
    SELECT @NICID = 'NIC-' + RIGHT('00000' + CAST(NEXT VALUE FOR NICIDSequence AS NVARCHAR(5)), 5) FROM inserted;
    INSERT INTO NIC (NICID,Model,Manufacturer,ConnectionType,CompatibleDevice)
    SELECT @NICID,Model,Manufacturer,ConnectionType,CompatibleDevice
    FROM inserted;
END;