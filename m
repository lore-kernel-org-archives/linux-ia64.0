From: chas williams <chas@cmf.nrl.navy.mil>
Date: Tue, 03 Jul 2001 13:45:56 +0000
Subject: [Linux-ia64] patching sys_call_table from a module
Message-Id: <marc-linux-ia64-105590693005808@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

afs patches the sys_call_table to provide support for various functions.
the existing doesnt seem to work right.  i figured out that the ia64
calls are offset by 1024.  but know i have a different problem:

during insmod i printk what i patch the table with:

sys_call_table[__NR_afs_syscall - 1024] = a000000000125bd0
afs_syscall a000000000125bd0

however, i get the following ksymoops when i try to use that syscall:

>>IP;  a000000000125bd1 <[libafs-2.4.5].bss.end+7e32/3fffffffffee2261>   <==>>b0;  e000000004415ce0 <ia64_ret_from_syscall+0/20>
>>b6;  e000000004402f60 <demine_args+0/a0>
>>b7;  e0000000044157b0 <ia64_switch_to+b0/120>
Trace; e00000000441a080 <show_stack+40/c0>
Trace; e00000000441a840 <show_regs+740/780>
Trace; e00000000442b830 <die_if_kernel+70/140>
Trace; e00000000442c510 <ia64_illegal_op_fault+130/220>
Trace; e000000004403ed0 <dispatch_illegal_op_fault+2b0/400>

so yes, a000000000125bd0 does seem to be [libafs-2.4.5].bss.end+7e32
however, if i look at the loadmap from the insmod, i see:

a0000000000f59e0 T afs_syscall

would this have anything to do with -mconstant-gp?

