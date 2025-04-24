#!/bin/bash

MACHINE_FILEPATH=`echo ~/remote-machines.txt`

function henlo() {
    echo "hnlo"
}

function addmachine2config() {
    if ! eval "select_machine"; then 
        echo "No machine selected"
        return 1
    fi

    # Extract username from hostname if it exists (user@host format)
    user=$(echo "$hostname" | cut -d'@' -f1)
    host=$(echo "$hostname" | cut -d'@' -f2)
    
    # If there was no @ in the hostname, host will be same as hostname
    # and we'll use the current user as default
    if [ "$host" = "$hostname" ]; then
        user=$(whoami)
        host=$hostname
    fi

    # Create the config entry
    config_entry="
Host $machine_name
    HostName $host
    User $user
    IdentityFile $keypath
    AddKeysToAgent yes
    UseKeychain yes
"
    
    # Append to ~/.ssh/config
    echo "$config_entry" >> ~/.ssh/config
    echo "$config_entry" >> ~/.ssh/config.personal
    echo "$config_entry" >> ~/.ssh/config.ritual
    echo "✅ Added config entry for $machine_name"
    echo "You can now use: code --remote ssh-remote+$machine_name /path/to/directory"
}
