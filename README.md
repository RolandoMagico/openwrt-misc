# D-Link M60 (AX6000 Wi-Fi 6 Smart Mesh Router)
## OEM Firmware Layout
Compared to M32, R32 and M30, it looks like the firmware layout has changed. Having a look at M60A1_FW100B21.bin, it seems that the firmware image is an recovery image containing 2 partitions with partition headers. The content of the partitions itself is encrypted. The recovery images were not encrypted in previous devices. So the already existing scripts/tools don't work anymore for the M60. There are M60 keys in the GPL sources for the M32, which means that they now have to be used in a different way or the image encryption procedure has changed completely.

##### Recovery Image
The recovery image consists of two partitions where every partition starts with a header followed by the partition data.
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x50         | Partition header, see [below](#partition-header)
| 0x00000050       | 0x100        | Partition data
| 0x00000150       | 0x50         | Partition header, see [below](#partition-header)
| 0x000001A0       | variable     | Partition data

The first partition has an erase length of 0 but a write length of 0x100. Not sure if it really contains data which is flashed or if it is some kind of additional information for decryption or the flash procedure itself.
The second partition has an erase length of 0x02D00000 and a write length of 0x0238BBA0. The wirte length matches the remaining data length in the image, I assume D-Link switched also to UBI format like in M30.

##### Partition Header

| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x0C         | ASCII "DLK6E8202001" without trailing \0
| 0x0000000C       | 0x04         | Constant 0x00 0x00 0x7D 0x4A (differs in different FW versions and also within partition headers of one firmware image)
| 0x00000010       | 0x0C         | Hex 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x01 0x00
| 0x0000001C       | 0x04         | Constant 0x38 0x9E 0x06 0x0C (differs in different FW versions)
| 0x00000020       | 0x04         | Erase start address of the partition (little endian format)
| 0x00000024       | 0x04         | Erase length of the partition (little endian format)
| 0x00000028       | 0x04         | Write start address of the partition (little endian format)
| 0x0000002C       | 0x04         | Write length of the partition (little endian format)
| 0x00000030       | 0x10         | 16 bytes 0x00
| 0x00000040       | 0x02         | Firware header ID: 0x42 0x48
| 0x00000042       | 0x02         | Firware header major version: 0x02 0x00
| 0x00000044       | 0x02         | Firware header minior version: 0x00 0x00
| 0x00000046       | 0x02         | Firware SID: 0x0B 0x00
| 0x00000048       | 0x02         | Firware image info type: 0x00 0x00
| 0x0000004A       | 0x02         | Unknown, set to 0x00 0x00
| 0x0000004C       | 0x02         | FM fmid: 0x82 0x6E. Has to be match the "fmid" of the device.
| 0x0000004E       | 0x02         | Header checksum. It must be set to that the sum of all words in the firware equals 0xFFFF. An overflow will increase the  checksum by 1.
