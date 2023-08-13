#!/bin/bash

# Function to print a simple ASCII box with the title
print_ascii_box() {
    local title="$1"
    local title_length=${#title}
    local box_width=$(( title_length + 4 ))
    
    echo "+$(printf '=%.0s' $(seq 1 $box_width))+"
    printf "| %s |\n" "$title"
    echo "+$(printf '=%.0s' $(seq 1 $box_width))+"
}

# Print the ASCII box with the title
print_ascii_box "Resonite Headless Installer"

# Rest of the script...

# Prompt the user for input
read -r -p "Enter your Steam username: " steam_username
while [[ -z "$steam_username" ]]; do
    echo "Username cannot be blank."
    read -r -p "Enter your Steam username: " steam_username
done

read -r -s -p "Enter your Steam password: " steam_password
echo
while [[ -z "$steam_password" ]]; do
    echo "Password cannot be blank."
    read -r -s -p "Enter your Steam password: " steam_password
    echo
done

read -r -p "Do you want to clean assets (true/false, press Enter for true)? " clean_assets_input
clean_assets=${clean_assets_input:-true}

read -r -p "Do you want to clean logs (true/false, press Enter for true)? " clean_logs_input
clean_logs=${clean_logs_input:-true}

# Write the values to the .env file
{
    echo "STEAMLOGIN=$steam_username $steam_password"
    echo "CLEANASSETS=$clean_assets"
    echo "CLEANLOGS=$clean_logs"
    echo "HOSTUSERID=1000"
    echo "HOSTGROUPID=1000"
    echo "STEAMBETA=headless"
} >> .env

echo
echo
# Check if Config/Config.json file exists
config_file="Config/Config.json"
if [ ! -e "$config_file" ]; then
    echo "Creation of Server Config"

    # Prompt for loginCredential and loginPassword if the file doesn't exist
    while true; do
        read -r -p "Enter your Resonite Headless Login (usually email): " login_credential
        if [[ -n "$login_credential" ]]; then
            break
        else
            echo "loginCredential cannot be blank."
        fi
    done

    while true; do
        read -r -s -p "Enter your Password: " login_password
        echo
        if [[ -n "$login_password" ]]; then
            break
        else
            echo "Password cannot be blank."
        fi
    done

    while true; do
        read -r -p "What default access level should the world be (Private, Friends, FriendsOfFriends, Registered, Anyone): " acl

        if [[ -n "$acl" ]]; then
            if [ "$acl" = "Private" ]; then
                echo
                echo -e "\e[1m\e[31m          ======= ! DANGER ! =======\e[0m"
                echo -e "\e[1m\e[31mPRIVATE ACCESS LEVEL WILL RESTRICT YOURSELF FROM ENTERING.\e[0m"
                echo -e "\e[1m\e[31mDo you wish to continue with this value (yes/no)?\e[0m"
                echo
                read -r confirm
                if [ "$confirm" = "yes" ]; then
                    break
                fi
            else
                break
            fi
        else
            echo "Access level cannot be blank."
        fi
    done

    while true; do
        read -r -p "What World URL Would you like to use (resrec:///): " resrec
        if [[ "$resrec" == resrec:///* ]]; then
            break
        else
            echo "World URL must start with 'resrec:///'."
        fi
    done

    while true; do
        read -r -p "Max User Count: " maxusers
        if [[ -z "$maxusers" || "$maxusers" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "Max User Count must be a numeric value or empty."
        fi
    done

echo

    cat <<EOT > "$config_file"
{
  "\$schema": "https://raw.githubusercontent.com/Yellow-Dog-Man/JSONSchemas/main/schemas/HeadlessConfig.schema.json",
  "comment": "DO NOT EDIT THIS FILE! Your changes will be lost. Copy it over and create a new file called Config.json",
  "universeId": null,
  "tickRate": 60.0,
  "maxConcurrentAssetTransfers": 4,
  "usernameOverride": null,
  "loginCredential": "$login_credential",
  "loginPassword": "$login_password",
  "startWorlds": [
    {
      "isEnabled": true,
      "sessionName": null,
      "customSessionId": null,
      "description": null,
      "maxUsers": $maxusers,
      "accessLevel": "$acl",
      "useCustomJoinVerifier": false,
      "hideFromPublicListing": null,
      "tags": null,
      "mobileFriendly": false,
      "loadWorldURL": "$resrec",
      "loadWorldPresetName": "Grid",
      "overrideCorrespondingWorldId": null,
      "forcePort": null,
      "keepOriginalRoles": false,
      "defaultUserRoles": null,
      "roleCloudVariable": null,
      "allowUserCloudVariable": null,
      "denyUserCloudVariable": null,
      "requiredUserJoinCloudVariable": null,
      "requiredUserJoinCloudVariableDenyMessage": null,
      "awayKickMinutes": -1.0,
      "parentSessionIds": null,
      "autoInviteUsernames": null,
      "autoInviteMessage": null,
      "saveAsOwner": null,
      "autoRecover": true,
      "idleRestartInterval": -1.0,
      "forcedRestartInterval": -1.0,
      "saveOnExit": false,
      "autosaveInterval": -1.0,
      "autoSleep": true
    }
  ],
  "dataFolder": null,
  "cacheFolder": null,
  "logsFolder": null,
  "allowedUrlHosts": null,
  "autoSpawnItems": null
}
EOT
else
    echo "Config/Config.json file already exists. Skipping creation."
fi

# Start the docker-compose services
echo "Starting docker container, you can tail this process with the command"
echo "docker logs -f resonite-headless-headless-core-1"
echo
docker-compose up -d