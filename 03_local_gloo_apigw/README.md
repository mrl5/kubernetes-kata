# API Gateway - gloo edge

[gloo getting started]


## Install
I'd use `helm` if it would be maintained in my dist ([installing on kubernetes with helm])

references: [installing on kubernetes with glooctl]
```
# ugly ugly
curl -sL https://run.solo.io/gloo/install | sh
```

```
glooctl install gateway
```


## Verify
[verify gloo installation]
```
kubectl get all -n gloo-system
```


## Hello world
from [gloo hello world]

deploy app
```
kubectl apply -f https://raw.githubusercontent.com/solo-io/gloo/v1.2.9/example/petstore/petstore.yaml
kubectl -n default get pods
kubectl -n default get svc petstore
glooctl get upstreams
kubectl label namespace default  discovery.solo.io/function_discovery=enabled namespace/default labeled
glooctl get upstream default-petstore-8080
```
routing
```
glooctl add route \
  --path-exact /all-pets \
  --dest-name default-petstore-8080 \
  --prefix-rewrite /api/pets
glooctl get virtualservice default
```
test
```
curl $(glooctl proxy url)/all-pets
```

## Clean up
[gloo edge clean up]
```
glooctl uninstall --all
```

## Post mortem

[knative] will be better than this



[gloo getting started]: https://docs.solo.io/gloo-edge/latest/getting_started/
[installing on kubernetes with helm]: https://docs.solo.io/gloo-edge/latest/installation/gateway/kubernetes/#installing-on-kubernetes-with-helm
[installing on kubernetes with glooctl]: https://docs.solo.io/gloo-edge/latest/installation/gateway/kubernetes/#installing-on-kubernetes-with-glooctl
[verify gloo installation]: https://docs.solo.io/gloo-edge/latest/installation/gateway/kubernetes/#verify-your-installation
[gloo hello world]: https://docs.solo.io/gloo-edge/latest/guides/traffic_management/hello_world/
[gloo edge clean up]: https://docs.solo.io/gloo-edge/latest/installation/gateway/kubernetes/#uninstall-with-glooctl
[knative]: https://knative.dev/docs/serving/getting-started-knative-app/
