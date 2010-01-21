#!/bin/sh

UNIXTIME=`date +"%s"`
POST_DATA=`hostname -f`
POST_DATA="heart=${POST_DATA}"
CONTENT_LENGTH=`echo -n "${POST_DATA}" | wc -c`

HTTP_REQUEST="POST /heartbeat.php?timestamp=${UNIXTIME} HTTP/1.1\r\n"\
"Host: %s\r\n"\
"User-Agent: http-heartbeat client 0.1b\r\n"\
"Accept: */*\r\n"\
"Content-Length: ${CONTENT_LENGTH}\r\n"\
"Content-Type: application/x-www-form-urlencoded\r\n"\
"\r\n"\
"%s"
printf "$HTTP_REQUEST" "$1" "${POST_DATA}" | nc $1 80 | grep "HTTP/1\.. 200 OK" > /dev/null