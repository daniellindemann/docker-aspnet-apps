# Demos

## Application configuration and first docker image build

> switch to `new` branch

- Show [`Program.cs`](src/DockerAspNetApps.SampleApi/Program.cs)
- Show configurations
    - Logging
    - Options configuration
    - Health probes
- Show [`appsettings.json`](src/DockerAspNetApps.SampleApi/appsettings.json)
- Explain how to add default docker files
    - VS Code > Open command palette > `Docker: Add Docker Files to Workspace...`
    - Throw `Dockerfile` away

> switch back to `main` branch

- Show [`Dockerfile.default`](src/DotnetContainerOptimization.SampleApp/Dockerfile.default)
    - Explain multi-stage build
    - Explain what happens
- Build and run the default docker container image
    - Build:
        - `-t` = name image with tag (can be added multiple times)
        - `.` = docker build context path
        - Docker is using the `Dockerfile` in the build context folder

        ```bash
        cd src/DockerAspNetApps.SampleApi

        docker build \
            -t docker-aspnet-apps/sample-api:10 \
            -t docker-aspnet-apps/sample-api:latest \
            .
        ```

        > See [scripts/01-build-images/01-build-image-default.sh](scripts/01-build-images/01-build-image-default.sh)
    - Check: list app images

        ```bash
        docker image ls docker-aspnet-apps/sample-api
        ```

    - Run:
        - `-it` = Interactive
        - `--rm` = Remove after container stops
        - `-p 6780:6780` bind host port `6780` to container port `6780`

        ```bash
        docker run -it --rm -p 6780:6780 docker-aspnet-apps/sample-api:10
        ```
    - Show running
        - Open <http://localhost:6780/hello>
- Update configuration via environment variables
    - Run:
        - `-e Greetings__To='crazy developers!'` = Set environment variable
        ```bash
        docker run --rm -it -p 6780:6780 -e Greetings__To='crazy developers!' docker-aspnet-apps/sample-api:10
        ```
    
    - Show running with new greetings
        - Open <http://localhost:6780/hello>

- Update application host config (kestrel)
    - Run:
        - `-p 5550:9999` bind host port `5550 `to container port `9999`
        - `-e ASPNETCORE_URLS=http://+:9999` overwrite Kestrel webserver listening urls
        ```bash
        docker run --rm -it -p 5550:9999 -e ASPNETCORE_URLS=http://+:9999 -e Greetings__To='crazy developers!' docker-aspnet-apps/sample-api:10
        ```
    
    - Show running on port 
        - Open <http://localhost:5550/hello>

    - See <https://learn.microsoft.com/en-us/aspnet/core/fundamentals/host/web-host?view=aspnetcore-10.0#server-urls>

# Optimized container image builds

- Compare [`Dockerfile`](src/DockerAspNetApps.SampleApi/Dockerfile) with [`Dockerfile.apine`](src/DockerAspNetApps.SampleApi/Dockerfile.alpine)
    - Show differences
    - Run default image

        ```bash
        docker run -it --rm -p 6780:6780 docker-aspnet-apps/sample-api:10
        ```
    
    - Show architecture is Ubuntu
        - Open <http://localhost:6780/architecture>
        - Go through all return parameters in pretty print

- Build and run alpine
    - Build:
        - `-f Dockerfile.alpine` = selected docker file

        ```bash
        cd src/DockerAspNetApps.SampleApi

        docker build \
            -t docker-aspnet-apps/sample-api:10-alpine \
            -f Dockerfile.alpine \
            .
        ```

        > See [scripts/01-build-images/02-build-image-alpine.sh](scripts/01-build-images/02-build-image-alpine.sh)

    - Run:

        ```bash
        docker run -it --rm -p 6780:6780 docker-aspnet-apps/sample-api:10-alpine
        ```

    - Show architecture is Alpine
        - Open <http://localhost:6780/architecture>

## Distroless image builds

> 💡 Only show **1**
> - [Chiseled Ubuntu](src/DockerAspNetApps.SampleApi/Dockerfile.chiseled-ubuntu)
> - [Azure Linux](src/DockerAspNetApps.SampleApi/Dockerfile.azure-linux)

