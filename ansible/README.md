# Installing dependencies

To install all ansible roles, run the following command:

```
ansible-galaxy install -r requirements.yml
```

## Kubernetes

To bootstrap a cluster, or add nodes to the cluster, check the hosts under `inventory/k8s/hosts.ini`. Then, run the following command:

```
ansible-playbook ./playbooks/k3s-cluster.yml -i inventory/k8s/hosts.ini
```