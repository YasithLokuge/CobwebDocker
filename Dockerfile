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

  useradd -ms /bin/bash spider && \
  apt-get install -y wget && \
  apt-get update && \
  apt-get install -y git-core && \
  cd spider && \
  mkdir cobweb && \
  cd cobweb && \  
  git clone http://gitlab.cobweb.io/YasithLokuge/tomcat8.git && \
  cd tomcat8/webapps && \
  mv ROOT root_  && \
  cd /home/spider/cobweb/tomcat8 && \
  mkdir logs 



# Define default command.
CMD ["bash"]


ENV CATALINA_HOME /home/spider/cobweb/tomcat8
ENV PATH $PATH:$CATALINA_HOME/bin

RUN \

  echo "cd /home/spider/cobweb/tomcat8/bin" >> /etc/profile && \
  echo "sh ./shutdown.sh" >> /etc/profile && \
  echo "sh ./startup.sh" >> /etc/profile


EXPOSE 80
EXPOSE 8009



##########################
#### Install OrientDB ####
##########################

WORKDIR /home/spider/cobweb

RUN \

  git clone http://gitlab.cobweb.io/YasithLokuge/orientdb.git && \
  cd orientdb/bin && \  
  echo "cd /home/spider/cobweb/orientdb/bin" >> /etc/profile && \
  echo "sh ./orientdb.sh start" >> /etc/profile && \
  ./orientdb.sh start

EXPOSE 2480
EXPOSE 2424

###########################
#### Install Mosquitto ####
###########################

WORKDIR /home/spider/cobweb

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
  echo "mosquitto -d -c /home/spider/cobweb/mosquitto/mosquitto.conf" >> /etc/profile 

EXPOSE 1883

#########################
#### Download Cobweb ####
#########################

WORKDIR /home/spider/cobweb
  
RUN git clone http://gitlab.cobweb.io/YasithLokuge/Deploy.git
#RUN chown -R spider Deploy
RUN cd Deploy

#USER spider

RUN cp cobweb.war /home/spider/cobweb/tomcat8/webapps
RUN mv /home/spider/cobweb/tomcat8/webapps/cobweb.war /home/cobweb/tomcat8/webapps/ROOT.war
RUN cd /home/spider/cobweb/tomcat8/bin
RUN ./shutdown.sh
RUN ./startup.sh
RUN cd /home/spider/cobweb/Deploy
RUN chmod +x coap
RUN chmod +x mqtt
RUN echo "cd /home/spider/cobweb/Deploy" >> /etc/profile
RUN echo "source ./coap &" >> /etc/profile
RUN echo "source ./mqtt &" >> /etc/profile

EXPOSE 5683

CMD ["bash", "-l"]