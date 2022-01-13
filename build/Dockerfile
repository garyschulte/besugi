FROM golang:1.16-buster as builder


RUN go install github.com/wealdtech/ethereal/v2@latest

RUN go install github.com/protolambda/eth2-val-tools@latest

FROM alpine:latest

WORKDIR /app

COPY --from=builder /go/bin/* /app/

RUN apk add --no-cache jq bash

COPY exec_deposits.sh .

COPY secrets.env .

RUN chmod 755 /app/exec_deposits.sh

ENV PATH "$PATH:/app"

ENTRYPOINT ["/app/exec_deposits.sh"]
