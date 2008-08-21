From: Jay Lan <jlan@sgi.com>
Date: Thu, 21 Aug 2008 21:39:50 +0000
Subject: Memory needed for a kdump kernel has been bloated (reposted)
Message-Id: <48ADE0A6.3050008@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org, kexec@lists.infradead.org

Repost to include linux-ia64...

I have an IA64 system with 250G memory. I reserved 1024M memory for the
kdump kernel. It worked fine... up to 2.6.23.

Starting 2.6.24-rc1, booting a kdump kernel on the machine has been
failed on OOM. I tried 1280M, but still failed. I threw in 2048M and
then it worked. When OOM happened, it failed on allocating memory
for adding disk /dev/sdb.

I saw two problems here:
1) the memory needed has been bloated since 2.6.23, and
2) the system tried to add disk /dev/sdb through probe on booting
   kdump kernel when it is not even in /etc/fstab. I think only
   the system disk and the disk where we want to save the vmcore
   to should be needed. It would be nice if there is a way to
   initialize only the needed disk.

Below is part of the console messages on OOM.

- jay


...
Loading mptscsih
Loading mptsas
Fusion MPT SAS Host driver 3.04.06
ACPI: PCI Interrupt 0001:00:01.0[A] -> GSI 60 (level, low) -> IRQ 60
mptbase: ioc0: Initiating bringup
ioc0: LSISAS1068 B0: Capabilities=3D{Initiator}
scsi0 : ioc0: LSISAS1068 B0, FwRev=01100000h, Ports=3D1, MaxQQ1, IRQ`
scsi 0:0:0:0: Direct-Access     SGI      ST3146854SS      X421 PQ: 0 ANSI: 3
sd 0:0:0:0: [sda] 286749488 512-byte hardware sectors (146816 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, supports
DPO and FUA
sd 0:0:0:0: [sda] 286749488 512-byte hardware sectors (146816 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, supports
DPO and FUA
 sda: sda1 sda2 sda3 sda4 sda5 sda6 sda7 sda8 sda9 sda10 sda11
sd 0:0:0:0: [sda] Attached SCSI disk
ACPI: PCI Interrupt 0011:01:00.0[A] -> GSI 66 (level, low) -> IRQ 66
mptbase: ioc1: Initiating bringup
sd 0:0:0:0: Attached scsi generic sg0 type 0
mptbase: ioc1: ERROR - Diagnostic reset FAILED! (142h)
mptbase: ioc1: WARNING - NOT READY!
mptbase: ioc1: ERROR - didn't initialize properly! (-1)
mptsas: probe of 0011:01:00.0 failed with error -1
ACPI: PCI Interrupt 0031:00:01.0[A] -> GSI 70 (level, low) -> IRQ 70
mptbase: ioc2: Initiating bringup
ioc2: LSISAS1064 A3: Capabilities=3D{Initiator}
scsi1 : ioc2: LSISAS1064 A3, FwRev=01070000h, Ports=3D1, MaxQQ1, IRQp
scsi 1:0:0:0: Direct-Access     SGI      ST3146854SS      X421 PQ: 0 ANSI: 3
sd 1:0:0:0: [sdb] 286749488 512-byte hardware sectors (146816 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Write cache: disabled, read cache: enabled, supports
DPO and FUA
sd 1:0:0:0: [sdb] 286749488 512-byte hardware sectors (146816 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Write cache: disabled, read cache: enabled, supports
DPO and FUA
 sdb: sdb1 sdb2 sdb3 sdb4 sdb5 sdb6 sdb7 sdb8 sdb9 sdb10 sdb11
modprobe invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oomkilladj=3D0

Call Trace:
 [<a000000100014e40>] show_stack+0x40/0xa0
                                sp=E00000607108f670 bsp=E000006071081a70
 [<a000000100014ed0>] dump_stack+0x30/0x60
                                sp=E00000607108f840 bsp=E000006071081a58
 [<a00000010010e980>] oom_kill_process+0x80/0x3a0
                                sp=E00000607108f840 bsp=E000006071081a00
 [<a00000010010f660>] out_of_memory+0x520/0x6a0
                                sp=E00000607108f850 bsp=E0000060710819b0
 [<a000000100116c80>] __alloc_pages_internal+0x580/0x700
                                sp=E00000607108f8e0 bsp=E000006071081928
 [<a000000100116e90>] __alloc_pages+0x30/0x60
                                sp=E00000607108f8f0 bsp=E0000060710818f8
 [<a0000001001658a0>] new_slab+0x2a0/0x6c0
                                sp=E00000607108f8f0 bsp=E0000060710818a8
 [<a0000001001661c0>] __slab_alloc+0x500/0xae0
                                sp=E00000607108f8f0 bsp=E000006071081848
 [<a000000100169ca0>] __kmalloc_node+0x120/0x200
                                sp=E00000607108f900 bsp=E000006071081808
 [<a00000010016fd20>] percpu_populate+0x100/0x160
                                sp=E00000607108f900 bsp=E0000060710817c0
 [<a00000010016fdf0>] __percpu_populate_mask+0x70/0x160
                                sp=E00000607108f900 bsp=E000006071081780
 [<a00000010016ff80>] __percpu_alloc_mask+0xa0/0xe0
                                sp=E00000607108f940 bsp=E000006071081748
 [<a000000100212f10>] add_partition+0x50/0x380
                                sp=E00000607108f940 bsp=E0000060710816f0
 [<a000000100213e20>] rescan_partitions+0x4a0/0x520
                                sp=E00000607108f940 bsp=E000006071081690
 [<a0000001001d5220>] do_open+0x520/0x6e0
                                sp=E00000607108f940 bsp=E000006071081628
 [<a0000001001d5490>] __blkdev_get+0xb0/0xe0
                                sp=E00000607108f950 bsp=E0000060710815e0
 [<a0000001001d54f0>] blkdev_get+0x30/0x60
                                sp=E00000607108fad0 bsp=E0000060710815b0
 [<a000000100213850>] register_disk+0x230/0x360
                                sp=E00000607108fad0 bsp=E000006071081578
 [<a0000001004146a0>] add_disk+0xa0/0x140
                                sp=E00000607108fad0 bsp=E000006071081550
 [<a0000001005fbce0>] sd_probe+0x740/0x8a0
                                sp=E00000607108fad0 bsp=E0000060710814f8
 [<a00000010051a5c0>] driver_probe_device+0x220/0x360
                                sp=E00000607108fae0 bsp=E0000060710814c0
 [<a00000010051a810>] __device_attach+0x30/0x60
                                sp=E00000607108fae0 bsp=E000006071081498
 [<a000000100518a00>] bus_for_each_drv+0xa0/0x140
                                sp=E00000607108fae0 bsp=E000006071081460
 [<a00000010051a940>] device_attach+0xa0/0xe0
                                sp=E00000607108fb00 bsp=E000006071081430
 [<a0000001005185d0>] bus_attach_device+0x70/0x100
                                sp=E00000607108fb00 bsp=E000006071081400
 [<a000000100515990>] device_add+0x810/0xb40
                                sp=E00000607108fb00 bsp=E000006071081390
 [<a0000001005cd5e0>] scsi_sysfs_add_sdev+0x160/0x480
                                sp=E00000607108fb00 bsp=E000006071081350
 [<a0000001005c8d00>] scsi_probe_and_add_lun+0x10a0/0x1340
                                sp=E00000607108fb00 bsp=E0000060710812e0
 [<a0000001005c9590>] __scsi_scan_target+0x150/0xb00
                                sp=E00000607108fb30 bsp=E000006071081290
 [<a0000001005caa00>] scsi_scan_target+0x120/0x160
                                sp=E00000607108fb90 bsp=E000006071081240
 [<a0000002024926a0>] sas_rphy_add+0x300/0x340 [scsi_transport_sas]
                                sp=E00000607108fb90 bsp=E000006071081200
 [<a000000202602240>] mptsas_probe_one_phy+0x900/0x9c0 [mptsas]
                                sp=E00000607108fb90 bsp=E0000060710811a8
 [<a000000202603be0>] mptsas_probe_hba_phys+0xe20/0xf00 [mptsas]
                                sp=E00000607108fbb0 bsp=E000006071081150
 [<a000000202607080>] mptsas_probe+0x7c0/0x960 [mptsas]
                                sp=E00000607108fcf0 bsp=E0000060710810e8
 [<a00000010044e730>] pci_device_probe+0x170/0x240
                                sp=E00000607108fd00 bsp=E000006071081090
 [<a00000010051a5c0>] driver_probe_device+0x220/0x360
                                sp=E00000607108fd80 bsp=E000006071081058
 [<a00000010051a780>] __driver_attach+0x80/0xe0
                                sp=E00000607108fd80 bsp=E000006071081020
 [<a000000100519070>] bus_for_each_dev+0x90/0x100
                                sp=E00000607108fd80 bsp=E000006071080fe0
 [<a00000010051a160>] driver_attach+0x40/0x60
                                sp=E00000607108fda0 bsp=E000006071080fc0
 [<a000000100519b00>] bus_add_driver+0x160/0x4a0
                                sp=E00000607108fda0 bsp=E000006071080f78
 [<a00000010051ae30>] driver_register+0x1b0/0x300
                                sp=E00000607108fda0 bsp=E000006071080f30
 [<a00000010044ecd0>] __pci_register_driver+0xb0/0x140
                                sp=E00000607108fda0 bsp=E000006071080ef8
 [<a0000002026301e0>] mptsas_init+0x1e0/0x320 [mptsas]
                                sp=E00000607108fdb0 bsp=E000006071080ec8
 [<a0000001000e6990>] sys_init_module+0x3610/0x3940
                                sp=E00000607108fdb0 bsp=E000006071080d48
 [<a00000010000af80>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000607108fe30 bsp=E000006071080d48
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000006071090000 bsp=E000006071080d48
