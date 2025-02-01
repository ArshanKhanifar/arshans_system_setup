#!/bin/bash

podinfo_columns="HOST_NAME:.spec.nodeName,NAME:.metadata.name,NAMESPACE:.metadata.namespace,STATUS:.status.phase,HOST_IP:.status.hostIP,IP:.status.podIP"

function selectPod() {
    if [ -z $1 ]; then
        line=`kubectl get pods --all-namespaces -o custom-columns=$podinfo_columns | fzf`
    else
        line=`kubectl get pods --all-namespaces -o custom-columns=$podinfo_columns | grep $1 | head -n 1`
    fi
    if [ -z "$line" ]; then return 1; fi
    pod=`echo $line | awk '{print $2}'`
    namespace=`echo $line | awk '{print $3}'`
}

function poddescribe() {
    if ! selectPod "$@"; then return; fi
    kubectl describe pod $pod -n $namespace
}

function poddescribew() {
    if ! selectPod "$@"; then return; fi
    while true; do
        clear
        kubectl describe pod $pod -n $namespace
        sleep 1
    done
}

function nodedescribe() {
    if ! selectPod "$@"; then return; fi
    kubectl describe node $pod
}

function nodedelete() {
    if ! selectPod "$@"; then return; fi
    kubectl delete node $pod
}

function delete_service() {
    service_name=$1
    if [ -z "$service_name" ]; then
        echo "Please provide a service name"
        return 1
    fi
    kubectl delete service $service_name
}

function podlogs() {
    if ! selectPod "$@"; then return; fi
    kubectl logs -f $pod -n $namespace
}

function poddelete() {
    if ! selectPod "$@"; then return; fi
    kubectl delete pod $pod --namespace=$namespace
}

function podcurl() {
    kubectl run curl-pod --rm -it --image=curlimages/curl --restart=Never -- sh
}

function podtop() {
    if ! selectPod "$@"; then return; fi
    watch -n 1 kubectl top pod $pod -n $namespace
}

function podsh() {
    if ! selectPod "$@"; then return; fi
    kubectl exec -it $pod -n $namespace -- /bin/sh
}
