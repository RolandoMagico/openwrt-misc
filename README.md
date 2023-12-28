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

## Memory
- 512MB RAM
- 128MB flash

## Memory Layout
Output of ```cat /proc/mtd```:
```
dev:    size   erasesize  name
mtd0: 00800000 00020000 "fit0"
mtd1: 00540000 00020000 "urlader"
mtd2: 00800000 00020000 "nand-tffs"
mtd3: 00800000 00020000 "fit1"
mtd4: 062c0000 00020000 "ubi"
mtd5: 02a05000 0001f000 "filesystem"
mtd6: 02a05000 0001f000 "reserved-filesystem"
mtd7: 0020f000 0001f000 "config"
mtd8: 0043d000 0001f000 "nand-filesystem"
```
