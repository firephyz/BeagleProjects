#!/bin/python3

import sys
import os
import math

beagle_root = os.getcwd() + '/..'

endians = {'little': -1, 'big': 1}
endian = 'little'

def gen_toc_header():
    convert_endian = lambda y: bytes('', 'ascii').join(map(lambda x: x[::endians[endian]], y))
    toc_struct_1 = [bytes.fromhex('00000040'),
                    bytes.fromhex('0000000C'),
                    bytes.fromhex('00' * 4 * 3),
                    bytes(('CHSETTINGS' + '\0' * (12-len('CHSETTINGS')))[::endians[endian]], 'ascii')]
    toc_struct_1 = convert_endian(toc_struct_1)
    toc_struct_2 = bytes.fromhex('FF'*0x20)
    magic = [bytes.fromhex('C0C0C0C1'),
             bytes.fromhex('00000100')]
    magic = convert_endian(magic)
    toc_start = toc_struct_1 + toc_struct_2 + magic
    toc_padding = bytes(512 - len(toc_start))
    return toc_start + toc_padding

flags_start = 2
config = {'raw_mode': False}

try:
    file = sys.argv[1]
except IndexError:
    print('No file provided.')
    exit(1)
    
try:
    dest = int(sys.argv[2], 16)
    flags_start = 3
except IndexError:
    dest = 0x402F0400

def do_raw_flag():
    config['raw_mode'] = True

flags = {'-raw': do_raw_flag}
for arg in sys.argv[flags_start:]:
    try:
        flags[arg]()
    except KeyError:
        print('Invalid flag \'{}\''.format(arg))
        exit(1)

binfile = open(file, 'rb').read()
filesize = len(binfile)

print('Size: {:8X}{:10}{}\nLoad Addr: {:8X}{:10}{}'.format(filesize, '', filesize, dest, '', dest))

outfilename = '{}/u-boot.img'.format(os.getcwd())
print('Writing to {}...'.format(outfilename))
int2bytes = lambda n: bytes.fromhex('{{:0{}x}}'.format(math.ceil(math.log2(n)/32)*8).format(n))[::endians[endian]]

sizebytes = int2bytes(filesize)
destbytes = int2bytes(dest)
payloadbytes = binfile
# open('{}/items/MLO.toc_header'.format(beagle_root), 'rb').read()
imagebytes = sizebytes + destbytes + payloadbytes
if config['raw_mode']:
    imagebytes = gen_toc_header() + imagebytes
padding = bytes(0x20000-len(imagebytes))

outfile = open(outfilename, 'wb+')
outfile.write(imagebytes + padding)
outfile.close()

# print('')
