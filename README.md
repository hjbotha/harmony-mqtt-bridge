# keyboard-mqtt-bridge
A very simple set of configuration files and scripts to bridge keystrokes to MQTT

Requirements:
- triggerhappy to detect keystrokes
- mosquitto_pub to publish messages.

Messages will be published when the ENTER key is received.

This is particularly useful in combination with Logitech Harmony remotes and a Raspberry Pi or similar small computer, as the remote can be paired with the system as a bluetooth keyboard, providing a large number of buttons and combinations.