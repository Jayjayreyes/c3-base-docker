FROM ubuntu:14.04

# Install Java 7
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -q -y software-properties-common
RUN apt-add-repository ppa:webupd8team/java -y
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install oracle-java7-installer -y && apt-get clean

RUN echo JAVA_HOME="$(update-java-alternatives -l | cut -d ' ' -f 3)" >> /etc/environment 

# Install ssh and supervisor
RUN apt-get -q -y install openssh-server supervisor
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

# Add services configuration for supervisor
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure 'c3-next' service startup in supervisor
COPY conf/start_c3.sh /usr/bin/start_c3.sh
RUN chmod +x /usr/bin/start_c3.sh

# Setup root credentials for ssh
RUN echo 'root:password' > /root/passwdfile
RUN cat /root/passwdfile | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN apt-get install unzip -y && apt-get clean

RUN wget -O /opt/virgo.zip http://ftp.snt.utwente.nl/pub/software/eclipse//virgo/release/VJS/3.5.0.RELEASE/virgo-jetty-server-3.5.0.RELEASE.zip 

RUN unzip /opt/virgo.zip -d /opt/

RUN ln -s /opt/virgo-jetty-server-3.5.0.RELEASE/ /opt/virgo && rm /opt/virgo.zip 

RUN cp /opt/virgo/configuration/serviceability.xml /opt/virgo/configuration/serviceability.xml.bkp

RUN wget -O /opt/virgo/configuration/serviceability.xml https://raw.githubusercontent.com/ifunsoftware/c3-next/master/c3-deploy/src/main/config/serviceability.xml

EXPOSE 22 8080 8443 7375

#Uncomment this to run all services with supervisor daemon
#ENTRYPOINT ["/usr/bin/supervisord"]
