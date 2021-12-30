
# Build time arguments
ARG platform=amd64
ARG jdk_version=11-jdk-bullseye

FROM --platform=${platform} openjdk:${jdk_version}
LABEL maintainer="am@alexandermoreno.com"
ARG platform=${platform}
ARG jdk_version=11-jdk-bullseye
ARG SERVER_FILE_URL
ARG EXPOSED_PORT=25565
ARG MAXRAM=5G
ARG MINRAM=5G

# prepare working directory
RUN mkdir /server-files
RUN mkdir /server-files/serverproperties
WORKDIR /server-files


# download, extract, and move the server files to the server-files folder
# then remove zip file
# test URL https://media.forgecdn.net/files/3583/968/SIMPLE-SERVER-FILES-1.8.16.zip

RUN curl -J -L ${SERVER_FILE_URL} -o minecraft-server.zip
RUN unzip minecraft-server.zip -d /server-files
RUN rm minecraft-server.zip
RUN cp -r $(echo ${SERVER_FILE_URL} | sed -e 's/.*\///' -e 's/\?.*//' -e 's/\.[^.]*$//')/* /server-files
RUN rm -r $(echo ${SERVER_FILE_URL} | sed -e 's/.*\///' -e 's/\?.*//' -e 's/\.[^.]*$//')

# configure server-setup-config.yaml
# replace the text minRam: 5G with minRam: ${MINRAM}
# replace the text maxRam: 5G with maxRam: ${MAXRAM} with sed
ENV maxRam ${MAXRAM}
ENV minRam ${MINRAM}


RUN sed -i "s/minRam: 5G/minRam: ${MINRAM}/" server-setup-config.yaml
RUN sed -i "s/maxRam: 5G/maxRam: ${MAXRAM}/" server-setup-config.yaml

# generate server files to make initialization faster
COPY ./killserver.sh /server-files/killserver.sh
RUN ./killserver.sh

# generate auto signed eula
RUN echo "eula=true" > eula.txt
RUN rm killserver.sh

# set up symbolic links for server config files to enable volume override
COPY ./server.properties /server-files/serverproperties/server.properties
RUN mv server-setup-config.yaml serverproperties/server-setup-config.yaml 
RUN ln -s /server-files/serverproperties/server.properties /server-files/server.properties
RUN ln -s /server-files/serverproperties/server-setup-config.yaml /server-files/server-setup-config.yaml



EXPOSE ${EXPOSED_PORT}
ENTRYPOINT [ "bash","./startserver.sh" ]