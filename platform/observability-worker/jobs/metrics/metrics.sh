#!/bin/sh
echo "labeling"
kubectl label authorino -n kuadrant-system authorino app=authorino
kubectl label service -n kuadrant-system authorino-controller-metrics app=authorino

echo "Adding prometheus proxy setup for scraping kubelet metrics from openshift monitoring stack"

# TLDR: Set up a ServiceMonitor to pull in low level metrics for our dashboards
#
# Some grafana dashboard panels make use of kubelet metrics & recording rules that
# only exist in the openshift-monitoring prometheus.
# These are metrics/rules like container_memory_working_set_bytes & 
# node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate
#
# Unfortunately, these metrics are not available in the user workload monitoring 
# prometheus instance, where we remote write metrics from, to our thanos instance
# in the monitoring namespace.
# In a single cluster environment, we could just add the thanos-query instance
# from the openshift-monitoring namespace as a data source to our Grafana instance,
# as that does have the combined openshift-monitoring *and* user workload metrics
# all in one place.
# However, our setup is designed to work with multiple clusters, hence our thanos
# instance in the monitoring namespace.
#
# The remote write of the user workload metrics is the easy part.
# That's done by patching the `user-workload-monitoring-config` configmap.
# See the patch.sh file for how that's done.
#
# To remote write the openshift-monitoring metrics, we need to do some hacky things.
#
# Here's some methods I've tried and ruled out already:
#
# 1. Configuring remoteWrite in the openshift-monitoring prometheus. Although this
# is configurable in the cluster-monitoring-config configmap
# (https://docs.openshift.com/container-platform/4.15/observability/monitoring/configuring-the-monitoring-stack.html),
# that's only possible with OCP, not OSD. In OSD, that configmap is reconciled
# back by hive.
#
# 2. Getting the user workload prometheus to scrape directly from prometheus federate
# endpoint by having a ServiceMonitor target the prometheus service in the
# openshift-monitoring namespace. This doesn't work as the user-workload prometheus
# has the `ignoreNamespaceSelectors` flag enabled in the Prometheus resource, which
# means a ServiceMonitor can't target a Service in a different namespace.
# (We have to create the ServiceMonitor in a user namespace, not an openshift- prefix
# namespace for user workload to detect it)
#
# 3. Getting the user workload prometheus to scrape directly from the kubelet via
# a ServiceMonitor. For the same reason that 2 is not possible, we can't do this
#
# 4. Adding a custom/additional scrape config. This isn't possible with user workload
# prometheus. The option isn't surfaced up from the Prometheus resource to the 
# user-workload-monitoring-config configmap.
#
# 5. Defining a custom/additional scrape config with a ScrapeConfig CRD. The version
# of the prometheus operator doesn't seem to have this CRD yet.
#
# The hacky workaround in the end was to create an 'ExternalName' Service with the
# internal service hostname of the prometheus service to bypass the cross namespace
# restriction. Then create a ServiceMonitor to scrape from that 'ExternalName' service.
# Additional setup was needed to create a serviceaccount and get a long lived bearer
# token to pass along to the federate endpoint.
# 1 more step was needed to trigger the prometheus service discovery logic - create
# a sort of dummy Endpoint resource. More info on this approach in
# https://github.com/prometheus-operator/prometheus-operator/issues/3204

kubectl apply -f ./sa.yaml
kubectl apply -f ./crb.yaml
TOKEN=$(kubectl create token prometheus-proxy-sa -n monitoring --duration=$((365*24))h)
kubectl -n monitoring delete secret prometheus-proxy
kubectl create secret generic prometheus-proxy --from-literal=token="${TOKEN}" -n monitoring
kubectl apply -f ./metrics-resources.yaml
