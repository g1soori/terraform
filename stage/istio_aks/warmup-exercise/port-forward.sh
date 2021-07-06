# kubectl --namespace default     port-forward $(kubectl \
#     --namespace default \
#     get pod \
#     --selector app=webapp \
#     --output jsonpath='{.items[0].metadata.name}') \
#     8000:80 &

kubectl --namespace istio-system      port-forward $(kubectl \
    --namespace istio-system \
    get pod \
    --selector app=kiali \
    --output jsonpath='{.items[0].metadata.name}') \
    8001:20001 &

kubectl --namespace istio-system      port-forward $(kubectl \
    --namespace istio-system \
    get pod \
    --selector app=kiali \
    --output jsonpath='{.items[0].metadata.name}') \
    9090:9090 &