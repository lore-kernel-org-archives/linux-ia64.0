From: Chris Blazie <cblazie@yahoo.com>
Date: Wed, 29 May 2002 00:35:14 +0000
Subject: [Linux-ia64] kernel boot failure
Message-Id: <marc-linux-ia64-105590701905606@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,
     I just started working with an HP RX4610 (4
Itaniums, 16gb) running RedHat Linux.  I wasn't
present for the initial RH installation, but I
understand it installed cleanly.  It was running
2.4.9-18.

     I installed an Emulex HBA and managed to compile
the driver modules against 2.4.18 (wouldn't compile
against 2.4.9).  So I went ahead and built a new
2.4.18 kernel, initrd, added both to elilo.conf, and
rebooted.  No luck; I tried twice to boot the new
kernel but only got kicked back to the efi.  I decided
it was probably a problem with the initrd file, and
tried to boot back to the 2.4.9 kernel.  And got a
kernel panic.  Then tried the alternate uniprocessor
kernel; no panic, but no boot either (output identical
to first set of messages below).  For a reality check
I tried to boot from the installation CD, and it STILL
hangs with the message:  Error:  only one processor
found.
In desperation we re-formatted the scsi drives and
tried again without success.  We also tried booting
the Windows Netserver CD, and it hangs as well (no
messages of course).

     So there must be a hardware or firmware problem
here.  But before we begin swapping parts and/or
upgrading the bios, I wrote down the boot messages
leading to the hang (and panic in a separate case) in
hopes someone here could shed some light on what stage
of the boot process is failing (and maybe why).

Thanks,
Chris

ia64_mca_platform_init:  corrected platform error
vector 0x1e setup and enabled
MCA initialization done.
One node 0 totalpages:  1179647
zone(0):  262144 pages
zone(1):  0 pages
zone(2):  917503 pages
kernel command line:  BOOT_IMAGE=3Datapi0:/vmlinuz
ramdisk_size=12288 maxcpus=3D1 ro
fpswa interface at 47fee4010 ITC freq=800.222
CPU 0:  base freq=133.370mhz, ITC ratio=12/2
Console:  color VGA+ 80X25
Calibrating delay loop...797.80 bogoMIPS
Memory 16597424k/18874352k available (4006k code,
167232k reserved, 2802k data, 352k init)
Dentry-cache hash table entries 1048576 (order:  10,
16777216 bytes)
Inode-cache hash table entries 1048576 (order 8,
4194384 bytes)
Buffer cache hash table entries 1048576 (order 9,
838608 bytes)
Page-cache hash table entries 1048576 (order 8,
4194384 bytes)
POSIC conformance testing by UNIFIX
Boot processor id 0x0/0x200
Limiting CPUs to 1
SMP:  starting up secondaries
Before bogomips.
Error:  only one processor found

-------------------------------------

If I pass maxcpus=3D4 on the kernel command line, I get
a kernel panic.  Here are the decoded traces that I
could see:

decoded to ia_64_leave_kernel [kernel] 0x0
bh_action [kernel] 0xe0
tasklet_hi_action [kernel] 0x250
do_softirq [kernel] 0x140
ia64_handle_irq [kernel] 0x100
ia64_leave_kernel [kernel] 0x0
do_boot_cpu [kernel] 0x4e0
smp_boot_cpus [kernel] 0x3e0
smp_init [kernel] 0x20
start_kernel [kernel] 0x460
start_ap [kernel] 0x160
kernel panic  Aiee, killing interrupt handler
In interrupt handler -- not syncing


__________________________________________________
Do You Yahoo!?
Yahoo! - Official partner of 2002 FIFA World Cup
http://fifaworldcup.yahoo.com

