# Knative - serving

> Knative is Kubernetes-based platform to deploy and manage modern serverless
> workloads.

`serving` features:
> Run serverless containers on Kubernetes with ease, Knative takes care of the
> details of networking, autoscaling (even to zero), and revision tracking. You
> just have to focus on your core logic.


## Installing serving component
references: [knative installing serving component], [gloo edge for knative]
```
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.19.0/serving-crds.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.19.0/serving-core.yaml
```
networking layer choice: `Ambassador`, `Contour`, `Gloo`, `Istio`, `Kong`,
`Kourier`

choosing `gloo` (`glooctl` install part covered in
[03_local_gloo_apigw](../03_local_gloo_apigw/README.md))
```
export PATH=$HOME/.gloo/bin:$PATH
glooctl install knative --install-knative=false
kubectl get all -n gloo-system
```

(optional) real dns ...
```
DOMAIN_NAME="foobar.gtn"
GATEWAY_IP=`glooctl proxy url --name knative-external-proxy | cut -d'/' -f3 | cut -d ':' -f1`
echo -e "$GATEWAY_IP\t$DOMAIN_NAME" | sudo tee -a /etc/hosts
```


## Hello World
references: [sample knative app]

creating deployment with yaml
```
kubectl apply --filename service.yaml
```

query app w/o setting up DNS
```
HOST=`kubectl get ksvc $app | grep $app | cut -d'/' -f3 | cut -d' ' -f1`
PROXY=`glooctl proxy url --name knative-external-proxy`
curl -H "Host: $HOST" $PROXY
```


## Monitoring
generating load (absolutely barbaric)
```
while true; do curl -H "Host: $HOST" $PROXY & done
```
watching pods scale
```
kubectl get pods
```
checking pods per node
```
kubectl describe nodes
```


## There is more
- https://www.youtube.com/watch?v=28CqZZFdwBY
- https://knative.dev/docs/serving/autoscaling/concurrency/



[knative installing serving component]: https://knative.dev/docs/install/any-kubernetes-cluster/#installing-the-serving-component
[gloo edge for knative]: https://docs.solo.io/gloo-edge/latest/installation/knative/
[sample knative app]: https://knative.dev/docs/serving/getting-started-knative-app/
