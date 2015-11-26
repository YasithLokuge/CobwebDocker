FROM ubuntu:15.10
MAINTAINER Yasith Lokuge <yasith@cobweb.io>



# Install Java.
RUN \

  apt-get install -y software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer


# Define working directory.
WORKDIR /home

RUN \

  apt-get install -y wget && \
  mkdir cobweb && \
  cd cobweb && \
  wget http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.9/bin/apache-tomcat-8.0.9.tar.gz && \
  tar -xzcv apache-tomcat-8.0.9.tar.gz && \
  cd apache-tomcat-8.0.9/bin && \
  ./startup.sh


# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Define default command.
CMD ["bash"]


ENV CATALINA_HOME /home/apache-tomcat-8.0.9
ENV PATH $PATH:$CATALINA_HOME/bin

RUN \

  echo "./home/apache-tomcat-8.0.9/bin/startup.sh" >> /etc/bash.bashrc


EXPOSE 8080
EXPOSE 8009

