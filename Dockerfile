FROM ubuntu:trusty
MAINTAINER Abhijith V G <abhijithvg@schogini.com>

# Make sure the package repository is up to date.
RUN apt-get -y update

# Installing software-properties-common to get the add-apt-repository command
RUN apt-get install -y --no-install-recommends software-properties-common

# Install Oracle Java8, a basic SSH server & other softwares
RUN add-apt-repository ppa:webupd8team/java -y \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get update && apt-get install -y --force-yes --no-install-recommends \
    oracle-java8-installer \
    ca-certificates \
	curl \
	wget \
	git \
	openssh-server \
	autoconf \
	build-essential \
	unzip \
	nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Downloading and copying the Maven tool
RUN \
  curl http://www.us.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar xz -C /usr/share/ && \
  ln -s /usr/share/apache-maven-3.3.9/bin/mvn /usr/bin/mvn

# Define working directory.
WORKDIR /data

# Set oracle java as the default java
RUN \
    ln -s /usr/lib/jvm/java-8-oracle /usr/lib/jvm/jdk-8-oracle-latest \
    && update-java-alternatives -s java-8-oracle

ENV JAVA_HOME /usr/lib/jvm/jdk-8-oracle-latest
ENV MVN_HOME  /usr/share/apache-maven-3.3.9


# Install a basic SSH server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Add user jenkins to the image
RUN adduser --quiet jenkins
# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd

# Maven Configurations & Installation
RUN mkdir /home/jenkins/.m2

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ 

RUN apt-get install -y maven

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
