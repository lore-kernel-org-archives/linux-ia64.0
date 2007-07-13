From: Kallol Biswas <kallol@nucleodyne.com>
Date: Fri, 13 Jul 2007 23:54:02 +0000
Subject: debian 40r installation issue on IA 64
Message-Id: <426724.15340.qm@web58005.mail.re3.yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have been trying to install debian 40r0 on hp longs
peak itanium server. The installation hangs trying to
configure net....


EFI Time Services Driver v0.4
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports,
IRQ sharing enabled
00:04: ttyS0 at MMIO 0xff5e0000 (irq = 49) is a 16550A
00:05: ttyS1 at MMIO 0xff5e2000 (irq = 50) is a 16550A
GSI 82 (level, low) -> CPU 1 (0x0100) vector 51
ACPI: PCI Interrupt 0000:e0:01.0[A] -> GSI 82 (level,
low) -> IRQ 51
0000:e0:01.0: ttyS2 at MMIO 0xf8031000 (irq = 51) is a
16550A
ACPI: PCI Interrupt 0000:e0:01.1[A] -> GSI 82 (level,
low) -> IRQ 51
0000:e0:01.1: ttyS3 at MMIO 0xf8030000 (irq = 51) is a
16550A
Couldn't register serial port 0000:e0:01.1: -28
RAMDISK driver initialized: 16 RAM disks of 32768K
size 1024 blocksize
mice: PS/2 mouse device common for all mice
TCP bic registered
NET: Re                            
