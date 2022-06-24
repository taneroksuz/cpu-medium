#!/usr/bin/env python3

import binascii
import sys
import subprocess
import os
from os.path import basename


if __name__ == '__main__':

    if len(sys.argv) < 5:
        print('Expected usage: {0} <filename> <start_address> <offset> <path>'.format(sys.argv[0]))
        sys.exit(1)

    filename = sys.argv[1]
    bin_file = '{0}/elf/{1}.bin'.format(sys.argv[4],os.path.splitext(basename(sys.argv[1]))[0])
    coe_file = '{0}/coe/{1}.coe'.format(sys.argv[4],os.path.splitext(basename(sys.argv[1]))[0])
    start_address = int(sys.argv[2],16)
    offset = int(sys.argv[3],16)

    print(coe_file)

    with open(bin_file, 'rb') as f:
        content = f.read()

    output = open(coe_file, 'wb')

    lines = len(content)

    output.write("memory_initialization_radix=16;\n".encode('ascii'))
    output.write("memory_initialization_vector=\n".encode('ascii'))

    address = 0
    while address < offset:
        if address < start_address:
            string0 = "00"
            string1 = "00"
            string2 = "00"
            string3 = "00"
        elif address-start_address < lines:
            if (address-start_address+3) < lines:
                string0 = "{:02X}".format(content[address-start_address+3])
            else:
                string0 = "00"
            if (address-start_address+2) < lines:
                string1 = "{:02X}".format(content[address-start_address+2])
            else:
                string1 = "00"
            if (address-start_address+1) < lines:
                string2 = "{:02X}".format(content[address-start_address+1])
            else:
                string2 = "00"
            if (address-start_address) < lines:
                string3 = "{:02X}".format(content[address-start_address])
            else:
                string3 = "00"
        else:
            string0 = "00"
            string1 = "00"
            string2 = "00"
            string3 = "00"
        if address<(offset-4):
            string = string0 + string1 + string2 + string3 + ",\n"
        else:
            string = string0 + string1 + string2 + string3 + ";"
        output.write(string.encode('ascii'))
        address = address + 4

    output.close()
