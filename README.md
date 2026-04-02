# Container-DNS

Primarily designed to run as a container on **TrueNAS Scale** (from the **Fangtooth** release onward), this is a small Dnsmasq-based DNS service that publishes **automatic hostnames** for running **Docker** and **Incus** containers. Each container gets a name under a configurable domain (for example `myapp.local.`) resolving to its IPv4 address on the chosen Docker network or Incus instance.

## How it works

- **Dnsmasq** serves only from generated files under `--hostsdir` (no upstream recursion in the default config).
- **Docker**: the entrypoint subscribes to `docker events` (start, stop, die) and rebuilds records from `docker ps` + network inspect for `DOCKER_NETWORK`.
- **Incus**: there is no event stream in this setup, so running containers are refreshed on a timer (`INCUS_UPDATE_INTERVAL`).
- Records are filtered by **subnet** so only addresses inside `SUBNET` are published.

## Requirements

- **Linux host** with Docker (or compatible runtime). `network_mode: host` is used so the service can bind to port **53/udp** on the host.
- **Docker socket** mounted read-only so the container can list containers and inspect networks.
- **Incus** (optional): mount the Incus UNIX socket if you want Incus containers included; omit that volume if you only use Docker.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DNS_DOMAIN` | `local.` | Domain suffix for names (e.g. `containername.local.`). |
| `SUBNET` | `172.17.0.0/16` | Only IPv4 addresses inside this CIDR are published. |
| `DOCKER_NETWORK` | `bridge` | Docker network name used when reading each container’s IP. |
| `INCUS_UPDATE_INTERVAL` | `300` | Seconds between Incus polls. |
| `DEBUG` | *(unset)* | If set, enables `set -x` in the shell for troubleshooting. |

## Using the DNS

Ensure nothing else on the host already binds to UDP port 53, or change deployment so Dnsmasq can listen as intended.
