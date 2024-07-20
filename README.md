# mergerfs-docker
[![build](https://github.com/hvalev/mergerfs-docker/actions/workflows/build.yml/badge.svg)](https://github.com/hvalev/mergerfs-docker/actions/workflows/build.yml)
![Shiny%20version](https://img.shields.io/badge/mergerfs%20version-2.40.2-green)
![Docker Pulls](https://img.shields.io/docker/pulls/hvalev/mergerfs)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/mergerfs)

All credit goes to [trapexit/mergerfs](https://github.com/trapexit/mergerfs).

## Motivation
If you are here, then you are most likely looking for a simple solution to fuse multiple hard drives' contents to a single mountpoint using mergerfs and docker. There are multiple containers which dockerize mergerfs, however none are regularly updated, with open-sourced dockerfiles (no crypto-miners) and simple to use. This repository attempts to do just that. Simply mount your hard drives as volumes to ```/disks``` and mergerfs will make them available under ```/merged```. Exposing the ```/merged``` volume to host, you need to use ```:shared``` bind to share it between the container and host. Change the volume path on the host to your prefered location and that's it!


## How to run it
Docker run:
```bash
docker run -v /mnt/nd1:/disks/nd1 -v /mnt/nd2:/disks/nd2 -v /mnt/nd3:/disks/nd3 -v /mnt/merged:/merged:shared --device /dev/fuse --cap-add SYS_ADMIN -d hvalev/mergerfs
```
docker-compose:
```yaml
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
* If you would like to customize the mergerfs command with additional options, you can overwrite `parameters.conf` with your own using an additional volume mount that maps onto `/config` inside the docker. You can use the one in the repo as a template.
* You can also override the default `mergerfs` parameters by using the `MERGERFS_PARAMS` environment variable as follows: 
```yaml
services:
  mergerfs:
    image: hvalev/mergerfs:latest
    container_name: mergerfs
    environment:
      MERGERFS_PARAMS: 'moveonenospc=true,dropcacheonclose=true,category.create=mfs,cache.files=partial'
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
* If you would like to combine this with samba to share it over the network, you could also use a samba docker container. Below is an example with a sample user read-write and guest read-only access.
```yaml
services:
  mergerfs:
    image: hvalev/mergerfs:latest
    container_name: mergerfs
    environment:
      MERGERFS_PARAMS: 'moveonenospc=true,dropcacheonclose=true,category.create=mfs,cache.files=partial'
    cap_add:
      - SYS_ADMIN
    devices:
      - /dev/fuse:/dev/fuse
    volumes:
      - /mnt/hd1:/disks/hd1
      - /mnt/hd2:/disks/hd2
      - /mnt/hd3:/disks/hd3
      - /mnt/hd:/merged:shared
    restart: always

  samba:
    image: elswork/samba:3.2.8
    container_name: samba
    environment:
      TZ: 'Europe/Amsterdam'
    ports:
      - 139:139
      - 445:445
    volumes:
      - /mnt/hd:/mnt/hd
    command: '-u "1000:1000:user:user:user_password" 
              -u "1000:1000:guest:guest:guest_password"
              -s "hd:/mnt/hd:rw:user"
              -s "media:/mnt/hd:ro:guest"'
    restart: unless-stopped
    depends_on:
      - mergerfs
```

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
