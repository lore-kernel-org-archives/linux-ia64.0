From: Jay Lan <jlan@sgi.com>
Date: Thu, 02 Nov 2006 18:48:51 +0000
Subject: ia64: What the stack trace of a slave cpu kdump should save?
Message-Id: <454A3D93.8090006@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have a vmcore created by NMI on an SN. The gdb backtrace
showed the slave cpu as below:

# gdb vmlinux vmcore-nmi-10
GNU gdb 6.4
Copyright 2005 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain
conditions.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "ia64-suse-linux"...Using host libthread_db
library "/lib/libthread_db.so.1".

#0  crash_save_this_cpu () at arch/ia64/kernel/crash.c:57

warning: Source file is more recent than executable.
57              memcpy(buf, name, note->n_namesz);
(gdb) bt
#0  crash_save_this_cpu () at arch/ia64/kernel/crash.c:57
#1  0xa00000010005f580 in kdump_cpu_freeze (info=<value optimized out>,
    arg=0x1) at arch/ia64/kernel/crash.c:166
#2  0xa00000010000c9f0 in unw_init_running () at include/linux/bitmap.h:237
#3  0xa00000010005ef70 in kdump_init_notifier (self=0xa000000100b47d78,
    val=<value optimized out>, data=0xe000003007157b70)
    at arch/ia64/kernel/crash.c:217
#4  0xa0000001000cf0d0 in notifier_call_chain (nl=0xe000003014bcb3f8,
val,
    v=0xe000003007157b70) at kernel/sys.c:144
#5  0xa0000001000cf170 in atomic_notifier_call_chain
(nh=0xe000003014bcb3f0,
    val!, v=0xe000003007157b70) at kernel/sys.c:229
#6  0xa000000100048480 in ia64_init_handler (regs=0xe000003007157e40,
    sw=<value optimized out>, sos=<value optimized out>)
    at include/asm/kdebug.h:88
#7  0xa0000001000493a0 in ia64_os_init_virtual_begin ()
    at include/asm/kdebug.h:88
(gdb)

It is the stack _after_ NMI is triggered. Is this supposed to be?
What do you see on other (ie not SN) ia64 platforms?

Thanks,
 - jay
