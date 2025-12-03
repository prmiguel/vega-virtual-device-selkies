### Stage 1: Dependencies
FROM ghcr.io/linuxserver/lsiodev-baseimage-selkies:ubuntunoble AS dependencies

USER root
RUN (dpkg -l | grep -q lz4 || sudo apt install -y lz4) && \
  sudo add-apt-repository -y ppa:deadsnakes/ppa && \
  sudo apt update && \
  (dpkg -l | grep -q libpython3.8-dev || sudo apt install -y libpython3.8-dev)

RUN apt-get update && \
  apt-get install -y \
  bridge-utils \
  cpu-checker \
  libvirt-clients \
  libvirt-daemon \
  qemu-system-x86 \
  wmctrl && \
  chmod 777 -R /config

### Stage 2: Downloas and Install SDK
ARG KEPLER_TOKEN
ARG SDK_VERSION
ARG INSTALLER_SCRIPT
ARG SDK_URL
ARG SIM_URL
ARG DIRECTED_ID
ARG SDK_ROOT=/kepler/sdk
FROM dependencies AS sdk
# Installer Environment Variables
ENV INSTALL_DIR=${SDK_ROOT}
ENV INSTALL_ROOT_DIR=${SDK_ROOT}
ENV NONINTERACTIVE=true
ENV DOWNLOAD_DIR=/config
ENV VERBOSE=true
ENV OVERWRITE_PREVIOUS=true
ENV KEPLER_STUDIO_INSTALLED=false
ENV INSECURE_DOWNLOADS=false
# Runtime Environment Variables
ENV KEPLER_SDK_PATH=${SDK_ROOT}/${SDK_VERSION}
ENV PATH=${KEPLER_SDK_PATH}/bin:$PATH
ENV PATH=${KEPLER_SDK_PATH}/bin/tools:$PATH
ENV PATH=${KEPLER_SDK_PATH}/runtimes/node/bin:$PATH

USER root

RUN mkdir -p ${SDK_ROOT} && chown abc:abc -R ${SDK_ROOT}

USER abc

RUN  curl -fsSL ${INSTALLER_SCRIPT} | bash -s -- \
  --sdk-url=${SDK_URL} \
  --sim-url=${SIM_URL} \
  --version=${SDK_VERSION} \
  --directed-id=${DIRECTED_ID}

RUN npm add -g appium@2.2.2 \
  && npm add -g @appium/types \
  && appium driver install --source=npm @amazon-devices/appium-kepler-driver@3.30.0 \
  && npm add -g selenium-webdriver

### Stage 2: Automatino Test
# ARG SDK_VERSION
# ARG SDK_ROOT=/kepler/sdk
# FROM dependencies AS automation-test
# ENV KEPLER_SDK_PATH=${SDK_ROOT}/${SDK_VERSION}
# ENV PATH=${KEPLER_SDK_PATH}/bin:$PATH
# ENV PATH=${KEPLER_SDK_PATH}/bin/tools:$PATH
# ENV PATH=${KEPLER_SDK_PATH}/runtimes/node/bin:$PATH
# ENV APPIUM_HOME=/config/.appium

# COPY --from=sdk --chown=abc:abc ${APPIUM_HOME} ${APPIUM_HOME}
# COPY --from=sdk --chown=abc:abc ${KEPLER_SDK_PATH}/bin/kepler ${KEPLER_SDK_PATH}/bin/kepler
# COPY --from=sdk --chown=abc:abc ${KEPLER_SDK_PATH}/bin/tools/vda ${KEPLER_SDK_PATH}/bin/tools/vda
# COPY --from=sdk --chown=abc:abc ${KEPLER_SDK_PATH}/bin/tools/vpt ${KEPLER_SDK_PATH}/bin/tools/vpt
# COPY --from=sdk --chown=abc:abc ${KEPLER_SDK_PATH}/kvd ${KEPLER_SDK_PATH}/kvd
# COPY --from=sdk --chown=abc:abc $KEPLER_SDK_PATH/runtimes $KEPLER_SDK_PATH/runtimes
# COPY --from=sdk --chown=abc:abc $KEPLER_SDK_PATH/packages $KEPLER_SDK_PATH/packages
# COPY --from=sdk --chown=abc:abc $KEPLER_SDK_PATH/tools $KEPLER_SDK_PATH/tools
# COPY --from=sdk --chown=abc:abc $KEPLER_SDK_PATH/workspace $KEPLER_SDK_PATH/workspace
# COPY --from=sdk --chown=abc:abc $KEPLER_SDK_PATH/sdk-info.toml $KEPLER_SDK_PATH/sdk-info.toml

USER root

COPY /root /

ENV SELKIES_UI_TITLE=kvd
ENV SELKIES_UI_SHOW_SIDEBAR=False

EXPOSE 4723
