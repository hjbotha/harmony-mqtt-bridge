# keyboard-mqtt-bridge
A very simple set of configuration files and scripts to bridge keystrokes to MQTT

Requirements:
- triggerhappy to detect keystrokes
- mosquitto_pub to publish messages.

Messages will be published when the ENTER key is received.

This is particularly useful in combination with Logitech Harmony remotes and a Raspberry Pi or similar small computer, as the remote can be paired with the system as a bluetooth keyboard, providing a large number of buttons and combinations.

My use case:
- My Harmony Watch TV activity includes this as a device
- Harmony is configured to use this device to change channels, by sending the channel number followed by ENTER
- When Harmony sends a string followed by ENTER, it gets sent to Home Assistant
- Home Assistant automations are configured to perform an action based on the channel number.
  - Channels 1-799 are used by Live TV. When a number in this range is received, Home Assistant will change the TV to that channel
  - Channels 900-919 are used for other TV sources. When a number in this range is received, Home Assistant will set the TV to that source. e.g. 901 = Plex.
  - Channels 920-929 are used to manage lights

## Home Assistant Automation YAML examples

```
- id: 'pi_harmony_0_to_900_tv_channel'
  alias: Pi Harmony - 0 to 900 - Set TV Channel
  description: ''
  trigger:
  - platform: mqtt
    topic: pi.harmony.command
  condition:
  - condition: template
    value_template: >
      {{ trigger.payload|int < 900 }}
  action:
  - service: media_player.play_media
    data_template:
      entity_id: media_player.living_room_tv
      media_content_id: >
        {{ trigger.payload }}
      media_content_type: "channel"

- id: 'pi_harmony_900_to_919_tv_source'
  alias: Pi Harmony - 900 to 919 - Set TV Source
  description: ''
  trigger:
  - platform: mqtt
    topic: pi.harmony.command
  condition:
  - condition: template
    value_template: >
      {{ trigger.payload|int >= 900 and trigger.payload|int < 932}}
  action:
  - service: media_player.select_source
    data_template:
      entity_id: media_player.living_room_tv
      source: >
        {% set sourcenr = trigger.payload|int %}
        {% if sourcenr == 901 %}    Plex
        {% elif sourcenr == 902 %}  Netflix
        {% elif sourcenr == 903 %}  Amazon Prime Video
        {% elif sourcenr == 904 %}  NOW TV
        {% elif sourcenr == 905 %}  MiBox
        {% elif sourcenr == 906 %}  BBC iPlayer
        {% else %} Plex
        {% endif %}

- id: 'pi_harmony_920_to_924_lights_off'
  alias: Pi Harmony - 920 to 924 - Lights Off
  description: ''
  trigger:
  - platform: mqtt
    topic: pi.harmony.command
  condition:
  - condition: template
    value_template: >
      {{ trigger.payload|int >= 920 and trigger.payload|int <= 924 }}
  action:
    service: light.turn_off
    data_template:
      entity_id: >
        {% if trigger.payload|int == 921 %}
          light.living_room
        {% endif %}

- id: 'pi_harmony_925_to_929_lights_on'
  alias: Pi Harmony - 925 to 929 - Lights On
  description: ''
  trigger:
  - platform: mqtt
    topic: pi.harmony.command
  condition:
  - condition: template
    value_template: >
      {{ trigger.payload|int >= 925 and trigger.payload|int <= 929 }}
  action:
    service: light.turn_on
    data_template:
      entity_id: >
        {% if trigger.payload|int == 925 %}
          light.living_room
        {% endif %}
      brightness: 50
```