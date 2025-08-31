# Installs build pipeline dependencies
install:
    #!/usr/bin/env fish
    set TAILWIND_VERSION v4.1.12
    if test -x ./tailwindcss; else; echo "Installing Tailwindcss $TAILWIND_VERSION... See https://tailwindcss.com/blog/standalone-cli"; curl -sL -o tailwindcss https://github.com/tailwindlabs/tailwindcss/releases/download/$TAILWIND_VERSION/tailwindcss-macos-arm64; chmod +x tailwindcss; end
    if test -z (which air); echo "Installing Go Air... See https://github.com/air-verse/air"; go install github.com/air-verse/air@latest; end
    if test -z (which templ); echo "Installing Go Templ... See https://templ.guide/quick-start/installation"; go install github.com/a-h/templ/cmd/templ@latest; end
    if test -z (which sqlc); echo "Installing SQLC... See https://docs.sqlc.dev/en/stable/overview/install.html"; go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest; end
    echo "All dependencies installed."

# Removes all compiled files
clean:
    rm unac
    rm -rf ./tmp

# Compile CSS, templ files, and SQL
build-dependencies:
    ./tailwindcss -i css/index.css -o assets/embed/compiled.css --minify
    templ generate
    # sqlc generate

# Compile for production
build: build-dependencies
    # TODO configure for production
    go build .

# Starts the server and watches for changes
dev:
    air

serve:
    go run main.go

# Deploy site to server
deploy: clean build
    echo "TODO"

