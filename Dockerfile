FROM ubuntu:18.04

#Java
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    java -version && \
    which java

#Maven
RUN apt-get update && \
    apt-get install -y maven && \
    mvn -version

# Nodejs & npm
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y wget && \	
    curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt install -y nodejs && \
    node -v && \
    npm -v

#Git
RUN apt-get install -y git-core && \
    apt-get install -y sed

#Hack for npm to run with root user
RUN npm set unsafe-perm true
RUN echo '{ "allow_root": true }' > /root/.bowerrc


#Cassandra
RUN cd /opt && \
    wget -c https://archive.apache.org/dist/cassandra/3.11.13/apache-cassandra-3.11.13-bin.tar.gz && \
    gzip -d apache-cassandra-3.11.13-bin.tar.gz && \
    tar -xvf  apache-cassandra-3.11.13-bin.tar

RUN sed -ri 's/-Xss256k/-Xss512k/g' /opt/apache-cassandra-3.11.13/conf/cassandra.yaml
RUN echo 'JVM_OPTS="$JVM_OPTS -Dcom.sun.jndi.rmiURLParsing=legacy"' >> /opt/apache-cassandra-3.11.13/conf/cassandra-env.sh

RUN cd /opt/apache-cassandra-3.11.13/bin \
    && nohup sh cassandra -R & > /opt/apache-cassandra-3.11.13/bin/nohup.out \
    && sleep 30 \
    && ps -aux | grep cassandra \
    && sleep 5 \
    && sh /opt/apache-cassandra-3.11.13/bin/nodetool status \
    && cd /opt/apache-cassandra-3.11.13/bin \
    && echo "CREATE KEYSPACE \"ApplicationsDiscoveryDataService\" WITH replication = {'class': 'SimpleStrategy','replication_factor': '3'};" | sh cqlsh \
    && echo 'USE "ApplicationsDiscoveryDataService";DESCRIBE KEYSPACE;' | sh cqlsh

#Xconf - download repo
RUN cd /opt \
    && git clone "https://code.rdkcentral.com/r/rdk/components/generic/xconfserver" 

#Remove the dependency as its failing
RUN sed -ir 's/"angular-file-saver": "~1.0.0",//g' /opt/xconfserver/xconf-angular-admin/src/main/webapp/bower.json

#xconf- admin service
RUN echo 'autoGenerateSchema=true' > /opt/xconfserver/xconf-angular-admin/src/main/resources/service.properties 
RUN cd /opt/xconfserver/xconf-angular-admin/src/main/webapp && \
    npm install -g bower

RUN cd /opt/xconfserver/xconf-angular-admin/src/main/webapp && \
    npm install -g grunt-cli

RUN cd /opt/xconfserver/xconf-angular-admin/src/main/webapp && \
    npm install

RUN cd /opt/xconfserver/xconf-angular-admin/src/main/webapp && \
    npm install grunt-contrib-copy --save-dev

#RUN cd /opt/xconfserver/xconf-angular-admin/src/main/webapp && \
#    npm install grunt --save-dev

RUN cd /opt/xconfserver/xconf-angular-admin/src/main/webapp && \
    grunt install

#Xconf dataservice
RUN echo 'autoGenerateSchema=true' > /opt/xconfserver/xconf-dataservice/src/main/resources/service.properties 

#Xconf - build source
RUN cd /opt/xconfserver \
    && mvn clean install

#create all start up commands to a single script and give it as entry point
RUN echo '#!/bin/bash' > /opt/xconf_starter.sh \
    && echo 'cd /opt/apache-cassandra-3.11.13/bin' >> /opt/xconf_starter.sh \
    && echo 'nohup sh cassandra -R & > /opt/cassandra.out' >> /opt/xconf_starter.sh \
    && echo 'sleep 30' >> /opt/xconf_starter.sh \
    && echo 'ps -aux | grep cassandra' >> /opt/xconf_starter.sh \
    && echo 'cd /opt/xconfserver/xconf-angular-admin' >> /opt/xconf_starter.sh \
    && echo 'nohup mvn jetty:run -DappConfig=/opt/xconfserver/xconf-angular-admin/src/main/resources/service.properties & > /opt/adminservice.out' >> /opt/xconf_starter.sh \
    && echo 'sleep 30' >> /opt/xconf_starter.sh \
    && echo 'ps -aux | grep xconf-angular-admin' >> /opt/xconf_starter.sh \
    && echo 'cd /opt/xconfserver/xconf-dataservice' >> /opt/xconf_starter.sh \
    && echo 'nohup mvn jetty:run -DappConfig=/opt/xconfserver/xconf-dataservice/src/main/resources/service.properties & > /opt/dataservice.out' >> /opt/xconf_starter.sh \
    && echo 'sleep 30' >> /opt/xconf_starter.sh \
    && echo 'ps -aux | grep xconf-dataservice' >> /opt/xconf_starter.sh \
    && echo 'wait' >> /opt/xconf_starter.sh

#execute permission for new starter script
RUN chmod +x /opt/xconf_starter.sh

#expose the ports of admin service & data service
EXPOSE 9092 9093

ENTRYPOINT ["/opt/xconf_starter.sh"]
