From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 01 Oct 2012 16:28:20 +0000
Subject: Re: [RFC/PATCH v2] ia64, SR870, EFI bug breaks ata_piix, uninitialized ICH4 IDE EXBAR mem resource
Message-Id: <CAErSpo4ErJsp5pWNLsu3x4YL9ZrtxHfk0tkYL7hZaY5TmMtH+A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120916183914.Horde._TGALdjz9kRQVgCy6ATxxJA@webmail.df.eu>
 <20120917115619.13d3a3cb@pyramind.ukuu.org.uk> <20120920161603.Horde.aF7BBcL8999QWyUjk2AmsNA@webmail.df.eu>
 <CAErSpo6+WYE6wnj4CcKVidNHmg-oGH9SBsvg3QP9syC+vo09HQ@mail.gmail.com>
 <20120924190912.Horde.qznUIqGZi1VQYJO46HeGkwA@webmail.df.eu>
 <20120924235457.GA31372@google.com> <20120930000934.Horde.grdOKKGZi1VQZ3GeI_YW9ZA@webmail.df.eu>
In-Reply-To: <20120930000934.Horde.grdOKKGZi1VQZ3GeI_YW9ZA@webmail.df.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephan Schreiber <info@fs-driver.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, 679545@bugs.debian.org, jrnieder@gmail.com

On Sat, Sep 29, 2012 at 4:09 PM, Stephan Schreiber <info@fs-driver.org> wrote:
> Hello Bjorn,
> thank you very much for the patch.
> I tested it; it works.
>
> (typing mistake: it must read PCI_COMMAND_MEMORY instead of PCI_COMMAND_MEM
> at one location;
> some hunks of the patch couldn't be applied automatically on Kernel 3.2.23
> because some comments in the contexts are different)

Thanks a lot for testing this!  I'll fix up this typo and work on
getting something like this merged.

> The dmesg output:
>
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.2.0-3-mckinley (Debian 3.2.23-1)
> (debian-kernel@lists.debian.org) (gcc version 4.6.3 (Debian 4.6.3-8) ) #1
> SMP Fri Sep 28 21:57:11 CEST 2012
> ...
> [    0.065510] pci 0000:00:1f.1: [8086:24cb] type 0 class 0x000101
> [    0.065524] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
> [    0.065535] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
> [    0.065546] pci 0000:00:1f.1: reg 18: [io  0x0000-0x0007]
> [    0.065556] pci 0000:00:1f.1: reg 1c: [io  0x0000-0x0003]
> [    0.065567] pci 0000:00:1f.1: reg 20: [io  0x1000-0x100f]
> [    0.065578] pci 0000:00:1f.1: reg 24: [mem 0x00000000-0x000003ff unset]
> ...
> [    1.391380] libata version 3.00 loaded.
> [    1.391922] ata_piix 0000:00:1f.1: version 2.13
> [    1.391938] ata_piix 0000:00:1f.1: can't derive routing for PCI INT A
> [    1.392493] scsi0 : ata_piix
> [    1.392886] scsi1 : ata_piix
> [    1.393018] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1000 irq
> 34
> [    1.393066] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1008 irq
> 33
> [    1.557756] ata1.00: ATAPI: HL-DT-ST DVDRAM GSA-T40N, JR03, max UDMA/33
> [    1.573616] ata1.00: configured for UDMA/33
> [    1.579147] scsi 0:0:0:0: CD-ROM            HL-DT-ST DVDRAM GSA-T40N
> JR03 PQ: 0 ANSI: 5
> [    1.590806] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2
> cdda tray
> [    1.590872] cdrom: Uniform CD-ROM driver Revision: 3.20
> [    1.591272] sr 0:0:0:0: Attached scsi CD-ROM sr0
> [    1.593910] sr 0:0:0:0: Attached scsi generic sg0 type 5
> ...

>> On x86, Windows normally doesn't reconfigure PCI devices unless it
>> finds a problem with the configuration done by the BIOS.  I suspect
>> it works similarly on ia64.  I would guess that Windows noticed that
>> the MEM bit was not set, and therefore ignored the MEM BAR contents.
>
>
> Since I have the four Windows versions 'for Itanium Based Systems' on that
> box as well (XP, Server 2003, 2008, 2008 R2), I can tell you more:
> The Device Manager shows a memory range FFBFFC00-FFBFFFFF for the "Intel
> 82801DB Ultra ATA Storage Controller-24CB" - on any of these Windows
> versions.

Oh, that's good data, thanks!  It looks like Windows noticed that the
BAR was invalid and assigned a valid resource to it.  That's in the
third aperture below:

ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-01])
pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000fffff]
pci_root PNP0A03:00: host bridge window [mem 0xfa000000-0xfbffffff]
pci_root PNP0A03:00: host bridge window [mem 0xff000000-0xffffffff]
pci_root PNP0A03:00: host bridge window [mem 0xfec00000-0xfec0ffff]

Linux *should* probably do the same (though at a different actual
address because we assign bottom-up instead of top-down as Windows
does).  I don't know off the top of my head whether we actually do in
this case or not.

What's the output of "dmesg | grep 0000:00:1f.1; lspci -vs00:1f.1"?
