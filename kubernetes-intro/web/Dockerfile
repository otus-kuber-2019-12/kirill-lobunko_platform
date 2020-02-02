FROM python:3.7-slim

ARG USER=app
ARG UID=1001
ARG GID=1001

RUN useradd ${USER} && usermod -u ${UID} ${USER} && groupmod -g ${GID} ${USER}

# Create app directory
WORKDIR /app

# Bundle app source
COPY src /

EXPOSE 8000
CMD [ "su", "app", "-c", "/usr/local/bin/python /server.py" ]