- Compare [`Dockerfile`](src/DockerAspNetApps.SampleApi/Dockerfile) with [`Dockerfile.chiseled-ubuntu`](src/DockerAspNetApps.SampleApi/Dockerfile.chiseled-ubuntu)
    - Show differences
- Run shell in *default* app container instance
    - Run:
        - `--entrypoint /bin/sh` overwrite entrypoint of image and start process `/bin/sh`

        ```bash
        docker run -it --rm -p 6780:6780 --entrypoint /bin/sh docker-aspnet-apps/sample-api:10
        ```
    
- Build *distroless* image
    - Build:
        - `-f Dockerfile.chiseled-ubuntu` selected docker file

        ```bash
        cd src/DockerAspNetApps.SampleApi

        docker build \
            -t docker-aspnet-apps/sample-api:10-noble-chiseled \
            -f Dockerfile.chiseled-ubuntu \
            .
        ```

        > See [scripts/01-build-images/03-build-image-distroless-chiseled-ubuntu.sh](scripts/01-build-images/03-build-image-distroless-chiseled-ubuntu.sh)
    
    - Run:
        - `--entrypoint /bin/sh` overwrite entrypoint of image and start process `/bin/sh`

        ```bash
        docker run -it --rm -p 6780:6780 --entrypoint /bin/sh docker-aspnet-apps/sample-api:10-noble-chiseled
        ```
    
    - Show error!

        ```bash
        docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: exec: "/bin/sh": stat /bin/sh: no such file or directory
        ```
    
    - Run with default entrypoint

        ```bash
        docker run -it --rm -p 6780:6780 docker-aspnet-apps/sample-api:10-noble-chiseled
        ```

    - Show app is running normally
        - *BUT* without `uname` result
        - Open <http://localhost:6780/architecture>

## Self-contained image build

- Compare [`Dockerfile`](src/DockerAspNetApps.SampleApi/Dockerfile) with [`Dockerfile.self-contained-alpine`](src/DockerAspNetApps.SampleApi/Dockerfile.self-contained-alpine)
    - Show differences
- Run *default* app container instance and show `/appfiletree`
    - Run:

        ```bash
        docker run -it --rm -p 6780:6780 docker-aspnet-apps/sample-api:10
        ```
    
    - Show app file tree
        - Open <http://localhost:6780/appfiletree>

- Build self-contained alpine image
    - Build:
        - `-f Dockerfile.self-contained-alpine` = selected docker file

        ```bash
        cd src/DockerAspNetApps.SampleApi

        docker build \
            -t docker-aspnet-apps/sample-api:10-self-contained-alpine \
            -f Dockerfile.self-contained-alpine \
            .
        ```

        > See [scripts/01-build-images/05-build-image-self-contained-alpine.sh](scripts/01-build-images/05-build-image-self-contained-alpine.sh)
    
    - Run:

        ```bash
        docker run -it --rm -p 6780:6780 docker-aspnet-apps/sample-api:10-self-contained-alpine
        ```

    - Show app file tree
        - Open <http://localhost:6780/appfiletree>

## Check image best practices with dockle

- Show best practice errors of [`Dockerfile`](src/DockerAspNetApps.SampleApi/Dockerfile)

    > Ensure image `docker-aspnet-apps/sample-api:10` is build

    - Run:

        ```bash
        dockle docker-aspnet-apps/sample-api:10
        ```

        > See [scripts/02-linting/01-dockle-default.sh](scripts/02-linting/01-dockle-default.sh)

- Show best practice errors of [`Dockerfile.self-contained-alpine`](src/DockerAspNetApps.SampleApi/Dockerfile.self-contained-alpine)

    > Ensure image `docker-aspnet-apps/sample-api:10-self-contained-alpine` is build

    - Run:

        ```bash
        dockle docker-aspnet-apps/sample-api:10-alpine
        ```

        > See [scripts/02-linting/02-dockle-self-contained-alpine.sh](scripts/02-linting/02-dockle-self-contained-alpine.sh)

---

> **--- BREAK ---**

---

## Non-root user

- Show `USER app` line in [`Dockerfile`](src/DockerAspNetApps.SampleApi/Dockerfile)
    - Instructs docker to run next commands as `app` user
