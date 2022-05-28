FROM ubuntu:focal-20220113

LABEL  filter FEELnc outputs and pull GO

RUN apt-get update 
#&& \
#    apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y  \
	apt-utils	\
        build-essential \
        pkg-config      \
        bzip2           \
        nano            \
	wget		\
	git		\
	gcc             \
	perl		\
	python3		\
	locales 
#    apt-get clean && \
#    apt-get purge && \
#    rm -rf /var/lib/apt/lists/* /tmp/*

RUN locale-gen en_US.UTF-8

# Set the locale

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

ADD filter_feelnc_topX.sh /usr/local/bin/
ADD pull_go_topX_gafout_feelnc.sh /usr/local/bin
ADD summary.sh  /usr/local/bin
ADD makeUNILNCmapping.sh /usr/local/bin
ADD makeUNILNCmapping_quant.sh /usr/local/bin

WORKDIR /usr/local/bin

RUN chmod 777 filter_feelnc_topX.sh pull_go_topX_gafout_feelnc.sh summary.sh makeUNILNCmapping.sh makeUNILNCmapping_quant.sh
