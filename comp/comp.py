#!/usr/bin/env python3

import os
import argparse
from vcdvcd import VCDVCD

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Compare vcd files.')
    parser.add_argument('--src_vcd',required=True,help='source of comapred vcd file')
    parser.add_argument('--dst_vcd',required=True,help='destination of comapred vcd file')

    args = parser.parse_args()

    src_vcd = VCDVCD(args.src_vcd)
    src_keys = src_vcd.references_to_ids.keys()

    #print(src_keys)

    src_wren = src_vcd['TOP.soc.cpu_comp.register_comp.register_win.wren[0:0]']
    src_waddr = src_vcd['TOP.soc.cpu_comp.register_comp.register_win.waddr[4:0]']
    src_wdata = src_vcd['TOP.soc.cpu_comp.register_comp.register_win.wdata[31:0]']

    del src_vcd

    #print(src_wren)
    #print(src_waddr)
    #print(src_wdata)

    dst_vcd = VCDVCD(args.dst_vcd)
    dst_keys = dst_vcd.references_to_ids.keys()

    #print(dst_keys)

    dst_wren0 = dst_vcd['TOP.soc.cpu_comp.register_comp.register0_win.wren[0:0]']
    dst_wren1 = dst_vcd['TOP.soc.cpu_comp.register_comp.register1_win.wren[0:0]']
    dst_waddr0 = dst_vcd['TOP.soc.cpu_comp.register_comp.register0_win.waddr[4:0]']
    dst_waddr1 = dst_vcd['TOP.soc.cpu_comp.register_comp.register1_win.waddr[4:0]']
    dst_wdata0 = dst_vcd['TOP.soc.cpu_comp.register_comp.register0_win.wdata[31:0]']
    dst_wdata1 = dst_vcd['TOP.soc.cpu_comp.register_comp.register1_win.wdata[31:0]']

    del dst_vcd

    #print(dst_wren0)
    #print(dst_wren1)
    #print(dst_waddr0)
    #print(dst_waddr1)
    #print(dst_wdata0)
    #print(dst_wdata1)

    src_list = []

    for i in range(0,src_wren.endtime,2):
        if src_wren[i] == '1' and src_waddr[i] != '00000':
            src_list.append([src_waddr[i],src_wdata[i]])

    #print(src_list)

    dst_list = {}

    for i in range(0,dst_wren0.endtime,2):
        element = []
        if dst_wren0[i] == '1' and dst_waddr0[i] != '00000':
            element.append([dst_waddr0[i],dst_wdata0[i]])
        if dst_wren1[i] == '1' and dst_waddr1[i] != '00000':
            element.append([dst_waddr1[i],dst_wdata1[i]])
        if len(element) > 0:
            dst_list[i] = element

    #print(dst_list)

    i = 0

    if os.path.isfile("difference.txt"):
        os.remove("difference.txt")

    f = open("difference.txt", "w")

    for key in dst_list:
        if len(dst_list[key]) == 1:
            if (dst_list[key][0][0] != src_list[i][0] or dst_list[key][0][1] != src_list[i][1]):
                f.writelines("Difference at "+str(key).rjust(10)+": \twaddr = "+str(int(dst_list[key][0][0],2)).rjust(2)+" \twdata = "+("0x%08X" % int(dst_list[key][0][1],2))+"\n")
            i += 1
        elif len(dst_list[key]) == 2:
            if (dst_list[key][0][0] != src_list[i][0] or dst_list[key][0][1] != src_list[i][1]):
                f.writelines("Difference at "+str(key).rjust(10)+": \twaddr = "+str(int(dst_list[key][0][0],2)).rjust(2)+" \twdata = "+("0x%08X" % int(dst_list[key][0][1],2))+"\n")
            i += 1
            if (dst_list[key][1][0] != src_list[i][0] or dst_list[key][1][1] != src_list[i][1]):
                f.writelines("Difference at "+str(key).rjust(10)+": \twaddr = "+str(int(dst_list[key][1][0],2)).rjust(2)+" \twdata = "+("0x%08X" % int(dst_list[key][1][1],2))+"\n")
            i += 1

    f.close()

    exit(0)