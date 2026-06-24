# Intermediate container to build dockerize
FROM golang:1.23-alpine AS dockerize
RUN apk --no-cache --update add openssl git

WORKDIR /tmp/
RUN git clone --branch v0.6.1 --depth 1 https://github.com/jwilder/dockerize.git
WORKDIR /tmp/dockerize

ENV GO111MODULE=on
RUN go mod tidy
RUN go install

# Intermediate container to build bastillion
FROM alpine:3.20 as stage1
ARG URL
ENV URL=${URL}
ADD ${URL} /tmp
RUN mkdir -p /opt/bastillion
RUN tar -xzf /tmp/bastillion-jetty*.tar.gz -C /opt/bastillion --strip-components=1
RUN cd /opt/bastillion/ && rm -f *.md *.bat

COPY ./bastillion/startBastillion.sh /opt/bastillion/
# Bastillion configuration template for dockerize
COPY ./bastillion/BastillionConfig.properties.tpl /opt/bastillion

# Configure Jetty
COPY  ./bastillion/jetty-start.ini /opt/bastillion/jetty/start.ini


# Final container with dockerize and bastillion
FROM alpine:3.20 as main
RUN apk add --no-cache --update openjdk17-jdk

# copy dockerize binaries from intermediate dockerize container
COPY --from=dockerize /go/bin/dockerize /usr/local/bin/
# copy bastillion binaries from intermediate "stage1" container
COPY --from=stage1 /opt/bastillion /opt/bastillion

# this is the home of Bastillion
WORKDIR /opt/bastillion

# run rights
RUN chmod +x /usr/local/bin/dockerize /opt/bastillion/startBastillion.sh

# persistent data of Bastillion is stored here
VOLUME /opt/bastillion/jetty/bastillion/WEB-INF/classes/keydb

# Bastillion listens on 8443 - HTTPS
EXPOSE 8443

ENTRYPOINT ["/usr/local/bin/dockerize"]
CMD ["-template", \
     "/opt/bastillion/BastillionConfig.properties.tpl:/opt/bastillion/jetty/bastillion/WEB-INF/classes/BastillionConfig.properties", \
     "/opt/bastillion/startBastillion.sh"]
