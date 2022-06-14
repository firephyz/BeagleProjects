import re
import lldb
cmds='type format add -f hex "unsigned int"\n      display $r1\n      display $r2\n      display $r5\n      display $r12\n      target stop-hook add -o "expr -l C -- ((uint32_t *)(void (*)())swp_addr)[0]"'
#re.split('\n', cmds))
for c in re.split('\n', cmds):
	lldb.debugger.HandleCommand(c)
