# Project Notes

## Requests and Memory

Setting resources and requests allow the manager to ensure each service has
the necessary resources.

> "Enables the cluster manager to make intelligent decisions about whether or not a node is able to run a pod or not."

It is up to the developer to determine the resources allocated to containers.

### Cluster memory

- 1Mi = 1024Ki  1ki = 1024bytes
- 1M  = 1000K   1K  = 1000bytes

To get the cluster nodes:

```sh
kubectl get nodes
```

To see memory settings for node:

```sh
kubectl describe node [some-node]
```

When describing node, can also see chart of memory allocations/usage. This is helpful for determining how much memory a container will need.

#### CPU vs Memory

- 1 CPU = 1 vCPU (virtual CPU) running on AWS
- 1000m CPU = 1 CPU (one hundred millicpu/millicores)

### Cluster Limits

If the actual usage at run time exceeds the limit, further usage will be "clamped" or "throttled". This is useful if a program could cause memory leaks.

If a container tries taking more memory than set for limit, then it will be terminated with **OOMKilled** Error. Fix this error by increasing memory limits.

#### Theory

K8s is able to do this by utilizing *cgroups*, or "control groups", a default feature in Linux.

## Metrics

Commands:

```sh
# Pod usage
kubectl top pod
# Node usage
kubectl top node
```
