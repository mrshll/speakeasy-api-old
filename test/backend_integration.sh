#!/usr/bin/env bash
# Usage:
#   backend_integration.sh # logs in and uploads a message
#   backend_integration.sh upload_message # uploads a message, using existing session
set -e

PHONE_NUMBER=6155197142
COOKIE_ARGS="-b cookiejar -c cookiejar"
ROOT_URL="http://4b4d0da3.ngrok.com"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

login () {
  curl $COOKIE_ARGS --data "phone_number=$PHONE_NUMBER" $ROOT_URL/login/phone_number
  echo ""
  echo "Enter login token:"
  read LOGIN_TOKEN

  curl $COOKIE_ARGS --data "phone_number=$PHONE_NUMBER&token=$LOGIN_TOKEN" $ROOT_URL/login/validate_token
}

upload_message () {
  curl $COOKIE_ARGS -F "phone_number=$PHONE_NUMBER" \
                    -F "delivery_unit=seconds" \
                    -F "delivery_magnitude=1" \
                    -F "source=@$SCRIPT_DIR/../assets/fixtures/ground_control.m4a" \
                    $ROOT_URL/messages
}

# if run with no arguments, log in and upload a message
# else, execute each argument as a function
if [[ $1 == "" ]]; then
  login
  upload_message
else
  for command in "$@"
  do
    $command
  done
fi

