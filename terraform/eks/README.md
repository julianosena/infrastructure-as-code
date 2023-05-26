# Useful commands

## See all of addons allowed in Elastic Kubernetes Cluster

```
aws eks describe-addon-versions > addons.json
```

### Config your kubectl to your cluster
```
aws eks --region <REGION> update-kubeconfig --name <CLUSTER NAME>
```

### Forward traffic from a local port on your machine to the specific pod port

```
kubectl port-forward <pod-name> <local-port>:<pod-port>
```