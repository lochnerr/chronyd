# NTP Container in Docker on Alpine #

This repository contains the Dockerfile and associated assets for
building an NTP (chronyd) Container in Docker on Alpine Linux.

### Building the container ###

Checkout the project:
```bash
git clone git@github.com:lochnerr/chronyd.git
```

To build the image, run the following:
```bash
cd chronyd
docker build -t chronyd .
```

### Running the container ###

You then can run the container with something like:
```bash
# Run the container.
sudo docker run -it --rm -p 80:80 \
  -v $(pwd)/chronyd:/srv/chronyd \
  chronyd
```

# Copyright 2019 Clone Research Corp. <lochner@clone1.com>
