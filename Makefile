## help: print this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ":" | sed -e 's/^/  /'

## lint: runs golangci lint based on .golangci.yml configuration
.PHONY: lint
lint:
	@if ! test -f `go env GOPATH`/bin/golangci-lint; then go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.51.0; fi
	golangci-lint run -c .golangci.yml --fix -v

## test: runs tests
.PHONY: test
test:
	go test -v ./... -coverprofile=unit_coverage.out -short

## unit-coverage-html: extract unit tests coverage to html format
.PHONY: unit-coverage-html
unit-coverage-html:
	make test
	go tool cover -html=unit_coverage.out -o unit_coverage.html

## godoc: generate documentation
.PHONY: godoc
godoc:
	@if ! test -f `go env GOPATH`/bin/godoc; then go install golang.org/x/tools/cmd/godoc; fi
	godoc -http=127.0.0.1:6060

## produce: produce test message (requires jq and kafka-console-producer)
## : make produce topic=exception
.PHONY: produce
produce:
	jq -rc . ./testdata/message.json | kafka-console-producer --bootstrap-server 127.0.0.1:9092 --topic ${topic}

# default value
export topic=exception
## produce-with-header: produce test message with retry header (requires jq and kcat)
## : make produce-with-header topic=exception
.PHONY: produce-with-header
produce-with-header:
	jq -rc . ./testdata/message.json | kcat -b 127.0.0.1:9092 -t ${topic} -P -H x-retry-count=1