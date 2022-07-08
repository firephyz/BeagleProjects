import re
import lldb
cmds='type format add -f hex "unsigned int"\n      display $r2\n      display $r3\n      display $pc\n'
for c in re.split('\n', cmds):
	lldb.debugger.HandleCommand(c)
