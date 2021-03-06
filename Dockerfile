FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    wget \
    unzip \
    psmisc \
    git \
    python-virtualenv \
    virtualenv \
    python-dev \
    libffi-dev \
    build-essential \
    tzdata \
    zlib1g-dev \
    libjpeg-dev

EXPOSE 5000

ARG tag=master

WORKDIR /opt/octoprint

#Create an octoprint user
RUN useradd -ms /bin/bash octoprint && adduser octoprint dialout
RUN chown octoprint:octoprint /opt/octoprint
USER octoprint

#This fixes issues with the volume command setting wrong permissions
RUN mkdir /home/octoprint/.octoprint

#Install Octoprint
RUN git clone --branch $tag https://github.com/foosel/OctoPrint.git /opt/octoprint \
  && virtualenv venv \
  && ./venv/bin/pip install .

RUN /opt/octoprint/venv/bin/python -m pip install \
https://github.com/AlexVerrico/Octoprint-Display-ETA/archive/master.zip \
https://github.com/1r0b1n0/OctoPrint-Tempsgraph/archive/master.zip \
https://github.com/tpmullan/OctoPrint-DetailedProgress/archive/master.zip \
https://github.com/AliceGrey/OctoprintKlipperPlugin/archive/master.zip \
https://github.com/jneilliii/OctoPrint-TabOrder/archive/master.zip \
https://github.com/jneilliii/OctoPrint-BedLevelVisualizer/archive/master.zip \
https://github.com/OctoPrint/OctoPrint-MQTT/archive/master.zip \
https://github.com/birkbjo/OctoPrint-Themeify/archive/master.zip \
https://github.com/jneilliii/OctoPrint-Python3PluginCompatibilityCheck/archive/master.zip \
https://github.com/OllisGit/OctoPrint-PrintJobHistory/releases/latest/download/master.zip \
https://github.com/marian42/octoprint-preheat/archive/master.zip \
https://github.com/OllisGit/OctoPrint-FilamentManager/releases/latest/download/master.zip \
https://github.com/OllisGit/OctoPrint-DisplayLayerProgress/releases/latest/download/master.zip \
https://github.com/jneilliii/OctoPrint-UltimakerFormatPackage/archive/master.zip \
https://github.com/jneilliii/OctoPrint-ConsolidateTempControl/archive/master.zip \
https://github.com/LazeMSS/OctoPrint-UICustomizer/archive/main.zip

VOLUME /home/octoprint/.octoprint

### Klipper setup ###

USER root

RUN apt-get install -y sudo

COPY klippy.sudoers /etc/sudoers.d/klippy

RUN useradd -ms /bin/bash klippy

# This is to allow the install script to run without error
RUN ln -s /bin/true /bin/systemctl

USER octoprint

WORKDIR /home/octoprint

RUN git clone https://github.com/KevinOConnor/klipper

RUN ./klipper/scripts/install-ubuntu-18.04.sh

USER root

# Clean up hack for install script
RUN rm -f /bin/systemctl

COPY start.py /
COPY runklipper.py /

CMD ["/start.py"]
