From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 11 May 2012 10:46:28 +0000
Subject: loading linux-3.3 with ski sim crashes
Message-Id: <201205110646.29925.vapier@gentoo.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart6087571.4Ue7EPYgPk"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--nextPart6087571.4Ue7EPYgPk
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

i'm using gcc-4.5.3, binutils-2.22, and linux-3.3.  i did `make sim_defconf=
ig`,=20
then `make`, then `make boot`.

now i'm trying to load it up into ski, but it crashes.  any ideas ?
$ ski linux-3.3/bootloader linux-3.3/vmlinux root=3D/dev/sda simscsi=3Dimag=
es/sda
run
loading linux-3.3/vmlinux...
starting kernel...
Linux version 3.3.0 (vapier@vapier) (gcc version 4.5.3 (Gentoo 4.5.3-r2 p1.=
1,=20
pie-0.4.7) ) #1 SMP PREEMPT Fri May 11 06:39:32 EDT 2012
EFI v1.00 by Hewlett-Packard: SALsystab=3D0x10b6d0
warning: unable to switch EFI into virtual mode (status=3D92233720368547758=
11)
No I/O port range found in EFI memory map, falling back to AR.KR0=20
(0xffffc000000)
console [simcons0] enabled
warning: skipping physical page 0
SAL 0.1: Hewlett-Packard HP-simulator version 0.0
get_cache_info: ia64_pal_cache_summary() failed (status=3D-1)
PAL_VM_PAGE_SIZE failed with status=3D-1; defaulting to architected purge p=
age-
sizes.
MCA related initialization done
Zone PFN ranges:
  DMA      0x00000000 -> 0x00010000
  Normal   empty
Movable zone start PFN for each node
Early memory PFN ranges
    0: 0x00000000 -> 0x00000800
Built 1 zonelists in Zone order, mobility grouping off.  Total pages: 2046
Kernel command line: root=3D/dev/sda simscsi=3Dimages/sda=20
PID hash table entries: 512 (order: -4, 4096 bytes)
Dentry cache hash table entries: 16384 (order: 1, 131072 bytes)
Inode-cache hash table entries: 8192 (order: 0, 65536 bytes)
Memory: 115328k/130048k available (6491k code, 14720k reserved, 3108k data,=
=20
640k init)
Leaving McKinley Errata 9 workaround enabled
SLUB: Genslabs=3D19, HWalign=3D128, Order=3D0-3, MinObjects=3D0, CPUs=3D1, =
Nodes=3D1
Preemptible hierarchical RCU implementation.
NR_IRQS:1024
Unable to handle kernel paging request at virtual address 0000000000104c78
swapper/0[0]: Oops 8813272891392 [1]
Modules linked in:

Pid: 0, CPU 0, comm:            swapper/0
psr : 00001010084a2018 ifs : 8000000000000008 ip  : [<e000000000100d30>]   =
=20
Not tainted (3.3.0)
ip is at 0xe000000000100d30
unat: 0000000000000000 pfs : 0000000000000491 rsc : 0000000000000003
rnat: 0000000000000004 bsps: 000000000001003e pr  : 0000000000005589
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010001e590 b6  : e000000000100bc0 b7  : a00000010004acc0
f6  : 1003e00000001b9aca000 f7  : 1003e00000000dcd65000
f8  : 1003e0000000000000002 f9  : 1001edcd6500000000000
f10 : 10000aa30beea17b9ff5f f11 : 1003e0000000000000002
r1  : e000000000305b98 r2  : 0000000000104c78 r3  : e000000000105f80
r8  : 0000000000000000 r9  : 0000000000000000 r10 : 0000000000000000
r11 : 0000000000000000 r12 : a0000001008cfca0 r13 : a0000001008c0000
r14 : 0000000001000000 r15 : 0000000000080004 r16 : 0000000000000000
r17 : 0000000000007fff r18 : a000000100012100 r19 : ffffffffffffffff
r20 : a00000010097f2b0 r21 : 0000000003ffffff r22 : a0000001008cfe00
r23 : a0000001008cfe00 r24 : 0000000000000000 r25 : a00000010091b8b0
r26 : a0000001008cfe20 r27 : a00000010091b8d0 r28 : 0000800000000000
r29 : 7000000000000000 r30 : 0000000000000008 r31 : 0000000000000030

Call Trace:
 [<a000000100013360>] show_stack+0x80/0xa0
                                sp=3Da0000001008cf870 bsp=3Da0000001008c0e40
 [<a0000001000139c0>] show_regs+0x640/0x860
                                sp=3Da0000001008cfa40 bsp=3Da0000001008c0de0
 [<a000000100025600>] die+0x240/0x360
                                sp=3Da0000001008cfa40 bsp=3Da0000001008c0da0
 [<a0000001000482f0>] ia64_do_page_fault+0x6b0/0xa00
                                sp=3Da0000001008cfa40 bsp=3Da0000001008c0d48
 [<a00000010000bd00>] ia64_native_leave_kernel+0x0/0x280
                                sp=3Da0000001008cfad0 bsp=3Da0000001008c0d48
 [<e000000000100d30>] 0xe000000000100d30
                                sp=3Da0000001008cfca0 bsp=3Da0000001008c0d08
 [<a00000010001e590>] ia64_sal_freq_base+0xb0/0x180
                                sp=3Da0000001008cfca0 bsp=3Da0000001008c0cc0
 [<a00000010064b680>] ia64_init_itm+0x40/0x7e0
                                sp=3Da0000001008cfd40 bsp=3Da0000001008c0c78
 [<a0000001007a6de0>] time_init+0x40/0x60
                                sp=3Da0000001008cfe10 bsp=3Da0000001008c0c60
 [<a0000001007a0d90>] start_kernel+0x460/0x6f0
                                sp=3Da0000001008cfe10 bsp=3Da0000001008c0be0
 [<a00000010064a720>] start_ap+0x3e0/0x400
                                sp=3Da0000001008cfe20 bsp=3Da0000001008c0be0
Disabling lock debugging due to kernel taint
Kernel panic - not syncing: Attempted to kill the idle task!

--nextPart6087571.4Ue7EPYgPk
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPrO4FAAoJEEFjO5/oN/WBh6oQAIWT8wkdrmN5cBejS/eaiii0
Tk+z6/QUtPdvTvYhVBQ3qjAq1Z5m6R9qTdv9ptMDaviXIY4kXYICfbeuDEAHRoPe
RoM7eKV3Zv1OZJaci4u0HhkJSFjAKY1gyL++2QUyfzlJIASIyv3XX6O0+mSXsBWr
3u3oWqsUoCHoNRKgjNKFNjQJ+BjCtxCOOVYXWWPHCfGKF6ZjX5ymV8k8kJdp1jIP
JPkyBfsNEYJsKHddtj8KeRS2jxChgPHKJfNK0UKgSJu23Qb1ne6mFXRb6pdfxUHf
2q0J+doVZE3Gqk1ftSPbvPYlM0lnlDNaCb5fDtFXGde73yNQwOMaQcWT61yJNbw0
3L08yZa97z0Ehshuoid5MoXqWxcKRPeO/4g5JPAjA7MvwUyI6+oOhP43ek+2n3iW
SdObshMEkAZuU/o8PsRXAuG5yk6v1nVcZSsksvlfikSbMGxj1+gg52jwVC8VDRjG
K/eBVAeTVYAd4B8qTr90KN5XVCDRX5Y97b9TT50AYb6vdm7ON0+dI5Fe/BjfATCs
zgB3ymhyQF2bDGhQdZfNsJCOv/tdRlEj7IHpqbY4Vq+y+IBDNtYeQCasg4ZJeu2e
Nx+dZgraHoz35FJkpv/FDN1rSaTwgMqssXgdM5xmFq8XCARZ0foobUKYx5EuDyPc
5OjnQswQVY0/vgCh9HbH
=VW1x
-----END PGP SIGNATURE-----

--nextPart6087571.4Ue7EPYgPk--
