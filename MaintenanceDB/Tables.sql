CREATE TABLE Device (
    DeviceID NVARCHAR(20) PRIMARY KEY,    
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

/*
CREATE TABLE Motherboard (
    MotherboardID NVARCHAR(20) PRIMARY KEY,    
    Model NVARCHAR(100),
    Manufacturer NVARCHAR(100),
    PartNumber NVARCHAR(30),
	LatestBiosVersion NVARCHAR(100),   
    Category NVARCHAR(50)    
);

CREATE SEQUENCE MotherboardIDSequence
    START WITH 1000
    INCREMENT BY 1;


CREATE TABLE Memory (
    MemoryID NVARCHAR(20) PRIMARY KEY,    
    Model NVARCHAR(100),
    Manufacturer NVARCHAR(100),
    PartNumber NVARCHAR(30),
	Speed NVARCHAR(100),   
    Capacity NVARCHAR(50),
	MemoryType NVARCHAR(100),
	Category NVARCHAR(30)
);

CREATE SEQUENCE MemoryIDSequence
    START WITH 1000
    INCREMENT BY 1;

CREATE TABLE Networkworkcard (
    NetworkworkcardID NVARCHAR(20) PRIMARY KEY,
    MACAddress NVARCHAR(100),
    Model NVARCHAR(100),
    Manufacturer NVARCHAR(100),
    ConnectionType NVARCHAR(30),
	Category NVARCHAR(30)
);

CREATE SEQUENCE NetworkworkcardIDSequence
    START WITH 1000
    INCREMENT BY 1;

CREATE TABLE Storage (
    StorageID NVARCHAR(20) PRIMARY KEY,
    SerialNumber NVARCHAR(100),
    Model NVARCHAR(100),
    Manufacturer NVARCHAR(100),
    InterfaceType NVARCHAR(100),
	Capacity NVARCHAR(100),
	Category NVARCHAR(30)
);

CREATE SEQUENCE StorageIDSequence
    START WITH 1000
    INCREMENT BY 1;


CREATE TABLE Cpu (
    CpuID NVARCHAR(20) PRIMARY KEY,
    SerialNumber NVARCHAR(100),
    Model NVARCHAR(100),
    Manufacturer NVARCHAR(100),
    SocketType NVARCHAR(100),
	Capacity NVARCHAR(100),
	Category NVARCHAR(30)
);

CREATE SEQUENCE CpuIDSequence
    START WITH 1000
    INCREMENT BY 1;


*/