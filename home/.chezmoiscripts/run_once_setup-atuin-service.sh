#!/bin/bash

# Setup atuin systemd service on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    systemctl --user daemon-reload
    systemctl --user enable atuin.service
    systemctl --user start atuin.service
    echo "Atuin systemd service enabled and started"
fi
