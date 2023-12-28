# FritzBox 7510

## Disassembly
Remove the four screws on the bottom of the device with a T10 screwdriver. Afterwards, the cover can be removed.

## Serial Interface
Serial interface can be connected in the front middle of the board.
Pinout (front to rear):
- 3.3V
- RX
- TX
- GND

Settings: 115200, 8N1

## MAC Addresses
There is no MAC address printed on the device label but the second part of the CWMP-Account information on the label contains a MAC address.
Base on this information and the bootlog, there are the following addreses:
- DSL MAC: MAC from CWMP Account - 3
- VOIP MAC: MAC from CWMP Account - 2
- VCC2 MAC: MAC from CWMP Account - 1
- VCC3 MAC: MAC from CWMP Account + 1
- LAN MAC: MAC from CWMP Account
- WLAN MAC: MAC from CWMP Account + 2
