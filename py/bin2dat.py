#!/usr/bin/env python3

import argparse
import subprocess
import os


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Transform binary files.')
    parser.add_argument('--input',required=True,help='file name')
    parser.add_argument('--address',required=True,help='start address')
    parser.add_argument('--offset',required=True,help='offset')

    args = parser.parse_args()

    bin_file = '{0}.bin'.format(os.path.splitext(args.input)[0])
    dat_file = '{0}.dat'.format(os.path.splitext(args.input)[0])
    start_address = int(args.address,16)
    offset = int(args.offset,16)

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
        string = string0 + string1 + string2 + string3
        if address<(offset-4):
            string = string + "\n"
        output.write(string.encode('ascii'))
        address = address + 4

    output.close()
