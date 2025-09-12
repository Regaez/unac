package assets

import (
	"crypto/sha256"
	_ "embed"
	"fmt"
	"net/http"
	"strings"
)

type Asset struct {
	content         []byte
	filenamePattern string
	hash            string
	mimeType        string
	serveFromRoot   bool
}

// A list of all embedded assets
var EmbeddedAssets = []Asset{
	AssetCss,
	AssetDatastar,
}

//go:embed embed/compiled.css
var assetContentCss []byte
var AssetCss = Asset{
	content:         assetContentCss,
	filenamePattern: "site.%s.css",
	hash:            getHash(assetContentCss),
	mimeType:        "text/css; charset=utf-8",
}

//go:embed embed/datastar-1-0-0-rc-5-86446608e10dc6cf.js
var assetContentDatastar []byte
var AssetDatastar = Asset{
	content:         assetContentDatastar,
	filenamePattern: "datastar.%s.js",
	hash:            getHash(assetContentDatastar),
	mimeType:        "application/javascript; charset=utf-8",
}

// Get the route for the asset.
//
//	@example /assets/site.css
func (a *Asset) Route() string {
	path := a.filenamePattern

	if strings.Contains(path, "%s") {
		path = fmt.Sprintf(path, a.hash)
	}

	if a.serveFromRoot == true {
		return fmt.Sprintf("/%s", path)
	}

	return fmt.Sprintf("/assets/%s", path)
}

func getHash(s []byte) string {
	h := sha256.New()
	h.Write(s)
	bs := h.Sum(nil)
	return fmt.Sprintf("%x", bs)[:8]
}

// Returns an HTTP GET handler for a given asset
func GetHandler(asset Asset) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		// If the route contains a hash, cache indefinitely, otherwise just cache for 24 hours
		if strings.Contains(asset.Route(), asset.hash) {
			w.Header().Add("Cache-Control", "max-age=2147483648, immutable")
		} else {
			w.Header().Add("Cache-Control", "max-age=86400, public")
		}

		w.Header().Add("Content-Type", asset.mimeType)
		w.Write(asset.content)
	}
}
