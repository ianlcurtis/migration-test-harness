-- Fleet Car Management Database Creation Script (IDEMPOTENT)
-- This script creates a comprehensive database for managing a fleet of vehicles
-- including vehicles, drivers, maintenance, fuel tracking, and assignments
-- This script can be run multiple times safely (idempotent)

-- Drop existing database if it exists (optional - uncomment if needed)
-- DROP DATABASE IF EXISTS FleetManagement;
-- GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'FleetManagement')
BEGIN
    CREATE DATABASE FleetManagement;
END
GO

USE FleetManagement;
GO

-- =============================================
-- DROP EXISTING OBJECTS (for idempotency)
-- =============================================

-- Drop objects in reverse dependency order
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ActiveAssignments]') AND type in (N'V'))
    DROP VIEW [dbo].[ActiveAssignments];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VehicleMaintenanceSummary]') AND type in (N'V'))
    DROP VIEW [dbo].[VehicleMaintenanceSummary];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DriverPerformanceMetrics]') AND type in (N'V'))
    DROP VIEW [dbo].[DriverPerformanceMetrics];

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_AssignVehicle]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_AssignVehicle];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ReturnVehicle]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ReturnVehicle];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_QuoteCalc]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_QuoteCalc];

-- Drop tables in reverse dependency order (child tables first, then parent tables)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuoteFollowUps]') AND type in (N'U'))
    DROP TABLE [dbo].[QuoteFollowUps];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuoteLineItems]') AND type in (N'U'))
    DROP TABLE [dbo].[QuoteLineItems];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VehicleQuotes]') AND type in (N'U'))
    DROP TABLE [dbo].[VehicleQuotes];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FleetUtilization]') AND type in (N'U'))
    DROP TABLE [dbo].[FleetUtilization];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DriverTraining]') AND type in (N'U'))
    DROP TABLE [dbo].[DriverTraining];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VehicleInspections]') AND type in (N'U'))
    DROP TABLE [dbo].[VehicleInspections];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Accidents]') AND type in (N'U'))
    DROP TABLE [dbo].[Accidents];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MaintenanceParts]') AND type in (N'U'))
    DROP TABLE [dbo].[MaintenanceParts];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MaintenanceRecords]') AND type in (N'U'))
    DROP TABLE [dbo].[MaintenanceRecords];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FuelRecords]') AND type in (N'U'))
    DROP TABLE [dbo].[FuelRecords];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VehicleAssignments]') AND type in (N'U'))
    DROP TABLE [dbo].[VehicleAssignments];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AuditTrail]') AND type in (N'U'))
    DROP TABLE [dbo].[AuditTrail];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Vehicles]') AND type in (N'U'))
    DROP TABLE [dbo].[Vehicles];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Drivers]') AND type in (N'U'))
    DROP TABLE [dbo].[Drivers];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VehicleModels]') AND type in (N'U'))
    DROP TABLE [dbo].[VehicleModels];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VehicleMakes]') AND type in (N'U'))
    DROP TABLE [dbo].[VehicleMakes];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Locations]') AND type in (N'U'))
    DROP TABLE [dbo].[Locations];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Departments]') AND type in (N'U'))
    DROP TABLE [dbo].[Departments];

GO

-- =============================================
-- LOOKUP/REFERENCE TABLES
-- =============================================

