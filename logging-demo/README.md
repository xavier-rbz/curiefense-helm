Sample filebeat + elasticsearch deployment, in order to get logs in the web UI.

Current status:

* logs flow from ingressgateway to filebeat to elasticsearch.
* UI tries to fetch logs from the "datalayer" backend service, which is not integrated yet.

The k8s cluster must have at least 3 nodes: the upstream elasticsearch does not
currently support single-node clusters (see
https://github.com/elastic/helm-charts/issues/1759). Or, you may manually
deploy your on single-node ES cluster.

# Installation

```
helm repo add elastic https://helm.elastic.co
helm install --create-namespace -n logging elasticsearch elastic/elasticsearch
helm install -f filebeat-values.yml --create-namespace -n logging filebeat elastic/filebeat
```

# Cleanup
```
helm uninstall -n logging elasticsearch
helm uninstall -n logging filebeat
kubectl delete namespace logging
```

# Troubleshooting notes
## Listing aliases from a elasticsearch pod
```
curl -k -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_aliases
```

## Searching aliases from a elasticsearch pod

* Generate searcheable logs first
```
export GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):80
curl -sS http://$GATEWAY_URL/AAAAAAAAAAAAA
```

* Search them from the elasticsearch pod
```
curl -k -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d '{"query": {"query_string": {"query":"AAAAAAAAAAAAA"}}}' https://localhost:9200/_search?pretty
```
