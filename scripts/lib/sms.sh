
# shellcheck disable=SC2206
send_sms() {
  PUBLIC_PHONE="$1"
  SECRET_MESSAGE=$(echo -en "\n\n$2")
  shift 2
  SECRET_PHOTOS=($@)
  twilio api:core:messages:create \
    --from "$PUBLIC_SOURCE_PHONE" \
    --to "$PUBLIC_PHONE" \
    --body "$SECRET_MESSAGE" \
    ${SECRET_PHOTOS[@]/#/--media-url } \
    >/dev/null
}
