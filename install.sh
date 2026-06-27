#!/usr/bin/env bash
# codememory install.sh
# One-line installer for codememory (Agentic Memory)
# Usage: curl -fsSL https://raw.githubusercontent.com/jarmen423/codememory/main/install.sh | bash
#        curl ... | bash -s -- --ui

set -euo pipefail

# --- Config ---
REPO="jarmen423/codememory"
BINARY_NAME="codememory"
INSTALL_DIR="${HOME}/.local/bin"
VERSION="${CODEMEMORY_VERSION:-latest}"
UI_VARIANT=false
SKIP_CONFIG=false

# --- Parse args ---
while [[ $# -gt 0 ]]; do
    case $1 in
        --ui) UI_VARIANT=true; shift ;;
        --dir=*) INSTALL_DIR="${1#*=}"; shift ;;
        --skip-config) SKIP_CONFIG=true; shift ;;
        -h|--help)
            echo "codememory installer"
            echo "  --ui           Install UI/graph viewer variant"
            echo "  --dir=PATH     Custom install directory"
            echo "  --skip-config  Skip automatic agent configuration"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# --- Detect OS/Arch ---
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "darwin" ;;
        Linux) echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unsupported"; exit 1 ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "amd64" ;;
        arm64|aarch64) echo "arm64" ;;
        *) echo "unsupported"; exit 1 ;;
    esac
}

OS=$(detect_os)
ARCH=$(detect_arch)

if [ "$OS" = "windows" ]; then
    echo "Windows detected — please use install.ps1 instead"
    exit 1
fi

# --- Determine binary variant ---
if [ "$UI_VARIANT" = true ]; then
    BINARY_VARIANT="ui"
else
    BINARY_VARIANT="standard"
fi

# --- Download URL (GitHub Releases) ---
if [ "$VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}-${OS}-${ARCH}${BINARY_VARIANT:+-${BINARY_VARIANT}}.tar.gz"
else
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY_NAME}-${OS}-${ARCH}${BINARY_VARIANT:+-${BINARY_VARIANT}}.tar.gz"
fi

CHECKSUM_URL="https://github.com/${REPO}/releases/latest/download/checksums.txt"

echo "→ Installing codememory (${OS}-${ARCH}) to ${INSTALL_DIR}"

# --- Create dir ---
mkdir -p "$INSTALL_DIR"

# --- Download & verify ---
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "→ Downloading..."
curl -fsSL "$DOWNLOAD_URL" -o "${BINARY_NAME}.tar.gz" || { echo "Download failed"; exit 1; }

if command -v sha256sum >/dev/null; then
    curl -fsSL "$CHECKSUM_URL" -o checksums.txt
    sha256sum -c checksums.txt --ignore-missing || { echo "Checksum failed"; exit 1; }
    echo "✓ Checksum verified"
fi

# --- Extract ---
tar -xzf "${BINARY_NAME}.tar.gz"

# --- Install ---
mv "${BINARY_NAME}"* "${INSTALL_DIR}/${BINARY_NAME}"
chmod +x "${INSTALL_DIR}/${BINARY_NAME}"

# macOS quarantine fix
if [ "$OS" = "darwin" ]; then
    xattr -d com.apple.quarantine "${INSTALL_DIR}/${BINARY_NAME}" 2>/dev/null || true
fi

cd - >/dev/null
rm -rf "$TMP_DIR"

# --- Verify ---
"${INSTALL_DIR}/${BINARY_NAME}" --version || true

# --- PATH check ---
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo ""
    echo "⚠️  ${INSTALL_DIR} is not in your PATH."
    echo "   Add this to your shell config:"
    echo "   export PATH=\"${INSTALL_DIR}:\$PATH\""
fi

# --- Optional agent config ---
if [ "$SKIP_CONFIG" = false ]; then
    echo ""
    echo "→ Running initial agent configuration (you can skip with --skip-config)..."
    "${INSTALL_DIR}/${BINARY_NAME}" config init --yes 2>/dev/null || echo "  (config step skipped or failed — you can run manually later)"
fi

echo ""
echo "✅ codememory installed successfully!"
echo "   Run: codememory --help"
echo "   Restart your coding agent and say: \"Index this project\""
