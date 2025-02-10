#!/bin/bash

function vmdelete() {
    rm -f /tmp/gcp-machines.txt 2>/dev/null || true
    gcloud compute instances list | grep -i running | fzf -m > /tmp/gcp-machines.txt
    while read -r line; do
        name=`echo $line | awk '{print $1}'`
        zone=`echo $line | awk '{print $2}'`
        gcloud compute instances delete $name --zone=$zone --quiet &
    done < /tmp/gcp-machines.txt
    wait
    rm -f /tmp/gcp-machines.txt
}

function parseVmArgs() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --name)
                name=$2
                shift
                ;;
            --tdx)
                tdx=1
                ;;
            --zone)
                zone=$2
                shift
                ;;
            --machine-type)
                machine_type=$2
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

# usage: vmcreate --tdx --name <n>
function vmcreate() {
    parseVmArgs "$@"

    if [ -z "$name" ]; then
        echo "name is required"
        return 1
    fi

    if [ -z "$zone" ]; then
        zone="us-central1-a"
    fi

    if [ -z "$machine_type" ]; then
        if [ -n "$tdx" ]; then
            machine_type="n2d-standard-4"
        else
            machine_type="e2-standard-4"
        fi
    fi

    if [ -n "$tdx" ]; then
        gcloud compute instances create $name \
            --zone=$zone \
            --machine-type=$machine_type \
            --confidential-compute \
            --maintenance-policy=TERMINATE \
            --image=ubuntu-2204-jammy-v20230919 \
            --image-project=ubuntu-os-cloud \
            --boot-disk-size=200GB \
            --boot-disk-type=pd-balanced \
            --boot-disk-device-name=$name \
            --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
            --no-shielded-secure-boot \
            --shielded-vtpm \
            --shielded-integrity-monitoring \
            --labels=goog-ec-src=vm_add-gcloud \
            --reservation-affinity=any
    else
        gcloud compute instances create $name \
            --zone=$zone \
            --machine-type=$machine_type \
            --image=ubuntu-2204-jammy-v20230919 \
            --image-project=ubuntu-os-cloud \
            --boot-disk-size=200GB \
            --boot-disk-type=pd-balanced \
            --boot-disk-device-name=$name
    fi

    # Add SSH key to the instance
    ssh_key=~/.ssh/arshan.pub
    gcloud compute instances add-metadata $name \
        --zone=$zone \
        --metadata=ssh-keys="ritual:`cat $ssh_key`"
}

function vmserial() {
    if ! eval "select_machine"; then
        echo "command was not successful"
        return
    fi
    gcloud compute instances get-serial-port-output $machine_name --zone=$zone
}

function vmaddserial() {
    if ! eval "select_machine"; then
        echo "command was not successful"
        return
    fi
    gcloud compute instances add-metadata $machine_name \
        --metadata=serial-port-enable=true \
        --zone=$zone
}

function copysetup() {
    if ! eval "select_machine"; then
        echo "command was not successful"
        return
    fi
    gcloud compute scp --zone=$zone setup.sh $machine_name:~/
}

function vmdescribe() {
    if ! eval "select_machine"; then
        echo "command was not successful"
        return
    fi
    gcloud compute instances describe $machine_name --zone=$zone
}

# NEW: vmwait command, keeps trying to ssh until the VM becomes available
function vmwait() {
    if ! eval "select_machine"; then
        echo "command was not successful"
        return
    fi
    local cmd="ssh -i $keyfile $hostname $additional_flags echo 'im ready'"
    echo "Waiting for $hostname to become available..."
    while true; do
        eval "$cmd" && break
        echo "VM not yet available, retrying in 5 seconds..."
        sleep 5
    done
}

# delete gcp firewalls
function fwdelete() {
    rm -f /tmp/gcp-firewalls.txt 2>/dev/null || true
    gcloud compute firewall-rules list | grep -i default | fzf -m > /tmp/gcp-firewalls.txt
    while read -r line; do
        name=`echo $line | awk '{print $1}'`
        gcloud compute firewall-rules delete $name --quiet &
    done < /tmp/gcp-firewalls.txt
    wait
    rm -f /tmp/gcp-firewalls.txt 2>/dev/null || true
}

