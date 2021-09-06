FROM registry.access.redhat.com/ubi8/go-toolset:1.15.14 AS builder
USER root
WORKDIR /
COPY pause.c /pause.c
RUN cc -o /pause /pause.c

FROM registry.access.redhat.com/ubi8/ubi-micro:8.4
COPY --from=builder /pause /pause
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]