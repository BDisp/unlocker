#!/usr/bin/env python
"""
The MIT License (MIT)

Copyright (c) 2014-2016 Dave Parsons

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

vSMC Header Structure
Offset  Length  Struct Type Description
----------------------------------------
0x00/00 0x08/08 Q      ptr  Offset to key table
0x08/08 0x04/4  I      int  Number of private keys
0x0C/12 0x04/4  I      int  Number of public keys

vSMC Key Data Structure
Offset  Length  Struct Type Description
----------------------------------------
0x00/00 0x04/04 4s     int  Key name (byte reversed e.g. #KEY is YEK#)
0x04/04 0x01/01 B      byte Length of returned data
0x05/05 0x04/04 4s     int  Data type (byte reversed e.g. ui32 is 23iu)
0x09/09 0x01/01 B      byte Flag R/W
0x0A/10 0x06/06 6x     byte Padding
0x10/16 0x08/08 Q      ptr  Internal VMware routine
0x18/24 0x30/48 48B    byte Data
"""

from __future__ import print_function
import struct
import sys

# Check minimal Python version is 3
if sys.version_info < (3, 0):
    sys.stderr.write('You need Python 3 or later\n')
    sys.exit(1)


def bytetohex(data):
    return "".join("{:02X} ".format(c) for c in data)


def printkey(i, offset, smc_key, smc_data):
    print(str(i + 1).zfill(3)
          + ' ' + hex(offset)
          + ' ' + smc_key[0][::-1].decode('UTF-8')
          + ' ' + str(smc_key[1]).zfill(2)
          + ' ' + smc_key[2][::-1].replace(b'\x00', b' ').decode('UTF-8')
          + ' ' + '{0:#0{1}x}'.format(smc_key[3], 4)
          + ' ' + hex(smc_key[4])
          + ' ' + bytetohex(smc_data))


def dumpkeys(f, key):
    # Setup struct pack string
    key_pack = '=4sB4sB6xQ'

    # Do Until OSK1 read
    i = 0
    while True:

        # Read key into struct str and data byte str
        offset = key + (i * 72)
        f.seek(offset)
        smc_key = struct.unpack(key_pack, f.read(24))
        smc_data = f.read(smc_key[1])

        # Dump entry
        printkey(i, offset, smc_key, smc_data)

        # Exit when OSK1 has been read
        if smc_key[0] == b'1KSO':
            break
        else:
            i += 1


def dumpsmc(name):

    with open(name, 'rb') as f:

        # Read file into variable
        vmx = f.read()

        print('File: ' + name)

        # Setup hex string for vSMC headers
        # These are the private and public key counts
        smc_header_v0 = b'\xF2\x00\x00\x00\xF0\x00\x00\x00'
        smc_header_v1 = b'\xB4\x01\x00\x00\xB0\x01\x00\x00'

        # Setup hex string for #KEY key
        key_key = b'\x59\x45\x4B\x23\x04\x32\x33\x69\x75'

        # Setup hex string for $Adr key
        adr_key = b'\x72\x64\x41\x24\x04\x32\x33\x69\x75'

        # Find the vSMC headers
        smc_header_v0_offset = vmx.find(smc_header_v0) - 8
        smc_header_v1_offset = vmx.find(smc_header_v1) - 8

        # Find '#KEY' keys
        smc_key0 = vmx.find(key_key)
        smc_key1 = vmx.rfind(key_key)

        # Find '$Adr' key only V1 table
        smc_adr = vmx.find(adr_key)

        # Print vSMC0 tables and keys
        print('appleSMCTableV0 (smc.version = "0")')
        print('appleSMCTableV0 Address      : ' + hex(smc_header_v0_offset))
        print('appleSMCTableV0 Private Key #: 0xF2/242')
        print('appleSMCTableV0 Public Key  #: 0xF0/240')

        if (smc_adr - smc_key0) != 72:
            print('appleSMCTableV0 Table        : ' + hex(smc_key0))
            dumpkeys(f, smc_key0)
        elif (smc_adr - smc_key1) != 72:
            print('appleSMCTableV0 Table        : ' + hex(smc_key1))
            dumpkeys(f, smc_key1)

        print()

        # Print vSMC1 tables and keys
        print('appleSMCTableV1 (smc.version = "1")')
        print('appleSMCTableV1 Address      : ' + hex(smc_header_v1_offset))
        print('appleSMCTableV1 Private Key #: 0x01B4/436')
        print('appleSMCTableV1 Public Key  #: 0x01B0/432')

        if (smc_adr - smc_key0) == 72:
            print('appleSMCTableV1 Table        : ' + hex(smc_key0))
            dumpkeys(f, smc_key0)
        elif (smc_adr - smc_key1) == 72:
            print('appleSMCTableV1 Table        : ' + hex(smc_key1))
            dumpkeys(f, smc_key1)

        # Tidy up
        f.close()


def main():
    print('dumpsmc')
    print('-------')

    if len(sys.argv) >= 2:
        vmx_path = sys.argv[1]
    else:
        print('Please pass file name!')
        return

    try:
        dumpsmc(vmx_path)
    except IOError:
        print('Cannot find file ' + vmx_path)


if __name__ == '__main__':
    main()
