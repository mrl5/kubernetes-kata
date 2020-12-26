# Kubernetes local infra kata

Setting up kubernetes cluster locally.
![https://kubernetes.io/docs/concepts/overview/components/](https://d33wubrfki0l68.cloudfront.net/2475489eaf20163ec0f54ddc1d92aa8d4c87c96b/e7c81/images/docs/components-of-kubernetes.svg)

from [nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)
> Kubernetes runs your workload by placing containers into Pods to run on Nodes.
> A node may be a virtual or physical machine, depending on the cluster. Each
> node contains the services necessary to run Pods, managed by the control plane.

## Master node on host
[control
plane](https://kubernetes.io/docs/reference/glossary/?all=true#term-control-plane)
description:
> The container orchestration layer that exposes the API and interfaces to
> define, deploy, and manage the lifecycle of containers

deps [kind install]
```
emerge docker kubectl
/etc/init.d/docker start
GO111MODULE="on" go get sigs.k8s.io/kind@v0.9.0
```
running control plane
```
cat <<EOF | $(go env GOPATH)/bin/kind create cluster --name kind --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  # WARNING: It is _strongly_ recommended that you keep this the default
  # (127.0.0.1) for security reasons. However it is possible to change this.
  apiServerAddress: "172.16.0.1"
  apiServerPort: 6443
EOF
```
info
```
kubectl cluster-info --context kind-kind
kubectl get nodes
```

new worker will require token and CA cert hash (from [adding new workers to cluster]):
```
docker exec -it kind-control-plane /bin/bash
kubeadm token create --print-join-command
```


## Worker node on microVM
> [kubelet] is the primary "node agent" that runs on each node

installing dependencies (references: [kubernetes on alpine linux], [kubernetes worker]):
```
echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories
apk update
apk add docker@community kubelet@testing kubeadm@testing kubectl@testing
```
clean fixes
```
sed -i 's/\t/    /g' /etc/init.d/docker
patch -p0 << 'EOF'
--- /etc/init.d/docker
+++ /etc/init.d/docker
@@ -7,6 +7,7 @@

 command="${DOCKERD_BINARY:-/usr/bin/dockerd}"
 command_args="${DOCKER_OPTS}"
+pidfile="${DOCKER_PIDFILE:-/run/${RC_SVCNAME}/${RC_SVCNAME}.pid}"
 DOCKER_LOGFILE="${DOCKER_LOGFILE:-/var/log/${RC_SVCNAME}.log}"
 DOCKER_ERRFILE="${DOCKER_ERRFILE:-${DOCKER_LOGFILE}}"
 DOCKER_OUTFILE="${DOCKER_OUTFILE:-${DOCKER_LOGFILE}}"
@@ -23,6 +24,7 @@
 }

 start_pre() {
+    mkdir -m 700 -p /run/docker
     checkpath -f -m 0644 -o root:docker "$DOCKER_ERRFILE" "$DOCKER_OUTFILE"
 }

EOF

patch -p0 << 'EOF'
--- /etc/init.d/kubelet
+++ /etc/init.d/kubelet
@@ -11,6 +11,7 @@

 command="/usr/bin/kubelet"
 command_args="${command_args} ${KUBELET_KUBEADM_ARGS}"
+pidfile="${KUBELET_PIDFILE:-/run/${RC_SVCNAME}.pid}"
 : ${output_log:=/var/log/$RC_SVCNAME/$RC_SVCNAME.log}
 : ${error_log:=/var/log/$RC_SVCNAME/$RC_SVCNAME.log}

EOF
```
dirty fixes
```
mkdir -p /boot && cd $_ &&
  wget https://raw.githubusercontent.com/firecracker-microvm/firecracker/master/resources/microvm-kernel-x86_64.config &&
  echo "CONFIG_NETFILTER_XT_MATCH_COMMENT=y" >> /boot/microvm-kernel-x86_64.config &&
  ln -s microvm-kernel-x86_64.config config-$(uname -r)

echo "172.16.0.1 kind-control-plane" >> /etc/hosts
echo "172.16.0.2 localhost worker-1" >> /etc/hosts
```
starting docker
```
/etc/init.d/docker start
rc-update add docker default
```
joining the cluster:
```
master=kind-control-plane
master_port=6443
token=
ca=

kubeadm join --v=5 --token $token $master:$master_port \
  --discovery-token-ca-cert-hash sha256:$ca
```
fixing ready state
```
sed -i 's/--network-plugin=cni //' /var/lib/kubelet/kubeadm-flags.env
/etc/init.d/kubelet restart
rc-update add kubelet default
```
improving entropy
```
echo $(cat /proc/sys/kernel/random/entropy_avail)/$(cat /proc/sys/kernel/random/poolsize)

apk add rng-tools
curl -s https://raw.githubusercontent.com/funtoo/nokit/1.4-release/sys-apps/rng-tools/files/rngd-initd-6.7-r1 \
    > /etc/init.d/rngd
/etc/init.d/rngd start
rc-update add rngd boot

echo $(cat /proc/sys/kernel/random/entropy_avail)/$(cat /proc/sys/kernel/random/poolsize)
```


## Verification
```
$ kubectl get nodes
NAME                 STATUS   ROLES    AGE     VERSION
kind-control-plane   Ready    master   5m49s   v1.19.1
worker-1             Ready    <none>   99s     v1.20.1
```

in case more verbosity is needed
```
kubectl describe nodes
```


[kubelet]: https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
[kubernetes cluster setup]: https://docs.solo.io/gloo-edge/latest/installation/platform_configuration/cluster_setup/
[kind install]: https://kind.sigs.k8s.io/
[kubernetes on alpine linux]: https://dev.to/xphoniex/how-to-create-a-kubernetes-cluster-on-alpine-linux-kcg
[kubernetes worker]: https://blog.sourcerer.io/a-kubernetes-quick-start-for-people-who-know-just-enough-about-docker-to-get-by-71c5933b4633#3664
[adding new workers to cluster]: https://www.serverlab.ca/tutorials/containers/kubernetes/how-to-add-workers-to-kubernetes-clusters/
