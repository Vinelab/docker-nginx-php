# Nginx • PHP-FPM | Mole
A PHP application container, with the mongo extension installed. Also includes Filebeat for ELK logging NGINX activity (hence Mole).

## Tags
- `latest`
- `mole`: Includes ELK stack's tools to enable logging

## Usage
You can either mount code into the container and run it, or use this image as base for an application image.

In addition to running code, this container enables logging using Filebeat.

### Required ENV Variables

| Tool | Variable | Description  |
|---|---|---|
| **Filebeat**  | `APP_ENV`  | The environment in which the service is running (namespace)  |
|   | `ELASTICSEARCH_HOST`  | The host URL to reach Elasticsearch  |
|   | `SERVICE_INSTANCE_NAME`  | The service's instance (container) name  |
|   | `SERVICE_INSTANCE_TYPE`  | The type of the service (i.e. HTTP, Queue Consumer, etc.)  |

### Mounting Code
```bash
docker run -d -p [host port]:80 -v /path/to/code:/code/public vinelab/nginx-php
```

#### With Laravel
Mounting Laravel code has to happen to `/code` instead of `/code/public` since Laravel incorporates a `/public` directory.

```bash
docker run -d -p [host port]:80 -v /path/to/laravel-code:/code vinelab/nginx-php
```

### As Base Image
Using this image as base image is as simple as creating a `Dockerfile` in the application root with the following content:

```Dockerfile
FROM vinelab/nginx-php

MAINTAINER You Name <your@email>

COPY . /code
```

## Exposing Ports
By default `443` and `80` are exposed

## License
This package is distributed under the MIT License (see LICENSE) file distributed with this package.
