From: Matthew Wilcox <willy@debian.org>
Date: Thu, 13 May 2004 15:08:47 +0000
Subject: Re: IA64 test report:Umount cdrom oops : 2.6.6 /Lion 2004-5-13: 8/10  pass
Message-Id: <20040513150847.GA6484@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <6E0C289723A0564F9A8279E236E8565F0766858E@pdsmsx402.pd.intel.com>
In-Reply-To: <6E0C289723A0564F9A8279E236E8565F0766858E@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, May 13, 2004 at 04:04:33PM +0800, Wang, Zhenyu Z wrote:
> kernel BUG at include/linux/smp_lock.h:52!

This is:

static inline void unlock_kernel(void)
{
        BUG_ON(current->lock_depth < 0);
        if (likely(--current->lock_depth < 0))
                put_kernel_lock();
}

In other words, we have a mismatched lock/unlock kernel at some point.
Ick.  The fault is clearly *not* in do_umount:

        lock_kernel();
        if( (flags&MNT_FORCE) && sb->s_op->umount_begin)
                sb->s_op->umount_begin(sb);
        unlock_kernel();

                        lock_kernel();
                        retval =3D do_remount_sb(sb, MS_RDONLY, 0, 0);
                        unlock_kernel();

                lock_kernel();
                DQUOT_OFF(sb);
                acct_auto_close(sb);
                unlock_kernel();

It would be helpful to know which unlock_kernel() revealed the problem.
I very much doubt it was the first one as umount_begin is only set
by cifs and nfs.  That leaves us with do_remount_sb and quota stuff
to investigate.  Can you figure this out by peering at a disassembly
(objdump -dr fs/namespace.o)?

> umount[1961]: bugcheck! 0 [1]
>=20
> Pid: 1961, CPU 3, comm:               umount
> psr : 0000101008026018 ifs : 800000000000038b ip  : [<a0000001001395f0>]
> Not tainted
> ip is at do_umount+0x750/0x760
> unat: 0000000000000000 pfs : 000000000000038b rsc : 0000000000000003
> rnat: a000000100738a93 bsps: 0000000000000320 pr  : 0000000005a66959
> ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
> csd : 0000000000000000 ssd : 0000000000000000
> b0  : a0000001001395f0 b6  : a0000001000090e0 b7  : a00000010006a6c0
> f6  : 1003e0fc0fc0fc0fc0fc1 f7  : 0ffdbca80000000000000
> f8  : 1003e0000000000000240 f9  : 1003e0000000000002490
> f10 : 1003e000000000ea00000 f11 : 1003e00000000367b7ad0
> r1  : a0000001009007a0 r2  : 0000000000004000 r3  : 0000000000004000
> r8  : 000000000000002b r9  : 0000000000000000 r10 : 0000000000003000
> r11 : 0000000000000300 r12 : e00000000f2ffe00 r13 : e00000000f2f8000
> r14 : e00000000f2ffda0 r15 : a00000010064e200 r16 : 0000000000000300
> r17 : a000000100648b50 r18 : a000000100631d38 r19 : 00000000000000fd
> r20 : 0000000000000001 r21 : a000000100648b4c r22 : 0000000000000000
> r23 : 00000000000000fd r24 : a000000100700918 r25 : 0000000000000004
> r26 : 0000000000000000 r27 : 0000000000000004 r28 : e00000005fc20c74
> r29 : 0000000000004000 r30 : e000000004755610 r31 : e000000007678038
>=20
> Call Trace:
>  [<a000000100015040>] show_stack+0x80/0xa0
>                                 sp=E00000000f2ff9d0 bsp=E00000000f2f8de0
>  [<a000000100023d10>] die+0x1d0/0x280
>                                 sp=E00000000f2ffba0 bsp=E00000000f2f8db8
>  [<a000000100024040>] ia64_bad_break+0x220/0x340
>                                 sp=E00000000f2ffba0 bsp=E00000000f2f8d98
>  [<a00000010000df20>] ia64_leave_kernel+0x0/0x260
>                                 sp=E00000000f2ffc30 bsp=E00000000f2f8d98
>  [<a0000001001395f0>] do_umount+0x750/0x760
>                                 sp=E00000000f2ffe00 bsp=E00000000f2f8d40
>  [<a000000100139760>] sys_umount+0x160/0x180
>                                 sp=E00000000f2ffe00 bsp=E00000000f2f8cd8
>  [<a00000010000dda0>] ia64_ret_from_syscall+0x0/0x20
>                                 sp=E00000000f2ffe30 bsp=E00000000f2f8cd0

--=20
"Next the statesmen will invent cheap lies, putting the blame upon=20
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince=20
himself that the war is just, and will thank God for the better sleep=20
he enjoys after this process of grotesque self-deception." -- Mark Twain
