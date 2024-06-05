#!/usr/bin/env python3

import re
import os
import argparse

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Compare register files.')
    parser.add_argument('--src_txt',required=True,help='source of compared register file')
    parser.add_argument('--dst_txt',required=True,help='destination of compared register file')

    args = parser.parse_args()

    src_txt = open(args.src_txt, "r")
    dst_txt = open(args.dst_txt, "r")


    src_list = []

    for src_line in src_txt:
        src_num = re.findall(r'[0-9a-f]+', src_line)
        src_pc = src_num[1]
        src_waddr = src_num[2]
        src_wdata = src_num[3]
        src_list.append([src_pc,src_waddr,src_wdata])

    #print(src_list)
    #exit(0)

    dst_list = []

    for dst_line in dst_txt:
        dst_num = re.findall(r'[0-9a-f]+', dst_line)
        dst_period = dst_num[0]
        dst_pc = dst_num[1]
        dst_waddr = dst_num[2]
        dst_wdata = dst_num[3]
        dst_list.append([dst_period,dst_pc,dst_waddr,dst_wdata])

    #print(dst_list)
    #exit(0)

    i = 0

    if os.path.isfile("difference.txt"):
        os.remove("difference.txt")

    f = open("difference.txt", "w")

    for i in range(len(dst_list)):
        if (dst_list[i][1] != src_list[i][0] or dst_list[i][2] != src_list[i][1] or dst_list[i][3] != src_list[i][2]):
            f.writelines("Difference at "+str(dst_list[i][0]).rjust(10)+" \tpc = "+("%08X" % int(dst_list[i][1],16))+": \twaddr = "+("%02X" % int(dst_list[i][2],16))+" \twdata = "+("%08X" % int(dst_list[i][3],16))+"\n")
        i += 1

    f.close()

    exit(0)