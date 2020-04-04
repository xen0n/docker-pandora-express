FROM ubuntu:18.04 AS build
ARG version=0.5.1
ARG os=linux
ARG arch=x64

# pull in tini
ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /tini
RUN chmod +x /tini

COPY prebuilts /prebuilts
COPY buildfs /
RUN /build/prepare-image.sh /prebuilts/pandora-express-v${version}-${os}-${arch}.tar.gz /image

# assemble final image

FROM openjdk:11.0.6-jre-buster AS final
RUN useradd -m pdr
COPY --from=build /tini /tini
COPY --from=build /image /home/pdr
COPY rootfs /

WORKDIR /home/pdr
# adjust permissions before changing into the user
RUN mkdir .pandora lib/pandora/cache logs && \
    chown pdr:pdr .pandora lib/pandora/cache logs
USER pdr

# configs

EXPOSE 9999
VOLUME /home/pdr/.pandora /home/pdr/lib/pandora/cache /home/pdr/logs
ENTRYPOINT ["/tini", "--"]
CMD ["/entrypoint.sh"]
