From: Andrew Patterson <andrew.patterson@hp.com>
Date: Wed, 10 Mar 2004 23:05:18 +0000
Subject: BUG in fs/buffer.c under heavy ext3 file-system load
Message-Id: <1078959918.12405.64.camel@bluto.andrew>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-u7mIYFcJ5QScRTESNgyL"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-u7mIYFcJ5QScRTESNgyL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I have been running a disk/file-system test using the ext3 file-system
that is running into the following BUG(s) when load gets very high.

buffer layer error at fs/buffer.c:1820
                                                                           =
    =20
Call Trace:
 [<a0000001000205a0>] show_stack+0x80/0xa0
                                sp=3De00000404009fae0 bsp=3De0000040400993c=
0
 [<a000000100125ee0>] __buffer_error+0x80/0xa0
                                sp=3De00000404009fcb0 bsp=3De00000404009939=
8
 [<a00000010012b9a0>] __block_write_full_page+0x3a0/0xba0
                                sp=3De00000404009fcb0 bsp=3De00000404009932=
8
 [<a000000100137630>] blkdev_writepage+0x30/0x60
                                sp=3De00000404009fcb0 bsp=3De00000404009930=
0
 [<a000000100173ce0>] mpage_writepages+0x700/0x8a0
                                sp=3De00000404009fcb0 bsp=3De00000404009924=
8
 [<a00000010013a130>] generic_writepages+0x30/0x60
                                sp=3De00000404009fcc0 bsp=3De00000404009922=
0
 [<a0000001000e9c00>] do_writepages+0x80/0xe0
                                sp=3De00000404009fcc0 bsp=3De0000040400991f=
0
 [<a000000100170140>] __sync_single_inode+0x1e0/0x4a0
                                sp=3De00000404009fcc0 bsp=3De00000404009919=
0
[<a000000100170a70>] sync_sb_inodes+0x490/0x640
                                sp=3De00000404009fcc0 bsp=3De0000040400990d=
8
 [<a000000100170d70>] writeback_inodes+0x150/0x200
                                sp=3De00000404009fcc0 bsp=3De00000404009909=
0
 [<a0000001000e9440>] background_writeout+0x100/0x1a0
                                sp=3De00000404009fcc0 bsp=3De00000404009904=
0
 [<a0000001000ea9d0>] __pdflush+0x2f0/0x540
                                sp=3De00000404009fe00 bsp=3De000004040098fa=
0
 [<a0000001000eac40>] pdflush+0x20/0x40
                                sp=3De00000404009fe00 bsp=3De000004040098f8=
8
 [<a000000100022370>] kernel_thread_helper+0xd0/0x100
                                sp=3De00000404009fe30 bsp=3De000004040098f6=
0
 [<a000000100010d20>] ia64_invoke_kernel_thread_helper+0x20/0x40
                                sp=3De00000404009fe30 bsp=3De000004040098f6=
0
kernel BUG at fs/buffer.c:572!
diskfs[14888]: bugcheck! 0 [2]
                                                                           =
    =20
Pid: 14888, CPU 1, comm:               diskfs
psr : 0000101008026018 ifs : 800000000000038a ip  :
[<a000000100128020>]    Not tainted
ip is at end_buffer_async_write+0x2a0/0x400
unat: 0000000000000000 pfs : 002000000000038a rsc : 0000000000000003
rnat: 0000101008026018 bsps: a00000020006bb80 pr  : ffffffffc015a965
ldrs: 0000000000000000 ccv : 0000000000000004 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100128020 b6  : a000000100003320 b7  : a00000010008fbe0
f6  : 1003e0fc0fc0fc0fc0fc1 f7  : 0ffdbca80000000000000
f8  : 1003e0000000000000280 f9  : 1003e00000000000028a0
f10 : 1003e0000000010400000 f11 : 1003e000000003c893320
r1  : a0000001009f0000 r2  : 0000000000004000 r3  : 0000000000004000
r8  : 000000000000001f r9  : 0000000000000004 r10 : 0000000000000004
r11 : 0000000000000001 r12 : e000004068c47ac0 r13 : e000004068c40000
r14 : e000004068c47a60 r15 : a00000010080ce40 r16 : e000004068c40f10
r17 : e000004068c40f20 r18 : e000004068c40f24 r19 : 0000000000000000
r20 : e00000404cb98038 r21 : e000004068c40f20 r22 : 0000000000000001
r23 : 0000000000000000 r24 : 0000000000000073 r25 : e000004043ab0038
r26 : e000004043ab0040 r27 : e000004040225730 r28 : e000004040225728
r29 : e000004040225708 r30 : 0000000000000073 r31 : e000004068c4002c
                                                                           =
    =20
Call Trace:
 [<a0000001000205a0>] show_stack+0x80/0xa0
                                sp=3De000004068c47690 bsp=3De000004068c4185=
8
 [<a000000100044f50>] die+0x170/0x200
                                sp=3De000004068c47860 bsp=3De000004068c4182=
