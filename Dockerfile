FROM alpine:3.16.3 AS builder
ENV MERGERFS_VERSION 2.33.3

RUN apk add g++ git linux-headers make python3
RUN git clone https://github.com/trapexit/mergerfs
WORKDIR mergerfs

RUN git checkout "$MERGERFS_VERSION"
RUN make
RUN mv build/mergerfs /bin/mergerfs

FROM alpine:3.16.3
COPY --from=builder /bin/mergerfs /usr/local/bin/mergerfs

RUN apk --no-cache add fuse libgcc libstdc++

RUN echo user_allow_other >> /etc/fuse.conf

COPY entrypoint.sh entrypoint.sh

RUN mkdir /disks && \
    chmod +x entrypoint.sh

VOLUME /merged

ENTRYPOINT ["./entrypoint.sh"]