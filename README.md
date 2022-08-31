# infra

This repository serves as the single source of truth for my infrastructure.

> **NOTE**: The repo used to contain secrets, so I decided to dump the history
and start fresh. No more secrets (hopefully)!! The previous history can be found
in the private "infra-archive" repository

## Deployment

1. To access the secrets, create a `.vault-password` file in the `ansible/`
directory containing the password.
2. Change into the `ansible/` directory
3. Deploy the infrastructure using `ansible-playbook boostrap.yml`. This will
deploy the terraform config under the hood.

Unfortunately, the next steps have not been automated yet:

1. After provisioning the terraform infrastructure, the nodes manually have to
be added to the Tailscale cluster. Afterwards, you can add them to the `hosts.ini`.

## Ansible

To access the secrets, create a `.vault-password` file in the `ansible/`
directory containing the password.

## Terraform

State is managed by Terraform cloud (though it would be nice to move it somewhere else...).

Run `terraform login` to access it.

## Kubernetes

To apply the resources to the cluster, run `kubectl apply -k k8s`.
