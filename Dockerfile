# Original credit: https://github.com/jpetazzo/dockvpn
# Semi-original credit: https://github.com/kylemanna/docker-openvpn

# Smallest base image
FROM ubuntu:latest

LABEL maintainer="Javier Godinez <godinezj@gmail.com>"

# Install dependencies
RUN apt-get update && apt-get upgrade && apt-get install -y openvpn openvpn-auth-ldap dnsmasq curl iptables
RUN curl -sO http://archive.ubuntu.com/ubuntu/pool/universe/e/easy-rsa/easy-rsa_3.0.4-2_all.deb && \
    dpkg -i easy-rsa_3.0.4-2_all.deb && rm easy-rsa_3.0.4-2_all.deb && \
    apt-get clean && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
