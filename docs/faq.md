# FAQ (Frequently Asked Questions)

## Get images of a specific name and all tags

```bash
docker image ls <IMAGE_NAME>
```

## Get OS base of container image

Receive it from file _/etc/os-release_

```bash
docker run --rm --entrypoint /bin/sh <IMAGE_NAME> -c 'cat /etc/os-release'
```

## .NET image size comparison

> From <https://github.com/dotnet/dotnet-docker/blob/main/documentation/sample-image-size-report.md>

The table below shows how base image choice and publish type affects typical
image sizes and for a simple .NET minimal web API. These images were produced
from the ["releasesapi" sample](../samples/releasesapi).

| Base Image                                 | Publish Type                  | Distroless | Globalization | Compressed Size |
| ------------------------------------------ | ----------------------------- | ---------- | ------------- | --------------: |
| [`aspnet:10.0`]                            | [Framework-dependent]         | ✖️ No      | ✅ Yes         |        92.48 MB |
| [`aspnet:10.0-noble-chiseled`]             | [Framework-dependent]         | ✅ Yes      | ✖️ No         |        52.81 MB |
| [`aspnet:10.0-noble-chiseled-extra`]       | [Framework-dependent]         | ✅ Yes      | ✅ Yes         |        67.68 MB |
| [`runtime-deps:10.0`]                      | [Self-contained] + [Trimming] | ✖️ No      | ✖️ No         |        61.53 MB |
| [`runtime-deps:10.0`]                      | [Self-contained] + [Trimming] | ✖️ No      | ✅ Yes         |        61.63 MB |
| [`runtime-deps:10.0-noble-chiseled`]       | [Self-contained] + [Trimming] | ✅ Yes      | ✖️ No         |        21.86 MB |
| [`runtime-deps:10.0-noble-chiseled-extra`] | [Self-contained] + [Trimming] | ✅ Yes      | ✅ Yes         |        36.82 MB |
| [`runtime-deps:10.0`]                      | [Native AOT]                  | ✖️ No      | ✖️ No         |        51.27 MB |
| [`runtime-deps:10.0`]                      | [Native AOT]                  | ✖️ No      | ✅ Yes         |        51.36 MB |
| [`runtime-deps:10.0-noble-chiseled`]       | [Native AOT]                  | ✅ Yes      | ✖️ No         |        11.60 MB |
| [`runtime-deps:10.0-noble-chiseled-extra`] | [Native AOT]                  | ✅ Yes      | ✅ Yes         |        26.56 MB |
| [`aspnet:10.0-alpine`]                     | [Framework-dependent]         | ✖️ No      | ✖️ No         |        51.93 MB |
| [`runtime-deps:10.0-alpine`]               | [Self-contained] + [Trimming] | ✖️ No      | ✖️ No         |        20.95 MB |
| [`runtime-deps:10.0-alpine-extra`]         | [Self-contained] + [Trimming] | ✖️ No      | ✅ Yes         |        35.52 MB |
| [`runtime-deps:10.0-alpine`]               | [Native AOT]                  | ✖️ No      | ✖️ No         |        10.69 MB |
| [`runtime-deps:10.0-alpine-extra`]         | [Native AOT]                  | ✖️ No      | ✅ Yes         |        25.25 MB |

> [!NOTE]
> Please note that these image sizes are a snapshot of deployment sizes from
> November 2025. Image sizes will fluctuate over time due to base image and
> package updates.
