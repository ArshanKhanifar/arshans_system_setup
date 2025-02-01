#!/bin/bash

MACHINE_FILEPATH=`echo ~/remote-machines.txt`

function watchoor() {
    src_path=$1
    ignore_path=$2

    src_path=`pwd`/$src_path
    src_path=`realpath $src_path`
    dirname=`basename $src_path`

    if [ -n "$3" ]; then
        dst_path=$3
    else
        dst_path="~/synced/"
    fi

    echo "src_path: $src_path"
    if ! eval "select_machine"; then echo "command was not successful"; return; fi

    eval "ssh -i $keypath $hostname $additional_flags \"mkdir -p $dst_path\""

    always_ignore=".git .venv .idea"

    paths="$ignore_path $EXCLUDE_PATH $always_ignore"

    if [ -f $src_path/.gitignore ] && [ -n "$USE_GITIGNORE" ]; then
        paths+="`cat $src_path/.gitignore | grep -vE '(#|\*|~$)' | tr '\n' ' '`"
    fi

    excludes=`bash -c '
        excludes=""
        for item in $1; do
            excludes+="--exclude $item "
        done
        echo $excludes
    ' _ "$paths"`

    sync_command="rsync -avz -e \"ssh -i $keypath $additional_flags\" \"$src_path\" $excludes \"$hostname:$dst_path\""

    echo "sync command: 🐸"
    echo $sync_command

    eval $sync_command

    function _sync() {
        fswatch -0 "$src_path" | xargs -0 -n 1 -I {} bash -c '
            function sync_event {
                local src_path=$1
                local keypath=$2
                local hostname=$3
                local dst_path=$4
                local excludes=$5

                echo "Detected change in $src_path"

                sync_command="rsync -avz -e \"ssh -i $keypath\" \"$src_path\" $excludes \"$hostname:$dst_path\""

                eval $sync_command

                echo "Done syncing to $hostname"
            }
            sync_event "$1" "$2" "$3" "$4" "$5"
        ' _ "$src_path" "$keypath" "$hostname" "$dst_path" "$excludes"
    }

    _sync > /dev/null 2>&1 &

    sync_pid=`ps aux | grep "$src_path" | grep "$hostname" | grep -v grep | awk '{print $2}' | head -n 1`

    echo "$sync_pid $machine_name $keypath $hostname $src_path $dst_path " >> ~/watchoors
}

function get_watchoors() {
  while IFS= read -r line; do
    pid=`echo $line | awk '{print $1}'`
    machine_name=`echo $line | awk '{print $2}'`
    keypath=`echo $line | awk '{print $3}'`
    hostname=`echo $line | awk '{print $4}'`
    src_path=`echo $line | awk '{print $5}'`
    dst_path=`echo $line | awk '{print $6}'`
    echo "pid: $pid, machine_name: $machine_name, keypath: $keypath, hostname: $hostname, src_path: $src_path, dst_path: $dst_path"
  done < ~/watchoors
}

function kill_watchoor() {
  watchoor_pid=`get_watchoors | fzf | awk '{print $1}'`
  if [ -z "$watchoor_pid" ]; then return 1; fi;
  kill $watchoor_pid
  sed -i "\|^$watchoor_pid|d" ~/watchoors
}
