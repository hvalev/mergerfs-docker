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


## Environnment variables

The following environnement variables allow to change mergerFS options:

You can provide a list of custom options:
* `MERGERFS_OPTIONS="cache.files=partial,dropcacheonclose=true,category.create=mfs"`

Or pass a config file through a volume:
* MERGERFS_CONFIG_PATH=/etc/mergerfs/config
Note that specyfing a config will ignore `MERGERFS_OPTIONS`.

These will overwrite the default options provided in the image entrypoint so make sure you know what you are doing.
See [trapexit/mergerfs options reference](https://github.com/trapexit/mergerfs?tab=readme-ov-file#mount-options) for more details on available options.


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
