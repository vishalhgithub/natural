#!/bin/bash

# Redirect output to log file
exec > /var/log/MVCuser-data.log 2>&1
set -x

# Add a delay to ensure all services are up
sleep 60

# Run the shell command and capture the IPv4 address output
PrivateIP=$(hostname -I | awk '{print $1}')
echo "The captured Private IP address is: $PrivateIP"


# MVC Configuration

# Append the URL configuration to Program.cs
sed -i "/var app = builder.Build();/a\
app.Urls.Add(\"http://${PrivateIP}:5001\");" /home/ubuntu/natural_mvc/NatDMS/Program.cs

# Capture the public IP address
PublicIP=$(curl -s ifconfig.me)
echo "The captured Public IP address is: ${PublicIP}"

# Define the URL to comment out and replace
urlNeedToComment='"Natrual_API": "https://localhost:7101/api",'
commentedUrl='//"Natrual_API": "https://localhost:7101/api",'
urlNeedToReplace='//"Natrual_API": "http://13.201.40.123:9999/api",'
replacementUrl="\"Natrual_API\": \"http://${PublicIP}:5024/api\","

# Comment out and replace the URL in appsettings.json
echo "Updating appsettings.json..."
sed -i "s|${urlNeedToComment}|${commentedUrl}|g" /home/ubuntu/natural_mvc/NatDMS/appsettings.json
sed -i "s|${urlNeedToReplace}|${replacementUrl}|g" /home/ubuntu/natural_mvc/NatDMS/appsettings.json

# Navigate to the Natural_MVC directory and publish the MVC application
cd /home/ubuntu/natural_mvc/NatDMS
DOTNET_CLI_HOME=/home/ubuntu/.dotnet /usr/share/dotnet/dotnet publish -c Release -o /home/ubuntu/natural_mvc/NatDMS/publish

# Check if publish was successful
if [ $? -ne 0 ]; then
    echo "dotnet publish failed for MVC."
    exit 1
fi

# Navigate to the Natural_MVC publish directory and run the MVC application
cd /home/ubuntu/natural_mvc/NatDMS/publish
nohup /usr/share/dotnet/dotnet NatDMS.dll > nohup-mvc.out 2>&1 &
