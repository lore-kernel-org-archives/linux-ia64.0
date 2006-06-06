From: Horms <horms@verge.net.au>
Date: Tue, 06 Jun 2006 04:13:15 +0000
Subject: ia64 kexec bug/warning
Message-Id: <20060606041314.GA27066@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

I am seeing the following when I kexec -e on ia64, is it anything to
worry about? The kexec seems to succeed regardless.

Synchronizing SCSI cache for disk sda:=20
ACPI: PCI interrupt for device 0000:04:01.1 disabled
GSI 25 (level, low) -> CPU 1 (0x0000) vector 49 unregistered
ACPI: PCI interrupt for device 0000:04:01.0 disabled
GSI 24 (level, low) -> CPU 0 (0x0100) vector 48 unregistered
Starting new kernel
ACPI: PCI interrupt for device 0000:03:01.0 disabled
GSI 48 (level, low) -> CPU 0 (0x0100) vector 50 unregistered
ACPI: PCI interrupt for device 0000:03:01.1 disabled
GSI 49 (level, low) -> CPU 0 (0x0100) vector 51 unregistered
BUG: warning at arch/ia64/kernel/irq.c:155/migrate_irqs()

Call Trace:
 [<a0000001000124d0>] show_stack+0x50/0xa0
                                sp=E00000007d277b20 bsp=E00000007d271128
 [<a000000100012550>] dump_stack+0x30/0x60
                                sp=E00000007d277cf0 bsp=E00000007d271110
 [<a0000001000112c0>] fixup_irqs+0x4a0/0x5c0
                                sp=E00000007d277cf0 bsp=E00000007d2710d8
 [<a000000100056920>] __cpu_disable+0x5c0/0x660
                                sp=E00000007d277d80 bsp=E00000007d271088
 [<a0000001000ccfa0>] take_cpu_down+0x20/0x80
                                sp=E00000007d277dc0 bsp=E00000007d271070
 [<a0000001000dd8e0>] do_stop+0x280/0x3a0
                                sp=E00000007d277dc0 bsp=E00000007d271030
 [<a0000001000befd0>] kthread+0x230/0x2a0
                                sp=E00000007d277dd0 bsp=E00000007d270fe8
 [<a000000100014990>] kernel_thread_helper+0xd0/0x100
                                sp=E00000007d277e30 bsp=E00000007d270fc0
 [<a0000001000094c0>] start_kernel_thread+0x20/0x40
                                sp=E00000007d277e30 bsp=E00000007d270fc0
Unexpected irq vector 0x31 on CPU 1!
CPU 1 is now offline
Linux version 2.6.17-rc5-g3fca936d-dirty (horms@XXX) (gcc version 3.4.5) #5=
8 SMP Mon Jun 5 12:46:43 JST 2006


I'm using Tony Luck's ia64 git tree from kernel.org, testing branch,
commit 3fca936d5a72905679b0389c7669013e788041c9, latest as of yesterday.

Hardware is the following (Japanese)
http://www.plathome.co.jp/factory/ser/tru_ita64_21.html


--=20
Horms                                           http://www.vergenet.net/~ho=
rms/

