# docker-bastillion-io

[![CI](https://github.com/ilionel/docker-bastillion-io/actions/workflows/ci.yml/badge.svg)](https://github.com/ilionel/docker-bastillion-io/actions/workflows/ci.yml)
Bastillion - the Web-Based Bastion Host and SSH Key Management (bastillion.io) into Docker container
Docker image (based on alpine) for [Bastillion.io](https://www.bastillion.io/)

## What is Bastillion?

Bastillion is an open-source web-based SSH console that centrally manages administrative access to systems.

A bastion host for administrators with features that promote infrastructure security, including key management and auditing.

For more information visit the [Bastillion website](https://www.bastillion.io/) or the [GitHub page](https://github.com/bastillion-io/Bastillion)

## Quick start

```
make build ; make run
```

From a web browser, navigate to `https://<Instance IP>:8443` and login with:

```
username:admin
password:changeme
```

## Persistent storage
_Currently not configurable using environment (need confirmation)_

This means that any volume must be mounted to the following path in the container: `/opt/bastillion/jetty/bastillion/WEB-INF/classes/keydb`

## Environment
_Dockerize is used to generate a configuration file for the application_

## Security notes

This image runs a **bastion host** — harden it before exposing it:

- **Change the default `admin` / `changeme` credentials** on first login.
- **Set `DB_PASSWORD`** (env). The H2 keydb is AES-encrypted; with no password the
  template renders an empty one, which is weak. Example:
  `make run RUN="--env-file=./config.env -e DB_PASSWORD=… …"` or add it to your env file.
- **`SSH_PASSPHRASE`** (env, optional): passphrase for keys Bastillion generates.
  Default is blank (keys without passphrase). *(Previously the template hard-coded the
  literal `${randomPassphrase}` — a non-substituted, constant value; fixed.)*
- **2FA**: set `ONE_TIME_PASSWORD=required` for a bastion (default is `optional`).
- **Network**: only `8443/HTTPS` is exposed; keep it behind a VPN / firewall, not on the
  open Internet.
- The container currently runs Jetty **as root** (TODO: a non-root user needs the keydb
  volume to be owned accordingly). Restrict exposure accordingly until then.

Base images and the `dockerize` build are **pinned** for reproducible, supply-chain-safe builds.
