# D-Link M32 (EAGLE PRO AI AX3200 Mesh-System)
## OEM Firmware Layout

The following example is based on M32_REVA_FIRMWARE_v1.00B34.bin where the firmware is "packed" multiple times with additional verification and decryption information.

### Overall Firmware Signature
First of all, the OEM firmware starts with 16 bytes header and ends with 256 bytes signature for SHA512 signature verification.
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x10         | Header for SHA512 verification of the image, details below.
| 0x00000010       | variable     | Encrypted firmware data
| variable         | 0x100        | The signature for the SHA512 verification.

#### Encrypted Firmware data
When removing the SHA512 header and signature from the firmware image, you get the encrypted firmware image wich starts with a header again.
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x10         | Header for AES-CBC decryption of the image, details below.
| 0x00000010       | 0x20         | IV for AES-CBC decryption as ASCII string.
| 0x00000030       | 0x01         | Constant 0x0A (LF)
| 0x00000031       | 0x08         | ASCII "Salted___" without trailing \0
| 0x00000039       | 0x08         | The salt for the firmware decryption.
| 0x00000041       | variable     | The encrypted data.

##### Recovery Image
After decrypting the firmware image, a "Recovery Image" is left. It's an image which can be flashed via the recovery web interface. The recovery image consists of one or more partitions where every partition starts with a header followed by the partition data.
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x50         | Partition header
| 0x00000050       | variable     | Partition data
| variable         | 0x50         | Partition header
| variable         | variable     | Partition data

##### AES-CBC Decryption Header
A header for AES-CBC decryption has the following layout:
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x04         | ASCII "MH01" without trailing \0
| 0x00000004       | 0x04         | Constant 0x21 0x01 0x00 0x00
| 0x00000008       | 0x04         | Length of the data to decrypt (little endian format)
| 0x0000000C       | 0x02         | Constant 0x2B 0x1A
| 0x0000000E       | 0x01         | Byte sum of byte 0-13
| 0x0000000F       | 0x01         | XOR of byte 0-13

##### SHA512 Verification Header
A header for SHA512 verification has the following layout:
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x04         | ASCII "MH01" without trailing \0
| 0x00000004       | 0x04         | Length of the data to verify (little endian format)
| 0x00000008       | 0x04         | Constant 0x00 0x01 0x00 0x00
| 0x0000000C       | 0x02         | Constant 0x2B 0x1A
| 0x0000000E       | 0x01         | Byte sum of byte 0-13
| 0x0000000F       | 0x01         | XOR of byte 0-13

##### Partition Header

| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x0C         | ASCII "DLK6E6010001" without trailing \0
| 0x0000000C       | 0x04         | Constant 0x00 0x00 0x3A 0xB5 (differs in different FW versions)
| 0x00000010       | 0x0C         | Hex 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x01 0x00
| 0x0000001C       | 0x04         | Constant 0x4E 0xCC 0xD1 0x0B (differs in different FW versions)
| 0x00000020       | 0x04         | Erase start address of the partition (little endian format)
| 0x00000024       | 0x04         | Erase length of the partition (little endian format)
| 0x00000028       | 0x04         | Write start address of the partition (little endian format)
| 0x0000002C       | 0x04         | Write length of the partition (little endian format)
| 0x00000030       | 0x10         | 16 bytes 0x00
| 0x00000040       | 0x02         | Firware header ID: 0x42 0x48
| 0x00000042       | 0x02         | Firware header major version: 0x02 0x00
| 0x00000044       | 0x02         | Firware header minior version: 0x00 0x00
| 0x00000046       | 0x02         | Firware SID: 0x09 0x00
| 0x00000048       | 0x02         | Firware image info type: 0x00 0x00
| 0x0000004A       | 0x02         | Unknown, set to 0x00 0x00
| 0x0000004C       | 0x02         | FM fmid: 0x60 0x6E. Has to be match the "fmid" of the device.
| 0x0000004E       | 0x02         | Header checksum. It must be set to that the sum of all words in the firware equals 0xFFFF. An overflow will increase the  checksum by 1. See function "UpdateHeaderInRecoveryImage".
