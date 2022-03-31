#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 29 19:21:27 2022

@author: kyle
"""

import sys
import os
import re
import itertools as it
import functools as ft
import subprocess
import progressbar

# filename = sys.argv[1]
filename = '/home/kyle/o/beagle/layout'
#top_modules = ['PeiMain', 'DxeMain', 'MemoryInitPeim', 'Bootloader']
aliasing_modules = [['DxeCoreMemoryAllocationLib','PeiMemoryAllocationLib'],
                    ['DxeCoreHobLib','PeiHobLib'],
                    ['PeiMain', 'DxeMain', 'MemoryInitPeim', 'Bootloader'],
                    ['DxeCoreEntryPoint', 'PeimEntryPoint', 'PeiCoreEntryPoint', 'Bootloader']]
targets_of_aliases = ['DxeCoreMemoryAllocationLib',
                      'DxeCoreHobLib',
                      'DxeMain',
                      'DxeCoreEntryPoint']
# targets_of_aliases = ['PeiMemoryAllocationLib',
#                       'PeiHobLib',
#                       'PeiMain',
#                       'PeiCoreEntryPoint']
target_efi = 'DxeCore.efi'
#target_efi = 'PeiCore.efi'



def aliasing_match_test(section, match_modules):
    match_module_names = list(map(lambda x: x['module'], match_modules))
    try:
        # Determine which alias group best matches this matched module set
        alias_count_pairs = list(map(lambda group: (len(list(filter(lambda match: match['module'] in group, match_modules))),
                                                        len(list(filter(lambda match: match['module'] not in group, match_modules)))),
                                         aliasing_modules))
        # Filter out alias groups that don't entirely cover the matched modules seen
        covering_count_pairs = list(filter(lambda pair: pair[1][1] == 0, enumerate(alias_count_pairs)))
        if len(covering_count_pairs) == 0:
            print('Multiple match top-level-module test failed: Some match modules aren\'t contained in any alias groups: {}'.format(match_module_names))
            raise Exception('TopModuleFailed')
        # Pick the alias group with the most coverage over our matched modules
        alias_match_index = ft.reduce(lambda acc,pair: pair if pair[1][0] > acc else acc, covering_count_pairs, -1)[0]
        if alias_match_index == -1:
            print('Multiple match top-level-module test failed: No alias groups cover any of the match modules found: {}'.format(match_module_names))
            raise Exception('TopModuleFailed')
        if len(list(filter(lambda pair: pair[1][0] == alias_count_pairs[alias_match_index][0], covering_count_pairs))) != 1:
            print('Multiple match top-level-module test failed: Multiple equivalent match groups found for match set {}'.format(match_module_names))
            raise Exception('TopModuleFailed')
        alias_group = aliasing_modules[alias_match_index]
        alias_target = targets_of_aliases[alias_match_index]

        target_match = list(filter(lambda match: match['module'] == alias_target, match_modules))
        return [target_match[0]]
    except StopIteration:
        return match_modules
    except Exception as e:
        if e.args[0] == 'TopModuleFailed':
            return match_modules




map_file = re.split('\n', open(filename, 'r').read())
map_file = list(filter(lambda line: not re.match('^[ ]*$', line), map_file))

sections = []
for i,line in enumerate(map_file):
    fill_re = '^[ ]*\*fill\*[ ]+0x([0-9a-z]+)[ ]+0x([0-9a-z]+)[ ]+'
    contents_re = '( ){16}0x([0-9a-z]+)[ ]+0x([0-9a-z]+)[ ]+([^ ]*)'
    section_re = '[ ]*(\.[^ ]+)([ ]*0x([0-9a-z]+)[ ]+0x([0-9a-z]+)){0,1}([ ]*(.*)){0,1}'
    script_re = '( ){16}0x([0-9a-z]+)[ ]+(?!0x)(.*)'
    discarded_res = ['[ ]+0x[0-9a-z]+[ ]+\(size before relaxing\)']
    if re.match(fill_re, line):
        match = re.findall(fill_re, line)[0]
        map_file[i] = {'type': 'fill', 'loc': int(match[0], base=16), 'size': int(match[1], base=16)}
    elif re.match(contents_re, line):
        match = re.findall(contents_re, line)[0]
        map_file[i] = {'type': 'contents',
                       'loc': int(match[1], base=16),
                       'size': int(match[2], base=16),
                       'obj_path': match[3]}
    elif re.match(section_re, line):
        match = re.findall(section_re, line)[0]
        if len(match[1]) == 0:
            misc_data = None
        else:
            misc_data = {'loc': int(match[2], base=16),
                         'size': int(match[3], base=16),
                         'obj_path': match[5]}
        section_name_match = re.findall('\.([^\.]+)(\.(.*)){0,1}', match[0])[0]
        subsec, sec_name = section_name_match[0], section_name_match[2]
        if len(sec_name) == 0:
            sec_name = subsec
            subsec = ''
        # Handle rodata lto string special case
        if subsec == 'rodata':
            if re.match('(.*?)\.str[0-9a-z]+\..*', sec_name):
                sec_name = re.findall('(.*?)\.str[0-9a-z]+\..*', sec_name)[0]
        map_file[i] = {'type': 'section',
                       'section': sec_name,
                       'section_type': subsec,
                       'name': match[0],
                       'misc': misc_data}
        # Handle other lto special cases
        if re.match('(.*)\.(constprop|isra)', sec_name):
            tmp = sec_name
            sec_name = re.findall('(.*)\.(constprop|isra).*', sec_name)[0][0]
            map_file[i]['section'] = sec_name
            print('{:<40} -> {}'.format(tmp, sec_name))
        sections += [line]
    elif re.match(script_re, line):
        match = re.findall(script_re, line)[0]
        map_file[i] = {'type': 'script',
                       'loc': int(match[1], base=16),
                       'script': match[2].strip()}
    elif ft.reduce(lambda acc,regex: acc or re.match(regex, line), discarded_res, False):
        print('Discarding \'{}\'.'.format(line))
        map_file[i] = ''
    # Must be an inline script if nothing else
    else:
        map_file[i] = {'type': 'inline_script',
                       'script': line.strip()}

# Remove empty lines
map_file = list(filter(lambda line: type(line) is not str or len(line) != 0, map_file))

new_map_file = []
# Process all sections with a contents inlined and separate them into a separate line
for line in map_file:
    new_map_file += [line]
    if line['type'] == 'section':
        contents = line.pop('misc')
        if contents is not None:
            contents['type'] = 'contents'
            new_map_file += [contents]
map_file = new_map_file

section_delims = ['section', 'inline_script', 'script', 'fill']
delim_points = list(map(lambda x: x[0], filter(lambda x: x[1]['type'] in section_delims, enumerate(map_file))))
# Take only the first delimiters that occur AFTER the first section
delim_points = list(filter(lambda delim: delim >= next(filter(lambda line: line[1]['type'] == 'section',
                                                              enumerate(map_file)))[0],
                           delim_points))
#section_content_ranges = zip(delim_points, delim_points[1:] + [len(map_file)])
section_starts = list(map(lambda x: x[0], filter(lambda line: line[1]['type'] == 'section', enumerate(map_file))))
# TODO make sure the last section_start index gets paired with a delimiter, we might need
  # to manufacture one with the last index of the map_file.
section_ends = list(map(lambda start: next(filter(lambda content_delim: content_delim > start, delim_points)),
                        progressbar.progressbar(section_starts)))
section_content_ranges = list(zip(section_starts, section_ends))

test = map_file[:]

# Collapse all section contents into their respective sections
new_map_file = []
for (start,end),last_end in list(zip(section_content_ranges, [0] + list(map(lambda pair: pair[1], section_content_ranges[:-1])))):
    new_map_file += map_file[last_end:start]
    section = map_file[start]
    section['parts'] = map_file[start+1:end]
    contents = list(filter(lambda x: x['type'] == 'contents', section['parts']))
    if len(contents) > 1:
        print('Invalid number of contents for section {}'.format(section['section']))
    section['contents'] = contents[0] if len(contents) > 0 else []
    new_map_file += [section]
new_map_file += map_file[section_content_ranges[-1][1]:]
map_file = new_map_file

map_file = list(filter(lambda x: x != [], map_file))





# Get list of obj sections
#get_section_cmd = 'for f in $(find edk2/Build/BeagleBone/DEBUG_GCC5/ARM/ -regex \'.*obj$\'); do echo $f; /home/builder/rpmbuild/BUILDROOT/root/bin/arm-none-eabi-objdump -D $f | grep section | grep -vE "debug_(info|abbrev|line|str)|\\.lto_(__FUNCTION_|\\.(inline|jmpfuncs|lto|symbol_nodes|refs|decls|symtab|ext_symtab|opts))|\\.comment|\\.ARM\\.attributes" | sed -r \'s/^/  /\'; done'
get_section_cmd = 'for f in $(find edk2/Build/BeagleBone/DEBUG_GCC5/ARM/ -regex \'.*obj$\'); do echo $f; /home/builder/rpmbuild/BUILDROOT/root/bin/arm-none-eabi-objdump -D $f | grep section | grep -vE "debug_(info|abbrev|line|str)|\\.comment|\\.ARM\\.attributes" | sed -r \'s/^/  /\'; done'
obj_section_text = subprocess.check_output(get_section_cmd, shell=True, text=True)
obj_sections = re.split('edk2/Build/BeagleBone/DEBUG_GCC5/ARM/', obj_section_text)
obj_sections = list(filter(lambda x: len(x) != 0, obj_sections))

#section_symbol_re_lto = '\.gnu\.lto_(?!(\.|__FUNCTION__))((.(?!part\.[0-9]+))+?)\.(?!part\.[0-9]+)[0-9]+\.[0-9a-z]+'
section_symbol_re_lto = '\.gnu\.lto_(?!(\.|__FUNCTION__))((.)+?)\.[0-9]+\.[0-9a-z]+'
section_symbol_re_general = '\.(?!gnu\.lto_)([^:]+)'
section_symbol_re = '.*of section ({}|{}):'.format(section_symbol_re_lto, section_symbol_re_general)
for i,sec in enumerate(obj_sections):
    lines = list(filter(lambda x: not re.match('^[ ]*$', x), re.split('\n', sec)))
    module, obj_name = re.findall('([^/]+)/OUTPUT/(.*)', lines[0])[0]
    symbols = list(map(lambda match: ''.join([match[0][2], match[0][4]]),
                       filter(lambda match: match != [],
                              map(lambda x: re.findall(section_symbol_re, x),
                                  lines[1:]))))
    obj_sections[i] = {'path': lines[0],
                       'module': module,
                       'obj': obj_name,
                       'symbols': symbols}
# Compress obj sections down into their respective EDK2 module instances
module_sections_dict = {}
for sec in obj_sections:
    if sec['module'] not in module_sections_dict:
        module_sections_dict[sec['module']] = []
    module_sections_dict[sec['module']] += [sec]
module_sections = []
for module_name,objs in list(module_sections_dict.items()):
    module_sections += [{'module': module_name,
                         'objs': objs,
                         'symbols': list(it.chain(*list(map(lambda obj: obj['symbols'], objs))))}]

# Get top-level EFI debug file info as well
get_debug_cmd = 'for f in $(find edk2/Build/BeagleBone/DEBUG_GCC5/ARM/ -maxdepth 1 -regex \'.*debug$\'); do echo $f; /home/builder/rpmbuild/BUILDROOT/root/bin/arm-none-eabi-readelf -W -s $f | tail -n +4 | sed -r \'s/^/  /\' | sed -r \'s/([ ]+[^ ]+){7}[ ]+//\' | grep -vE "^([^.]+\\.c.[0-9a-z]+|[^.]+\\.obj)$" | grep -vE "^[ ]*\\$"; done'
debug_symbol_text = subprocess.check_output(get_debug_cmd, shell=True, text=True)
efi_debug_syms = re.split('edk2/Build/BeagleBone/DEBUG_GCC5/ARM/', debug_symbol_text)
efi_debug_syms = list(filter(lambda x: len(x) != 0, efi_debug_syms))

for i,efi_debug in enumerate(efi_debug_syms):
    lines = list(filter(lambda x: not re.match('^[ ]*$', x), re.split('\n', efi_debug)))
    module = '{}.efi'.format(re.findall('(.*?)\.debug', lines[0])[0])
    efi_debug_syms[i] = {'path': lines[0],
                         'module': module,
                         'obj': None,
                         'symbols': lines[1:]}
efi_debug_syms = list(filter(lambda x: x['module'] == target_efi, efi_debug_syms))



# Compute size contributions for each module
module_sizes = {}
module_matches = {}
multiple_matches = []
no_matches = []
efi_matches = []
for section in filter(lambda x: x['type'] == 'section', progressbar.progressbar(map_file)):
    # Find modules with symbols matching this section name
    match_modules = []
    for module in module_sections:
        # TODO check for 'name' matches as well
        match_symbols = list(filter(lambda obj_section: section['section'] == obj_section,
                                    module['symbols']))
        if len(match_symbols) != 0:
            match_modules += [module]

    # Handle the 'text' section special case, these sections may be found across
    # multiple obj files and multiple modules so we have to locate exactly which module
    # we are refering to.
    if section['section'] == 'text':
        # Top level text doesn't belong to any submodule, just a top level efi file
        if section['contents']['obj_path'] == '':
            match_modules = []
        else:
            try:
                section_archive, section_obj_file = re.findall('/([^\(/]+)\((.*)\)', section['contents']['obj_path'])[0]
                if section_archive in ['libgcc.a']:
                    match_modules = []
                else:
                    sec_module_name = re.findall('(.*?)\.lib', section_archive)[0]
                    match_modules = list(filter(lambda mod: mod['module'] == sec_module_name, match_modules))
            except IndexError:
                print('hi')

    # Check in efi_debug_symbols if no matches found in obj files
    if len(match_modules) == 0:
        match_modules = list(filter(lambda obj: len(list(filter(lambda obj_section:
                                                                section['section'] == obj_section,
                                                                obj['symbols']))) != 0,
                                    efi_debug_syms))
        if len(match_modules) == 0:
            print('No match found for {}'.format(section['name']))
            no_matches += [section]
            continue
        else:
            efi_matches += [section]

    # Check more multiple module matches
    if len(match_modules) != 1:
        # Consider the special case of matching only multiple top level modules
        match_modules = aliasing_match_test(section, match_modules)

        # Check for multiple matches even after special cases
        if len(match_modules) != 1:
            print('More than one match found for {}'.format(section['name']))
            multiple_matches += [(section, match_modules)]
            continue

    match = match_modules[0]

    if not match['module'] in module_sizes:
        module_sizes[match['module']] = 0
    module_sizes[match['module']] += section['contents']['size']
    if not match['module'] in module_matches:
        module_matches[match['module']] = []
    module_matches[match['module']] += [section]

a = list(module_sizes.items())
a.sort(key=lambda x: x[1], reverse=True)
print('\n'.join(map(lambda x: '{:<7} {}'.format(x[1], x[0]), a)))

# def print_sorted(x, key, ident, count=None):
#     if count is None: count = len(x)
#     a = x
#     a.sort(key=key, reverse=True)
#     m = max(map(lambda x: key(x), a))
#     print('\n'.join(map(lambda x: '{{:<{}}} {{}}'.format(len('{}'.format(m))+1).format(key(x), ident(x)), a[:count])))
# print_sorted(module_matches['DxeMain'], key=lambda x: x['contents']['size'], ident=lambda x: x['section'], count=50)

az = {}
for count,mult in map(lambda x: (len(x[1]), x), multiple_matches):
    if count not in az:
        az[count] = []
    az[count] += [mult]

pass
