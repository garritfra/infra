# infra

This repository serves as the single source of truth for my infrastructure.

> **NOTE**: The repo used to contain secrets, so I decided to dump the history
and start fresh. No more secrets (hopefully)!! The previous history can be found
in the private "infra-archive" repository

# Kubernetes

## Cluster bootstrapping

1. Spin up a cluster
2. Make sure the node you're setting up can read the repository
3. `flux bootstrap git --url=ssh://git@github.com/garritfra/infra --branch=main --private-key-file=.ssh/id_ed25519 --path=k8s/clusters/infra-k8s-01`
4. Save age cluster key as `age-key.txt`
5. `cat age.agekey kubectl create secret generic infra-sops-age-key --namespace=infra-base --from-file=age.agekey=/dev/stdin`

## Encrypt Secrets

1. Create the secret like you would any other secret
2. `sops --age=<public-key> --encrypt --in-place path/to/secret.yaml`
   1. This assumes that you have a `.sops.yaml` in your directory (TODO: Or at the repo top level?)