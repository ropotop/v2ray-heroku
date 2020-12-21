FROM debian:sid

COPY entrypoint.sh /entrypoint.sh

RUN set -ex\
    && apt update -y \
    && apt upgrade -y \
    && apt install -y wget unzip daemon\
    && chmod +x /entrypoint.sh

CMD /entrypoint.sh
