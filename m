From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 14 Apr 2004 15:25:38 +0000
Subject: Re: oops in serial_out in 2.6.5
Message-Id: <200404140925.38296.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413063757.GA11350@hp.com>
In-Reply-To: <20040413063757.GA11350@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 13 April 2004 5:55 pm, Martin Pool wrote:
> /dev/ttyS0 uart 16550A port 0x0000 irq 59 baud_base 115200 spd_normal skip_test
> auto_irq
> /dev/ttyS1 uart 16550A port 0x0000 irq 60 baud_base 115200 spd_normal skip_test
> auto_irq
> /dev/ttyS2 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_test
> /dev/ttyS3 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_test
> /dev/ttyS4 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_test
> /dev/ttyS5 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_test

Notice that setserial is missing some smarts about MMIO UARTS (see
the "port 0x0000" above).  I poked at this a while back, but it seemed
sort of ugly to fix, IIRC.  Removing setserial seemed to be the
easiest workaround.

> Apr 13 16:18:25 kate kernel: Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
> Apr 13 16:18:25 kate kernel: ttyS0 at MMIO 0xf4050000 (irq = 49) is a 16550A
> Apr 13 16:18:25 kate kernel: GSI 0x22(high,edge) -> CPU 0x0000 vector 75
> Apr 13 16:18:25 kate kernel: ttyS1 at MMIO 0xff5e0000 (irq = 75) is a 16550A
> Apr 13 16:18:25 kate kernel: GSI 0x23(high,edge) -> CPU 0x0000 vector 76
> Apr 13 16:18:25 kate kernel: ttyS2 at MMIO 0xff5e2000 (irq = 76) is a 16550A
> Apr 13 16:18:25 kate kernel: PCI: Found IRQ 49 for device 0000:e0:01.0
> Apr 13 16:18:25 kate kernel: IOSAPIC: vector 49 -> CPU 0x0100, enabled
> Apr 13 16:18:25 kate kernel: ttyS3 at MMIO 0xf4051000 (irq = 49) is a 16450
> Apr 13 16:18:25 kate kernel: PCI: Found IRQ 49 for device 0000:e0:01.1
> Apr 13 16:18:25 kate kernel: IOSAPIC: vector 49 -> CPU 0x0000, enabled
> Apr 13 16:18:25 kate kernel: Couldn't register serial port 0000:e0:01.1: -28
