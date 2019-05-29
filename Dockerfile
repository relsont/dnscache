FROM centos

#Download DJBDNS files from https://cr.yp.to/djbdns/install.html
COPY daemontools-0.76.tar.gz /root
COPY ucspi-tcp-0.88.tar.gz /root
COPY djbdns-1.05.tar.gz /root

#install GCC
RUN bash
RUN yum install gcc make -y

# Compile and install daemontools
RUN gunzip /root/daemontools-0.76.tar
RUN tar -xpf /root/daemontools-0.76.tar -C /root
RUN rm -f /root/daemontools-0.76.tar
RUN sed -i 's/extern int errno\;/#include <errno.h>/g' /root/admin/daemontools-0.76/src/error.h
RUN cd /root/admin/daemontools-0.76/ ; package/install

#Compile and install ucspi
RUN gunzip /root/ucspi-tcp-0.88.tar
RUN tar -xf /root/ucspi-tcp-0.88.tar -C /root
RUN sed -i 's/extern int errno\;/#include <errno.h>/g' /root/ucspi-tcp-0.88/error.h
RUN cd /root/ucspi-tcp-0.88; make; make setup check

#Compile and install djbdns
RUN gunzip /root/djbdns-1.05.tar
RUN tar -xf /root/djbdns-1.05.tar -C /root
RUN cd /root/djbdns-1.05 ; echo gcc -O2 -include /usr/include/errno.h > conf-cc ; make; make setup check

#Configure djbdns service
RUN useradd Gdnscache
RUN useradd Gdnslog
RUN dnscache-conf Gdnscache Gdnslog /etc/dnscache 0.0.0.0
RUN touch /etc/dnscache/root/ip/172
RUN ln -s /etc/dnscache /service/dnscache; sleep 5

#Start the djbdns service
ENTRYPOINT ["/command/svscanboot"] 
