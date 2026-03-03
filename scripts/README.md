# PVC Debugger

export PVC_NAME=<my-pvc-name>
envsubst < pvc-debugger.yaml | kubectl apply -n <namespace> -f -