- Show docker layers

    > Best write to file `layers.txt`

    ```
    docker history --no-trunc docker-aspnet-apps/sample-api:10 > layers.txt
    ```

- Show `useradd` line

## Vulnerability checks with trivy

> Ensure docker-aspnet-apps/sample-api:10 and docker-aspnet-apps/sample-api:10-alpine are available

- Run `trivy` against `default` image
    - Run:

        ```bash
        trivy image docker-aspnet-apps/sample-api:10
        ```

        > See [scripts/03-trivy/01-trivy-image-default.sh](scripts/03-trivy/01-trivy-image-default.sh)
        
    - Explain errors

- Run `trivy` against `default` image with severity MEDIUM,HIGH,CRITICAL

    - Run:

        ```bash
        trivy image docker-aspnet-apps/sample-api:10 --severity MEDIUM,HIGH,CRITICAL
        ```

        > See [scripts/03-trivy/02-trivy-image-default-severity.sh](scripts/03-trivy/02-trivy-image-default-severity.sh)

- Run `trivy` against `alpine` image 

    - Run:

        ```bash
        trivy image docker-aspnet-apps/sample-api:10-alpine --severity MEDIUM,HIGH,CRITICAL
        ```

        > See [scripts/03-trivy/03-trivy-image-alpine-severity.sh](scripts/03-trivy/03-trivy-image-alpine-severity.sh)
    
    - Show few to no errors!

## Image patching with copacetic

> Ensure docker-aspnet-apps/sample-api:10 is available

- Explain script [`scripts/04-copacetic/01-copa-full-patch-process.sh`](scripts/04-copacetic/01-copa-full-patch-process.sh)
- Run script [`scripts/04-copacetic/01-copa-full-patch-process.sh`](scripts/04-copacetic/01-copa-full-patch-process.sh)
- Test pateched image
    - Run:

        ```bash
        docker run -it --rm -p 6780:6780 docker-aspnet-apps/sample-api:10-patched
        ```

    - Show app is working
        - Open <http://localhost:6780/hello>

## Images signieren

- Explain script [`scripts/05-signing-images-notation-kv/01-notation-azure-keyvault-sign-image.sh`](scripts/05-signing-images-notation-kv/01-notation-azure-keyvault-sign-image.sh)
- Run script [`scripts/05-signing-images-notation-kv/01-notation-azure-keyvault-sign-image.sh`](scripts/05-signing-images-notation-kv/01-notation-azure-keyvault-sign-image.sh) with parameters

    > - Ensure Azure Deployment was executed:
    >
    >   ```bash
    >   bicep/azuredeploy.sh
    >   ```
    >
    > - Get Azure resources from Azure Portal

    ```bash
    scripts/05-signing-images-notation-kv/01-notation-azure-keyvault-sign-image.sh \
    <AZURE_KEY_VAULT> \
    <AZURE_CONTAINER_REGISTRY>
    ```

---

> **--- BREAK ---**

---

## Build multi-arch image

- Check from [`Dockerfile`](src/DockerAspNetApps.SampleApi/Dockerfile) for `--platform=$BUILDPLATFORM`
- Check manifest of `docker-aspnet-apps/sample-api:10`

    ```bash
    docker image inspect docker-aspnet-apps/sample-api:10
    ```

- Check available builder

    ```bash
    docker buildx ls
    docker buildx inspect
    ```

- Build for multi-platform

    - Build

        ```bash
        cd src/DockerAspNetApps.SampleApi

        docker build \
            --platform linux/amd64,linux/arm64 \
            -t docker-aspnet-apps/sample-api:10 \
            -f Dockerfile \
            .
        ```
    
    - See build output for *arm64* and *amd64*

    > It's hard to get the full information of multi-arch image without pushing to a registry.
    > But we can get it by extracting info from image via script:
    > ```bash
    > IMG='docker-aspnet-apps/sample-api:10'
    > TMP="$(mktemp -d)"
    > DIGEST="$(docker image inspect "$IMG" --format '{{.Descriptor.digest}}' | sed 's/^sha256://')"
    > 
    > docker save "$IMG" -o "$TMP/img.tar"
    > tar -xOf "$TMP/img.tar" "blobs/sha256/$DIGEST" | jq
    > ```
