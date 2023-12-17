#!/bin/bash
# Usage: ExtractFirmware.sh <Firmware.bin>
# <Firmware.bin> is the file name of the firmware downloaded from D-Link

# Remove the SHA512 verification header from the original firmware file
dd if=${1} iflag=skip_bytes of=Firmware.tmp1 bs=1M skip=16

# Extract the SHA512 signature from the firmware
dd if=Firmware.tmp1 of=Firmware.tmp1.sig bs=1 count=256 skip=$(( $(stat -c %s Firmware.tmp1) - 256))

# Remove the SHA512 signature from the firmware
dd if=Firmware.tmp1 iflag=count_bytes of=Firmware.tmp2 bs=1M count=$(( $(stat -c %s Firmware.tmp1) - 256))

# Create digest for verification
openssl dgst -sha512 -binary -out Firmware.tmp2.dgst Firmware.tmp2

# Verify image
openssl dgst -verify Key.pub -sha512 -binary -signature Firmware.tmp1.sig Firmware.tmp2.dgst



# Extract IV from image
dd if=Firmware.tmp2 of=Firmware.tmp3.IV bs=1 skip=16 count=33
IV_STRING=$(cat Firmware.tmp3.IV)

# Extract encrypted data from image
dd if=Firmware.tmp2 iflag=skip_bytes of=Firmware.tmp3.enc bs=1M skip=49

# Decrypt data
openssl aes-128-cbc -d -md sha256 -in Firmware.tmp3.enc -out Firmware.tmp4 -kfile=Key.firmware -iv $IV_STRING


# Remove the SHA512 verification header from the image
dd if=Firmware.tmp4 iflag=skip_bytes of=Firmware.tmp5 bs=1M skip=16

# Extract the SHA512 signature from the image
dd if=Firmware.tmp5 of=Firmware.tmp5.sig bs=1 count=256 skip=$(( $(stat -c %s Firmware.tmp5) - 256))

# Remove the SHA512 signature from the image
dd if=Firmware.tmp5 iflag=count_bytes of=Firmware.tmp6 bs=1M count=$(( $(stat -c %s Firmware.tmp5) - 256))

# Create digest for verification
openssl dgst -sha512 -binary -out Firmware.tmp6.dgst Firmware.tmp6

# Verify image
openssl dgst -verify Key.pub -sha512 -binary -signature Firmware.tmp5.sig Firmware.tmp6.dgst

