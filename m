From: chas williams <chas@cmf.nrl.navy.mil>
Date: Tue, 03 Jul 2001 20:03:23 +0000
Subject: Re: [Linux-ia64] patching sys_call_table from a module
Message-Id: <marc-linux-ia64-105590693005809@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005808@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005808@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

i wrote a little example to illustrate my problem.  its attached at the
bottom.  if i make a syscall(__NR_afs_syscall, ...) i get the following:

pts[2437]: Bad break 104

psr : 0000101008026018 ifs : 8000000000000008 ip  : [<a0000000000344b0>]
unat: 0000000000000000 pfs : 0000000000000089 rsc : 0000000000000003
rnat: 40000000000bb190 bsps: e0000000044157b0 pr  : 000000000001015b
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
b0  : e000000004415ce0 b6  : e000000004402f60 b7  : e0000000044157b0
f6  : 1003e0000000000000020 f7  : 1003e0000000000000010
f8  : 1003e0000000000000006 f9  : 10002a000000000000000
r1  : e000000004a12b20 r2  : 0000000000000000 r3  : 00000000000000ff
r8  : e00000002facff00 r9  : 0000000000000000 r10 : ffffffffffffffff
r11 : 600000000000c3b8 r12 : e00000002facfe60 r13 : e00000002fac8000
r14 : e000000000000000 r15 : e000000004415ce0 r16 : e00000002facfe70
r17 : e00000002facfe78 r18 : 00001013080a6010 r19 : 20000000001e1bb0
r20 : 0000000000000000 r21 : 4000000000000e98 r22 : 600000000005ec20
r23 : 600000000005ed28 r24 : 0000000000005540 r25 : 2000000000293f90
r26 : 600000000005ed28 r27 : 0000000000000000 r28 : 0000000000000040
r29 : 0000000000000000 r30 : 0000000000000008 r31 : 0000000000000000
r32 : 0000000000000000 r33 : 0000000000000000 r34 : 0000000000000000
r35 : 0000000000000000 r36 : 0000000000000000 r37 : 0000000000000000
r38 : 0000000000000000 r39 : 0000000000000000

Call Trace: [<e00000000441a080>] sp=3D0xe00000002facfa50 bsp=3D0xe00000002f=
ac8ec8
[<e00000000441a840>] sp=3D0xe00000002facfc10 bsp=3D0xe00000002fac8e70
[<e00000000442b830>] sp=3D0xe00000002facfc30 bsp=3D0xe00000002fac8e48
[<e00000000442bb00>] sp=3D0xe00000002facfc30 bsp=3D0xe00000002fac8e28
[<e000000004415d00>] sp=3D0xe00000002facfcc0 bsp=3D0xe00000002fac8e28
[<a0000000000344b0>] sp=3D0xe00000002facfe60 bsp=3D0xe00000002fac8de0
[<e000000004415ce0>] sp=3D0xe00000002facfe60 bsp=3D0xe00000002fac8dd8

what am i doing wrong or cant i do this?

/* mysyscall.c=20
 =20
% cc -O2 -fomit-frame-pointer -fno-strict-aliasing -pipe -ffixed-r13 -mfixe=
d-range=F10-f15,f32-f127 -falign-functions2 -mb-step -D__KERNEL__ -DKERNEL =
-D_KERNEL -DMODULE -c mysyscall.c

*/

#include <linux/config.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/types.h>
#include <linux/string.h>
#include <linux/init.h>
#include <sys/syscall.h>

extern long sys_call_table[];
static long saved_syscall;

asmlinkage long=20
afs_syscall(long arg0, long arg1, long arg2, long arg3,
          long arg4, long arg5, long arg6, long arg7, long stack)
{
        struct pt_regs *regs =3D (struct pt_regs *) &stack;
=09
	printk("afs_syscall()\n");

	return 0;
}

int __init
mysyscall_init(void)
{
	printk("hello world\n");
	saved_syscall =3D sys_call_table[__NR_afs_syscall - 1024];
	sys_call_table[__NR_afs_syscall - 1024] =3D (long) afs_syscall;
	return 0;
}

void __exit
mysyscall_exit(void)
{
	printk("goodbye cruel world\n");
	sys_call_table[__NR_afs_syscall - 1024] =3D saved_syscall;
}

module_init(mysyscall_init);
module_exit(mysyscall_exit);


