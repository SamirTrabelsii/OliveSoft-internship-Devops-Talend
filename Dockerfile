FROM debian:11

RUN apt-get update && apt-get install -y openjdk-11-jdk

# Set environment variables
ENV TALEND_HOME=/opt/talend
ENV PATH=$TALEND_HOME/bin:$PATH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64  

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Copy Talend Remote Engine package from local machine to the image
COPY Talend-RemoteEngine-V2.12.14-262.tar.gz /tmp/talend_remote_engine.tar.gz

# Extract the package
RUN tar xf /tmp/talend_remote_engine.tar.gz -C /tmp && \
    mv /tmp/Talend-RemoteEngine-* $TALEND_HOME && \
    rm /tmp/talend_remote_engine.tar.gz

# Expose the ports used by Talend Remote Engine
EXPOSE 8040

# Set the working directory
WORKDIR $TALEND_HOME

RUN sed -i "s|pairing.service.url=.*|pairing.service.url=https://pair.eu.cloud.talend.com|" $TALEND_HOME/etc/org.talend.ipaas.rt.pairing.client.cfg
RUN sed -i "s|remote.engine.pre.authorized.key =|remote.engine.pre.authorized.key =EEDFB0FD75A67880DCCB9219A8DC1E370991D852F84A1BA4783D5D9B4C7F311A|" $TALEND_HOME/etc/preauthorized.key.cfg
RUN sed -i "s|remote.engine.name =|remote.engine.name =NewRemoteEngine|" $TALEND_HOME/etc/preauthorized.key.cfg

# Start Talend Remote Engine
ENTRYPOINT ["/opt/talend/bin/trun"]

