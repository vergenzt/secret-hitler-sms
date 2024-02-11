FROM alpine

ARG apk='apk --no-cache add'

RUN $apk bash
RUN $apk coreutils
RUN $apk moreutils
RUN $apk grep

RUN $apk npm
ARG npm='npm install --global'

RUN $npm twilio-cli
