From: Horms <horms@verge.net.au>
Date: Fri, 02 Jun 2006 11:48:06 +0000
Subject: IA64: Broken Serial Console
Message-Id: <20060602114805.GA1462@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <44128F9D.7050402@sgi.com> <200603112017.k2BKHcg20412@unix-os.sc.intel.com> <20060310082445.GA18715@verge.net.au> <yq0irqm39r8.fsf@jaguar.mkp.net> <20060311034346.GI11359@verge.net.au> <44128F9D.7050402@sgi.com> <20060313040825.GA31703@verge.net.au>
In-Reply-To: <20060313040825.GA31703@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Russell King <rmk+kernel@arm.linux.org.uk>

Hi,

I have noticed that the serial console on my ia64 machine seems
to have broken since 2.6.16. Thanks to git bisect I have been
able to track this problem down to 111c9bf8c5cfa92363b3719c8956d29368b5b9de

  [SERIAL] remove 8250_acpi (replaced by 8250_pnp and PNPACPI)

  With the combination of PNPACPI and 8250_pnp, we no longer need
  8250_acpi.

  Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
  Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

I haven't had time to look into the code and I have to leave
my desk shortly, so I thought I would post here to see if anyone
has any ideas.

I am boot using the following command line:

  console=tty0 console=uart,io,0x2f8 console=ttyS0

Althogh I'm pretty sure I really only need:

  console=uart,io,0x2f8

A failed boot looks like this:

  io scheduler anticipatory registered (default)
  Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
  isa bounce pool size: 16 pages
  RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
  mice: PS/2 mouse device common for all mice
  EFI Variables Facility v0.08 2004-May-17
  No ttyS device at I/O port 0x2f8 for console

And a successful boot looks like this:

  io scheduler anticipatory registered (default)
  Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
  acpi_serial_port: zero-length IO port range?
  serial8250: ttyS0 at I/O 0x3f8 (irq = 44) is a 16550A
  acpi_serial_port: zero-length IO port range?
  serial8250: ttyS1 at I/O 0x2f8 (irq = 45) is a 16550A
  isa bounce pool size: 16 pages
  RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
  mice: PS/2 mouse device common for all mice
  EFI Variables Facility v0.08 2004-May-17
  Adding console on ttyS1 at I/O port 0x2f8 (options '115200')

  prompt #

The machine in question is a Trus64-21. Sorry I don't have an English
link handy, but if you need me to dig up details please ask.

http://www.plathome.co.jp/factory/ser/tru_ita64_21.html

-- 
Horms                                           http://www.vergenet.net/~horms/

