#!/bin/bash
set -e

# Define variables
INSTALL_DIR="/usr/local/bin/pathsense"
RC_LOCAL_FILE="/etc/rc.local"
RELEASE_DIR="$(dirname "$0")/pathsense-release"

# Create installation directory
echo "=== Preparing installation directories ==="
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"

# Install runtime dependencies
echo "=== Installing runtime dependencies ==="
sudo chmod +x "$RELEASE_DIR/prepare-runtime.sh"
$RELEASE_DIR/prepare-runtime.sh >/dev/null

# Copy files to the installation directory
echo "=== Copying PathSense files to installation directory ==="
sudo cp -r "$RELEASE_DIR/system/bin/pathsense_system" "$INSTALL_DIR/pathsense_system"
sudo cp -r "$RELEASE_DIR/system/bin/dependencies" "$INSTALL_DIR/dependencies"
sudo cp -r "$RELEASE_DIR/system/bin/proto" "$INSTALL_DIR/proto"
sudo chmod +x "$INSTALL_DIR/pathsense_system"

# Configure rc.local to start PathSense at boot
echo "=== Configuring rc.local ==="
if [ ! -f "$RC_LOCAL_FILE" ]; then
  echo "#!/bin/bash" | sudo tee "$RC_LOCAL_FILE" >/dev/null
  echo "exit 0" | sudo tee -a "$RC_LOCAL_FILE" >/dev/null
  sudo chmod +x "$RC_LOCAL_FILE"
fi

sudo sed -i "/^exit 0/i export RUST_LOG=info && cd $INSTALL_DIR && nohup ./pathsense_system > pathsense_system.log 2>&1 &" "$RC_LOCAL_FILE"

echo "=== PathSense installation complete ==="
