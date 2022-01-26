ARG XC_NUMBER_BITS
ARG XC_VERSION

FROM mchp-sensiml-xc${XC_NUMBER_BITS}:latest

#%% Download DFP
ARG DFP_NAME
ARG DFP_VERSION
RUN \
    wget -qO /tmp/tmp-pack.atpack \
    https://packs.download.microchip.com/Microchip.${DFP_NAME}.${DFP_VERSION}.atpack \
    && mkdir -p /opt/microchip/mplabx/v${MPLABX_VERSION}/packs/Microchip/${DFP_NAME}/${DFP_VERSION} \
    && unzip -o /tmp/tmp-pack.atpack -d /opt/microchip/mplabx/v${MPLABX_VERSION}/packs/Microchip/${DFP_NAME}/${DFP_VERSION} \
    && rm /tmp/tmp-pack.atpack \
    && rm -rf /var/lib/apt/lists/*

#%% Checkout prj builder
ARG GIT_MCHP_PRJ_BUILDER="https://github.com/tjgarcia-mchp/ml-sensiml-project-builder.git"
RUN \
    git clone --depth 1 "${GIT_MCHP_PRJ_BUILDER}" /build \
    && chmod a+x /build/build.sh

#%% Build library
ARG MPLABX_VERSION
ARG XC_NUMBER_BITS
ARG XC_VERSION

ARG PRJ_TARGET
ARG PRJ_NAME=libsensiml.${PRJ_TARGET}.xc${XC_NUMBER_BITS}.${XC_VERSION}
ARG PRJ_BUILD_LIB=1
ARG PRJ_PROJECT_FILE=sensiml.xc${XC_NUMBER_BITS}.project.ini
ARG PRJ_OPTIONS_FILE=sensiml.xc${XC_NUMBER_BITS}.options.ini
ARG PRJ_MODEL_FOLDER=knowledgepack

COPY "${PRJ_PROJECT_FILE}" "${PRJ_OPTIONS_FILE}" /build/
COPY "${PRJ_MODEL_FOLDER}" /build/"${PRJ_MODEL_FOLDER}"

RUN \
    cd /build/ \
    && ./build.sh \
    && mkdir -p /dist/ \
    && mv *.a /dist/