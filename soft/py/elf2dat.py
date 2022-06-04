#!/usr/bin/env python

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
    dat_file = '{0}/dat/{1}.dat'.format(sys.argv[4],os.path.splitext(basename(sys.argv[1]))[0])
    start_address = int(sys.argv[2],16)
    offset = int(sys.argv[3],16)

    print(dat_file)

    with open(bin_file, 'rb') as f:
        content = f.read()

    output = open(dat_file, 'wb')

    lines = len(content)

    address = 0
    while address < offset:
        if address < start_address:
            string0 = "00"
            string1 = "00"
            string2 = "00"
            string3 = "00"
        elif address-start_address < lines:
            if (address-start_address+3) < lines:
                string0 = str(binascii.hexlify(content[address-start_address+3])).upper()
            else:
                string0 = "00"
            if (address-start_address+2) < lines:
                string1 = str(binascii.hexlify(content[address-start_address+2])).upper()
            else:
                string1 = "00"
            if (address-start_address+1) < lines:
                string2 = str(binascii.hexlify(content[address-start_address+1])).upper()
            else:
                string2 = "00"
            if (address-start_address) < lines:
                string3 = str(binascii.hexlify(content[address-start_address])).upper()
            else:
                string3 = "00"
        else:
            string0 = "00"
            string1 = "00"
            string2 = "00"
            string3 = "00"
        string = string0 + string1 + string2 + string3
        if address<(offset-4):
            string = string + "\n"
        output.writelines(string)
        address = address + 4

    output.close()
