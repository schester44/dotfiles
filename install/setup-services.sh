# Elephant
elephant service enable
# Fix target — graphical-session.target is never reached under Hyprland
sed -i 's/graphical-session.target/default.target/g' ~/.config/systemd/user/elephant.service
systemctl --user daemon-reload
systemctl --user enable --now elephant.service

# Bluetooth
sudo systemctl enable --now bluetooth

# Keyd (key remapping) — disabled: capslock/hyper handled by XKB via Hyprland
# Re-enable if keyd is needed for other remappings (e.g. rightalt)
# sudo ln -sf "$DOTFILES/system/keyd/default.conf" /etc/keyd/default.conf
# sudo systemctl enable --now keyd

