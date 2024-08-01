CREATE TABLE Cpu (
    CpuID NVARCHAR(20) PRIMARY KEY,
    --SerialNumber NVARCHAR(100),
    Model NVARCHAR(100),
    Manufacturer NVARCHAR(100),
    SocketType NVARCHAR(100),	
	Category NVARCHAR(30)
    CompatibleDevice NVARCHAR(MAX)
);

CREATE SEQUENCE CpuIDSequence
    START WITH 1000
    INCREMENT BY 1
GO	
CREATE TRIGGER GenerateCpuID
ON Cpu
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CpuID NVARCHAR(20);
    SELECT @CpuID = 'CPU-' + RIGHT('00000' + CAST(NEXT VALUE FOR CpuIDSequence AS NVARCHAR(5)), 5) FROM inserted;

    INSERT INTO Cpu (CpuID, Model, Manufacturer, SocketType, Category,CompatibleDevice)
    SELECT @CpuID, Model, Manufacturer, SocketType, Category,CompatibleDevice
    FROM inserted;
END;