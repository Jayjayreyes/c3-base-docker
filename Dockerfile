FROM ubuntu:14.04

# Install Java 7
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -q -y software-properties-common
RUN apt-add-repository ppa:webupd8team/java -y
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install oracle-java7-installer -y && apt-get clean

RUN echo JAVA_HOME="$(update-java-alternatives -l | cut -d ' ' -f 3)" >> /etc/environment 

RUN apt-get install unzip -y && apt-get clean

RUN wget -O /opt/virgo.zip http://ftp.snt.utwente.nl/pub/software/eclipse//virgo/release/VJS/3.5.0.RELEASE/virgo-jetty-server-3.5.0.RELEASE.zip 

RUN unzip /opt/virgo.zip -d /opt/

RUN ln -s /opt/virgo-jetty-server-3.5.0.RELEASE/ /opt/virgo && rm /opt/virgo.zip 

RUN cp /opt/virgo/configuration/serviceability.xml /opt/virgo/configuration/serviceability.xml.bkp

RUN wget -O /opt/virgo/configuration/serviceability.xml https://raw.githubusercontent.com/ifunsoftware/c3-next/master/c3-deploy/src/main/config/serviceability.xml

EXPOSE 8080 8443 7375

#Uncomment this to run virgo
#CMD JAVA_HOME="$(update-java-alternatives -l | cut -d ' ' -f 3)" JAVA_OPTS=-Xmx1024m /opt/virgo/bin/startup.sh
