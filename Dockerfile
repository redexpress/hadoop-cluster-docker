FROM ubuntu:18.04

MAINTAINER KiwenLau <kiwenlau@gmail.com>

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && \
    apt-get install -y openssh-server openjdk-8-jdk wget nano iputils-ping curl

ADD hadoop-2.7.2.tar.gz .
ADD apache-hive-2.3.7-bin.tar.gz .
COPY mysql-connector-java-8.0.15.jar .
ADD spark-2.2.3-bin-without-hadoop.tgz .

ADD scala-2.13.3.tgz /usr/local/java
ADD sbt-1.4.1.tgz /usr/local/java
ADD apache-maven-3.6.3-bin.tar.gz /usr/local/java

# RUN wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.15/mysql-connector-java-8.0.15.jar && \
RUN mv hadoop-2.7.2 /usr/local/hadoop && \
    mv apache-hive-2.3.7-bin /usr/local/hive && \
    mv spark-2.2.3-bin-without-hadoop /usr/local/spark && \
    mv mysql-connector-java-8.0.15.jar /usr/local/hive/lib/

# install hadoop 2.7.2
# RUN wget https://github.com/kiwenlau/compile-hadoop/releases/download/2.7.2/hadoop-2.7.2.tar.gz && \
#    tar -xzvf hadoop-2.7.2.tar.gz && \
#    mv hadoop-2.7.2 /usr/local/hadoop && \
#    rm hadoop-2.7.2.tar.gz

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop
ENV HIVE_HOME=/usr/local/hive
ENV SPARK_HOME=/usr/local/spark
ENV SCALA_HOME=/usr/local/java/scala-2.13.3
ENV MAVEN_HOME=/usr/local/java/apache-maven-3.6.3
ENV M2_HOME=$MAVEN_HOME
ENV SBT_HOME=/usr/local/java/sbt
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$SPARK_HOME/bin:$SCALA_HOME/bin:$MAVEN_HOME/bin:$SBT_HOME/bin

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    mv /tmp/hive-site.xml $HIVE_HOME/conf/hive-site.xml && \
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/start-spark.sh ~/start-spark.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

