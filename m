From: Keith Owens <kaos@melbourne.sgi.com>
Date: Tue, 30 Jan 2001 03:53:55 +0000
Subject: [Linux-ia64] kdb v1.7 for IA64 is available
Message-Id: <marc-linux-ia64-105590693005109@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=us-ascii

http://oss.sgi.com/projects/kdb/download/ia64/ contains kdb v1.7 for
IA64, using the same design as kdb for i386.  This is completely
incompatible with HP's version of kdb, use one or the other but not
both.

kdb-v1.7-ia64-2.4.0-010109 is a patch against Linus's 2.4.0 tree + HP's
linux-2.4.0-ia64-010109.diff; apply the HP IA64 kernel patch before
kdb.

You must use a compiler that supports the new unwind code, kdb relies
on unwind data.  I have been using gcc snapshot snap-001117 from
cygnus.  The kdb patch also contains code for the i386 version of kdb
but do not use this patch on i386, the i386 and IA64 patches for kdb
are not interchangable due to ia64-010109 changes to common kernel code.

There are still a lot of rough edges in kdb for IA64, treat it with
care.

Save your .config and do make mrproper after applying the kdb patch.
To cross compile kdb for ia64 from i386 from you need
kallsyms_i386_ia64.c from kdb/download/ia64.  Compile and save the
binary anywhere, no special compile options.  Specify the location of
the cross compile kallsyms on the make command.

Point CROSS_COMPILE_INC at an include library that contains an ia64
version of bfd.h, it must contain these lines

#define BFD_ARCH_SIZE 64
#define BFD_HOST_64BIT_LONG 0

Example cross compile from i386 to ia64 with kdb.

make ARCH=ia64 \
  CROSS_COMPILE=/ia64/install/bin/ia64-unknown-linux- \
  CROSS_COMPILE_INC=/ia64/install/include/ \
  KALLSYMS=/ia64/kallsyms_i386_ia64 \
  vmlinux modules


Working:

* Accurate back traces, but only with new unwind code.
* Display arguments.  This is really the stacked in+local registers,
  not just the in registers.  Also the values could have been changed
  between the time the function was called and when the registers were
  stacked so take the values with a pinch of salt.  This uncertainty is
  inherent in the IA64 ABI for parameter passing.
* SMP.  The other cpus are pulled into kdb, but only if they are
  accepting interrupts.  The cpu command works nicely.
* Disassembler, up to date with gdb as of approx November 27, 2000.
* Software breakpoints.
* Single step.
* Back trace all (bta) and back trace process (btp).  See note below.
* Input from serial console or keyboard.
* All architecture independent commands.

Not working or incomplete:

* No hardware breakpoints, except for single step.
* Single step until branch is treated as single step.
* Not all special IA64 registers can be printed.
* Command history.  There are fragments of HP's command history in kdb
  for IA64 but they do nothing.  I want to do a proper command history,
  using cursor keys (up, down, left, right, insert, delete) instead of
  just ^D, ^N.
* Input from simulated console.
* None of the new commands that people have requested have been coded
  yet.  The hard part of port kdb v1.7 to IA64 has been done, adding
  new commands is arch independent and is relatively easy.
* No use of NMI yet.  If a cpu is spinning in kernel with interrupts
  disabled, you will not be able to debug that process.
* No documentation updates for IA64 yet.
* The checks for whether a kernel address is valid or not sometimes
  treat a valid address as invalid and refuse to print the data at
  that location.

Accurate and reliable back traces are the hard part, in particular
deciding if a process that is running on another cpu is in a fit state
to be traced.  I added a field to struct thread to track the current
struct switch_stack plus a field in switch_stack to point to the
previous switch_stack, if any.  Adding those fields and tracking the
current stack state required a lot of changes in entry.[hS].

A default back trace prints the instruction pointer, the "arguments" in
hex and the information about the module (or kernel), the section name
and the addresses that are useful for objdump.  set BTARGS=0 to
suppress the arguments in hex.  set NOSECT=1 to suppress the section
data.  You can also expand the back trace data, set BTSYMARG=1 will
convert arguments into symbols and offsets.  set BTSP=1 will print the
memory and register stack pointers for each frame.

