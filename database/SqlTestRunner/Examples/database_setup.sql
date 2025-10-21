-- =====================================================
-- Fleet Management Database Setup Script (Pre-Configured Data)
-- =====================================================
-- This script contains lookup/reference data that must exist
-- for the Fleet Management system to function correctly.
-- 
-- These rows are inserted ONCE before any tests run.
-- Test data setup scripts should NOT re-insert these rows.
-- Tests should reference existing IDs/values from this script.
-- =====================================================

USE FleetManagement;
GO

-- =====================================================
-- VEHICLE LOOKUP TABLES
-- =====================================================

-- Vehicle Makes - Core automotive manufacturers
-- Tests should use these MakeID values: 1-8
INSERT INTO VehicleMakes (MakeName, Country) VALUES
('Ford', 'USA'),
('Toyota', 'Japan'),
('Chevrolet', 'USA'),
('Honda', 'Japan'),
('Nissan', 'Japan'),
('BMW', 'Germany'),
('Mercedes-Benz', 'Germany'),
('Volkswagen', 'Germany');

-- Vehicle Models - Standard fleet vehicle models
-- Tests should use these ModelID values: 1-15
INSERT INTO VehicleModels (MakeID, ModelName, VehicleType, FuelType) VALUES
-- Ford Models
(1, 'F-150', 'Truck', 'Gasoline'),
(1, 'Transit', 'Van', 'Gasoline'),
(1, 'Explorer', 'SUV', 'Gasoline'),
(1, 'Escape', 'SUV', 'Hybrid'),
-- Toyota Models
(2, 'Camry', 'Sedan', 'Hybrid'),
(2, 'Prius', 'Hatchback', 'Hybrid'),
(2, 'Highlander', 'SUV', 'Gasoline'),
(2, 'Sienna', 'Van', 'Hybrid'),
-- Chevrolet Models
(3, 'Silverado', 'Truck', 'Gasoline'),
(3, 'Tahoe', 'SUV', 'Gasoline'),
(3, 'Malibu', 'Sedan', 'Gasoline'),
-- Honda Models
(4, 'Accord', 'Sedan', 'Gasoline'),
(4, 'CR-V', 'SUV', 'Gasoline'),
-- Other Makes
(5, 'Altima', 'Sedan', 'Gasoline'),
(7, 'Sprinter', 'Van', 'Diesel');

-- =====================================================
-- ORGANIZATIONAL REFERENCE DATA
-- =====================================================

-- Departments - Core company departments
-- Tests should use these DepartmentID values: 1-8
INSERT INTO Departments (DepartmentName, DepartmentCode, ManagerName, Budget) VALUES
('Sales', 'SALES', 'John Smith', 250000.00),
('Marketing', 'MKTG', 'Sarah Johnson', 180000.00),
('Operations', 'OPS', 'Mike Wilson', 320000.00),
('Information Technology', 'IT', 'Lisa Chen', 150000.00),
('Human Resources', 'HR', 'David Brown', 120000.00),
('Finance', 'FIN', 'Emma Davis', 200000.00),
('Maintenance', 'MAINT', 'Robert Garcia', 280000.00),
('Security', 'SEC', 'James Rodriguez', 140000.00);

-- Locations - Standard fleet locations
-- Tests should use these LocationID values: 1-8
INSERT INTO Locations (LocationName, Address, City, State, ZipCode, Country, Latitude, Longitude) VALUES
('Headquarters', '123 Main St', 'Seattle', 'WA', '98101', 'USA', 47.6062, -122.3321),
('North Branch', '456 Oak Ave', 'Portland', 'OR', '97201', 'USA', 45.5152, -122.6784),
('South Branch', '789 Pine Rd', 'San Francisco', 'CA', '94102', 'USA', 37.7749, -122.4194),
('East Branch', '321 Elm St', 'Denver', 'CO', '80202', 'USA', 39.7392, -104.9903),
('West Branch', '654 Maple Dr', 'Phoenix', 'AZ', '85001', 'USA', 33.4484, -112.0740),
('Central Depot', '987 Cedar Ln', 'Dallas', 'TX', '75201', 'USA', 32.7767, -96.7970),
('Maintenance Facility', '555 Service Way', 'Austin', 'TX', '73301', 'USA', 30.2672, -97.7431),
('Training Center', '777 Learning Blvd', 'Atlanta', 'GA', '30309', 'USA', 33.7490, -84.3880);

-- =====================================================
-- SAMPLE CORE DATA (MINIMAL SEED SET)
-- =====================================================

