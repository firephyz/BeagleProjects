#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Mar 27 19:19:02 2022

@author: kyle
"""

import subprocess
import re
import sys

#sys.argv = [sys.argv[0]] + ['name','pei','-showinvalid','-namesonly']


script_mode = sys.argv[1]
used_args = [0,1]
if script_mode in ['name', 'libs']:
    target_module = sys.argv[2]
    used_args += [2]

names_only = False
show_invalid = False
print_mode = 'all'

remaining_flags = list(map(lambda x: x[1], filter(lambda x: x[0] not in used_args, enumerate(sys.argv))))
if '-namesonly' in remaining_flags:
    names_only = True
if '-showinvalid' in remaining_flags:
    show_invalid = True
if '-exact' in remaining_flags:
    print_mode = 'exact' if print_mode == 'all' else 'all'
if '-partial' in remaining_flags:
    print_mode = 'partial' if print_mode == 'all' else 'all'




def inf_identifer_string(inf):
    if inf['type'] == 'library':
        return '{} ({})'.format('{}'.format(inf['BASE_NAME']), inf['LIBRARY_CLASS']['name'])
    elif inf['type'] == 'component':
        return '{}'.format(inf['BASE_NAME'])
    else:
        raise Exception('Unknown inf type')

def inf_match_extra_data(inf):
    if inf['type'] == 'library':
        extra_data_string = 'N/A' if len(inf['LIBRARY_CLASS']['types']) == 0 else ','.join(inf['LIBRARY_CLASS']['types'])
    elif inf['type'] == 'component':
        extra_data_string = ''
    else:
        raise Exception('Unknown inf type')

    if len(extra_data_string) != 0:
        return ' ├─ {}\n'.format(extra_data_string)
    else:
        return ''

def inf_match_to_string(inf, indent=0):
    if names_only:
        matches_string = '{0}'.format(inf_identifer_string(inf))
    else:
        matches_string = '{0}\n{3} └─ {1} | {2}'.format(inf_identifer_string(inf),
                                                inf['MODULE_TYPE'],
                                                inf['path'],
                                                inf_match_extra_data(inf))
    matches_string = '\n'.join(map(lambda line: ('  ' * indent) + line,
                                   re.split('\n', matches_string)))
    return matches_string

def print_matches(matches, header):
    if script_mode == 'libs':
        indent_level = 1
        print_sections = [('', matches)]
    elif script_mode == 'name':
        indent_level = 3
        print_sections = [('Components', filter(lambda x: x['type'] == 'component', matches)),
                          ('Libraries', filter(lambda x: x['type'] == 'library', matches))]
    else:
        raise Exception('Unknown script mode {}'.format(script_mode))

    print_section_strings = []
    for section_name, section_infs in print_sections:
        section_string = ''.join(map(lambda match: inf_match_to_string(match, indent_level) + '\n',
                                     section_infs))
        if len(section_name) != 0:
            section_header = '  {}:\n'.format(section_name)
        else:
            section_header = ''
        section_string = '{}{}'.format(section_header, section_string) if len(section_string) != 0 else ''
        print_section_strings += [section_string]

    match_string = '{} matches:\n{}'.format(header, ''.join(print_section_strings)) if len(''.join(print_section_strings)) != 0 else ''
    print(match_string, end='')


try:
    inf_data = open('/tmp/find_inf_filelist.txt').read()
    inf_files = re.split('/home/kyle/o/beagle/edk2/', inf_data)[1:]
except Exception:
    inf_search_cmd = 'for f in $(find /home/kyle/o/beagle/edk2 -regex \'.*\\.inf\' | grep -vE "edk2/Build/"); do\
                        echo $f;\
                        cat $f | sed -nr \':b0;/^\\[Defines\\]/b b1;n;b b0;:b1;n;/^\\[/!{/^[ ]*(BASE_NAME|MODULE_TYPE|LIBRARY_CLASS)/p;b b1;};q\';\
                      done'
    inf_data = subprocess.check_output(inf_search_cmd, shell=True, text=True)
    inf_file = open('/tmp/find_inf_filelist.txt', 'w+')
    inf_file.write(inf_data)
    inf_file.close()
    inf_files = re.split('/home/kyle/o/beagle/edk2/', inf_data)[1:]

for i,inf in enumerate(inf_files):
    lines = re.split('\n', inf)[:-1]
    inf_path = lines[0]
    if len(lines) <= 2:
        print('Invalid inf found. Too few lines. {}'.format(inf))
    attributes = list(map(lambda line: re.findall('[ ]*([^ ]+)[ ]*=[ ]*(.*?)[ ]*$', line)[0], lines[1:]))
    inf_type = 'library' if 'LIBRARY_CLASS' in map(lambda x: x[0], attributes) else 'component'
    inf_files[i] = {'path': inf_path, 'attrs': attributes, 'type': inf_type}
    inf_files[i] = dict(list(inf_files[i].items()) + attributes)

    # Check for invalid entries
    # Libs with an unusual number of LIBRARY_CLASS entries
    if inf_files[i]['type'] == 'library' and len(list(filter(lambda attr: attr[0] == 'LIBRARY_CLASS', inf_files[i]['attrs']))) != 1:
        inf_files[i]['invalid'] = True
    else:
        inf_files[i]['invalid'] = False

    if 'LIBRARY_CLASS' in inf_files[i].keys():
        try:
            match = re.findall('([^|]+)(\|(.*)){0,1}', inf_files[i]['LIBRARY_CLASS'])[0]
            name, modes = (match[0], [] if len(match[2]) == 0 else re.split(' ', match[2].strip()))
        except IndexError:
            pass
        inf_files[i]['LIBRARY_CLASS'] = {'name': name, 'types': modes}

type_sort_map = dict([(j,i) for i,j in enumerate(['component', 'library'])])
module_efi_mode_map = dict([(j,i) for i,j in enumerate(['BASE','SEC','PEI_CORE','PEIM',
                                                        'DXE_CORE','DXE_DRIVER','DXE_RUNTIME_DRIVER',
                                                        'UEFI_APPLICATION','UEFI_DRIVER','HOST_APPLICATION',
                                                        'MM_CORE_STANDALONE','MM_STANDALONE',
                                                        'SMM_CORE','DXE_SMM_DRIVER',
                                                        'USER_DEFINED'])])
inf_files.sort(key=lambda inf: (type_sort_map[inf['type']], module_efi_mode_map[inf['MODULE_TYPE']], inf['path']))

# Determine inf matches from query
if script_mode == 'libs':
    matches = list(filter(lambda lib: re.match('.*{}.*'.format(target_module.lower()),
                                               lib['LIBRARY_CLASS']['name'].lower()),
                          filter(lambda inf: inf['type'] == 'library', inf_files)))
    exact_matches = list(filter(lambda lib: lib['LIBRARY_CLASS']['name'] == target_module, matches))
elif script_mode == 'name':
    matches = list(filter(lambda lib: re.match('.*{}.*'.format(target_module.lower()),
                                               lib['BASE_NAME'].lower()),
                          inf_files))
    exact_matches = list(filter(lambda lib: lib['BASE_NAME'] == target_module, matches))
else:
    print('Unknown script mode \'{}\'.'.format(script_mode))
    sys.exit(1)

invalid_matches = list(filter(lambda x: x['invalid'], matches))
matches = list(filter(lambda x: not x['invalid'], matches))
exact_invalid_matches = list(filter(lambda x: x['invalid'], exact_matches))
exact_matches = list(filter(lambda x: not x['invalid'], exact_matches))

# Print matches
if print_mode in ['all', 'partial']:
    print_matches(matches, 'Partial')
if print_mode in ['all', 'exact']:
    print_matches(exact_matches, 'Exact')

# Print invalid matches if applicable
if show_invalid:
    print_matches(invalid_matches, 'Invalid')
    print_matches(exact_invalid_matches, 'Exact Invalid')