bp sys_open, followed by bt with BTARGS=5, BTSYMARG=1, BTSP=1.

Entering kdb (current=0xe00000003eb90000, pid 287) on processor 0 due to Breakpoint @ 0xe0000000005bf9e0
[0]kdb> bt
0xe0000000005bf9e0 sys_open
        args (0x20000000002c2498, 0x2, 0x80000ffffffffd00)
        kernel .text 0xe000000000500000 0xe0000000005bf9e0 0xe0000000005bfda0
        sp 0xe00000003eb97e60 bsp 0xe00000003eb90dd0 cfm 0x8000000000000003
0xe000000000521780 ia64_ret_from_syscall
        args (0x20000000002c2498, 0x2, 0x80000ffffffffd00)
        kernel .text 0xe000000000500000 0xe000000000521780 0xe0000000005217a0
        sp 0xe00000003eb97e60 bsp 0xe00000003eb90dd0 cfm 0x0000000000000003


Although kdb can accurately determine where the current stack frame is
for any process, it cannot reliably determine the interrupt point for
an arbitrary process.  That information is only available in the
context of the current process.  So if you trace a process by any
command other than 'bt', kdb gives you the entire stack trace, not just
from the point of interrupt.  For example, 'bt' above only printed the
interrupt context for process 287.  But if you explictly print a
process via btp or bta, kdb has to print the entire stack trace.

[0]kdb> btp 287
0xe000000000899cd0 kdba_main_loop+0xb0
        args (0x3, 0x3, 0x80100, 0x0, 0xe00000003eb97cd0)
        kernel .text 0xe000000000500000 0xe000000000899c20 0xe000000000899d00
        sp 0xe00000003eb97c00 bsp 0xe00000003eb90e78 cfm 0x0000000000000389
0xe0000000006b6c80 kdb+0xe60
        args (0x3, 0x80100, 0xe00000003eb97cd0, 0xe000000000aaa8a8, 0x400000)
        arg 3 0xe000000000aaa8a8 (kdb_flags)
        kernel .text 0xe000000000500000 0xe0000000006b5e20 0xe0000000006b7100
        sp 0xe00000003eb97c20 bsp 0xe00000003eb90e10 cfm 0x0000000000000692
0xe0000000005329a0 ia64_bad_break+0x2e0
        args (0x80100, 0xe00000003eb97cd0, 0xe0000000005217a0, 0x2)
        arg 2 0xe0000000005217a0 (ia64_leave_kernel)
        kernel .text 0xe000000000500000 0xe0000000005326c0 0xe000000000532a40
        sp 0xe00000003eb97c30 bsp 0xe00000003eb90de8 cfm 0x0000000000000207
0xe0000000005217a0 ia64_leave_kernel
        args (0x80100, 0xe00000003eb97cd0)
        kernel .text 0xe000000000500000 0xe0000000005217a0 0xe000000000521800
        sp 0xe00000003eb97cc0 bsp 0xe00000003eb90de8 cfm 0x0000000000000002

        The entries above are handling the breakpoint and entering kdb.
        For the moment, just ignore the extra kdb entries when you do
        an explicit back trace of another process.

0xe0000000005bf9e0 sys_open
        args (0x20000000002c2498, 0x2, 0x80000ffffffffd00)
        kernel .text 0xe000000000500000 0xe0000000005bf9e0 0xe0000000005bfda0
        sp 0xe00000003eb97e60 bsp 0xe00000003eb90dd0 cfm 0x8000000000000003
0xe000000000521780 ia64_ret_from_syscall
        args (0x20000000002c2498, 0x2, 0x80000ffffffffd00)
        kernel .text 0xe000000000500000 0xe000000000521780 0xe0000000005217a0
        sp 0xe00000003eb97e60 bsp 0xe00000003eb90dd0 cfm 0x0000000000000003


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.3 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE6djrSi4UHNye0ZOoRAuchAJ41JB/wDCAhFj4nBM+v8PgCryN5TQCg5RDW
BH/DbLSloHul7Jnosa4FwrU=kBIV
-----END PGP SIGNATURE-----


