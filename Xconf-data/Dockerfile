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

#Git
RUN apt-get install -y git-core && \
    apt-get install -y sed

#iputils package - need to be used for ping command
RUN apt-get update && \
    apt-get install -y iputils-ping

#curl 
RUN apt-get update && \
    apt-get install -y curl

#Xconf - download repo
RUN cd /opt \
    && git clone "https://code.rdkcentral.com/r/rdk/components/generic/xconfserver" 

#Xconf dataservice
RUN echo 'autoGenerateSchema=true' > /opt/xconfserver/xconf-dataservice/src/main/resources/service.properties 

#build xconf
RUN cd /opt/xconfserver && \
    mvn clean install

#create all start up commands to a single script and give it as entry point
RUN echo '#!/bin/bash' > /opt/xconfdata_starter.sh \
    && echo 'ipAddress=$(ping -c 1 cassandravm | grep -Eo "[0-9\.]{7,15}" | head -1);sed -i "s/localhost:9160/$ipAddress:9160/g" /opt/xconfserver/dataaccess-core/src/main/java/com/comcast/hesperius/dataaccess/core/config/DataServiceConfiguration.java' >> /opt/xconfdata_starter.sh \
    && echo 'ipAddress=$(ping -c 1 cassandravm | grep -Eo "[0-9\.]{7,15}" | head -1);echo "connectionPools.SharedConnectionPool.seeds="$ipAddress >> /opt/xconfserver/xconf-dataservice/src/main/resources/service.properties' >> /opt/xconfdata_starter.sh \
    && echo 'cd /opt/xconfserver' >> /opt/xconfdata_starter.sh \
    && echo 'mvn clean install' >> /opt/xconfdata_starter.sh \
    && echo 'cd /opt/xconfserver/xconf-dataservice' >> /opt/xconfdata_starter.sh \
    && echo 'nohup mvn jetty:run -DappConfig=/opt/xconfserver/xconf-dataservice/src/main/resources/service.properties & > /opt/dataservice.out' >> /opt/xconfdata_starter.sh \
    && echo 'sleep 30' >> /opt/xconfdata_starter.sh \
    && echo 'ps -aux | grep xconf-dataservice' >> /opt/xconfdata_starter.sh \
    && echo 'while true; do sleep 600; done' >> /opt/xconfdata_starter.sh

#execute permission for new starter script
RUN chmod +x /opt/xconfdata_starter.sh

#expose the ports of data service
EXPOSE 9092

ENTRYPOINT ["/opt/xconfdata_starter.sh"]


