# Elephant
elephant service enable
# Fix target — graphical-session.target is never reached under Hyprland
sed -i 's/graphical-session.target/default.target/g' ~/.config/systemd/user/elephant.service
systemctl --user daemon-reload
systemctl --user enable --now elephant.service

# Bluetooth
sudo systemctl enable --now bluetooth

