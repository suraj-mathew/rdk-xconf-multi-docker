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

#iputils package - need to be used for ping command
RUN apt-get update && \
    apt-get install -y iputils-ping

#Hack for npm to run with root user
RUN npm set unsafe-perm true
RUN echo '{ "allow_root": true }' > /root/.bowerrc

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

RUN cd /opt/xconfserver/xconf-angular-admin/src/main/webapp && \
    grunt install

# Workaround to overcome the issue with Apache Commons Validator version 1.4.1.
# This version doesnt support some domain names like ".cloud".
# The latest version supports it, but its not upgraded in RDK central code as on Sep-2020 (informed & they will take via dev process)
# So, doing this workaround in docker script
RUN sed -i "s/<commons-validator.version>1.4.1</<commons-validator.version>1.7</g" /opt/xconfserver/pom.xml

#build xconf
RUN cd /opt/xconfserver && \
    mvn clean install

#create all start up commands to a single script and give it as entry point
RUN echo '#!/bin/bash' > /opt/xconfadmin_starter.sh \    
    && echo 'ipAddress=$(ping -c 1 cassandravm | grep -Eo "[0-9\.]{7,15}" | head -1);sed -i "s/localhost:9160/$ipAddress:9160/g" /opt/xconfserver/dataaccess-core/src/main/java/com/comcast/hesperius/dataaccess/core/config/DataServiceConfiguration.java' >> /opt/xconfadmin_starter.sh \
    && echo 'ipAddress=$(ping -c 1 cassandravm | grep -Eo "[0-9\.]{7,15}" | head -1);echo "connectionPools.SharedConnectionPool.seeds="$ipAddress >> /opt/xconfserver/xconf-angular-admin/src/main/resources/service.properties' >> /opt/xconfadmin_starter.sh \
    && echo 'cd /opt/xconfserver' >> /opt/xconfadmin_starter.sh \
    && echo 'mvn clean install' >> /opt/xconfadmin_starter.sh \
    && echo 'cd /opt/xconfserver/xconf-angular-admin' >> /opt/xconfadmin_starter.sh \
    && echo 'nohup mvn jetty:run -DappConfig=/opt/xconfserver/xconf-angular-admin/src/main/resources/service.properties & > /opt/adminservice.out' >> /opt/xconfadmin_starter.sh \
    && echo 'sleep 30' >> /opt/xconfadmin_starter.sh \
    && echo 'ps -aux | grep xconf-angular-admin' >> /opt/xconfadmin_starter.sh \
    && echo 'while true; do sleep 600; done' >> /opt/xconfadmin_starter.sh

#execute permission for new starter script
RUN chmod +x /opt/xconfadmin_starter.sh

#expose the ports of admin service
EXPOSE 9093

ENTRYPOINT ["/opt/xconfadmin_starter.sh"]


