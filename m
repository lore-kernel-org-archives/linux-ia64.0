From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 18 Jul 2007 21:04:29 +0000
Subject: Re: debian 40r installation issue on IA 64
Message-Id: <200707181504.29930.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <426724.15340.qm@web58005.mail.re3.yahoo.com>
In-Reply-To: <426724.15340.qm@web58005.mail.re3.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 13 July 2007 05:54:02 pm Kallol Biswas wrote:
> I have been trying to install debian 40r0 on hp longs
> peak itanium server. The installation hangs trying to
> configure net....

I copied the debian-ia64 list, which is probably a better place to
start.

The HP management processor contains a virtual UART that is
implemented partly in hardware and partly in firmware.  There
have been a number of issues related to the fact that it is not
a real 16550 UART.

Here's a summary of the issues I know about.  My guess is that
you're seeing the first one, so I'd start by checking your
MP firmware revision.

  * serial console device lockup
    - system responds via network
    - no input or output via serial console device
    - occurs when application opens device while transmit buffer contains
      polled-mode kernel output, typically during boot
    - INIT dump shows CPUs in idle loop
    - after system reset, MP event log shows "BOOT_PLAT_CONSOLE_DEV_FAILED"
      or similar event
    - hang is resolved only by MP reset; system reset is not sufficient
    - resolved in MP firmware E.03.29 or later (rx16x0, rx26x0, rx4640, rx5670)
    - resolved in MP firmware F.01.39 or later (rx3600, rx6600)

  * serial console driver deadlock
    - system completely unresponsive to all devices
    - INIT dump shows one or more CPUs in ia64_spinlock_contention,
      waiting for a ttyS UART lock (lock ptr in r31)

  * serial device out of sync with driver
    - system responds via network
    - serial output stops
    - sending serial input generates an interrupt that causes up to 16
      more characters of output
    - re-opening the device fixes the problem

  * serial device drops interrupt
    - system responds via network
    - serial output stops
    - sending serial input generates an interrupt that resolves the problem

> EFI Time Services Driver v0.4
> Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
> 00:04: ttyS0 at MMIO 0xff5e0000 (irq = 49) is a 16550A
> 00:05: ttyS1 at MMIO 0xff5e2000 (irq = 50) is a 16550A
> GSI 82 (level, low) -> CPU 1 (0x0100) vector 51
> ACPI: PCI Interrupt 0000:e0:01.0[A] -> GSI 82 (level, low) -> IRQ 51
> 0000:e0:01.0: ttyS2 at MMIO 0xf8031000 (irq = 51) is a 16550A
> ACPI: PCI Interrupt 0000:e0:01.1[A] -> GSI 82 (level, low) -> IRQ 51
> 0000:e0:01.1: ttyS3 at MMIO 0xf8030000 (irq = 51) is a 16550A
> Couldn't register serial port 0000:e0:01.1: -28
> RAMDISK driver initialized: 16 RAM disks of 32768K size 1024 blocksize
> mice: PS/2 mouse device common for all mice
> TCP bic registered
> NET: Re                            
