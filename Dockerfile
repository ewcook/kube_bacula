FROM ubuntu:24.04 AS bacula_builder

ENV BACULAVER=15.0.2 \
    BACULAUSER=bacula \
    BACULAGROUP=bacula \
    DEBIAN_FRONTEND=noninteractive \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

RUN apt-get -y update \
    && apt-get -y install postgresql-server-dev-all vim build-essential wget \
    && useradd bacula \
    && mkdir -p /build /bacula/backup /bacula/restore /var/run/bacula /var/spool/bacula /var/log/bacula \
    && chown -R bacula:bacula /bacula \
    && chmod -R 700 /bacula \
    && chown -R bacula:bacula /usr/local/etc 

RUN cd /build; wget --no-check-certificate -qO- https://sourceforge.net/projects/bacula/files/bacula/15.0.2/bacula-15.0.2.tar.gz/download| tar zxvf -; 
RUN cd /build/bacula-15.0.2;./configure --prefix=/usr/local --with-postgresql;make; make install \
    && rm -rf /build

FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y libpq5 \
    && apt-get clean all \
    && useradd bacula \
    && mkdir -p /build /bacula/backup /bacula/restore /var/run/bacula /var/spool/bacula /var/log/bacula \
    && chown -R bacula:bacula /bacula \
    && chmod -R 700 /bacula \
    && chown -R bacula:bacula /usr/local/etc \
    && mkdir -p /opt/bacula/working

COPY --from=bacula_builder /usr/local /usr/local

EXPOSE 9101
EXPOSE 9102
EXPOSE 9103
