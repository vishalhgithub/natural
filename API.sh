#!/bin/bash

# Redirect output to log file
exec > /var/log/user-data.log 2>&1
set -x

# Add a delay to ensure all services are up
sleep 60

# Run the shell command and capture the IPv4 address output
PrivateIP=$(hostname -I | awk '{print $1}')

# Use the PrivateIP variable in your script as needed
echo "The captured IP address is: $PrivateIP"

# Define the URL to replace
urlNeedToReplace='//app.Urls.Add("http://10.0.0.4:5024")'

# Define the replacement URL
replacementUrl="app.Urls.Add(\"http://${PrivateIP}:5024\")"

# Check if the directory and file exist
if [ -d "/home/ubuntu/natural_api/Natural_API" ]; then
    cd /home/ubuntu/natural_api/Natural_API
    if [ -f "Program.cs" ]; then
        echo "Updating Program.cs file..."
        sed -i "s|${urlNeedToReplace}|${replacementUrl}|g" Program.cs
        echo "Program.cs updated successfully."
    else
        echo "Program.cs not found."
    fi
else
    echo "Directory /home/ubuntu/natural_api/Natural_API not found."
fi

#Create publish folder
mkdir -p /home/ubuntu/natural_api/Natural_API/publish

# Execute dotnet publish command with the environment variable inline
echo "Running dotnet publish..."
DOTNET_CLI_HOME=/home/ubuntu/.dotnet /usr/share/dotnet/dotnet publish -c Release -o /home/ubuntu/natural_api/Natural_API/publish

# Check if publish was successful
if [ $? -ne 0 ]; then
    echo "dotnet publish failed."
    exit 1
fi

# Navigate to the publish directory
cd /home/ubuntu/natural_api/Natural_API/publish

# Run the .NET application with nohup
nohup /usr/share/dotnet/dotnet Natural_API.dll > nohup.out 2>&1 &
