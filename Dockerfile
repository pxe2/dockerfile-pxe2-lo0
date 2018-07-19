FROM alpine:edge
LABEL maintainer='peter@pouliot.net'

ADD VERSION .
ADD Dockerfile .

# Arguments
ARG DHCP_RANGE
ARG DHCP_MODE
ARG PXE2_URL
ARG BOOTFILE


# Environment Variables
ENV dhcp_range=$DHCP_RANGE
ENV dhcp_mode=$DHCP_MODE
ENV pxe2_url=$pxe2_url
ENV bootfile=$BOOTFILE

RUN \
  echo "!!! Adding basic iPXE build packages !!!" \
  && echo "dhcp_mode: "$DHCP_MODE  \
  && echo "dhcp_range: "$DHCP_RANGE  \
  && echo "pxe2_url: "$PXE2_URL  \
  && echo "bootfile: "$BOOTFILE  \
  && apk add --no-cache --virtual build-dependencies dnsmasq \
  && mkdir -p /opt/tftpboot
ADD https://boot.netboot.xyz/ipxe/netboot.xyz.kpxe /opt/tftpboot/ipxe.0
ADD https://boot.netboot.xyz/ipxe/netboot.xyz-undionly.kpxe /opt/tftpboot/undionly.0
COPY dnsmasq.d /opt/dnsmasq.d
EXPOSE 67 67/udp
EXPOSE 53 53/udp
#ENTRYPOINT ["dnsmasq", "-q -d --conf-file=/opt/dnsmasq.d/ProxyDHCP.conf --dhcp-broadcast"]
