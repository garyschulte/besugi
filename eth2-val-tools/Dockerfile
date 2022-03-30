FROM golang:1.16-buster

RUN go install github.com/wealdtech/ethereal/v2@latest

RUN go install github.com/protolambda/eth2-val-tools@latest

WORKDIR /app

RUN apt update && apt install -y jq bash

COPY exec_deposits.sh .

COPY goerli-shadow-fork-2.env .

RUN chmod 755 /app/exec_deposits.sh

ENV PATH "$PATH:/app:/go/bin"

ENTRYPOINT ["/go/bin/eth2-val-tools"]
