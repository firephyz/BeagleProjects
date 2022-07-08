#!/bin/bash

cat >lldb_pyscripts.py <<EOF
import re
import lldb
cmds='type format add -f hex "unsigned int"\n\
      display \$r2\n\
      display \$r3\n\
      display \$pc\n'
for c in re.split('\n', cmds):
	lldb.debugger.HandleCommand(c)
EOF

cat >.lldbinit <<EOF
gdb-remote localhost:1234
process status
command script import lldb_pyscripts.py
command script add setup -f local_lldb_setup
EOF

lldb --source .lldbinit gpio.elf
