# D-Link M32 (EAGLE PRO AI AX3200 Mesh-System)
## OEM Firmware Layout

The following example is based on M32-REVA_1.03.01_HOTFIX.enc.bin where the firmware is "packed" multiple times with additional verification and decryption information. All required data for verification and decryption are included in the GPL package from D-Link in the foler ```BPI-R2/meta-myproject/recipes-dlink/imgcrypto/files/919251a1_dlink-fw-encdec-keys-native.tar.gz/git/M32```:
- Key.pub: The public key for SHA512 verification
- Key.firmware: The key do decrypt the firmware

Additionally, there are:
- Key.pri: To sign images

### Overall Firmware Signature
First of all, the OEM firmware starts with 16 bytes header and ends with 256 bytes signature for SHA512 signature verification.
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x10         | Header for SHA512 verification of the image, details [below](#sha512-verification-header).
| 0x00000010       | variable     | Encrypted firmware data
| variable         | 0x100        | The signature for the SHA512 verification.

Example script for verification:
- Remove the SHA512 verification header from the original firmware file:
```
dd if=M32-REVA_1.03.01_HOTFIX.enc.bin iflag=skip_bytes of=Firmware.tmp1 bs=1M skip=16
```
- Extract the SHA512 signature from the firmware:
```
dd if=Firmware.tmp1 of=Firmware.tmp1.sig bs=1 count=256 skip=$(( $(stat -c %s Firmware.tmp1) - 256))
```
- Remove the SHA512 signature from the firmware:
```
dd if=Firmware.tmp1 iflag=count_bytes of=Firmware.tmp2 bs=1M count=$(( $(stat -c %s Firmware.tmp1) - 256))
```
- Create digest for verification:
```
openssl dgst -sha512 -binary -out Firmware.tmp2.dgst Firmware.tmp2
```
- Verify image:
```
openssl dgst -verify Key.pub -sha512 -binary -signature Firmware.tmp1.sig Firmware.tmp2.dgst
```
- This should result in output ```Verified OK```, now ```Firmware.tmp2``` contains the encrypted data.

#### Encrypted Firmware data
When removing the SHA512 header and signature from the firmware image, you get the encrypted firmware image wich starts with a header again.
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x10         | Header for AES-CBC decryption of the image, details [below](#aes-cbc-decryption-header).
| 0x00000010       | 0x20         | IV for AES-CBC decryption as ASCII string.
| 0x00000030       | 0x01         | Constant 0x0A (LF)
| 0x00000031       | 0x08         | ASCII "Salted___" without trailing \0
| 0x00000039       | 0x08         | The salt for the firmware decryption.
| 0x00000041       | variable     | The encrypted data.

Example script for decryption:
- Extract IV from image:
```
dd if=Firmware.tmp2 of=Firmware.tmp3.IV bs=1 skip=16 count=33
IV_STRING=$(cat Firmware.tmp3.IV)
```
- Extract encrypted data from image:
```
dd if=Firmware.tmp2 iflag=skip_bytes of=Firmware.tmp3.enc bs=1M skip=49
```

- Decrypt data:
```
openssl aes-128-cbc -d -md sha256 -in Firmware.tmp3.enc -out Firmware.tmp4 -kfile=Key.firmware -iv $IV_STRING
```
- Now ```Firmware.tmp4``` contains the decrypted data.

##### Signed Recovery Image
After decrypting the firmware image, a "Signed Recovery Image" is left. Like in the overall firmware image, there is a SHA512 header in the beginning and a signature in the end.
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x10         | Header for SHA512 verification of the image, details [below](#sha512-verification-header).
| 0x00000010       | variable     | Encrypted firmware data
| variable         | 0x100        | The signature for the SHA512 verification.

Example script for verification:
- Remove the SHA512 verification header from the image:
```
dd if=Firmware.tmp4 iflag=skip_bytes of=Firmware.tmp5 bs=1M skip=16
```
- Extract the SHA512 signature from the image:
```
dd if=Firmware.tmp5 of=Firmware.tmp5.sig bs=1 count=256 skip=$(( $(stat -c %s Firmware.tmp5) - 256))
```
- Remove the SHA512 signature from the image:
```
dd if=Firmware.tmp5 iflag=count_bytes of=Firmware.tmp6 bs=1M count=$(( $(stat -c %s Firmware.tmp5) - 256))
```
- Create digest for verification:
```
openssl dgst -sha512 -binary -out Firmware.tmp6.dgst Firmware.tmp6
```
- Verify image:
```
openssl dgst -verify Key.pub -sha512 -binary -signature Firmware.tmp5.sig Firmware.tmp6.dgst
```
- This should result in output ```Verified OK```, now ```Firmware.tmp6``` contains the recovery image.

##### Recovery Image
After removing the signature data, a "Recovery Image" is left. It's an image which can be flashed via the recovery web interface. The recovery image consists of one or more partitions where every partition starts with a header followed by the partition data.
| Address (hex)    | Length (hex) | Data
|------------------|--------------|-----------------------------------------------------------------
| 0x00000000       | 0x50         | Partition header, see [below](#partition-header)
| 0x00000050       | variable     | Partition data
| variable         | 0x50         | Partition header, see [below](#partition-header)
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
| 0x0000004E       | 0x02         | Header checksum. It must be set to that the sum of all words in the firware equals 0xFFFF. An overflow will increase the  checksum by 1.
 
