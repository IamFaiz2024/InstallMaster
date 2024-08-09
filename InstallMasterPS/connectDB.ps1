# Define the connection string to your database
$connectionString = "Server=YourServerName;Database=YourDatabaseName;Integrated Security=True;"

# Define the values for the stored procedure parameters
$paramValue1 = "Value1"
$paramValue2 = "Value2"
$paramValue3 = "Value3"
$paramValue4 = "Value4"
$paramValue5 = "Value5"
$paramValue6 = "Value6"

# Create a connection to the database
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# Create a command to execute the stored procedure with parameters
$command = $connection.CreateCommand()
$command.CommandText = "EXEC YourStoredProcedureName @Param1, @Param2, @Param3, @Param4, @Param5, @Param6"
$command.Parameters.AddWithValue("@Param1", $paramValue1)
$command.Parameters.AddWithValue("@Param2", $paramValue2)
$command.Parameters.AddWithValue("@Param3", $paramValue3)
$command.Parameters.AddWithValue("@Param4", $paramValue4)
$command.Parameters.AddWithValue("@Param5", $paramValue5)
$command.Parameters.AddWithValue("@Param6", $paramValue6)
$command.CommandType = [System.Data.CommandType]::StoredProcedure

# Execute the command and fetch the results
$results = $command.ExecuteReader()

# Display the output from the stored procedure
while ($results.Read()) {
    $results.GetString(0)  # Adjust the index based on the column you want to display
}

# Close the connection
$connection.Close()