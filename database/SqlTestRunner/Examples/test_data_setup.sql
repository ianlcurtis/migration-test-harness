-- =====================================================
-- Test Data Setup Script for sp_QuoteCalc
-- Generated from Test Case Design
-- Total Tests: 23
-- =====================================================
-- This script contains test data setup for the sp_QuoteCalc stored procedure.
-- It does NOT re-insert pre-configured data from database_setup.sql.
-- All tests reference existing ModelID values (1-15) from database_setup.sql.
-- =====================================================

USE FleetManagement;
GO

-- =====================================================
-- HAPPY PATH TESTS
-- =====================================================

-- TEST: HP001 - Basic Quote - Standard Sedan Lease
-- Category: HAPPY_PATH
-- Description: Create a basic quote for a single sedan with standard parameters and no optional packages
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 5 (Toyota Camry)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: HP002 - Quote with Maintenance and Insurance Packages
-- Category: HAPPY_PATH
-- Description: Create quote for SUV with both maintenance and insurance packages
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 3 (Ford Explorer)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: HP003 - Quote with Discount Applied
-- Category: HAPPY_PATH
-- Description: Create quote with significant volume discount
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 1 (Ford F-150)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: HP004 - Quote for Premium Convertible
-- Category: HAPPY_PATH
-- Description: Create quote for luxury convertible with all premium features
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 15 (Mercedes Sprinter)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: HP005 - Minimal Required Parameters Only
-- Category: HAPPY_PATH
-- Description: Create quote with only required parameters all others default
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 12 (Honda Accord)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: HP006 - Quote for Older Vehicle Model
-- Category: HAPPY_PATH
-- Description: Create quote for vehicle older than 3 years to test depreciation discount
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 11 (Chevrolet Malibu)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: HP007 - High Mileage Lease Quote
-- Category: HAPPY_PATH
-- Description: Create quote for high-mileage lease scenario
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 1 (Ford F-150)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: HP008 - Quote with NULL Optional Fields
-- Category: HAPPY_PATH
-- Description: Explicitly test NULL handling for all optional contact fields
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 14 (Nissan Altima)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- =====================================================
-- UNHAPPY PATH TESTS
-- =====================================================

-- TEST: UP001 - Missing Required Customer Name
-- Category: UNHAPPY_PATH
-- Description: Attempt to create quote without customer name
-- Expected: ERROR - Customer name is required
-- Dependencies: Uses pre-configured ModelID 5
-- NO SETUP REQUIRED - Error expected before any data access

-- TEST: UP002 - Empty String Customer Name
-- Category: UNHAPPY_PATH
-- Description: Attempt to create quote with whitespace-only customer name
-- Expected: ERROR - Customer name is required
-- Dependencies: Uses pre-configured ModelID 5
-- NO SETUP REQUIRED - Error expected before any data access

-- TEST: UP003 - Invalid Quantity (Zero)
-- Category: UNHAPPY_PATH
-- Description: Attempt to create quote with quantity of zero
-- Expected: ERROR - Quantity must be greater than 0
-- Dependencies: Uses pre-configured ModelID 5
-- NO SETUP REQUIRED - Error expected before any data access

-- TEST: UP004 - Invalid Quantity (Negative)
-- Category: UNHAPPY_PATH
-- Description: Attempt to create quote with negative quantity
-- Expected: ERROR - Quantity must be greater than 0
-- Dependencies: Uses pre-configured ModelID 5
-- NO SETUP REQUIRED - Error expected before any data access

-- TEST: UP005 - Lease Duration Too Short
-- Category: UNHAPPY_PATH
-- Description: Attempt to create quote with lease duration of 0 months
-- Expected: ERROR - Lease duration must be between 1 and 120 months
-- Dependencies: Uses pre-configured ModelID 5
-- NO SETUP REQUIRED - Error expected before any data access

-- TEST: UP006 - Lease Duration Too Long
-- Category: UNHAPPY_PATH
-- Description: Attempt to create quote with lease duration exceeding maximum
-- Expected: ERROR - Lease duration must be between 1 and 120 months
-- Dependencies: Uses pre-configured ModelID 5
-- NO SETUP REQUIRED - Error expected before any data access

-- TEST: UP007 - Invalid ModelID (Non-Existent)
-- Category: UNHAPPY_PATH
-- Description: Attempt to create quote with ModelID that doesn't exist
-- Expected: ERROR - Invalid or inactive vehicle model
-- Dependencies: None (ModelID 9999 does not exist)
-- NO SETUP REQUIRED - Error expected when ModelID validation fails

-- =====================================================
-- EDGE CASE TESTS
-- =====================================================

-- TEST: EC001 - Maximum Valid Lease Duration
-- Category: EDGE_CASE
-- Description: Create quote with exactly 120 months (boundary value)
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 2 (Ford Transit)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: EC002 - Minimum Valid Lease Duration
-- Category: EDGE_CASE
-- Description: Create quote with exactly 1 month (minimum boundary)
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 6 (Toyota Prius)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: EC003 - Maximum Discount Percentage
-- Category: EDGE_CASE
-- Description: Create quote with 100% discount (edge case for discount calculation)
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 5 (Toyota Camry)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: EC004 - Zero Miles Per Month
-- Category: EDGE_CASE
-- Description: Create quote with zero miles per month (unusual but valid)
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 10 (Chevrolet Tahoe)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: EC005 - Very Long Customer Name (Boundary)
-- Category: EDGE_CASE
-- Description: Create quote with 100-character customer name (maximum length)
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 5 (Toyota Camry)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: EC006 - Current Year Vehicle (No Adjustment)
-- Category: EDGE_CASE
-- Description: Create quote for current year vehicle (2025) - no year adjustment
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 13 (Honda CR-V)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: EC007 - Exactly 24-Month Lease (Short Lease Threshold)
-- Category: EDGE_CASE
-- Description: Create quote with exactly 24 months to test short lease premium boundary
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 5 (Toyota Camry)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- TEST: EC008 - Exactly 48-Month Lease (Long Lease Discount Threshold)
-- Category: EDGE_CASE
-- Description: Create quote with exactly 48 months to test long lease discount boundary
-- Expected: SUCCESS with QuoteID returned
-- Dependencies: Uses pre-configured ModelID 7 (Toyota Highlander)
-- NO SETUP REQUIRED - All dependencies exist in database_setup.sql

-- =====================================================
-- VERIFICATION QUERIES (EXAMPLE - NOT EXECUTED)
-- =====================================================
-- Note: sp_QuoteCalc is data-modifying, so verification can be done via:
-- 1. Check the OUTPUT parameters returned by the stored procedure
-- 2. Query the database state captured by the test harness
-- 3. Examine the result sets returned by the stored procedure
--
-- Example verification queries (for manual use):
--
-- VERIFY QuoteRecord:
-- SELECT * FROM VehicleQuotes WHERE QuoteID = <returned_quote_id>;
--
-- VERIFY LineItems:
-- SELECT * FROM QuoteLineItems WHERE QuoteID = <returned_quote_id>;
--
-- VERIFY FollowUp:
-- SELECT * FROM QuoteFollowUps WHERE QuoteID = <returned_quote_id>;
--
-- =====================================================

-- PRINT 'Test data setup completed successfully - All tests ready to execute';
-- PRINT 'Note: No test data was inserted because sp_QuoteCalc does not require pre-existing data';
-- PRINT 'All dependencies (VehicleModels, VehicleMakes) exist in database_setup.sql';