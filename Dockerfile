FROM alpine:3.23.3 AS builder-mergerfs
ENV MERGERFS_VERSION=null

RUN apk add g++ git linux-headers make python3
RUN git clone https://github.com/trapexit/mergerfs /mergerfs
WORKDIR /mergerfs

RUN git checkout -b $MERGERFS_VERSION
RUN make
RUN mv build/mergerfs /bin/mergerfs

FROM builder-mergerfs AS builder-mergerfs-tools
RUN git clone https://github.com/trapexit/mergerfs-tools.git /mergerfs-tools

WORKDIR /mergerfs-tools
RUN make
RUN mv src/mergerfs.* /bin/
RUN chmod +x /bin/mergerfs.*

FROM alpine:3.23.3 AS mergerfs-release
COPY --from=builder-mergerfs /bin/mergerfs /usr/local/bin/mergerfs

RUN apk --no-cache add fuse libgcc libstdc++
RUN echo user_allow_other >> /etc/fuse.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir /config
COPY parameters.conf /config/parameters.conf

RUN mkdir /disks

VOLUME /merged

ENTRYPOINT ["/entrypoint.sh"]

FROM mergerfs-release AS mergerfs-tools-release
COPY --from=builder-mergerfs-tools /bin/mergerfs.* /usr/local/bin/

RUN apk add python3 rsync

ENTRYPOINT ["/entrypoint.sh"]