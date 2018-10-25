# Nginx • PHP-FPM
A PHP application container, with the mongo extension installed.

## Tags
- `latest`
- `mole`: ELK enabled image for logging

## Usage
You can either mount code into the container and run it, or use this image as base for an application image.

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
