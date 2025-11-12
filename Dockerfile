# ------------------------

FROM rockylinux/rockylinux:10 AS builder

ENV PG_VERSION=18

RUN dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-10-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
    && dnf -y install postgresql${PG_VERSION}-server

# ------------------------

FROM rockylinux/rockylinux:10-ubi-micro AS final

ENV PG_VERSION=18
ENV PGDATA=/var/lib/postgresql/data
ENV PATH=/usr/pgsql-$PG_VERSION/bin:$PATH


COPY --from=builder /usr/pgsql-${PG_VERSION}/ /usr/pgsql-${PG_VERSION}/

# Shared Libs
COPY --from=builder /lib64/libzstd.so.1 /lib64/
COPY --from=builder /lib64/liblz4.so.1 /lib64/
COPY --from=builder /lib64/libxml2.so.2 /lib64/
COPY --from=builder /lib64/libpam.so.0 /lib64/
COPY --from=builder /lib64/libssl.so.3 /lib64/
COPY --from=builder /lib64/libcrypto.so.3 /lib64/
COPY --from=builder /lib64/libgssapi_krb5.so.2 /lib64/
COPY --from=builder /lib64/libz.so.1 /lib64/
COPY --from=builder /lib64/libm.so.6 /lib64/
COPY --from=builder /lib64/libldap.so.2 /lib64/
COPY --from=builder /lib64/libicui18n.so.74 /lib64/
COPY --from=builder /lib64/libicuuc.so.74 /lib64/
COPY --from=builder /lib64/libsystemd.so.0 /lib64/
COPY --from=builder /lib64/liblzma.so.5 /lib64/
COPY --from=builder /lib64/libaudit.so.1 /lib64/
COPY --from=builder /lib64/libeconf.so.0 /lib64/
COPY --from=builder /lib64/libkrb5.so.3 /lib64/
COPY --from=builder /lib64/libk5crypto.so.3 /lib64/
COPY --from=builder /lib64/libcom_err.so.2 /lib64/
COPY --from=builder /lib64/libkrb5support.so.0 /lib64/
COPY --from=builder /lib64/libkeyutils.so.1 /lib64/
COPY --from=builder /lib64/libresolv.so.2 /lib64/
COPY --from=builder /lib64/liblber.so.2 /lib64/
COPY --from=builder /lib64/libevent-2.1.so.7 /lib64/
COPY --from=builder /lib64/libsasl2.so.3 /lib64/
COPY --from=builder /lib64/libstdc++.so.6 /lib64/
COPY --from=builder /lib64/libgcc_s.so.1 /lib64/
COPY --from=builder /lib64/libicudata.so.74 /lib64/
COPY --from=builder /lib64/libcap.so.2 /lib64/
COPY --from=builder /lib64/libcap-ng.so.0 /lib64/
COPY --from=builder /lib64/libselinux.so.1 /lib64/
COPY --from=builder /lib64/libcrypt.so.2 /lib64/
COPY --from=builder /lib64/libpcre2-8.so.0 /lib64/
COPY --from=builder /lib64/ld-linux-x86-64.so.2 /lib64/
COPY --from=builder /lib64/libnuma.so.1 /lib64/
COPY --from=builder /lib64/liburing.so.2 /lib64/
COPY --from=builder /lib64/libc.so.6 /lib64/



# Copier l'entrypoint
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh 

# Créer le groupe et l'utilisateur postgres manuellement
RUN echo "postgres:x:1001:1001:PostgreSQL User:/var/lib/postgresql/data:/bin/bash" >> /etc/passwd \
    && echo "postgres:x:1001:" >> /etc/group \
    && mkdir -p ${PGDATA} \
    && chown -R 1001:1001 ${PGDATA} \
    && chmod 700 ${PGDATA} \
    && chown -R 1001:1001 /usr/pgsql-${PG_VERSION}/ \ 
    && mkdir /run/postgresql/ \
    && chown -R 1001:1001 /run/postgresql/



USER 1001

WORKDIR ${PGDATA}

EXPOSE 5432
ENTRYPOINT ["entrypoint.sh"]