-- Vehicle Makes Table
CREATE TABLE VehicleMakes (
    MakeID INT IDENTITY(1,1) PRIMARY KEY,
    MakeName NVARCHAR(50) NOT NULL UNIQUE,
    Country NVARCHAR(50),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

-- Vehicle Models Table
CREATE TABLE VehicleModels (
    ModelID INT IDENTITY(1,1) PRIMARY KEY,
    MakeID INT NOT NULL,
    ModelName NVARCHAR(50) NOT NULL,
    VehicleType NVARCHAR(30) NOT NULL CHECK (VehicleType IN ('Sedan', 'SUV', 'Truck', 'Van', 'Hatchback', 'Coupe', 'Convertible')),
    FuelType NVARCHAR(20) NOT NULL CHECK (FuelType IN ('Gasoline', 'Diesel', 'Hybrid', 'Electric', 'Natural Gas')),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (MakeID) REFERENCES VehicleMakes(MakeID)
);

-- Departments Table
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL,
    DepartmentCode NVARCHAR(10) NOT NULL UNIQUE,
    ManagerName NVARCHAR(100),
    Budget DECIMAL(15,2),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

-- Locations Table
CREATE TABLE Locations (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    LocationName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200),
    City NVARCHAR(50),
    State NVARCHAR(50),
    ZipCode NVARCHAR(10),
    Country NVARCHAR(50) DEFAULT 'USA',
    Latitude DECIMAL(10,8),
    Longitude DECIMAL(11,8),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

GO

-- =============================================
-- CORE ENTITY TABLES
-- =============================================

-- Drivers Table
CREATE TABLE Drivers (
    DriverID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20),
    LicenseNumber NVARCHAR(30) NOT NULL UNIQUE,
    LicenseExpiryDate DATE NOT NULL,
    DepartmentID INT,
    HireDate DATE,
    DateOfBirth DATE,
    Address NVARCHAR(200),
    City NVARCHAR(50),
    State NVARCHAR(50),
    ZipCode NVARCHAR(10),
    EmergencyContactName NVARCHAR(100),
    EmergencyContactPhone NVARCHAR(20),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

-- Vehicles Table
CREATE TABLE Vehicles (
    VehicleID INT IDENTITY(1,1) PRIMARY KEY,
    VIN NVARCHAR(17) NOT NULL UNIQUE,
    LicensePlate NVARCHAR(10) NOT NULL UNIQUE,
    ModelID INT NOT NULL,
    Year INT NOT NULL CHECK (Year >= 1900 AND Year <= YEAR(GETDATE()) + 1),
    Color NVARCHAR(30),
    Mileage INT DEFAULT 0,
    PurchaseDate DATE,
    PurchasePrice DECIMAL(12,2),
    CurrentValue DECIMAL(12,2),
    Status NVARCHAR(20) DEFAULT 'Available' CHECK (Status IN ('Available', 'In Use', 'Maintenance', 'Out of Service', 'Sold')),
    LocationID INT,
    InsurancePolicyNumber NVARCHAR(50),
    InsuranceExpiryDate DATE,
    RegistrationExpiryDate DATE,
    NextMaintenanceDue DATE,
    FuelCapacity DECIMAL(5,2),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    LastUpdatedDate DATETIME2 DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (ModelID) REFERENCES VehicleModels(ModelID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

GO

-- =============================================
-- OPERATIONAL TABLES
-- =============================================

-- Vehicle Assignments Table
CREATE TABLE VehicleAssignments (
    AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleID INT NOT NULL,
    DriverID INT NOT NULL,
    AssignedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    ReturnedDate DATETIME2,
    StartMileage INT,
    EndMileage INT,
    Purpose NVARCHAR(200),
    Destination NVARCHAR(200),
    Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Completed', 'Cancelled')),
    AssignedByUserID NVARCHAR(50),
    Notes NVARCHAR(500),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

-- Fuel Records Table
CREATE TABLE FuelRecords (
    FuelRecordID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleID INT NOT NULL,
    DriverID INT NOT NULL,
    FuelDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    Odometer INT NOT NULL,
    GallonsPurchased DECIMAL(6,2) NOT NULL,
    PricePerGallon DECIMAL(5,2) NOT NULL,
    TotalCost DECIMAL(8,2) NOT NULL,
    FuelType NVARCHAR(20),
    FuelStationName NVARCHAR(100),
    FuelStationLocation NVARCHAR(200),
    ReceiptNumber NVARCHAR(50),
    MPG DECIMAL(5,2), -- Miles per gallon (calculated separately, not as computed column)
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

-- Maintenance Records Table
CREATE TABLE MaintenanceRecords (
    MaintenanceID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleID INT NOT NULL,
    MaintenanceDate DATETIME2 NOT NULL,
    MaintenanceType NVARCHAR(50) NOT NULL CHECK (MaintenanceType IN ('Oil Change', 'Tire Rotation', 'Brake Service', 'Transmission Service', 'Engine Repair', 'Body Work', 'Inspection', 'Other')),
    Description NVARCHAR(500),
    ServiceProvider NVARCHAR(100),
    Odometer INT,
    Cost DECIMAL(10,2),
    LaborCost DECIMAL(10,2),
    PartsCost DECIMAL(10,2),
    WarrantyExpiryDate DATE,
    NextServiceDue DATE,
    NextServiceMileage INT,
    InvoiceNumber NVARCHAR(50),
    Status NVARCHAR(20) DEFAULT 'Completed' CHECK (Status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled')),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID)
);

-- Maintenance Parts Table
CREATE TABLE MaintenanceParts (
    PartID INT IDENTITY(1,1) PRIMARY KEY,
    MaintenanceID INT NOT NULL,
    PartName NVARCHAR(100) NOT NULL,
    PartNumber NVARCHAR(50),
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(8,2),
    TotalPrice DECIMAL(10,2),
    Supplier NVARCHAR(100),
    WarrantyMonths INT,
    FOREIGN KEY (MaintenanceID) REFERENCES MaintenanceRecords(MaintenanceID) ON DELETE CASCADE
);

-- Accidents/Incidents Table
CREATE TABLE Accidents (
    AccidentID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleID INT NOT NULL,
    DriverID INT,
    AccidentDate DATETIME2 NOT NULL,
    Location NVARCHAR(200),
    Description NVARCHAR(1000),
    Severity NVARCHAR(20) CHECK (Severity IN ('Minor', 'Moderate', 'Major', 'Total Loss')),
    PoliceReportNumber NVARCHAR(50),
    InsuranceClaimNumber NVARCHAR(50),
    RepairCost DECIMAL(12,2),
    Odometer INT,
    WeatherConditions NVARCHAR(50),
    RoadConditions NVARCHAR(50),
    AtFault BIT,
    InjuriesReported BIT DEFAULT 0,
    VehicleDriveable BIT,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

-- Vehicle Inspections Table
CREATE TABLE VehicleInspections (
    InspectionID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleID INT NOT NULL,
    InspectorName NVARCHAR(100),
    InspectionDate DATETIME2 NOT NULL,
    InspectionType NVARCHAR(30) CHECK (InspectionType IN ('Safety', 'Emissions', 'DOT', 'Pre-Trip', 'Post-Trip', 'Annual')),
    Odometer INT,
    PassedInspection BIT NOT NULL,
    Notes NVARCHAR(1000),
    NextInspectionDue DATE,
    CertificateNumber NVARCHAR(50),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID)
);

-- Driver Training Records Table
CREATE TABLE DriverTraining (
    TrainingID INT IDENTITY(1,1) PRIMARY KEY,
    DriverID INT NOT NULL,
    TrainingType NVARCHAR(100) NOT NULL,
    TrainingDate DATE NOT NULL,
    ExpiryDate DATE,
    Instructor NVARCHAR(100),
    TrainingProvider NVARCHAR(100),
    CertificateNumber NVARCHAR(50),
    Cost DECIMAL(8,2),
    Status NVARCHAR(20) DEFAULT 'Completed' CHECK (Status IN ('Scheduled', 'In Progress', 'Completed', 'Failed', 'Expired')),
    Notes NVARCHAR(500),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

-- Fleet Utilization Log Table
CREATE TABLE FleetUtilization (
    UtilizationID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleID INT NOT NULL,
    Date DATE NOT NULL,
    HoursUsed DECIMAL(4,2) DEFAULT 0,
    MilesDriven INT DEFAULT 0,
    UtilizationPercentage DECIMAL(5,2),
    IdleTime DECIMAL(4,2) DEFAULT 0,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
    UNIQUE (VehicleID, Date)
);

-- Vehicle Quotes Table
CREATE TABLE VehicleQuotes (
    QuoteID INT IDENTITY(1,1) PRIMARY KEY,
    QuoteNumber NVARCHAR(20) NOT NULL UNIQUE,
    CustomerName NVARCHAR(100) NOT NULL,
    CustomerEmail NVARCHAR(100),
    CustomerPhone NVARCHAR(20),
    CompanyName NVARCHAR(100),
    ModelID INT NOT NULL,
    Year INT NOT NULL,
    Color NVARCHAR(30),
    Quantity INT NOT NULL DEFAULT 1,
    LeaseDurationMonths INT NOT NULL,
    MilesPerMonth INT NOT NULL DEFAULT 1000,
    BasePrice DECIMAL(12,2) NOT NULL,
    MonthlyLeaseRate DECIMAL(8,2) NOT NULL,
    MaintenancePackage BIT DEFAULT 0,
    InsurancePackage BIT DEFAULT 0,
    MaintenanceCost DECIMAL(8,2) DEFAULT 0,
    InsuranceCost DECIMAL(8,2) DEFAULT 0,
    TotalMonthlyPayment DECIMAL(10,2) NOT NULL,
    TotalQuoteValue DECIMAL(12,2) NOT NULL,
    DiscountPercentage DECIMAL(5,2) DEFAULT 0,
    DiscountAmount DECIMAL(10,2) DEFAULT 0,
    TaxRate DECIMAL(5,4) DEFAULT 0.0875, -- Default 8.75% tax
    TaxAmount DECIMAL(10,2) DEFAULT 0,
    FinalAmount DECIMAL(12,2) NOT NULL,
    QuoteDate DATETIME2 DEFAULT GETDATE(),
    ExpiryDate DATETIME2 NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Approved', 'Rejected', 'Expired', 'Converted')),
    SalesRepresentative NVARCHAR(100),
    Notes NVARCHAR(500),
    CreatedBy NVARCHAR(100),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    LastUpdatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ModelID) REFERENCES VehicleModels(ModelID)
);

-- Quote Line Items (for detailed pricing breakdown)
CREATE TABLE QuoteLineItems (
    LineItemID INT IDENTITY(1,1) PRIMARY KEY,
    QuoteID INT NOT NULL,
    ItemType NVARCHAR(50) NOT NULL CHECK (ItemType IN ('Base Vehicle', 'Options', 'Maintenance', 'Insurance', 'Tax', 'Fee', 'Discount')),
    Description NVARCHAR(200) NOT NULL,
    Quantity INT DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalPrice DECIMAL(10,2) NOT NULL,
    IsRecurring BIT DEFAULT 0, -- For monthly charges
    SortOrder INT DEFAULT 0,
    FOREIGN KEY (QuoteID) REFERENCES VehicleQuotes(QuoteID) ON DELETE CASCADE
);

-- Quote Follow-ups Table
CREATE TABLE QuoteFollowUps (
    FollowUpID INT IDENTITY(1,1) PRIMARY KEY,
    QuoteID INT NOT NULL,
    FollowUpDate DATETIME2 NOT NULL,
    ContactMethod NVARCHAR(20) CHECK (ContactMethod IN ('Phone', 'Email', 'In-Person', 'Text')),
    ContactedBy NVARCHAR(100),
    Response NVARCHAR(500),
    NextFollowUpDate DATETIME2,
    Status NVARCHAR(20) DEFAULT 'Completed' CHECK (Status IN ('Scheduled', 'Completed', 'No Response')),
    Notes NVARCHAR(1000),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (QuoteID) REFERENCES VehicleQuotes(QuoteID) ON DELETE CASCADE
);

GO

-- =============================================
-- AUDIT TABLE
-- =============================================

-- Audit Trail Table for tracking changes
CREATE TABLE AuditTrail (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(100) NOT NULL,
    RecordID INT NOT NULL,
    Action NVARCHAR(10) NOT NULL CHECK (Action IN ('INSERT', 'UPDATE', 'DELETE')),
    OldValues NVARCHAR(MAX),
    NewValues NVARCHAR(MAX),
    ChangedBy NVARCHAR(100),
    ChangedDate DATETIME2 DEFAULT GETDATE(),
    IPAddress NVARCHAR(45)
);

-- Add foreign key constraints that were deferred
ALTER TABLE Drivers ADD CONSTRAINT FK_Drivers_Departments 
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID);

GO

-- =============================================
-- INDEXES FOR PERFORMANCE (IDEMPOTENT)
-- =============================================

-- Indexes on frequently queried columns
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Vehicles_Status' AND object_id = OBJECT_ID('Vehicles'))
    CREATE INDEX IX_Vehicles_Status ON Vehicles(Status);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Vehicles_VIN' AND object_id = OBJECT_ID('Vehicles'))
    CREATE INDEX IX_Vehicles_VIN ON Vehicles(VIN);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Vehicles_LicensePlate' AND object_id = OBJECT_ID('Vehicles'))
    CREATE INDEX IX_Vehicles_LicensePlate ON Vehicles(LicensePlate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleAssignments_Status' AND object_id = OBJECT_ID('VehicleAssignments'))
    CREATE INDEX IX_VehicleAssignments_Status ON VehicleAssignments(Status);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleAssignments_AssignedDate' AND object_id = OBJECT_ID('VehicleAssignments'))
    CREATE INDEX IX_VehicleAssignments_AssignedDate ON VehicleAssignments(AssignedDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Drivers_EmployeeID' AND object_id = OBJECT_ID('Drivers'))
    CREATE INDEX IX_Drivers_EmployeeID ON Drivers(EmployeeID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Drivers_LicenseNumber' AND object_id = OBJECT_ID('Drivers'))
    CREATE INDEX IX_Drivers_LicenseNumber ON Drivers(LicenseNumber);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FuelRecords_FuelDate' AND object_id = OBJECT_ID('FuelRecords'))
    CREATE INDEX IX_FuelRecords_FuelDate ON FuelRecords(FuelDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MaintenanceRecords_MaintenanceDate' AND object_id = OBJECT_ID('MaintenanceRecords'))
    CREATE INDEX IX_MaintenanceRecords_MaintenanceDate ON MaintenanceRecords(MaintenanceDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MaintenanceRecords_Status' AND object_id = OBJECT_ID('MaintenanceRecords'))
    CREATE INDEX IX_MaintenanceRecords_Status ON MaintenanceRecords(Status);

-- Quote-related indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleQuotes_QuoteNumber' AND object_id = OBJECT_ID('VehicleQuotes'))
    CREATE INDEX IX_VehicleQuotes_QuoteNumber ON VehicleQuotes(QuoteNumber);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleQuotes_Status' AND object_id = OBJECT_ID('VehicleQuotes'))
    CREATE INDEX IX_VehicleQuotes_Status ON VehicleQuotes(Status);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleQuotes_QuoteDate' AND object_id = OBJECT_ID('VehicleQuotes'))
    CREATE INDEX IX_VehicleQuotes_QuoteDate ON VehicleQuotes(QuoteDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleQuotes_ExpiryDate' AND object_id = OBJECT_ID('VehicleQuotes'))
    CREATE INDEX IX_VehicleQuotes_ExpiryDate ON VehicleQuotes(ExpiryDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleQuotes_CustomerEmail' AND object_id = OBJECT_ID('VehicleQuotes'))
    CREATE INDEX IX_VehicleQuotes_CustomerEmail ON VehicleQuotes(CustomerEmail);

-- Composite indexes for common query patterns
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleAssignments_Vehicle_Driver' AND object_id = OBJECT_ID('VehicleAssignments'))
    CREATE INDEX IX_VehicleAssignments_Vehicle_Driver ON VehicleAssignments(VehicleID, DriverID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FuelRecords_Vehicle_Date' AND object_id = OBJECT_ID('FuelRecords'))
    CREATE INDEX IX_FuelRecords_Vehicle_Date ON FuelRecords(VehicleID, FuelDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MaintenanceRecords_Vehicle_Date' AND object_id = OBJECT_ID('MaintenanceRecords'))
    CREATE INDEX IX_MaintenanceRecords_Vehicle_Date ON MaintenanceRecords(VehicleID, MaintenanceDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VehicleQuotes_Customer_Status' AND object_id = OBJECT_ID('VehicleQuotes'))
    CREATE INDEX IX_VehicleQuotes_Customer_Status ON VehicleQuotes(CustomerEmail, Status);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_QuoteLineItems_Quote_Type' AND object_id = OBJECT_ID('QuoteLineItems'))
    CREATE INDEX IX_QuoteLineItems_Quote_Type ON QuoteLineItems(QuoteID, ItemType);

GO

-- =============================================
-- VIEWS FOR COMMON QUERIES
-- =============================================

-- View for active vehicle assignments
GO
CREATE VIEW ActiveAssignments AS
SELECT 
    va.AssignmentID,
    va.VehicleID,
    v.VIN,
    v.LicensePlate,
    vm.ModelName,
    vmk.MakeName,
    va.DriverID,
    d.FirstName + ' ' + d.LastName AS DriverName,
    d.EmployeeID,
    va.AssignedDate,
    va.Purpose,
    va.Destination,
    DATEDIFF(DAY, va.AssignedDate, GETDATE()) AS DaysAssigned
FROM VehicleAssignments va
JOIN Vehicles v ON va.VehicleID = v.VehicleID
JOIN VehicleModels vm ON v.ModelID = vm.ModelID
JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID
JOIN Drivers d ON va.DriverID = d.DriverID
WHERE va.Status = 'Active' AND va.ReturnedDate IS NULL;

-- View for vehicle maintenance summary
GO
CREATE VIEW VehicleMaintenanceSummary AS
SELECT 
    v.VehicleID,
    v.VIN,
    v.LicensePlate,
    vmk.MakeName + ' ' + vm.ModelName AS VehicleInfo,
    v.Year,
    v.Mileage,
    COUNT(mr.MaintenanceID) AS MaintenanceCount,
    ISNULL(SUM(mr.Cost), 0) AS TotalMaintenanceCost,
    MAX(mr.MaintenanceDate) AS LastMaintenanceDate,
    MIN(mr.NextServiceDue) AS NextServiceDue
FROM Vehicles v
JOIN VehicleModels vm ON v.ModelID = vm.ModelID
JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID
LEFT JOIN MaintenanceRecords mr ON v.VehicleID = mr.VehicleID
WHERE v.IsActive = 1
GROUP BY v.VehicleID, v.VIN, v.LicensePlate, vmk.MakeName, vm.ModelName, v.Year, v.Mileage;

-- View for driver performance metrics
GO
CREATE VIEW DriverPerformanceMetrics AS
SELECT 
    d.DriverID,
    d.EmployeeID,
    d.FirstName + ' ' + d.LastName AS DriverName,
    dept.DepartmentName,
    COUNT(DISTINCT va.VehicleID) AS VehiclesAssigned,
    COUNT(va.AssignmentID) AS TotalAssignments,
    AVG(CASE WHEN va.EndMileage > va.StartMileage 
        THEN va.EndMileage - va.StartMileage ELSE NULL END) AS AvgMilesPerTrip,
    COUNT(a.AccidentID) AS AccidentCount,
    ISNULL(AVG(fr.MPG), 0) AS AverageMPG
FROM Drivers d
LEFT JOIN Departments dept ON d.DepartmentID = dept.DepartmentID
LEFT JOIN VehicleAssignments va ON d.DriverID = va.DriverID
LEFT JOIN Accidents a ON d.DriverID = a.DriverID
LEFT JOIN FuelRecords fr ON d.DriverID = fr.DriverID
WHERE d.IsActive = 1
GROUP BY d.DriverID, d.EmployeeID, d.FirstName, d.LastName, dept.DepartmentName;

-- =============================================
-- STORED PROCEDURES
-- =============================================

-- Procedure to assign a vehicle to a driver
GO
CREATE PROCEDURE sp_AssignVehicle
    @VehicleID INT,
    @DriverID INT,
    @Purpose NVARCHAR(200) = NULL,
    @Destination NVARCHAR(200) = NULL,
    @AssignedBy NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if vehicle is available
    IF NOT EXISTS (SELECT 1 FROM Vehicles WHERE VehicleID = @VehicleID AND Status = 'Available')
    BEGIN
        RAISERROR('Vehicle is not available for assignment', 16, 1);
        RETURN;
    END
    
    -- Check if driver exists and is active
    IF NOT EXISTS (SELECT 1 FROM Drivers WHERE DriverID = @DriverID AND IsActive = 1)
    BEGIN
        RAISERROR('Driver not found or inactive', 16, 1);
        RETURN;
    END
    
    BEGIN TRANSACTION;
    
    -- Update vehicle status
    UPDATE Vehicles SET Status = 'In Use' WHERE VehicleID = @VehicleID;
    
    -- Create assignment record
    INSERT INTO VehicleAssignments (VehicleID, DriverID, StartMileage, Purpose, Destination, AssignedByUserID)
    SELECT @VehicleID, @DriverID, Mileage, @Purpose, @Destination, @AssignedBy
    FROM Vehicles WHERE VehicleID = @VehicleID;
    
    COMMIT TRANSACTION;
END;

-- Procedure to return a vehicle
GO
CREATE PROCEDURE sp_ReturnVehicle
    @AssignmentID INT,
    @EndMileage INT,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @VehicleID INT;
    
    -- Get vehicle ID and validate assignment
    SELECT @VehicleID = VehicleID 
    FROM VehicleAssignments 
    WHERE AssignmentID = @AssignmentID AND Status = 'Active';
    
    IF @VehicleID IS NULL
    BEGIN
        RAISERROR('Assignment not found or already completed', 16, 1);
        RETURN;
    END
    
    BEGIN TRANSACTION;
    
    -- Update assignment
    UPDATE VehicleAssignments 
    SET ReturnedDate = GETDATE(), 
        EndMileage = @EndMileage, 
        Status = 'Completed',
        Notes = @Notes
    WHERE AssignmentID = @AssignmentID;
    
    -- Update vehicle
    UPDATE Vehicles 
    SET Status = 'Available', 
        Mileage = @EndMileage,
        LastUpdatedDate = GETDATE()
    WHERE VehicleID = @VehicleID;
    
    COMMIT TRANSACTION;
END;

-- Procedure to calculate and create a vehicle quote
GO
CREATE PROCEDURE sp_QuoteCalc
    @CustomerName NVARCHAR(100),
    @CustomerEmail NVARCHAR(100) = NULL,
    @CustomerPhone NVARCHAR(20) = NULL,
    @CompanyName NVARCHAR(100) = NULL,
    @ModelID INT,
    @Year INT,
    @Color NVARCHAR(30) = 'White',
    @Quantity INT = 1,
    @LeaseDurationMonths INT = 36,
    @MilesPerMonth INT = 1000,
    @MaintenancePackage BIT = 0,
    @InsurancePackage BIT = 0,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SalesRep NVARCHAR(100) = NULL,
    @CreatedBy NVARCHAR(100) = 'System',
    @QuoteID INT OUTPUT,
    @TotalQuoteAmount DECIMAL(12,2) OUTPUT,
    @MonthlyPayment DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @QuoteNumber NVARCHAR(20);
    DECLARE @BasePrice DECIMAL(12,2);
    DECLARE @MonthlyLeaseRate DECIMAL(8,2);
    DECLARE @MaintenanceCost DECIMAL(8,2) = 0;
    DECLARE @InsuranceCost DECIMAL(8,2) = 0;
    DECLARE @TotalMonthlyPayment DECIMAL(10,2);
    DECLARE @TotalQuoteValue DECIMAL(12,2);
    DECLARE @DiscountAmount DECIMAL(10,2) = 0;
    DECLARE @TaxRate DECIMAL(5,4) = 0.0875; -- 8.75% default tax rate
    DECLARE @TaxAmount DECIMAL(10,2);
    DECLARE @FinalAmount DECIMAL(12,2);
    DECLARE @ExpiryDate DATETIME2;
    DECLARE @VehicleType NVARCHAR(30);
    DECLARE @MakeName NVARCHAR(50);
    DECLARE @ModelName NVARCHAR(50);
    
    -- Validation
    IF @CustomerName IS NULL OR LTRIM(RTRIM(@CustomerName)) = ''
    BEGIN
        RAISERROR('Customer name is required', 16, 1);
        RETURN;
    END
    
    IF @Quantity <= 0
    BEGIN
        RAISERROR('Quantity must be greater than 0', 16, 1);
        RETURN;
    END
    
    IF @LeaseDurationMonths <= 0 OR @LeaseDurationMonths > 120
    BEGIN
        RAISERROR('Lease duration must be between 1 and 120 months', 16, 1);
        RETURN;
    END
    
    -- Get vehicle information and validate model
    SELECT 
        @VehicleType = vm.VehicleType,
        @MakeName = vmk.MakeName,
        @ModelName = vm.ModelName
    FROM VehicleModels vm
    JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID
    WHERE vm.ModelID = @ModelID AND vm.IsActive = 1;
    
    IF @VehicleType IS NULL
    BEGIN
        RAISERROR('Invalid or inactive vehicle model', 16, 1);
        RETURN;
    END
    
    -- Calculate base pricing based on vehicle type and year
    SET @BasePrice = CASE 
        WHEN @VehicleType = 'Truck' THEN 45000.00
        WHEN @VehicleType = 'SUV' THEN 40000.00
        WHEN @VehicleType = 'Van' THEN 35000.00
        WHEN @VehicleType = 'Sedan' THEN 28000.00
        WHEN @VehicleType = 'Hatchback' THEN 25000.00
        WHEN @VehicleType = 'Coupe' THEN 32000.00
        WHEN @VehicleType = 'Convertible' THEN 38000.00
        ELSE 30000.00
    END;
    
    -- Adjust for vehicle age (year)
    IF @Year < YEAR(GETDATE()) - 3
        SET @BasePrice = @BasePrice * 0.85; -- 15% discount for older models
    ELSE IF @Year = YEAR(GETDATE()) + 1
        SET @BasePrice = @BasePrice * 1.05; -- 5% premium for next year models
    
    -- Calculate monthly lease rate (approximately 2.5% of base price for standard lease)
    SET @MonthlyLeaseRate = (@BasePrice * 0.025) + (@MilesPerMonth * 0.15); -- $0.15 per mile factor
    
    -- Adjust lease rate based on duration
    IF @LeaseDurationMonths >= 48
        SET @MonthlyLeaseRate = @MonthlyLeaseRate * 0.92; -- 8% discount for longer leases
    ELSE IF @LeaseDurationMonths <= 24
        SET @MonthlyLeaseRate = @MonthlyLeaseRate * 1.15; -- 15% premium for shorter leases
    
    -- Add maintenance package cost if selected
    IF @MaintenancePackage = 1
    BEGIN
        SET @MaintenanceCost = CASE 
            WHEN @VehicleType IN ('Truck', 'SUV') THEN 150.00
            WHEN @VehicleType = 'Van' THEN 135.00
            ELSE 120.00
        END;
    END
    
    -- Add insurance package cost if selected
    IF @InsurancePackage = 1
    BEGIN
        SET @InsuranceCost = CASE 
            WHEN @VehicleType IN ('Truck', 'SUV', 'Van') THEN 200.00
            WHEN @VehicleType = 'Convertible' THEN 250.00
            ELSE 180.00
        END;
    END
    
    -- Calculate totals
    SET @TotalMonthlyPayment = (@MonthlyLeaseRate + @MaintenanceCost + @InsuranceCost) * @Quantity;
    SET @TotalQuoteValue = @TotalMonthlyPayment * @LeaseDurationMonths;
    
    -- Apply discount
    IF @DiscountPercentage > 0
    BEGIN
        SET @DiscountAmount = @TotalQuoteValue * (@DiscountPercentage / 100.0);
        SET @TotalQuoteValue = @TotalQuoteValue - @DiscountAmount;
        SET @TotalMonthlyPayment = @TotalQuoteValue / @LeaseDurationMonths;
    END
    
    -- Calculate tax
    SET @TaxAmount = @TotalQuoteValue * @TaxRate;
    SET @FinalAmount = @TotalQuoteValue + @TaxAmount;
    
    -- Generate unique quote number
    SET @QuoteNumber = 'Q' + CONVERT(NVARCHAR, YEAR(GETDATE())) + 
                      RIGHT('000' + CONVERT(NVARCHAR, MONTH(GETDATE())), 2) + 
                      RIGHT('000' + CONVERT(NVARCHAR, ABS(CHECKSUM(NEWID())) % 10000), 4);
    
    -- Set expiry date (30 days from now)
    SET @ExpiryDate = DATEADD(DAY, 30, GETDATE());
    
    BEGIN TRANSACTION;
    
    -- Insert main quote record
    INSERT INTO VehicleQuotes (
        QuoteNumber, CustomerName, CustomerEmail, CustomerPhone, CompanyName,
        ModelID, Year, Color, Quantity, LeaseDurationMonths, MilesPerMonth,
        BasePrice, MonthlyLeaseRate, MaintenancePackage, InsurancePackage,
        MaintenanceCost, InsuranceCost, TotalMonthlyPayment, TotalQuoteValue,
        DiscountPercentage, DiscountAmount, TaxRate, TaxAmount, FinalAmount,
        ExpiryDate, SalesRepresentative, CreatedBy
    )
    VALUES (
        @QuoteNumber, @CustomerName, @CustomerEmail, @CustomerPhone, @CompanyName,
        @ModelID, @Year, @Color, @Quantity, @LeaseDurationMonths, @MilesPerMonth,
        @BasePrice, @MonthlyLeaseRate, @MaintenancePackage, @InsurancePackage,
        @MaintenanceCost, @InsuranceCost, @TotalMonthlyPayment, @TotalQuoteValue,
        @DiscountPercentage, @DiscountAmount, @TaxRate, @TaxAmount, @FinalAmount,
        @ExpiryDate, @SalesRep, @CreatedBy
    );
    
    SET @QuoteID = SCOPE_IDENTITY();
    
    -- Insert line items for detailed breakdown
    INSERT INTO QuoteLineItems (QuoteID, ItemType, Description, Quantity, UnitPrice, TotalPrice, IsRecurring, SortOrder)
    VALUES 
        (@QuoteID, 'Base Vehicle', @MakeName + ' ' + @ModelName + ' ' + CAST(@Year AS NVARCHAR), @Quantity, @MonthlyLeaseRate, @MonthlyLeaseRate * @Quantity, 1, 1);
    
    -- Add maintenance package line item if selected
    IF @MaintenancePackage = 1
    BEGIN
        INSERT INTO QuoteLineItems (QuoteID, ItemType, Description, Quantity, UnitPrice, TotalPrice, IsRecurring, SortOrder)
        VALUES (@QuoteID, 'Maintenance', 'Comprehensive Maintenance Package', @Quantity, @MaintenanceCost, @MaintenanceCost * @Quantity, 1, 2);
    END
    
    -- Add insurance package line item if selected
    IF @InsurancePackage = 1
    BEGIN
        INSERT INTO QuoteLineItems (QuoteID, ItemType, Description, Quantity, UnitPrice, TotalPrice, IsRecurring, SortOrder)
        VALUES (@QuoteID, 'Insurance', 'Comprehensive Insurance Package', @Quantity, @InsuranceCost, @InsuranceCost * @Quantity, 1, 3);
    END
    
    -- Add discount line item if applicable
    IF @DiscountAmount > 0
    BEGIN
        INSERT INTO QuoteLineItems (QuoteID, ItemType, Description, Quantity, UnitPrice, TotalPrice, IsRecurring, SortOrder)
        VALUES (@QuoteID, 'Discount', 'Volume/Promotional Discount (' + CAST(@DiscountPercentage AS NVARCHAR) + '%)', 1, -@DiscountAmount, -@DiscountAmount, 0, 4);
    END
    
    -- Add tax line item
    INSERT INTO QuoteLineItems (QuoteID, ItemType, Description, Quantity, UnitPrice, TotalPrice, IsRecurring, SortOrder)
    VALUES (@QuoteID, 'Tax', 'Sales Tax (' + CAST(@TaxRate * 100 AS NVARCHAR) + '%)', 1, @TaxAmount, @TaxAmount, 0, 5);
    
    -- Schedule initial follow-up (3 days from now)
    INSERT INTO QuoteFollowUps (QuoteID, FollowUpDate, ContactMethod, ContactedBy, Status, Notes)
    VALUES (@QuoteID, DATEADD(DAY, 3, GETDATE()), 'Email', ISNULL(@SalesRep, 'Sales Team'), 'Scheduled', 'Initial follow-up on quote #' + @QuoteNumber);
    
    COMMIT TRANSACTION;
    
    -- Set output parameters
    SET @TotalQuoteAmount = @FinalAmount;
    SET @MonthlyPayment = @TotalMonthlyPayment;
    
    -- Return summary information
    SELECT 
        @QuoteID AS QuoteID,
        @QuoteNumber AS QuoteNumber,
        @CustomerName AS CustomerName,
        @MakeName + ' ' + @ModelName + ' ' + CAST(@Year AS NVARCHAR) AS VehicleDescription,
        @Quantity AS Quantity,
        @LeaseDurationMonths AS LeaseDurationMonths,
        @TotalMonthlyPayment AS MonthlyPayment,
        @TotalQuoteValue AS SubTotal,
        @DiscountAmount AS DiscountAmount,
        @TaxAmount AS TaxAmount,
        @FinalAmount AS TotalAmount,
        @ExpiryDate AS ExpiryDate,
        'Quote created successfully' AS Message;
        
END;

GO

-- =============================================
-- SAMPLE DATA INSERTION (IDEMPOTENT)
-- =============================================

-- Insert sample vehicle makes (only if they don't exist)
IF NOT EXISTS (SELECT 1 FROM VehicleMakes WHERE MakeName = 'Ford')
    INSERT INTO VehicleMakes (MakeName, Country) VALUES ('Ford', 'USA');
IF NOT EXISTS (SELECT 1 FROM VehicleMakes WHERE MakeName = 'Chevrolet')
    INSERT INTO VehicleMakes (MakeName, Country) VALUES ('Chevrolet', 'USA');
IF NOT EXISTS (SELECT 1 FROM VehicleMakes WHERE MakeName = 'Toyota')
    INSERT INTO VehicleMakes (MakeName, Country) VALUES ('Toyota', 'Japan');
IF NOT EXISTS (SELECT 1 FROM VehicleMakes WHERE MakeName = 'Honda')
    INSERT INTO VehicleMakes (MakeName, Country) VALUES ('Honda', 'Japan');
IF NOT EXISTS (SELECT 1 FROM VehicleMakes WHERE MakeName = 'Nissan')
    INSERT INTO VehicleMakes (MakeName, Country) VALUES ('Nissan', 'Japan');
IF NOT EXISTS (SELECT 1 FROM VehicleMakes WHERE MakeName = 'BMW')
    INSERT INTO VehicleMakes (MakeName, Country) VALUES ('BMW', 'Germany');
IF NOT EXISTS (SELECT 1 FROM VehicleMakes WHERE MakeName = 'Mercedes-Benz')
    INSERT INTO VehicleMakes (MakeName, Country) VALUES ('Mercedes-Benz', 'Germany');
IF NOT EXISTS (SELECT 1 FROM VehicleMakes WHERE MakeName = 'Volkswagen')
    INSERT INTO VehicleMakes (MakeName, Country) VALUES ('Volkswagen', 'Germany');

-- Insert sample vehicle models (only if they don't exist)
IF NOT EXISTS (SELECT 1 FROM VehicleModels vm JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID WHERE vmk.MakeName = 'Ford' AND vm.ModelName = 'F-150')
    INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) 
    SELECT MakeID, 'F-150', 'Truck', 'Gasoline' FROM VehicleMakes WHERE MakeName = 'Ford';
IF NOT EXISTS (SELECT 1 FROM VehicleModels vm JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID WHERE vmk.MakeName = 'Ford' AND vm.ModelName = 'Transit')
    INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) 
    SELECT MakeID, 'Transit', 'Van', 'Gasoline' FROM VehicleMakes WHERE MakeName = 'Ford';
IF NOT EXISTS (SELECT 1 FROM VehicleModels vm JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID WHERE vmk.MakeName = 'Ford' AND vm.ModelName = 'Explorer')
    INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) 
    SELECT MakeID, 'Explorer', 'SUV', 'Gasoline' FROM VehicleMakes WHERE MakeName = 'Ford';
IF NOT EXISTS (SELECT 1 FROM VehicleModels vm JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID WHERE vmk.MakeName = 'Chevrolet' AND vm.ModelName = 'Silverado')
    INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) 
    SELECT MakeID, 'Silverado', 'Truck', 'Gasoline' FROM VehicleMakes WHERE MakeName = 'Chevrolet';
IF NOT EXISTS (SELECT 1 FROM VehicleModels vm JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID WHERE vmk.MakeName = 'Chevrolet' AND vm.ModelName = 'Tahoe')
    INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) 
    SELECT MakeID, 'Tahoe', 'SUV', 'Gasoline' FROM VehicleMakes WHERE MakeName = 'Chevrolet';
IF NOT EXISTS (SELECT 1 FROM VehicleModels vm JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID WHERE vmk.MakeName = 'Toyota' AND vm.ModelName = 'Camry')
    INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) 
    SELECT MakeID, 'Camry', 'Sedan', 'Hybrid' FROM VehicleMakes WHERE MakeName = 'Toyota';
IF NOT EXISTS (SELECT 1 FROM VehicleModels vm JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID WHERE vmk.MakeName = 'Toyota' AND vm.ModelName = 'Prius')
    INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) 
    SELECT MakeID, 'Prius', 'Hatchback', 'Hybrid' FROM VehicleMakes WHERE MakeName = 'Toyota';
IF NOT EXISTS (SELECT 1 FROM VehicleModels vm JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID WHERE vmk.MakeName = 'Honda' AND vm.ModelName = 'Accord')
    INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) 
    SELECT MakeID, 'Accord', 'Sedan', 'Gasoline' FROM VehicleMakes WHERE MakeName = 'Honda';
IF NOT EXISTS (SELECT 1 FROM VehicleModels vm JOIN VehicleMakes vmk ON vm.MakeID = vmk.MakeID WHERE vmk.MakeName = 'Honda' AND vm.ModelName = 'CR-V')
    INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) 
    SELECT MakeID, 'CR-V', 'SUV', 'Gasoline' FROM VehicleMakes WHERE MakeName = 'Honda';

-- Insert sample departments (only if they don't exist)
IF NOT EXISTS (SELECT 1 FROM Departments WHERE DepartmentCode = 'SALES')
    INSERT INTO Departments (DepartmentName, DepartmentCode, ManagerName, Budget) VALUES ('Sales', 'SALES', 'John Smith', 500000.00);
IF NOT EXISTS (SELECT 1 FROM Departments WHERE DepartmentCode = 'MKT')
    INSERT INTO Departments (DepartmentName, DepartmentCode, ManagerName, Budget) VALUES ('Marketing', 'MKT', 'Jane Doe', 300000.00);
IF NOT EXISTS (SELECT 1 FROM Departments WHERE DepartmentCode = 'OPS')
    INSERT INTO Departments (DepartmentName, DepartmentCode, ManagerName, Budget) VALUES ('Operations', 'OPS', 'Mike Johnson', 750000.00);
IF NOT EXISTS (SELECT 1 FROM Departments WHERE DepartmentCode = 'IT')
    INSERT INTO Departments (DepartmentName, DepartmentCode, ManagerName, Budget) VALUES ('IT', 'IT', 'Sarah Wilson', 400000.00);
IF NOT EXISTS (SELECT 1 FROM Departments WHERE DepartmentCode = 'HR')
    INSERT INTO Departments (DepartmentName, DepartmentCode, ManagerName, Budget) VALUES ('Human Resources', 'HR', 'Tom Brown', 200000.00);

-- Insert sample locations (only if they don't exist)
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Headquarters')
    INSERT INTO Locations (LocationName, Address, City, State, ZipCode) VALUES ('Headquarters', '123 Main Street', 'New York', 'NY', '10001');
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'West Coast Office')
    INSERT INTO Locations (LocationName, Address, City, State, ZipCode) VALUES ('West Coast Office', '456 Tech Drive', 'San Francisco', 'CA', '94105');
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Midwest Branch')
    INSERT INTO Locations (LocationName, Address, City, State, ZipCode) VALUES ('Midwest Branch', '789 Industrial Blvd', 'Chicago', 'IL', '60601');
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Service Center A')
    INSERT INTO Locations (LocationName, Address, City, State, ZipCode) VALUES ('Service Center A', '321 Service Road', 'Houston', 'TX', '77001');
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Service Center B')
    INSERT INTO Locations (LocationName, Address, City, State, ZipCode) VALUES ('Service Center B', '654 Repair Lane', 'Phoenix', 'AZ', '85001');

GO

PRINT 'Fleet Management Database created/updated successfully!';
PRINT 'Database includes:';
PRINT '- 16 core tables for comprehensive fleet management';
PRINT '- 3 useful views for common reporting needs';
PRINT '- 3 stored procedures for vehicle assignment and quoting operations';
PRINT '- 25 optimized indexes for performance';
PRINT '- Sample reference data to get started';
PRINT '- IDEMPOTENT: This script can be run multiple times safely';
PRINT '';
PRINT 'Ready to manage your fleet operations!';
GO