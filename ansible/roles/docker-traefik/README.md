# Traefik

### User Management

To add users to the simpleAuth middleware, run the following command to generate a credentials pair:

```
docker run --rm --entrypoint htpasswd httpd:2 -Bbn <user> <password>
```

and append it to the `.users` file located in this directory.
