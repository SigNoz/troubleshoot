# Troubleshooting SigNoz

## Install

You can run the install script below to download the troubleshoot binary:

```console
curl -sL https://raw.githubusercontent.com/SigNoz/troubleshoot/main/scripts/install.sh | bash
```

We currently support the following:
- Linux (amd64/arm64)
- MacOS/Darwin (amd64/arm64)

## Build from source

```
git clone git@github.com:signoz/troubleshoot.git && cd signoz

go build
```

## Run command

### Binary

```
./troubleshoot checkEndpoint --endpoint=<endpoint-to-check>
```

Eg. `./troubleshoot checkEndpoint --endpoint=localhost:4317`

### Docker

```console
docker run -it --rm signoz/troubleshoot checkEndpoint --endpoint=localhost:4317
```

### Kubernetes

```console
kubectl -n platform run troubleshoot --image=signoz/troubleshoot --restart='OnFailure' -i --tty --rm --command -- ./troubleshoot checkEndpoint --endpoint=otel-collector:4317
```

## Community

Join the [slack community](https://signoz.io/slack) to know more about distributed tracing, observability, or SigNoz and to connect with other users and contributors.

If you have any ideas, questions, or any feedback, please share on our [Github Discussions](https://github.com/SigNoz/signoz/discussions/680)
