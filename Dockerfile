FROM qnib/u14-consul
MAINTAINER "Christian Kniep <christian@qnib.org>"

RUN apt-get install -y dnsutils vim nmap

##### USER
# Set (very simple) password for root
ADD root/ssh /root/.ssh
RUN echo "root:root"|chpasswd && \
    chmod 600 /root/.ssh/authorized_keys /root/.ssh/id_rsa && \
    chown -R root:root /root/

### SSHD
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    sed -i -e 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
RUN getent passwd sshd || useradd -g sshd sshd
ADD opt/qnib/bin/startup_sshd.sh /opt/qnib//bin/startup_sshd.sh
ADD etc/supervisord.d/sshd.ini /etc/supervisord.d/sshd.ini
ADD etc/consul.d/check_sshd.json /etc/consul.d/check_sshd.json


# We do not care about the known_hosts-file and all the security
####### Highly unsecure... !1!! ###########
RUN echo "        StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    echo "        UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config && \
    echo "        AddressFamily inet" >> /etc/ssh/ssh_config

#RUN yum install -y python-pip && \
#    pip install envoy neo4jrestclient
RUN apt-get install -y git-core make golang && cd /tmp/ && \
    git clone https://github.com/hashicorp/consul-template.git && \
    cd /tmp/consul-template && \
    GOPATH=/root/ make && \
    mv /tmp/consul-template/bin/consul-template /usr/local/bin/ && \
    rm -rf /tmp/consul-template && \
    apt-get purge -y make golang git-core
# dependencies needed by costum scripts (e.g. osquery)
RUN apt-get install -y python-pip libyaml-dev python-dev 
RUN /usr/bin/pip install neo4jrestclient pyyaml docopt python-consul jinja2 && \ 
    /usr/bin/pip install psutil graphitesend
#ADD opt/qnib/bin/watch_psutil.py /opt/qnib/bin/
#ADD etc/supervisord.d/watchpsutil.ini /etc/supervisord.d/
# osqueryi
#RUN yum install -y http://ftp.wrz.de/pub/fedora-epel/7/x86_64/e/epel-release-7-5.noarch.rpm 
#RUN yum install -y https://osquery-packages.s3.amazonaws.com/centos7/osquery.rpm 
#RUN yum install -y osquery

