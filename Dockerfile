FROM ubuntu:18.04 AS build
ARG version=0.5.1
ARG os=linux
ARG arch=x64

# pull in tini
ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /tini
RUN chmod +x /tini

COPY buildfs /
COPY prebuilts /prebuilts
RUN /build/prepare-image.sh /prebuilts/pandora-express-v${version}-${os}-${arch}.tar.gz /image

# assemble final image

FROM openjdk:11.0.6-jre-buster AS final
RUN useradd -m pdr
COPY --from=build /tini /tini
COPY rootfs /
COPY --from=build /image /home/pdr

WORKDIR /home/pdr
# adjust permissions before changing into the user
RUN mkdir .pandora && \
    chown pdr:pdr .pandora && \
    chown -R pdr:pdr conf/
USER pdr

# configs

EXPOSE 9999
VOLUME /home/pdr/.pandora
ENTRYPOINT ["/tini", "--"]
CMD ["/entrypoint.sh"]
