# Project Notes

## Requests and Memory

Setting resources and requests allow the manager to ensure each service has
the necessary resources.

> "Enables the cluster manager to make intelligent decisions about whether or not a node is able to run a pod or not."

It is up to the developer to determine the resources allocated to containers.

### Cluster memory

- 1Mi = 1024Ki 1ki = 1024bytes
- 1M = 1000K 1K = 1000bytes

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

If a container tries taking more memory than set for limit, then it will be terminated with `OOMKilled` Error. Fix this error by increasing memory limits.

#### Theory

K8s is able to do this by utilizing _cgroups_, or "control groups", a default feature in Linux.

## Metrics

Commands:

```sh
# Pod usage
kubectl top pod
# Node usage
kubectl top node
```

## Scaling

- **Horizontal scaling**: increasing the amount of pods/nodes in the system to handle more requests
- **Vertical scaling**: increasing the individual power of each pod

### Horizontal Auto Scaling (HPA)

Create autoscale:

```sh
kubectl autoscale deployment api-gateway --cpu-percent 400 --min 1 --max 4
```

Show autoscale rules:

```sh
kubectl get hpa
```

Get yml version of autoscale:

```sh
kubectl get hpa api-gateway -o yaml
```

## QoS and Evictions

### QoS

> Quality of Service

K8s applies labels to pods depending on memory and cpu:

- **QoS: Guaranteed**: If the pod has a mem/cpu request and limit set
- **QoS: Burstable**: If the pod only has a mem/cpu request set
- **QoS: BestEffort**: If neither mem/cpu request or limit is set

## Helm

### Commands

**Add a repo:**

```sh
helm repo add [label] [repo-link]
```

**Add chart:**

```sh
helm install [label] [repo-label]/[chart-name]
```

**Set variable via cli:**

```sh
helm upgrade [chart-label] [repo-label]/[chart] --set [parent].[variable]=[new-value]
```

**Show default values for chart:**

```sh
helm show values [repo-label]/[chart]
```

**Output values to file (values.yml):**

```sh
helm show values [repo-label]/[chart] > values.yml
```

**Apply values file:**

```sh
helm upgrade [chart-label] [repo-label]/[chart] --values=values.yml
# Ex: helm upgrade monitoring prom-repo/kube-prometheus-stack --values=values.yml
```

**Download chart locally:**

```sh
helm pull [repo-label]/[chart] --untar=true
# Ex: helm pull prom-repo/kube-prometheus-stack --untar=true
```

**Generate template from helm chart:**

```sh
helm template [chart-label] [chart-location] [...flags]
# Ex: helm template monitoring ./kube-prometheus-stack/ --values=./kube-prometheus-stack/myvalues.yml
# Note: chart-location could be directory, or [repo-label]/[chart]
```

**Apply variables to local chart:**

```sh
helm upgrade [chart-label] --values=[./path/to/values.yml] [./path/to/chart]
# Ex: helm upgrade monitoring --values=./kube-prometheus-stack/myvalues.yml .
```

**Create new chart:**

```sh
helm create [chart-name]
# Ex: helm create fleetman-helm-chart
```

**Testing template generation of custom chart (inside its directory):**

```sh
helm template .
```

This will combine all yaml files into one file.

### Notes

Do not put custom values in values.yaml of chart, make custom overrides file.

When working with helm, need to avoid "snowflake" servers: <https://martinfowler.com/bliki/SnowflakeServer.html>, instead need to make "phoenix" servers: <https://martinfowler.com/bliki/PhoenixServer.html> by making templates, etc.

### About Custom Charts

Files:

- `Chart.yaml`: useful info about chart, like package.json for meta info
- `templates/`: All yml files defined in here will be sent through processor to create k8s yml files.
- `values.yaml`: Variables to switch out in template files
- `templates/_file-name.tpl`: Named templates / Partials. Can have any extension, convention to use .tpl
- `charts/`: External charts to use

### Templating

Template processor uses Go templating language

When accessing variables from `values.yaml`, reference it like this:

```txt
replicas: {{ .Values.replicaCount }}
```

Flow control using prefix notation:

```yaml
image: richardchesterwood/k8s-fleetman-helm-demo:v1.0.0{{ if .Values.development }}-dev{{ end }}
```

If the env is dev, it will render the image with -dev appended to tag; otherwise, will skip the rest of the line of logic

#### Named templates

When using template tag like:

```txt
{{- template "sometemplate" . }}
```

- The dot represents context for variables, start from '.' context.
- The dash tells parser to remove leftover blank lines.

Difference between _template_ and _include_ directives: when using include, can produce yaml from pipelines.

## Secrets

When using the 'data' block, values need to be base64 encoded. Instead need to use stringData block for automatic encoding.

Secrets are unsecured, can easily get values by:

```sh
kubectl get secret secret-name -o yaml
echo secret-value | base64 -d
```

Secrets are used to just add another layer of defense. They should be used for values that you wouldn't want someone seeing if peeking over your shoulder in public, but it is fine if a coworker has access to the system and can see the secret. Do not use for hyper-sensitive values like aws credentials.

## Ingress

Levels:

- Use level 4 if doing websockets
- Use level 7 otherwise
