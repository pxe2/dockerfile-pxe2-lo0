FROM alpine:edge
LABEL maintainer="peter@pouliot.net"
COPY Dockerfile /Dockerfile
ADD VERSION .
ARG DHCP_RANGE=192.168.0
ARG PXE2_URL=https://i.pxe.to
ARG BOOTFILE=undi.kpxe
RUN \
  echo "!!! Adding basic iPXE build packages !!!" \
  && apk add --no-cache --virtual build-dependencies dnsmasq \
  && echo "!!! Creating Directories for tftpp !!!" \
  && mkdir -p /tftpboot /opt/dnsmasq.d \
  && echo "!!! Downloading undi.kpxe !!!"
# Generate The Different Configs
RUN \
  echo " \n\
## pxe2.lo0 \n\
## DNSmasq ProxyDHCP Configuration \n\
port=0 \n\
log-dhcp \n\
dhcp-range=${SUBNET_ADDRESS},proxy \n\
dhcp-boot=${BOOTFILE} \n\
pxe-service=x86PC,'Network Boot',pxelinux \n\
enable-tftp \n\
tftp-root=/opt/tftpboot \n\
" > /opt/dnsmasq.d/proxyDHCP.conf
RUN echo " \n\
## pxe2.lo0 \n\
## DNS & DHCP Configuration \n\
## https://blogging.dragon.org.uk/howto-setup-dnsmasq-as-dns-dhcp \n\
domain-needed \n\
bogus-priv \n\
no-resolv \n\
no-poll \n\
server=/example.com/192.168.0.5 \n\
server=1.1.1.1 \n\
server=8.8.8.8 \n\
local=/pxe2-l0/ \n\
address=/doubleclick.net/127.0.0.1 \n\
no-hosts \n\ 
addn-hosts=/opt/dnsmasq.d/dnsmasq_static_hosts.conf \n\
expand-hosts \n\
domain ${DOMAIN_NAME} \n\
dhcp-range=192.168.0.20,192.168.0.50,72h \n\
dhcp-range=tftp,192.168.0.250,192.168.0.254  \n\
dhcp-host=mylaptop,192.168.0.199,36h \n\
dhcp-option=option:router,192.168.0.1 \n\
dhcp-option=option:ntp-server,192.168.0.5 \n\
dhcp-option=19,0 # ip-forwarding off \n\
dhcp-option=44,192.168.0.5 # set netbios-over-TCP/IP aka WINS \n\
dhcp-option=45,192.168.0.5 # netbios datagram distribution server \n\
dhcp-option=46,8           # netbios node type \n\
" > /opt/dnsmasq.d/DNS_DHCP.conf

EXPOSE 67 67/udp
EXPOSE 53 53/udp
ENTRYPOINT ["dnsmasq", "-q -d --conf-file=/opt/dnsmasq.conf --dhcp-broadcast"]
