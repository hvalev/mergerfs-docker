FROM alpine:3.19.1 AS builder
ENV MERGERFS_VERSION=2.38.0

RUN apk add g++ git linux-headers make python3
RUN git clone https://github.com/trapexit/mergerfs /mergerfs
WORKDIR /mergerfs

RUN git checkout -b $MERGERFS_VERSION
RUN make
RUN mv build/mergerfs /bin/mergerfs

FROM alpine:3.19.1
COPY --from=builder /bin/mergerfs /usr/local/bin/mergerfs

RUN apk --no-cache add fuse libgcc libstdc++

RUN echo user_allow_other >> /etc/fuse.conf

COPY entrypoint.sh entrypoint.sh

RUN mkdir /disks && \
    chmod +x entrypoint.sh

VOLUME /merged

ENTRYPOINT ["./entrypoint.sh"]