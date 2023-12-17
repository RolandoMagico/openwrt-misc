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
When removing the header and signature from the firmware image, you get the encrypted firmware image wich starts with a header again.

| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x10         | Header for AES-CBC decryption of the image, details below.
| 0x00000010       | 0x20         | IV for AES-CBC decryption as ASCII string.
| 0x00000030       | 0x01         | Constant 0x0A (LF)
| 0x00000031       | 0x08         | ASCII "Salted___" without trailing \0
| 0x00000039       | 0x08         | The salt for the firmware decryption.
| 0x00000041       | variable     | The encrypted data.

A header for AES-CBC decryption has the following layout:
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x04         | ASCII "MH01" without trailing \0
| 0x00000004       | 0x04         | Constant 0x21 0x01 0x00 0x00
| 0x00000008       | 0x04         | Length of the data to decrypt (little endian format)
| 0x0000000C       | 0x02         | Constant 0x2B 0x1A
| 0x0000000E       | 0x01         | Byte sum of byte 0-13
| 0x0000000F       | 0x01         | XOR of byte 0-13

#### SHA512 Verification Header

A header for SHA512 verification has the following layout:
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x04         | ASCII "MH01" without trailing \0
| 0x00000004       | 0x04         | Length of the data to verify (little endian format)
| 0x00000008       | 0x04         | Constant 0x00 0x01 0x00 0x00
| 0x0000000C       | 0x02         | Constant 0x2B 0x1A
| 0x0000000E       | 0x01         | Byte sum of byte 0-13
| 0x0000000F       | 0x01         | XOR of byte 0-13
