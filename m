From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Fri, 13 May 2005 15:57:29 +0000
Subject: xfs Oops 2.6.12-rc4 Badness in xfs_page_state_convert
Message-Id: <20050513155729.GC31449@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi all
 I have been benchmarking on an Altix 350 4way and upon
upgrading from 2.6.12-rc3 -> rc4 Git tree-id=20
eed337ef5e9ae7d62caa84b7974a11fddc7f06e0 using the sn2_defconfig
with # CONFIG_MODULES is not set, I am seeing a constant stream of
the following Oops:

Badness in xfs_page_state_convert at=20
/usr/src/dsw/SanJose/git-linux/fs/xfs/linux-2.6/xfs_aops.c:889

Call Trace:
 [<a000000100010280>] show_stack+0x80/0xa0
                                sp=E00000b0f608f8f0 bsp=E00000b0f6089380
 [<a0000001000102d0>] dump_stack+0x30/0x60
                                sp=E00000b0f608fac0 bsp=E00000b0f6089368
 [<a0000001003a0cf0>] xfs_page_state_convert+0x530/0xac0
                                sp=E00000b0f608fac0 bsp=E00000b0f6089290
 [<a0000001003a1fa0>] linvfs_writepage+0x120/0x240
                                sp=E00000b0f608fc00 bsp=E00000b0f6089258
 [<a00000010018c5d0>] mpage_writepages+0x530/0x7e0
                                sp=E00000b0f608fc10 bsp=E00000b0f6089178
 [<a0000001000fa760>] do_writepages+0xe0/0x100
                                sp=E00000b0f608fcb0 bsp=E00000b0f6089150
 [<a0000001001888d0>] __sync_single_inode+0xb0/0x500
                                sp=E00000b0f608fcb0 bsp=E00000b0f60890e8
 [<a000000100188e40>] __writeback_single_inode+0x120/0x320
                                sp=E00000b0f608fcb0 bsp=E00000b0f60890a0
 [<a0000001001894e0>] sync_sb_inodes+0x4a0/0x6e0
                                sp=E00000b0f608fd30 bsp=E00000b0f6088fd8
 [<a0000001001899f0>] writeback_inodes+0x2d0/0x300
                                sp=E00000b0f608fd30 bsp=E00000b0f6088f80
 [<a0000001000fa140>] wb_kupdate+0x220/0x320
                                sp=E00000b0f608fd30 bsp=E00000b0f6088f28
 [<a0000001000fb8a0>] __pdflush+0x240/0x420
                                sp=E00000b0f608fda0 bsp=E00000b0f6088e90
 [<a0000001000fbac0>] pdflush+0x40/0x60
                                sp=E00000b0f608fda0 bsp=E00000b0f6088e78
 [<a0000001000d5d70>] kthread+0x1f0/0x200
                                sp=E00000b0f608fdd0 bsp=E00000b0f6088e38
 [<a0000001000125d0>] kernel_thread_helper+0xd0/0x100
                                sp=E00000b0f608fe30 bsp=E00000b0f6088e10
 [<a000000100009120>] start_kernel_thread+0x20/0x40
                                sp=E00000b0f608fe30 bsp=E00000b0f6088e10
 =20
This patch introduces the WARN_ON
http://www.kernel.org/git/gitweb.cgi?p=3Dlinux/kernel/git/torvalds/linux-2.=
6.git;a=3Dcommitdiff;h$e17b5fb99d4d1b47fe0847a3a801e36d431ff6

  - dsw

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
