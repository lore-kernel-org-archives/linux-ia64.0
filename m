From: Andrew Morton <akpm@osdl.org>
Date: Fri, 04 Feb 2005 09:37:24 +0000
Subject: ia64 uaccess changes?
Message-Id: <20050204013724.7f2ccdd7.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107509583.2555.51.camel@linux-znh>
In-Reply-To: <1107509583.2555.51.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Did something changed with the ia64 uaccess functions a few weeks ago?

Because a couple of weeks ago I was seeing repeatable oopses in Linus's
tree early in boot in create_elf_tables(), here:

	/* Now, let's put argc (and argv, envp if appropriate) on the stack */
	if (__put_user(argc, sp++))
		return -EFAULT;

that shouldn't happen.


Now, Linus's tree works OK, but I'm seeing repeatable oopses late in boot
with this patch applied:=20

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.11-rc2/2.=
6.11-rc2-mm2/broken-out/add-do_proc_doulonglongvec_minmax-to-sysctl-functio=
ns.patch

which is crazy - that code isn't even executed.

They look like this:

Pid: 1003, CPU 3, comm:                mount
psr : 0000101008026018 ifs : 8000000000000309 ip  : [<a000000100169070>]   =
 Notd
ip is at exact_copy_from_user+0x70/0x120                                   =
   =20
unat: 0000000000000000 pfs : 000000000000040b rsc : 0000000000000003
rnat: 800000000000058e bsps: 0000000000000000 pr  : 0000000000005559
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000                      =20
b0  : a0000001001691c0 b6  : a000000100002d70 b7  : a000000100002cd0
f6  : 1003e6db6db6db6db6db7 f7  : 000000000000000000000            =20
f8  : 1003e000000000000f1d4 f9  : 1003e0000000000069ccc
f10 : 000000000000000000000 f11 : 000000000000000000000
r1  : a000000100df22c0 r2  : e00000003f1f0d48 r3  : 00000fffffffbfff
r8  : 0000000000000000 r9  : 0000000000000000 r10 : a000000100c0ea70
r11 : e00000003c750000 r12 : e00000003f1f7e10 r13 : e00000003f1f0000
r14 : 9fffffffffffffff r15 : 000000000000f1d4 r16 : 6db6db6db6db6db7
r17 : 0000000000069ccc r18 : 000000000034e660 r19 : e000000004d61000
r20 : a000000100c0ea50 r21 : 000000000000ffb1 r22 : a000000100c2bc80
r23 : a000000100a3b200 r24 : a000000100c2bc80 r25 : 0000000000000000
r26 : 0000000000004000 r27 : 0000000000000000 r28 : 2000000000212680
r29 : 0000000000000008 r30 : 0000000000000009 r31 : 0000000000200200
                                                                   =20
Call Trace:
 [<a00000010000f360>] show_stack+0x80/0xa0
                                sp=E00000003f1f79d0 bsp=E00000003f1f1090
 [<a00000010000fbc0>] show_regs+0x7e0/0x800                            =20
                                sp=E00000003f1f7ba0 bsp=E00000003f1f1030
 [<a000000100033830>] die+0x150/0x1c0                                  =20
                                sp=E00000003f1f7bb0 bsp=E00000003f1f0fe8
 [<a000000100053890>] ia64_do_page_fault+0x370/0x980                   =20
                                sp=E00000003f1f7bb0 bsp=E00000003f1f0f80
 [<a00000010000a780>] ia64_leave_kernel+0x0/0x260                      =20
                                sp=E00000003f1f7c40 bsp=E00000003f1f0f80
 [<a000000100169070>] exact_copy_from_user+0x70/0x120                  =20
                                sp=E00000003f1f7e10 bsp=E00000003f1f0f38
 [<a0000001001691c0>] copy_mount_options+0xa0/0x160                    =20
                                sp=E00000003f1f7e10 bsp=E00000003f1f0ef8
 [<a000000100169c50>] sys_mount+0x30/0x1c0                             =20
                                sp=E00000003f1f7e10 bsp=E00000003f1f0e70
 [<a00000010000a600>] ia64_ret_from_syscall+0x0/0x20                   =20
                                sp=E00000003f1f7e30 bsp=E00000003f1f0e70
 <6>Adding 2024144k swap on /dev/sda2.  Priority:-1 extents:1          =20
Unable to handle kernel paging request at virtual address 6000000000018000

copy_mount_options() is a popular place for kernels to oops if there's
anything unusual in the uaccess handling.

Thanks.
