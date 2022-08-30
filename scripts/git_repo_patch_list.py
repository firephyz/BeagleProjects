#!/bin/python

import subprocess as sp
import os
import sys
import re

def get_patch_list(git_repo_dir, git_end_tag):    
    os.chdir(git_repo_dir)
    
    def get_end_commit():
        proc = sp.run(['bash', '-c', 'git log --oneline v2022.07 | head -n 1'], capture_output=True)
        return re.findall('([^ ]+).*', proc.stdout.decode('ascii'))[0]
    
    # Read out each line, stop when we reach the desired tag
    recent_commits_sed_string = '{{:loop0; /{}/b loop1; p; n; b loop0}}; :loop1; p; q'.format(get_end_commit())
    # Read git log output according to recent commits sed string
    git_log_cmd = 'git log --graph --oneline | sed -n \'{}\''.format(recent_commits_sed_string)
    
    def get_git_log_commits():
        proc = sp.run(['bash', '-c', git_log_cmd], capture_output=True)
        return proc.stdout.decode('ascii')
    
    def get_git_commit_date(commit):
        proc = sp.run(['bash', '-c', 'git log | sed -nr \'{{:loop0;/{}/b loop1;n;b loop0}};:loop1;n;n;s/Date\:[ ]+//p;q\''.format(commit)], capture_output=True)
        return proc.stdout.decode('ascii')
    
    # Get git log output
    log_output = get_git_log_commits()
    commits = list(map(lambda l: re.findall('([0-9a-f]+)[ ]+(.*)', l)[0], re.split('\n', log_output)[:-1]))
    
    for ((commit,comment),(next_commit,_a)) in zip(commits,commits[1:]):
        proc = sp.run(['bash', '-c', 'git diff -p {} {}'.format(commit, next_commit)], capture_output=True)
        proc_stdout = proc.stdout.decode('ascii')
        print('COMMENT: {}'.format(comment))
        print('DATE: {}'.format(get_git_commit_date(commit)))
        print(proc_stdout)

def apply_patch_list(git_repo_dir, patch_filename):
    patch = open(patch_filename, 'r').read()

    os.chdir(git_repo_dir)

    patches = re.findall('COMMENT: (.*)\nDATE: (.*)\n\n(((?!COMMENT)(.|\n))*)', patch)
    for i,p in enumerate(patches):
        print('Applying patch {}: {}'.format(i+1,p[0]))
        sys.stdin.readline()

    #print(a)

        
if sys.argv[1] == 'get':
    get_patch_list(*sys.argv[2:])
elif sys.argv[1] == 'apply':
    apply_patch_list(*sys.argv[2:])
else:
    print('Unknown function \'{}\''.format(sys.argv[1]))
    sys.exit(1)
