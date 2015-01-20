FROM debian:latest

WORKDIR /usr/local/cspm161/
VOLUME /usr/local/cspm161/downloaded_files

RUN apt-get update && apt-get install -y curl

ADD digest_checker.sh /usr/local/cspm161/digest_checker.sh

ENTRYPOINT ["bash", "/usr/local/cspm161/digest_checker.sh"]
