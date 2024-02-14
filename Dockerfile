# Use a base image with Java as Hadoop requires Java to run
FROM openjdk:8-jdk-alpine

# Set environment variables for Hadoop
ENV HADOOP_VERSION 3.3.6
ENV HADOOP_URL https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install necessary packages
RUN apk add --no-cache curl bash

# Download and extract Hadoop
RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && tar -xvf /tmp/hadoop.tar.gz -C /usr/local \
    && mv /usr/local/hadoop-$HADOOP_VERSION $HADOOP_HOME \
    && rm /tmp/hadoop.tar.gz

# Add configuration files
COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/

# Format the NameNode
RUN $HADOOP_HOME/bin/hdfs namenode -format

# Download Jolokia JVM agent
ENV JOLOKIA_VERSION 1.6.2
ADD https://repo1.maven.org/maven2/org/jolokia/jolokia-jvm/$JOLOKIA_VERSION/jolokia-jvm-$JOLOKIA_VERSION-agent.jar /usr/local/jolokia-jvm.jar

# Set permissions for the Jolokia JAR
RUN chmod a+x /usr/local/jolokia-jvm.jar

# Attach Jolokia agent to Hadoop process at start
ENV JOLOKIAJAR="/usr/local/jolokia-jvm.jar"
ENV HDFS_NAMENODE_OPTS="-javaagent:${JOLOKIAJAR}=port=8778,host=0.0.0.0"
ENV HDFS_DATANODE_OPTS="-javaagent:${JOLOKIAJAR}=port=8779,host=0.0.0.0"

# Install Telegraf for ARM architecture
ENV TELEGRAF_VERSION 1.24.1
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_arm64.tar.gz && \
    tar xf telegraf-${TELEGRAF_VERSION}_linux_arm64.tar.gz && \
    mv telegraf-${TELEGRAF_VERSION}/usr/bin/telegraf /usr/bin/ && \
    rm -rf ./telegraf* && \
    mkdir -p /etc/telegraf

# Copy Telegraf configuration for Hadoop
COPY telegraf.conf /etc/telegraf/telegraf.conf

# Expose necessary ports
## NameNode ports
EXPOSE 9870 9820
## DataNode ports
EXPOSE 9866 9867 9864
## Jolokia ports for NameNode and DataNode
EXPOSE 8778 8779

# Copy the entry point script
COPY docker_entrypoint.sh /root/
RUN chmod a+x /root/docker_entrypoint.sh

# Create a shared folder
RUN mkdir /root/shared

# Set the entry point to the initialization script
ENTRYPOINT ["/root/docker_entrypoint.sh"]