#!/usr/bin/env python3

import sys
import time
import serial


if __name__ == '__main__':

    if len(sys.argv) < 4:
        print('Expected usage: {0} <port> <filename> <size>'.format(sys.argv[0]))
        sys.exit(1)

    fb = open(sys.argv[2], 'rb')
    ba = bytearray(fb.read())
    size = int(sys.argv[3], 16)

    ser = serial.Serial(
        port=sys.argv[1],
        baudrate=115200,
        parity='N',
        stopbits=1,
        bytesize=8,
        timeout=120,
        xonxoff=0,
        rtscts=0
    )

    if ser.isOpen():
        ser.close()

    ser.open()
    ser.isOpen()

    ser.write(ba[0:size])

    while(1):
        line = ser.readline()
        if line == b'':
            break
        print(line.decode("ascii"))

    ser.close()

    sys.exit(0)