From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 17 Sep 2012 21:41:41 +0000
Subject: Re: [RFC/PATCH] ia64, SR870, EFI bug breaks ata_piix, uninitialized ICH4 IDE EXBAR mem resource
Message-Id: <CAErSpo6j==2_HsLrMsJ30SFZkG6q_JqrcKe=XMa1Woy4C_if5Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120916183914.Horde._TGALdjz9kRQVgCy6ATxxJA@webmail.df.eu>
In-Reply-To: <20120916183914.Horde._TGALdjz9kRQVgCy6ATxxJA@webmail.df.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephan Schreiber <info@fs-driver.org>
Cc: linux-ia64@vger.kernel.org, alan@lxorguk.ukuu.org.uk, linux-pci@vger.kernel.org, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, 679545@bugs.debian.org, jrnieder@gmail.com

On Sun, Sep 16, 2012 at 10:39 AM, Stephan Schreiber <info@fs-driver.org> wrote:

> [    0.065516] pci 0000:00:1f.1: [8086:24cb] type 0 class 0x000101
> [    0.065530] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
> [    0.065541] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
> [    0.065552] pci 0000:00:1f.1: reg 18: [io  0x0000-0x0007]
> [    0.065563] pci 0000:00:1f.1: reg 1c: [io  0x0000-0x0003]
> [    0.065574] pci 0000:00:1f.1: reg 20: [io  0x1000-0x100f]
> [    0.065585] pci 0000:00:1f.1: reg 24: [mem 0x00000000-0x000003ff]
> ...
> [    1.640965] libata version 3.00 loaded.
> [    1.641656] ata_piix 0000:00:1f.1: version 2.13
> [    1.641671] ata_piix 0000:00:1f.1: device not available (can't reserve
> [mem 0x00000000-0x000003ff])
> [    1.641747] ata_piix: probe of 0000:00:1f.1 failed with error -22
> ...
>
> lspci -vvxxx reports:
>
> 00:1f.1 IDE interface: Intel Corporation 82801DB (ICH4) IDE Controller (rev
> 02) (prog-if 8a [Master SecP PriP])
>         Subsystem: Intel Corporation Device 3404
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 0
>         Region 0: I/O ports at 01f0 [size=8]
>         Region 1: I/O ports at 03f4 [size=1]
>         Region 2: I/O ports at 0170 [size=8]
>         Region 3: I/O ports at 0374 [size=1]
>         Region 4: I/O ports at 1000 [size]
> 00: 86 80 cb 24 05 00 80 02 02 8a 01 01 00 00 00 00
> 10: 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00
> 20: 01 10 00 00 00 00 00 00 00 00 00 00 86 80 04 34
> 30: 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00

I agree that we should have a generic way to do this rather than an
ia64-specific way.  In this case you have EFI, but the same thing
could happen with BIOS.

The firmware left the memory BAR at 0x24 cleared (0x00000000), but it
also left the MEM bit in the command register disabled.  So it seems
like a Linux bug that we're trying to use that zero address from the
BAR.  If the firmware left the MEM or IO decode enable bit cleared,
why would we assume it put anything useful in the corresponding BARs?

What would break if we paid attention to the command register enables
in the PCI core and just cleared the resource flags for MEM BARs if
the MEM-decode bit was off, and those for IO BARs if the IO-decode bit
was off?

I don't know much of the ancient history here, so maybe there's a good
reason why this works the way it currently does.

Bjorn
