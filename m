From: Keith Owens <kaos@sgi.com>
Date: Wed, 01 Dec 2004 11:02:35 +0000
Subject: Out of order console initialization on HP CX2600
Message-Id: <7077.1101898955@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This problem has been reported against the SLES9 SP1 Beta3 ia64 debug
kernel on HP CX2600.  The ttySn ports are detected long after
console_init() has run, kdb detects no console and shuts down.

Why do the ttySn ports get detected after console_init() on HP?

Is there anything that can be done to detect ttySn before
console_init()?  EARLY_PRINTK is not an option, the kernel is compiled
for CONFIG_IA64_GENERIC, which disables EARLY_PRINK.

<4>Kernel command line: BOOT_IMAGE=scsi1:\efi\SuSE\vmlinuz-2.6.5-7.118-debug root=/dev/sda4 console=ttyS1,9600n8 ro
<3>kdb: Initialization failed - no console.  kdb is disabled.
<4>kdb version 4.4 by Keith Owens, Scott Lurndal. Copyright SGI, All Rights Reserved
<4>ttyS0 at MMIO 0xf4050000 (irq = 49) is a 16550A
<4>ttyS1 at MMIO 0xff5e0000 (irq = 59) is a 16550A
<4>ttyS2 at MMIO 0xff5e2000 (irq = 60) is a 16550A
<4>ttyS3 at MMIO 0xf4051000 (irq = 49) is a 16550A
Boot logging started on /dev/ttyS1(/dev/console) at Tue Nov 30 17:49:25 2004
/dev/ttyS0 at 0x0000 (irq = 49) is a 16550A
/dev/ttyS1 at 0x0000 (irq = 59) is a 16550A
/dev/ttyS2 at 0x0000 (irq = 60) is a 16550A
/dev/ttyS3 at 0x0000 (irq = 49) is a 16550A
Boot logging started on /dev/ttyS1(/dev/console) at Tue Nov 30 17:49:35 2004

