# Kubernetes

To bootstrap a cluster, or add nodes to the cluster, check the hosts under `inventory/k8s/hosts.ini`. Then, run the following command:

```
ansible-playbook k3s-cluster.yml -i inventory/k8s/hosts.ini
```