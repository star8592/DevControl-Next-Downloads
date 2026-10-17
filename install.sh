#!/usr/bin/env bash
# DevControl Next Linux x86_64 preview installer; no root, no Docker, no old Agent.
set -Eeuo pipefail
tag="v0.1.0-preview.1"
base="https://github.com/star8592/DevControl-Next-Downloads/releases/download/$tag"
filename="devcontrol-next-agent-linux-x86_64.tar.gz"
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo "Only Linux x86_64 is supported by this package" >&2; exit 3
fi
for dep in curl tar sha256sum mktemp; do command -v "$dep" >/dev/null || { echo "Missing $dep" >&2; exit 3; }; done
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
curl --fail --location --retry 2 --silent --show-error "$base/$filename" -o "$scratch/$filename"
curl --fail --location --retry 2 --silent --show-error "$base/$filename.sha256" -o "$scratch/$filename.sha256"
(cd "$scratch"; sha256sum --check --status "$filename.sha256") || { echo "Checksum failure; installation cancelled" >&2; exit 5; }
prefix="${XDG_DATA_HOME:-$HOME/.local/share}/devcontrol-next"
release="$prefix/releases/$tag"
mkdir -p "$prefix/releases" "$HOME/.local/bin"
if [[ -d "$release" ]]; then
  test -x "$release/bin/devcontrol-agent" || { echo "Invalid existing Next release" >&2;exit 6; }
else
  staging=$(mktemp -d "$prefix/releases/.incoming-XXXXXXXX")
  trap 'rm -rf "$scratch"; rm -rf "$staging"' EXIT
  tar -xzf "$scratch/$filename" -C "$staging" --no-same-owner
  "$staging/bin/devcontrol-agent" --version | grep -q '^DevControl Next Agent ' || { echo "Binary is not Next" >&2; exit 6; }
  mv "$staging" "$release"
fi
ln -sfn "$release" "$prefix/.current-new"
mv -Tf "$prefix/.current-new" "$prefix/current"
cat > "$HOME/.local/bin/devcontrol-next-agent" <<'WRAPPER'
#!/usr/bin/env bash
set -e
root="${XDG_DATA_HOME:-$HOME/.local/share}/devcontrol-next"
export DEVCONTROL_NEXT_AGENT_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/devcontrol-next/agent"
export DEVCONTROL_NEXT_AGENT_NAMESPACE="devcontrol-next-staging"
export DEVCONTROL_NEXT_LOCAL_AUTH_BIND="127.0.0.1:28789"
export DEVCONTROL_NEXT_COMPONENT_ROOT="$root/current/components"
export DEVCONTROL_NEXT_SECURITY_MODE="guarded"
mkdir -p "$DEVCONTROL_NEXT_AGENT_STATE_DIR"
exec "$root/current/bin/devcontrol-agent" "$@"
WRAPPER
chmod 700 "$HOME/.local/bin/devcontrol-next-agent"
echo "NEXT_LINUX_INSTALL_OK version=$tag"
"$HOME/.local/bin/devcontrol-next-agent" --version
echo "NEXT MCP is not online yet. Agent is installed but NOT enrolled or started."
echo "When Next Gateway opens, run:"
echo "  $HOME/.local/bin/devcontrol-next-agent run --gateway https://mcpx.devcontrol.dev"
