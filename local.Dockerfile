#
# Copyright (C) 2019-2022, Zhichun Wu
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
FROM adoptopenjdk/openjdk8-openj9:jre8u322-b06_openj9-0.30.0-ubuntu

ARG revision=latest
ARG repository=ClickHouse/clickhouse-jdbc-bridge

# Maintainer
LABEL maintainer="zhicwu@gmail.com"

# Environment variables
ENV JDBC_BRIDGE_HOME=/app JDBC_BRIDGE_VERSION=${revision}

# Labels
LABEL app_name="ClickHouse JDBC Bridge" app_version="$JDBC_BRIDGE_VERSION"

# Update system and install additional packages for troubleshooting
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated apache2-utils \
		apt-transport-https curl htop iftop iptraf iputils-ping jq lsof net-tools tzdata wget \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p $JDBC_BRIDGE_HOME/drivers

COPY --chown=root:root NOTICE $JDBC_BRIDGE_HOME/NOTICE
COPY --chown=root:root LICENSE $JDBC_BRIDGE_HOME/LICENSE

COPY --chown=root:root docker/ $JDBC_BRIDGE_HOME
COPY --chown=root:root jdbc-bridge/drivers $JDBC_BRIDGE_HOME/drivers

COPY --chown=root:root target/clickhouse-jdbc-bridge-2.1.0-SNAPSHOT-shaded.jar $JDBC_BRIDGE_HOME/clickhouse-jdbc-bridge-shaded.jar

RUN chmod +x $JDBC_BRIDGE_HOME/*.sh \
	&& mkdir -p $JDBC_BRIDGE_HOME/logs /usr/local/lib/java \
	&& ln -s $JDBC_BRIDGE_HOME/logs /var/log/clickhouse-jdbc-bridge \
	&& ln -s $JDBC_BRIDGE_HOME/clickhouse-jdbc-bridge-${JDBC_BRIDGE_VERSION}-shaded.jar \
		/usr/local/lib/java/clickhouse-jdbc-bridge-shaded.jar \
	&& ln -s $JDBC_BRIDGE_HOME /etc/clickhouse-jdbc-bridge

WORKDIR $JDBC_BRIDGE_HOME

EXPOSE 9019

VOLUME ["${JDBC_BRIDGE_HOME}/drivers", "${JDBC_BRIDGE_HOME}/extensions", "${JDBC_BRIDGE_HOME}/logs", "${JDBC_BRIDGE_HOME}/scripts"]

CMD "./docker-entrypoint.sh"
