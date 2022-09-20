# docker-bastillion-io
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
