From: Paul Jackson <pj@sgi.com>
Date: Tue, 25 Nov 2003 04:15:47 +0000
Subject: [PATCH] check user access ok writing /proc/irq/<pid>/smp_affinity
Message-Id: <marc-linux-ia64-106973370622421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David,

Could you kindly apply the following patch?

In arch/ia64/kernel/irq.c:irq_affinity_write_proc() there
is an unchecked user access that examines writes to files
/proc/irq/<pid>/smp_affinity for a leading character 'R',
in order to trigger some interrupt redirect feature.

You can oops the kernel easily, by issuing a write() system
call to these files with a bogus address.

Here's a patch against test10 to fix it:


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1484  -> 1.1485=20
#	arch/ia64/kernel/irq.c	1.31    -> 1.32  =20
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/24	pj@sgi.com	1.1485
# Verify user access_ok writing /proc/irq/<pid>/smp_affinity on arch ia64
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c	Mon Nov 24 19:41:58 2003
+++ b/arch/ia64/kernel/irq.c	Mon Nov 24 19:41:58 2003
@@ -1004,6 +1004,9 @@
 	if (!desc->handler->set_affinity)
 		return -EIO;
=20
+	if (!access_ok(VERIFY_READ, buf, count))
+		return -EFAULT;
+
 	if (buf[0] =3D 'r' || buf[0] =3D 'R') {
 		++buf;
 		while (*buf =3D ' ') ++buf;


# More details ...

Test code of program to demonstrate bug:

#include <stdio.h>
#include <stdlib.h>
main(int argc,char **argv)
{
    long x =3D strtoul(argv[1],0,16);
    fprintf(stderr,"writing from addr 0x%lx\n", x);
    write(1,x,16);
}

Compile to 'foo' and invoke it by doing:

  # cd /proc/irq/99    # where 99 is some pid
  # foo 9999 > smp_affinity=20

See an oops such as:

Unable to handle kernel paging request at virtual address 0000000000009999
foo[2779]: Oops 8813272891392 [1]

Pid: 2779, CPU 31, comm:                  foo
psr : 0000101008026018 ifs : 800000000000048c ip  : [<a000000100013810>]   =
 Not tainted
ip is at irq_affinity_write_proc+0x70/0x240
unat: 0000000000000000 pfs : 000000000000048c rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 80000000ff76a519
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001000137d0 b6  : a000000100002d70 b7  : a0000001000137a0
f6  : 000000000000000000000 f7  : 000000000000000000000
f8  : 000000000000000000000 f9  : 000000000000000000000
f10 : 000000000000000000000 f11 : 000000000000000000000
r1  : a0000001009acb00 r2  : a0000001006315e0 r3  : a0000001006ddaf8
r8  : a0000001006ddac0 r9  : a0000001007ade58 r10 : 0000000000000063
r11 : e00006307b4e2c98 r12 : e00007b07bdefe10 r13 : e00007b07bde8000
r14 : 20000000002c6b50 r15 : a00000010062c9d8 r16 : e0000ab07be9be90
r17 : a00000010070d4c0 r18 : 0000000000000000 r19 : e0000f307bd01f88
r20 : a000000100169da0 r21 : 40000000000002c0 r22 : 2000000000203cc0
r23 : e0000f307bd01f80 r24 : 0000000000000400 r25 : 0000000000000000
r26 : c00000000000040b r27 : 0000000000000408 r28 : e0000f307bd01edc
r29 : a00000010070d4b8 r30 : a00000010070d498 r31 : a0000001001d2e80

Call Trace:
 [<a000000100015160>] show_stack+0x80/0xa0
                                sp=E00007b07bdef9e0 bsp=E00007b07bde9168
 [<a000000100038930>] die+0x1b0/0x260
                                sp=E00007b07bdefbb0 bsp=E00007b07bde9140
 [<a000000100059940>] ia64_do_page_fault+0x360/0x9a0
                                sp=E00007b07bdefbb0 bsp=E00007b07bde90e0
 [<a00000010000ddc0>] ia64_leave_kernel+0x0/0x260
                                sp=E00007b07bdefc40 bsp=E00007b07bde90e0
 [<a000000100013810>] irq_affinity_write_proc+0x70/0x240
                                sp=E00007b07bdefe10 bsp=E00007b07bde9080
 [<a0000001001d2f40>] proc_file_write+0xc0/0xe0
                                sp=E00007b07bdefe20 bsp=E00007b07bde9058
 [<a000000100169c40>] vfs_write+0x200/0x2a0
                                sp=E00007b07bdefe20 bsp=E00007b07bde9010
 [<a000000100169e00>] sys_write+0x60/0xc0
                                sp=E00007b07bdefe20 bsp=E00007b07bde8f98
 [<a00000010000dc40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00007b07bdefe30 bsp=E00007b07bde8f98
 Segmentation fault


--=20
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
