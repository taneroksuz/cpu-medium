#!/usr/bin/env python3

import argparse
import subprocess
import os


def getHex(offset):
    i = 1
    bits = 0
    while i<offset:
        i = i << 1
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

    parser = argparse.ArgumentParser(description='Transform binary files.')
    parser.add_argument('--input',required=True,help='file name')
    parser.add_argument('--address',required=True,help='start address')
    parser.add_argument('--offset',required=True,help='offset')

    args = parser.parse_args()

    bin_file = '{0}.bin'.format(os.path.splitext(args.input)[0])
    hex_file = '{0}.hex'.format(os.path.splitext(args.input)[0])
    start_address = int(args.address,16)
    offset = int(args.offset,16)

    print(hex_file)

    with open(bin_file, 'rb') as f:
        content = f.read()

    output = open(hex_file, 'wb')

    lines = len(content)

    byte = "04"

    string = "00"

    address = 0
    while address < offset+4:
        byte_addr = "{0:04X}".format(address>>2)
        if address == offset:
            w_line = ":00000001FF\n"
        else:
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
            string_check = byte + byte_addr + string + string0 + string1 + string2 + string3
            checksum = getCheckSum(string_check)
            w_line = ":" + string_check + checksum + "\n";
        output.write(w_line.encode('ascii'))
        address = address + 4

    output.close()
