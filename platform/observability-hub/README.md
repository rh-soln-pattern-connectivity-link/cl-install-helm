### Adding New Grafana Dashboards

This guide outlines the steps required to add new Grafana dashboards to the observability platform via GitOps.

#### Files to Update

1. **Dashboard JSON Files:**
   - Add your Grafana dashboard JSON files to the `platform/observability/grafana/dashboards/` directory.
   - Example file:
     - `grafana-dashboard-app-developer.json`

2. **Grafana Deployment Patch (YAML):**
   - Update `platform/observability/grafana/grafana-deployment-patch.yaml` to include new ConfigMap volumes and mounts corresponding to the new dashboards.

3. **Kustomization (YAML):**
   - Modify `platform/observability/kustomization.yaml` to include new ConfigMap definitions for the newly added dashboard JSON files.

#### Detailed Steps

1. **Add Dashboard JSON Files:**
   ```bash
   git add platform/observability/grafana/dashboards/grafana-dashboard-app-developer.json
   ```

2. **Edit Grafana Deployment Patch:**
   - Include changes in ConfigMap sections to mount new dashboards in the Grafana pod.
     ```yaml
     - op: add
       path: /spec/template/spec/volumes/-
       value:
         name: grafana-app-developer
         configMap:
          defaultMode: 420
          name: grafana-app-developer
     ```
   - Mount the configmap:
     ```yaml
     - op: add
       path: /spec/template/spec/containers/0/volumeMounts/-
       value:
         name: grafana-app-developer
         mountPath: /grafana-dashboard-definitions/0/grafana-app-developer
     ```

3. **Update Kustomization File:**
   - Add entries under `configMapGenerator` for each new dashboard.
   - Example snippet:
     ```yaml
     - name: grafana-app-developer
       namespace: monitoring
       files:
       - ./grafana/dashboards/grafana-dashboard-app-developer.json
     ```

4. **Commit and Push Changes:**
   ```bash
   git commit -am "Add new Grafana dashboards for app developers"
   git push origin main
   ```

#### Verify Deployment

Ensure that the changes are deployed and the new dashboards are available in Grafana by checking the deployment status in your Kubernetes cluster.

```bash
kubectl describe configmap -n monitoring | grep grafana-dashboard
```

This will confirm that the new dashboards are loaded and available for use.

### Updating existing dashboards

```shell
./update_dashboards.sh
```

This will fetch the latest dashboards from main of the kuadrant-operator.
After updating, commit & push the changes.

   ```bash
   git commit -am "Updating Grafana dashboards"
   git push origin main
   ```