-- Sample Drivers - Standard test drivers
-- Tests should use these DriverID values: 1-5 for basic operations
INSERT INTO Drivers (EmployeeID, FirstName, LastName, Email, Phone, LicenseNumber, LicenseExpiryDate, DepartmentID, HireDate, DateOfBirth, Address, City, State, ZipCode, EmergencyContactName, EmergencyContactPhone) VALUES
('EMP001', 'James', 'Anderson', 'james.anderson@company.com', '555-0101', 'DL123456789', '2026-12-31', 1, '2020-01-15', '1985-03-22', '100 First St', 'Seattle', 'WA', '98101', 'Mary Anderson', '555-0102'),
('EMP002', 'Maria', 'Rodriguez', 'maria.rodriguez@company.com', '555-0103', 'DL234567890', '2026-06-15', 2, '2021-03-10', '1990-07-14', '200 Second Ave', 'Portland', 'OR', '97201', 'Carlos Rodriguez', '555-0104'),
('EMP003', 'Michael', 'Johnson', 'michael.johnson@company.com', '555-0105', 'DL345678901', '2025-09-30', 3, '2019-05-20', '1988-11-08', '300 Third Blvd', 'San Francisco', 'CA', '94102', 'Jennifer Johnson', '555-0106'),
('EMP004', 'Sarah', 'Williams', 'sarah.williams@company.com', '555-0107', 'DL456789012', '2026-03-15', 4, '2022-02-01', '1992-05-17', '400 Fourth Way', 'Denver', 'CO', '80202', 'Tom Williams', '555-0108'),
('EMP005', 'Robert', 'Davis', 'robert.davis@company.com', '555-0109', 'DL567890123', '2026-08-20', 5, '2020-09-12', '1987-12-03', '500 Fifth Place', 'Phoenix', 'AZ', '85001', 'Linda Davis', '555-0110');

-- Sample Vehicles - Standard test fleet
-- Tests should use these VehicleID values: 1-5 for basic operations
INSERT INTO Vehicles (VIN, LicensePlate, ModelID, Year, Color, Mileage, PurchaseDate, PurchasePrice, CurrentValue, Status, LocationID, InsurancePolicyNumber, InsuranceExpiryDate, RegistrationExpiryDate, NextMaintenanceDue, FuelCapacity) VALUES
('1FTFW1ET5DKE12345', 'FLEET-001', 1, 2022, 'White', 25000, '2022-01-15', 35000.00, 30000.00, 'Available', 1, 'INS-001-2022', '2025-12-31', '2025-12-31', '2025-01-15', 26.0),
('1FTBW2CM8GKE23456', 'FLEET-002', 2, 2023, 'Blue', 15000, '2023-02-20', 42000.00, 38000.00, 'Available', 1, 'INS-002-2023', '2025-12-31', '2025-12-31', '2025-02-20', 25.0),
('4T1C11AK8JU45678', 'FLEET-003', 5, 2023, 'Silver', 18000, '2023-04-05', 28000.00, 26000.00, 'Available', 2, 'INS-003-2023', '2025-12-31', '2025-12-31', '2025-04-05', 14.5),
('1HGCV1F39JA90123', 'FLEET-004', 12, 2022, 'Black', 22000, '2022-09-30', 26000.00, 23000.00, 'Available', 3, 'INS-004-2022', '2025-12-31', '2025-12-31', '2025-09-30', 17.2),
('5J6RW2H54LA01234', 'FLEET-005', 13, 2024, 'Green', 5000, '2024-01-08', 35000.00, 34000.00, 'Available', 4, 'INS-005-2024', '2025-12-31', '2025-12-31', '2026-01-08', 15.8);

-- =====================================================
-- NOTES FOR TEST DEVELOPERS
-- =====================================================
-- 
-- IMPORTANT: When creating test data setup scripts:
--
-- 1. DO NOT re-insert any of the above reference data
-- 2. DO use the IDs/values listed above in your tests
-- 3. DO create only test-specific operational data (assignments, fuel records, maintenance, etc.)
-- 4. DO reference these pre-configured IDs in foreign key relationships
--
-- Available Reference IDs for Testing:
-- - VehicleMakes: MakeID 1-8 (Ford, Toyota, Chevrolet, Honda, Nissan, BMW, Mercedes-Benz, Volkswagen)
-- - VehicleModels: ModelID 1-15 (Various models across makes)
-- - Departments: DepartmentID 1-8 (Sales, Marketing, Operations, IT, HR, Finance, Maintenance, Security)
-- - Locations: LocationID 1-8 (Seattle HQ, Portland, San Francisco, Denver, Phoenix, Dallas, Austin, Atlanta)
-- - Drivers: DriverID 1-5 (Basic test driver set)
-- - Vehicles: VehicleID 1-5 (Basic test vehicle fleet)
--
-- Examples for Test Scripts:
-- - When creating VehicleAssignments, use VehicleID 1-5 and DriverID 1-5
-- - When adding FuelRecords, reference existing VehicleID and DriverID
-- - When scheduling MaintenanceRecords, use VehicleID 1-5
-- - When adding new vehicles, use ModelID 1-15 and LocationID 1-8
-- - When adding new drivers, use DepartmentID 1-8
--
-- Vehicle Status Options: 'Available', 'In Use', 'Maintenance', 'Out of Service', 'Sold'
-- Vehicle Types: 'Sedan', 'SUV', 'Truck', 'Van', 'Hatchback', 'Coupe', 'Convertible'
-- Fuel Types: 'Gasoline', 'Diesel', 'Hybrid', 'Electric', 'Natural Gas'
--
-- =====================================================
