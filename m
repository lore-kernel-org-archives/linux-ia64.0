From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 01 Aug 2005 15:36:47 +0000
Subject: Re: 2.6.13-rc3-mm3
Message-Id: <200508010936.47741.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050728025840.0596b9cb.akpm@osdl.org> <1122678354.20867.48.camel@lyra.fc.hp.com> <20050729161751.34705ac6.akpm@osdl.org>
In-Reply-To: <20050729161751.34705ac6.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Khalid Aziz <khalid_aziz@hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@intel.com

On Friday 29 July 2005 5:17 pm, Andrew Morton wrote:
> Khalid Aziz <khalid_aziz@hp.com> wrote:
> >
> > Serial console is broken on ia64 on an HP rx2600 machine on
> > 2.6.13-rc3-mm3. When kernel is booted up with "console=ttyS,...", no
> > output ever appears on the console and system is hung. So I booted the
> > kernel with "console=uart,mmio,0xff5e0000" to enable early console and
> > here is how far the kernel got before hanging:

> > Serial: 8250/16550 driver $Revision: 1.90 $ 6 ports, IRQ sharing enabled
> > ...
> > No ttyS device at MMIO 0xff5e0000 for console
> > 
> > Serial driver failed to find any serial ports. I am using defconfig. A
> > 2.6.13-rc3 kernel (no mm3 patch) compiled with defconfig boots up fine
> > and finds all serial ports.

Your rc3-mm3 boot is also missing this:

IOC: zx1 2.2 HPA 0xfed01000 IOVA space 1024Mb at 0x40000000

So something's busted with ACPI.  Both the IOC and the rx2600 serial
ports should be discovered via ACPI.
