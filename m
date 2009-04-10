From: Doug Chapman <doug.chapman@hp.com>
Date: Fri, 10 Apr 2009 19:13:23 +0000
Subject: squashfs broken on ia64
Message-Id: <1239390803.21349.13.camel@oberon>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

It appears that squashfs 4.0 doesn't work on ia64.  I am not sure what
could be arch specific here but the same kernel versions work OK on
x86_64.

I can reproduce this even with a very simple squashfs image that
contains just one "hello world" text file so it isn't specific to any
strange corner case.  I also tried a known-good image file (from x86_64
fedora rawhide) to ensure it wasn't something specific to the ia64
squashfs tool.  As far as I can tell the last time this worked on ia64
was with the older squashfs 3.1 code.

I will continue to investigate but any ideas are very welcome as I have
never looked at the squashfs code before.  I did some quick debugging
and found that zlib_inflate is returning Z_BUF_ERROR but that is as deep
as I have gone.


squashfs: version 4.0 (2009/01/31) Phillip Lougher
SQUASHFS error: zlib_inflate error, data probably corrupt
SQUASHFS error: squashfs_read_data failed to read block 0x85
SQUASHFS error: Unable to read metadata cache entry [85]
SQUASHFS error: Unable to read inode 0x20
------------[ cut here ]------------
WARNING: at fs/inode.c:673 unlock_new_inode+0x50/0xc0()
Hardware name: server rx2660                  =20
Modules linked in: squashfs sunrpc ip6table_filter ip6_tables ipv6
cpufreq_ondemand acpi_cpufreq freq_table vfat fat dm_multipath tg3
joydev mptsas mptscsih mptbase [last unloaded: scsi_wait_scan]

Call Trace:
 [<a000000100017b10>] show_stack+0x50/0xa0
                                sp=E0000100874efab0 bsp=E0000100874e9278
 [<a0000001009b9cb0>] dump_stack+0x30/0x50
                                sp=E0000100874efc80 bsp=E0000100874e9260
 [<a0000001000b2450>] warn_slowpath+0x130/0x200
                                sp=E0000100874efc80 bsp=E0000100874e9200
 [<a000000100234650>] unlock_new_inode+0x50/0xc0
                                sp=E0000100874efda0 bsp=E0000100874e91d8
 [<a000000100239b50>] iget_failed+0x30/0x60
                                sp=E0000100874efda0 bsp=E0000100874e91b8
 [<a00000020511e9e0>] squashfs_fill_super+0x900/0xb80 [squashfs]
                                sp=E0000100874efda0 bsp=E0000100874e9160
 [<a000000100208350>] get_sb_bdev+0x230/0x320
                                sp=E0000100874efdc0 bsp=E0000100874e9100
 [<a00000020511dea0>] squashfs_get_sb+0x40/0x60 [squashfs]
                                sp=E0000100874efde0 bsp=E0000100874e90c0
 [<a000000100207a20>] vfs_kern_mount+0x140/0x2e0
                                sp=E0000100874efde0 bsp=E0000100874e9070
 [<a000000100207c80>] do_kern_mount+0x60/0x220
                                sp=E0000100874efde0 bsp=E0000100874e9030
 [<a000000100244300>] do_mount+0x1480/0x1540
                                sp=E0000100874efde0 bsp=E0000100874e8fb8
 [<a0000001002444c0>] sys_mount+0x100/0x1c0
                                sp=E0000100874efe10 bsp=E0000100874e8f28
 [<a00000010000c4b0>] ia64_trace_syscall+0xf0/0x130
                                sp=E0000100874efe30 bsp=E0000100874e8f28
 [<a000000000010800>] __kernel_syscall_via_break+0x0/0x20
                                sp=E0000100874f0000 bsp=E0000100874e8f28
---[ end trace c6916087bfb06ff0 ]---


