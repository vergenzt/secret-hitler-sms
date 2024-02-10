FROM alpine

RUN apk --no-cache add \
  bash \
  coreutils \
  moreutils \
  grep \
  npm \
  `# end`

RUN $npm twilio-cli
