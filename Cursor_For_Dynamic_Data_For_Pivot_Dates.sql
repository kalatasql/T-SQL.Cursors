-- Declare the cursor to fetch distinct OrderDate values from the Orders table
DECLARE Date_Cursor CURSOR FOR
SELECT DISTINCT OrderDate FROM Orders;  -- Get only distinct values from OrderDate

-- Open the cursor to start fetching data
OPEN Date_Cursor;

-- Declare variables to store data fetched by the cursor
DECLARE @dates DATE;  -- Variable to store the current OrderDate
DECLARE @pivotColumns NVARCHAR(MAX) = '';  -- String to accumulate the list of pivot columns (dates)
DECLARE @dynamicSQL NVARCHAR(MAX);  -- Variable to store the dynamic SQL query

-- Fetch the first OrderDate from the cursor into the @dates variable
FETCH NEXT FROM Date_Cursor INTO @dates;

-- Loop through all fetched dates to build the pivot columns string
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Add each date as a column in the pivot clause, formatting it correctly with QUOTENAME
    SET @pivotColumns = @pivotColumns + QUOTENAME(CONVERT(VARCHAR, @dates)) + ', ';
    
    -- Fetch the next OrderDate from the cursor
    FETCH NEXT FROM Date_Cursor INTO @dates;
END

-- Close the cursor after use
CLOSE Date_Cursor;
-- Deallocate the cursor to free up resources
DEALLOCATE Date_Cursor;

-- Remove the last comma and space from the pivot columns string
SET @pivotColumns = LEFT(@pivotColumns, LEN(@pivotColumns) - 1);

-- Build the dynamic SQL query for the PIVOT operation using the accumulated pivot columns
SET @dynamicSQL = '
SELECT *
FROM (
    SELECT OrderID, OrderDate
    FROM Orders
) o
PIVOT (
    COUNT(OrderID) FOR OrderDate IN (' + @pivotColumns + ')  -- Perform the pivot operation using the distinct dates as columns
) pvt;';

-- Execute the dynamically generated SQL query
EXEC sp_executesql @dynamicSQL;
