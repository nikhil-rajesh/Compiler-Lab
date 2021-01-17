FROM ubuntu:20.04
MAINTAINER Anandu


RUN apt-get update \
  && apt-get install -y bison flex libreadline-dev libc6-dev libfl-dev wget vim build-essential \
  && wget "https://silcnitc.github.io/files/xsm_expl.tar.gz" \
  && tar -xzf xsm_expl.tar.gz \
  && cd xsm_expl && make \
  && sed -i '1s/^/#!\/usr\/bin\/env bash \n/' /xsm_expl/xsm \
  && cd /xsm_expl/xfs-interface && ./init

WORKDIR /xsm_expl