function fwallow() {
    if ! eval "select_machine"; then
        echo "command was not successful"
        return
    fi
    gcloud compute firewall-rules create default-allow-$machine_name \
        --direction=INGRESS \
        --priority=1000 \
        --network=default \
        --action=ALLOW \
        --rules=tcp:80,tcp:443,tcp:22 \
        --source-ranges=0.0.0.0/0 \
        --target-tags=$machine_name
}

function removetags() {
    if ! eval "select_machine"; then
        echo "command was not successful"
        return
    fi
    gcloud compute instances remove-tags $machine_name \
        --zone=$zone \
        --tags=http-server,https-server
}

# delete gcp networks
function nwdelete() {
    rm -f /tmp/gcp-networks.txt 2 >/dev/null || true
    gcloud compute networks list | grep -i default | fzf -m > /tmp/gcp-networks.txt
    while read -r line; do
        name=`echo $line | awk '{print $1}'`
        gcloud compute networks delete $name --quiet &
    done < /tmp/gcp-networks.txt
    wait
    rm -f /tmp/gcp-networks.txt
}

# delete gcp subnetworks
function snwdelete() {
    rm /tmp/gcp-subnetworks.txt || true
    gcloud compute networks subnets list | grep -i default | fzf -m > /tmp/gcp-subnetworks.txt
    while read -r line; do
        name=`echo $line | awk '{print $1}'`
        region=`echo $line | awk '{print $2}'`
        gcloud compute networks subnets delete $name --region=$region --quiet
    done < /tmp/gcp-subnetworks.txt
    rm /tmp/gcp-subnetworks.txt
}

function create_vm() {
  if [ -z "$1" ]; then
    echo "Please provide a machine type"
    return
  fi
  zone_line=`gcloud compute zones list | fzf `
  zone=`echo $zone_line | awk '{print $1}'`
  region=`echo $zone_line | awk '{print $2}'`
  echo "Creating instance in zone: $zone & region: $region"
  instance_name=$(prefix)-$zone
  output=`gcloud compute instances create $instance_name \
    --zone=$zone \
    --machine-type=$1 \
    --image-family=debian-10 \
    --image-project=debian-cloud \
    --tags=http-server`
  ip=`echo $output | grep RUNNING | awk '{print $5}'`
  echo "$instance_name gcp-ritual $ip" >> $MACHINE_FILEPATH
}

function add_to_machine_file() {
  filename=$1
  # note: for looping over space-separated values don't work the same way in zsh,
  # this should work both in bash and zsh
  ip_addresses=(`cat $filename | awk '{print $4}' | tr '\n' ' '`)
  for ip in "${ip_addresses[@]}"; do
    name=`cat $filename | grep $ip | awk '{print $1}'`
    ssh_user=`cat $filename | grep $ip | awk '{print $2}'`
    ssh_key=`cat $filename | grep $ip | awk '{print $3}'`
    sed -i "\|$ip|d" $MACHINE_FILEPATH
    echo "$name $ssh_key $ssh_user@$ip" >> $MACHINE_FILEPATH
  done
}

function add_gcp_vms_to_machine_file() {
  gcloud compute instances list > /tmp/allmachines
  if [ -z "$1" ] && [ "$1" = "auto" ]; then
    cat /tmp/allmachines > /tmp/machines
  else
    cat /tmp/allmachines | fzf -m > /tmp/machines
  fi
  ip_addresses=`cat /tmp/machines | awk '{print $5}'`
  for ip in $ip_addresses; do
    ssh-keygen -R $ip && ssh-keyscan -H $ip >> ~/.ssh/known_hosts 2>&1 > /dev/null
    sed -i "\|$ip|d" $MACHINE_FILEPATH
  done
  cat /tmp/machines | awk '{print $1 " ~/.ssh/arshan ritual@" $5}' >> $MACHINE_FILEPATH
  rm /tmp/machines
}
