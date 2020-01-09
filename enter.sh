#! /bin/bash

# Place this file in /opt/thd-out and insert your MQTT details

mqtt_payload_file=/tmp/mqtt-payload
mosquitto_pub -t pi.harmony.command -u <MQTT_USER> -P <MQTT_PASSWORD> -h <MQTT_SERVER> -m $(cat $mqtt_payload_file)
rm $mqtt_payload_file
