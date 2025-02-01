#!/bin/bash

alias docrmall='docker kill `docker ps -aq` || true && docker rm `docker ps -aq` || true'

function selectContainers() {
    local pattern=$1
    if [ -z "$pattern" ]; then
        docker ps --format "{{.ID}} {{.Names}}" | fzf -m | awk '{print $1}'
    else
        docker ps --format "{{.ID}} {{.Names}}" | grep "$pattern" | fzf -m | awk '{print $1}'
    fi
}

function docrm() {
    local containers=$(selectContainers $1)
    [ ! -z "$containers" ] && echo "$containers" | xargs docker rm -f
}

function dockill() {
    local containers=$(selectContainers $1)
    [ ! -z "$containers" ] && echo "$containers" | xargs docker kill
}

function docsh() {
    local container=$(selectContainers $1 | head -n1)
    [ ! -z "$container" ] && docker exec -it "$container" sh
}

function doctest() {
    docker exec -it $(selectContainers $1 | head -n1) pytest
}

function parseCommonLogs() {
    local pattern=$1
    local containers=$(selectContainers "$pattern")
    if [ ! -z "$containers" ]; then
        echo "$containers" | while read container; do
            docker logs "$container" 2>&1 | grep -v "DEBUG\|INFO" | grep -v "Validating\|Validated\|Generating\|Generated\|Compiling\|Compiled" | grep -v "Checking\|Checked\|Loading\|Loaded\|Writing\|Wrote" | grep -v "Scanning\|Scanned\|Reading\|Read\|Creating\|Created" | grep -v "Building\|Built\|Installing\|Installed\|Downloading\|Downloaded" | grep -v "Collecting\|Collected\|Preparing\|Prepared\|Unpacking\|Unpacked" | grep -v "Setting up\|Set up\|Cleaning up\|Cleaned up" | grep -v "Running\|Ran\|Finishing\|Finished\|Starting\|Started" | grep -v "Searching\|Searched\|Finding\|Found\|Looking\|Looked" | grep -v "Processing\|Processed\|Handling\|Handled\|Managing\|Managed"
        done
    fi
}

function doclogsm() {
    local pattern=$1
    local containers=$(selectContainers "$pattern")
    if [ ! -z "$containers" ]; then
        echo "$containers" | while read container; do
            docker logs "$container" 2>&1 | grep -v "DEBUG\|INFO" | grep -v "Validating\|Validated\|Generating\|Generated\|Compiling\|Compiled" | grep -v "Checking\|Checked\|Loading\|Loaded\|Writing\|Wrote" | grep -v "Scanning\|Scanned\|Reading\|Read\|Creating\|Created" | grep -v "Building\|Built\|Installing\|Installed\|Downloading\|Downloaded" | grep -v "Collecting\|Collected\|Preparing\|Prepared\|Unpacking\|Unpacked" | grep -v "Setting up\|Set up\|Cleaning up\|Cleaned up" | grep -v "Running\|Ran\|Finishing\|Finished\|Starting\|Started" | grep -v "Searching\|Searched\|Finding\|Found\|Looking\|Looked" | grep -v "Processing\|Processed\|Handling\|Handled\|Managing\|Managed" | less
        done
    fi
}

function doclogs() {
    local container=$(selectContainers $1 | head -n1)
    [ ! -z "$container" ] && docker logs -f "$container"
}

function docinspect() {
    local container=$(selectContainers $1 | head -n1)
    [ ! -z "$container" ] && docker inspect "$container"
}

function emlinux() {
  image="arshankhanifar/profile:latest"
  if [ -n "$1" ]; then
    image=$1
  fi
  docker run --rm -it $image
}
