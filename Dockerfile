FROM alpine

RUN apk --no-cache add \
  bash \
  coreutils \
  moreutils \
  grep \
  npm \
  `# end`

RUN $apk npm
ARG npm='npm install --global'

RUN $npm twilio-cli
