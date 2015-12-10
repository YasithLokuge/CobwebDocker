FROM ubuntu:15.10
MAINTAINER Yasith Lokuge <yasith@cobweb.io>



#######################
#### Install Java8 ####
#######################

RUN \

  apt-get install -y software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get upgrade -y && \  
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#########################
#### Install Tomcat8 ####
#########################

# Define working directory.
WORKDIR /home

RUN \

  apt-get install -y wget && \
  apt-get update && \
  apt-get install -y git-core && \
  mkdir cobweb && \
  cd cobweb && \  
  git clone http://gitlab.cobweb.io/YasithLokuge/tomcat8.git && \
  cd tomcat8/webapps && \
  mv ROOT root_  && \
  cd /home/cobweb/tomcat8 && \
  mkdir logs 



# Define default command.
CMD ["bash"]


ENV CATALINA_HOME /home/cobweb/tomcat8
ENV PATH $PATH:$CATALINA_HOME/bin

RUN \

  echo "cd /home/cobweb/tomcat8/bin" >> ~/etc/profile && \
  echo "sh ./shutdown.sh" >> ~/etc/profile && \
  echo "sh ./startup.sh" >> ~/etc/profile


EXPOSE 80
EXPOSE 8009



##########################
#### Install OrientDB ####
##########################

WORKDIR /home/cobweb

RUN \

  git clone http://gitlab.cobweb.io/YasithLokuge/orientdb.git && \
  cd orientdb/bin && \  
  echo "cd /home/cobweb/orientdb/bin" >> ~/etc/profile && \
  echo "sh ./orientdb.sh start" >> ~/etc/profile && \
  ./orientdb.sh start

EXPOSE 2480
EXPOSE 2424

###########################
#### Install Mosquitto ####
###########################

WORKDIR /home/cobweb

RUN  \

  apt-get install -y build-essential && \
  apt-get install -y libssl-dev && \
  apt-get install -y libcurl4-openssl-dev && \
  apt-get install -y libc-ares-dev && \
  apt-get install -y uuid-dev && \  
  git clone http://gitlab.cobweb.io/YasithLokuge/mosquitto.git && \
  cd mosquitto && \
  make binary && \
  make install && \
  echo "mosquitto -d -c /home/cobweb/mosquitto/mosquitto.conf" >> ~/etc/profile 

EXPOSE 1883

#########################
#### Download Cobweb ####
#########################

WORKDIR /home/cobweb

RUN \
  
  git clone http://gitlab.cobweb.io/YasithLokuge/Deploy.git && \  
  cd Deploy && \
  cp cobweb.war /home/cobweb/tomcat8/webapps && \
  mv /home/cobweb/tomcat8/webapps/cobweb.war /home/cobweb/tomcat8/webapps/ROOT.war && \
  cd /home/cobweb/tomcat8/bin && \
  ./shutdown.sh && \
  ./startup.sh && \
  cd /home/cobweb/Deploy && \  
  chmod +x coap && \
  chmod +x mqtt && \  
  echo "cd /home/cobweb/Deploy" >> ~/etc/profile && \  
  echo "source ./coap &" >> ~/etc/profile && \
  echo "source ./mqtt &" >> ~/etc/profile

EXPOSE 5683

CMD ["bash", "-l"]
