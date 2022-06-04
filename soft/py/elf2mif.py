#!/usr/bin/env python

import binascii
import sys
import subprocess
import os
from os.path import basename


def getHex(offset):
    i = 1
    bits = 0
    while i<offset:
        i = i << 1;
        bits = bits + 1
    hex = 1
    while bits >= 0:
        bits = bits - 4
        hex = hex + 1
    return hex


def getCheckSum(string_check):
    sum = 0
    for i in range(0,len(string_check),2):
        sum = sum + int(string_check[i:i+2],16)
    checksum = 256 - sum % 256
    return "{0:02X}".format(checksum % 256)


if __name__ == '__main__':

    if len(sys.argv) < 5:
        print('Expected usage: {0} <filename> <start_address> <offset> <path>'.format(sys.argv[0]))
        sys.exit(1)

    filename = sys.argv[1]
    bin_file = '{0}/elf/{1}.bin'.format(sys.argv[4],os.path.splitext(basename(sys.argv[1]))[0])
    mif_file = '{0}/mif/{1}.mif'.format(sys.argv[4],os.path.splitext(basename(sys.argv[1]))[0])
    start_address = int(sys.argv[2],16)
    offset = int(sys.argv[3],16)

    print(mif_file)

    with open(bin_file, 'rb') as f:
        content = f.read()

    output = open(mif_file, 'wb')

    lines = len(content)

    output.writelines("DEPTH = {:d};\n".format(offset/4))
    output.writelines("WIDTH = 32;\n")
    output.writelines("ADDRESS_RADIX = HEX;\n")
    output.writelines("string_RADIX = HEX;\n")
    output.writelines("CONTENT;\n")
    output.writelines("BEGIN\n")

    total_lines = offset

    byte = "04"

    string = "00"

    address = 0
    while address < total_lines:
        byte_addr = "{0:04X}".format(address>>2)
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
        w_line = byte_addr + " : " + string0 + string1 + string2 + string3 + ";\n"
        output.writelines(w_line)
        address = address + 4
