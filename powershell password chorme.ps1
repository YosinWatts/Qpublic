$path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"

# Copy Login Data to a temporary location to avoid locking issues
$tmp = "$env:TEMP\chrome-login-data"
Copy-Item -Path $path -Destination $tmp -Force

# Connect to the SQLite database
$connection = New-Object System.Data.SQLite.SQLiteConnection
$connection.ConnectionString = "Data Source=$tmp;Version=3;New=False;Compress=True;"
$connection.Open()

# Retrieve the saved passwords
$query = "SELECT username_value, password_value, origin_url FROM logins"
$command = New-Object System.Data.SQLite.SQLiteCommand($query, $connection)
$result = $command.ExecuteReader()

# Convert password bytes to plaintext
$passwords = @()
while ($result.Read())
{
    $password = [System.Text.Encoding]::UTF8.GetString($result["password_value"])
    $username = $result["username_value"]
    $url = $result["origin_url"]
    $passwords += [PSCustomObject]@{
        Username = $username
        Password = $password
        URL = $url
    }
}

# Clean up
$result.Close()
$connection.Close()
Remove-Item $tmp -Force

# Display the saved passwords
$passwords
