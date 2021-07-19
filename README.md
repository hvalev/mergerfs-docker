# mergerfs-docker
[![build](https://github.com/hvalev/mergerfs-docker/actions/workflows/build.yml/badge.svg)](https://github.com/hvalev/mergerfs-docker/actions/workflows/build.yml)
![Shiny%20version](https://img.shields.io/badge/mergerfs%20version-2.32.5-green)
![Docker Pulls](https://img.shields.io/docker/pulls/hvalev/mergerfs)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/mergerfs)

All credit goes to [trapexit/mergerfs](https://github.com/trapexit/mergerfs).

## Motivation
If you are here, then you are most likely looking for a simple solution to fuse files and folders on multiple hard drives to a single mountpoint. What I could not find, however, was a simple and regularly updated docker container which simply takes input volumes and merges them to a predefined path. This repository attempts to do just that.

As you will see below, you just need to mount all drives you wish to merge to ```/disks``` and they will appear as one drive under ```/merged```. It is important that for the merged volume, you add the ```:shared``` bind to expose the containers' merged path to the host. To adjust the path where the merged drives would appear on the host, simply change the ```/mnt/merged``` path to one of your choice. That's it! 


## How to run it
Docker run:
```
docker run -v /mnt/nd1:/disks/nd1 -v /mnt/nd2:/disks/nd2 -v /mnt/nd3:/disks/nd3 -v /mnt/merged:/merged:shared --device /dev/fuse --cap-add SYS_ADMIN -d hvalev/mergerfs
```
docker-compose:
```
version: "3.8"
services:
  mergerfs:
    image: hvalev/mergerfs:latest
    container_name: mergerfs
    cap_add:
      - SYS_ADMIN
    devices:
      - /dev/fuse:/dev/fuse
    volumes:
       - /mnt/nd1:/disks/nd1
       - /mnt/nd2:/disks/nd2
       - /mnt/nd3:/disks/nd3
       - /mnt/merged:/merged:shared
    restart: always
```

## Customizing
* If you would like to customize the mergerfs command with additional options, you can overwrite entrypoint.sh by mounting your own using an additional volume mount.
* If you would like to combine this with samba to share it over the network, you could also use a samba docker container.

## Acknowledgements
The following resources have been extremely helpful:
* https://hub.docker.com/r/ojford/mergerfs
* https://perfectmediaserver.com/tech-stack/mergerfs.html
* https://github.com/homespirit/mergerfs-docker


## Licence
mergerfs itself has the following licence:
```
/*
  ISC License

  Copyright (c) 2016, Antonio SJ Musumeci <trapexit@spawn.link>

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/
```
https://github.com/trapexit/mergerfs/blob/master/LICENSE
