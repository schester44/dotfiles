.PHONY: build test install uninstall clean

build:
	go build -o wezwork .

test:
	go test ./...

install:
	go install .
	go run . install
	mv "$$(go env GOPATH)/bin/wezwork" /usr/local/bin/wezwork

uninstall:
	-go run . uninstall
	rm -f "$$(go env GOPATH)/bin/wezwork"

clean:
	rm -f wezwork