0
 [<a000000100045260>] ia64_bad_break+0x220/0x340
                                sp=3De000004068c47860 bsp=3De000004068c417f=
0
 [<a000000100019680>] ia64_leave_kernel+0x0/0x260
                                sp=3De000004068c478f0 bsp=3De000004068c417f=
0

 [<a000000100128020>] end_buffer_async_write+0x2a0/0x400
                                sp=3De000004068c47ac0 bsp=3De000004068c417a=
0
 [<a00000010012fd20>] end_bio_bh_io_sync+0xa0/0xc0
                                sp=3De000004068c47ae0 bsp=3De000004068c4178=
0
 [<a0000001001332f0>] bio_endio+0x110/0x160
                                sp=3De000004068c47ae0 bsp=3De000004068c4174=
8
 [<a00000010039a420>] __end_that_request_first+0x360/0x420
                                sp=3De000004068c47ae0 bsp=3De000004068c416d=
0
 [<a00000010044e490>] scsi_end_request+0x50/0x200
                                sp=3De000004068c47ae0 bsp=3De000004068c4168=
8
 [<a00000010044ec00>] scsi_io_completion+0x2a0/0x8a0
                                sp=3De000004068c47ae0 bsp=3De000004068c4161=
0
 [<a0000001004bdb30>] sd_rw_intr+0x170/0x520
                                sp=3De000004068c47ae0 bsp=3De000004068c415b=
8
 [<a0000001004437b0>] scsi_finish_command+0x270/0x2a0
                                sp=3De000004068c47ae0 bsp=3De000004068c4158=
8
 [<a000000100443420>] scsi_softirq+0x220/0x280
                                sp=3De000004068c47ae0 bsp=3De000004068c4154=
8
 [<a0000001000a40f0>] do_softirq+0x270/0x280
                                sp=3De000004068c47af0 bsp=3De000004068c414c=
0
 [<a00000010001d820>] do_IRQ+0x1e0/0x400
                                sp=3De000004068c47af0 bsp=3De000004068c4147=
0
 [<a00000010001f5c0>] ia64_handle_irq+0x80/0x140
                                sp=3De000004068c47af0 bsp=3De000004068c4143=
8
 [<a000000100019680>] ia64_leave_kernel+0x0/0x260
                                sp=3De000004068c47af0 bsp=3De000004068c4143=
8
 [<a0000001002ddc80>] __copy_user+0x120/0x920
                                sp=3De000004068c47cc0 bsp=3De000004068c4137=
0
 [<a0000001000dda60>] file_read_actor+0x240/0x260
                                sp=3De000004068c47cc0 bsp=3De000004068c4131=
8
 [<a0000001000dcd80>] do_generic_mapping_read+0x1e0/0xc80
                                sp=3De000004068c47cc0 bsp=3De000004068c4126=
8
 [<a0000001000dddb0>] __generic_file_aio_read+0x330/0x3c0
                                sp=3De000004068c47cc0 bsp=3De000004068c411f=
0
 [<a0000001000ddec0>] generic_file_aio_read+0x80/0xe0
                                sp=3De000004068c47ce0 bsp=3De000004068c411b=
8
 [<a000000100123360>] do_sync_read+0xe0/0x140
                                sp=3De000004068c47cf0 bsp=3De000004068c4117=
8
 [<a0000001001235c0>] vfs_read+0x200/0x2a0
                                sp=3De000004068c47e20 bsp=3De000004068c4112=
8
 [<a000000100123aa0>] sys_read+0x60/0xc0
                                sp=3De000004068c47e20 bsp=3De000004068c410b=
0
 [<a000000100019500>] ia64_ret_from_syscall+0x0/0x20
                                sp=3De000004068c47e30 bsp=3De000004068c410b=
0
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing

I was using a 2.6.4-rc2 kernel during the test, but I have also seen a
similar problem on 2.6.2.  The test runs a series of mkfs,     =20
tunefs, reads, and writes. =20

When run on just two disks with two partitions per disk, I can run the
test for days with no problems.  When I increase the number of disks to
5 or more, the test fails with the above BUG(s) within minutes.  I have
tried both SCSI disks using the sym53c8xxx driver and fibre-channel
disks using the qla2xxx driver with the same result. =20

I also tried running the same test on the ext2 file-system.  I did not
run into this bug, but instead got data corruption problems.  I get the
same data corruption problems on an ia32 system, so it is not a
ia64-only issue.



Andrew Patterson


--=20
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D
Andrew Patterson                Voice:  (970) 898-3261
Hewlett-Packard Company         Email:  andrew@fc.hp.com



--=-u7mIYFcJ5QScRTESNgyL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAT58uoKXgdXvblSgRAnruAJ9M30dWth2N9R9SD0K38boJAYBfMQCeO8Ig
pHSmmz0wBLLIM7WNtk2+lDg=
=IXhY
-----END PGP SIGNATURE-----

--=-u7mIYFcJ5QScRTESNgyL--

