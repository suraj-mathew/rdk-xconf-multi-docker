FROM ubuntu:18.04

#Java
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    java -version && \
    which java

#Cassandra
RUN cd /opt && \
    apt-get update && \
    apt-get install -y wget && \
    apt install -y python-minimal && \
    wget -c https://archive.apache.org/dist/cassandra/2.0.17/apache-cassandra-2.0.17-bin.tar.gz && \
    gzip -d apache-cassandra-2.0.17-bin.tar.gz && \
    tar -xvf  apache-cassandra-2.0.17-bin.tar && \
    rm -rf apache-cassandra-2.0.17-bin.tar

RUN sed -ri 's/-Xss256k/-Xss512k/g' /opt/apache-cassandra-2.0.17/conf/cassandra.yaml

RUN cd /opt/apache-cassandra-2.0.17/bin \
    && nohup sh cassandra & > /opt/apache-cassandra-2.0.17/bin/nohup.out \
    && echo . \
    && echo 'Waiting for 5 seconds...' \
    && sleep 5 \
    && ps -aux | grep cassandra \
    && echo . \
    && echo 'Waiting for 5 seconds...' \
    && sleep 5 \
    && sh /opt/apache-cassandra-2.0.17/bin/nodetool status \
    && cd /opt/apache-cassandra-2.0.17/bin \
    && echo "CREATE KEYSPACE \"ApplicationsDiscoveryDataService\" WITH replication = {'class': 'SimpleStrategy','replication_factor': '3'};" | sh cqlsh \
    && echo 'USE "ApplicationsDiscoveryDataService";DESCRIBE KEYSPACE;' | sh cqlsh

#create all start up commands to a single script and give it as entry point
RUN echo '#!/bin/bash' > /opt/cassandra_starter.sh \
    && echo 'ipAddress=$(hostname -I);sed -i "s/localhost/$ipAddress/g" /opt/apache-cassandra-2.0.17/conf/cassandra.yaml' >> /opt/cassandra_starter.sh \
    && echo 'cd /opt/apache-cassandra-2.0.17/bin' >> /opt/cassandra_starter.sh \
    && echo 'nohup sh cassandra & > /opt/cassandra.out' >> /opt/cassandra_starter.sh \
    && echo 'sleep 5' >> /opt/cassandra_starter.sh \
    && echo 'ps -aux | grep cassandra' >> /opt/cassandra_starter.sh \
    && echo 'sh /opt/apache-cassandra-2.0.17/bin/nodetool status' >> /opt/cassandra_starter.sh \
    && echo 'while true; do sleep 600; done' >> /opt/cassandra_starter.sh

#execute permission for new starter script
RUN chmod +x /opt/cassandra_starter.sh

#expose the ports of cassandra service
EXPOSE 9042 9160

ENTRYPOINT ["/opt/cassandra_starter.sh"]


