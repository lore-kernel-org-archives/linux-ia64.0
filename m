From: Keith Owens <kaos@sgi.com>
Date: Fri, 04 Feb 2005 09:44:29 +0000
Subject: Re: ia64 uaccess changes?
Message-Id: <6037.1107510269@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107509583.2555.51.camel@linux-znh>
In-Reply-To: <1107509583.2555.51.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, 4 Feb 2005 01:37:24 -0800,=20
Andrew Morton <akpm@osdl.org> wrote:
>
>Did something changed with the ia64 uaccess functions a few weeks ago?
>
>Because a couple of weeks ago I was seeing repeatable oopses in Linus's
>tree early in boot in create_elf_tables(), here:
>
>	/* Now, let's put argc (and argv, envp if appropriate) on the stack */
>	if (__put_user(argc, sp++))
>		return -EFAULT;
>
>that shouldn't happen.
>
>
>Now, Linus's tree works OK, but I'm seeing repeatable oopses late in boot
>with this patch applied:=20
>
>ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.11-rc2/2=
.6.11-rc2-mm2/broken-out/add-do_proc_doulonglongvec_minmax-to-sysctl-functi=
ons.patch
>
>which is crazy - that code isn't even executed.

2.6.11-rc3 also breaks on SN2 in create_elf_tables().

Freeing unused kernel memory: 352kB freed
init[1]: IA-64 Illegal operation fault 0 [1]
Modules linked in:
   =20
Pid: 1, CPU 1, comm:                 init
psr : 0000101008026018 ifs : 8000000000000710 ip  : [<a0000001001ae120>]   =
 Not tainted
ip is at create_elf_tables+0x3c0/0x800
unat: 0000000000000000 pfs : 0000000000000000 rsc : 0000000000000000
rnat: 0000000000000000 bsps: e00000b07a850e70 pr  : 000000000000801b
ldrs: 0000000000880000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
f6  : 000000000000000000000 f7  : 000000000000000000000
f8  : 000000000000000000000 f9  : 000000000000000000000
f10 : 000000000000000000000 f11 : 000000000000000000000
r1  : a000000100ce0720 r2  : e00000b07a857d10 r3  : 0000000000000308       =
                                                                   r8  : 00=
00000000000000 r9  : 0000000000000000 r10 : 0000000000000000               =
                                                           r11 : 0000000000=
000000 r12 : 60000fffffffbdf0 r13 : e00000b07a850000                       =
                                                   r14 : 0000000000000000 r=
15 : 0000000000000409 r16 : e00000b07a850e70                               =
                                           r17 : ffffffffffffffc1 r18 : 000=
0000000000040 r19 : 0000000000000000                                       =
                                   r20 : 0009804c0270033f r21 : a0000001000=
09290 r22 : 0000000000000000                                               =
                           r23 : 60000fff7fffc000 r24 : 0000000000000000 r2=
5 : 0000000000000000                                                       =
              =20
     r26 : 0000000000000186 r27 : 000000000000000f r28 : 4000000000000200  =
                                                                        r29=
 : 00001013085a6000 r30 : 0000000000000003 r31 : 0000000000005541

Call Trace:=20
 [<a000000100010220>] show_stack+0x80/0xa0
                                sp=E00000b07a857b30 bsp=E00000b07a850f58
 [<a000000100010b00>] show_regs+0x860/0x880=20
                                sp=E00000b07a857d00 bsp=E00000b07a850ef8
 [<a000000100036050>] die+0x170/0x220
                                sp=E00000b07a857d10 bsp=E00000b07a850ec0
 [<a000000100036140>] die_if_kernel+0x40/0x60
                                sp=E00000b07a857d10 bsp=E00000b07a850e98
 [<a000000100036c60>] ia64_illegal_op_fault+0x60/0x140
                                sp=E00000b07a857d10 bsp=E00000b07a850e78
 [<a000000100003f20>] dispatch_illegal_op_fault+0x300/0x800
                                sp=E00000b07a857e30 bsp=E00000b07a850e78

The code in create_elf_tables is good.  Single stepping through the
offending region works, but as soon as the kernel is allowed to run
again it dies at a different place in create_elf_tables.

