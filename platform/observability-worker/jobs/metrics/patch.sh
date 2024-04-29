#!/bin/sh

# TODO: Move this hardcoded value out of the script
receiver="thanos-receive-router-monitoring.apps.rh-cl-us-east.vtdv.p1.openshiftapps.com"

echo "receiver url ${receiver}" 1>&2
set -x
kubectl patch cm user-workload-monitoring-config -n openshift-user-workload-monitoring --type json --patch '[{ "op": "replace", "path": "/data/config.yaml", "value": "prometheus:\n    remoteWrite:\n    - url: \"https://'${receiver}'/api/v1/receive\"\n      basicAuth:\n        username:\n          name: basic-auth-prom\n          key: username\n        password:\n          name: basic-auth-prom\n          key: password\n"}]'
