#!/usr/bin/python3

import re
import argparse

def bin2mem(ihexfile):
    ohexfile = re.sub('.hex$', '.mem', ihexfile)

    IFILE = open(ihexfile, "r")
    OFILE = open(ohexfile, "w")

    proglines = IFILE.readlines();


    inst = ""
    i = 3
    for line in proglines:
        if(line[0] == '@'):
            OFILE.write(line)
            continue
        for word in line.split():
            i -= 1
            inst = word + inst
            if i == -1:
                OFILE.write(inst+"\n")
                inst=""
                i = 3


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='RISCV Binary to SystemVerilog Memory Converter')
    parser.add_argument('--bin', default=None, help="--bin <file.bin> Specify binary file to be processed")

    args = parser.parse_args()

    bin2mem(args.bin)