FROM alpine:edge
LABEL maintainer="peter@pouliot.net"
COPY Dockerfile /Dockerfile
ADD VERSION .
ARG DHCP_RANGE=192.168.0
ARG DHCP_MODE=ProxyDHCP
ARG PXE2_URL=https://i.pxe.to
ARG BOOTFILE=undi.kpxe
ARG DHCP_MODE=ProxyDHCP
RUN \
  echo "!!! Adding basic iPXE build packages !!!" \
  && apk add --no-cache --virtual build-dependencies dnsmasq \
  && mkdir -p /opt/tftpboot
COPY dnsmasq.d /opt/tftpboot/dnsmasq.d
EXPOSE 67 67/udp
EXPOSE 53 53/udp
ENTRYPOINT ["dnsmasq", "-q -d --conf-file=/opt/dnsmasq.d/${DHCP_MODE}.conf --dhcp-broadcast"]
