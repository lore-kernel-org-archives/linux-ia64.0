From: Stephan Schreiber <info@fs-driver.org>
Date: Mon, 24 Sep 2012 17:09:12 +0000
Subject: Re: [RFC/PATCH v2] ia64, SR870, EFI bug breaks ata_piix, uninitialized ICH4 IDE EXBAR mem resource
Message-Id: <20120924190912.Horde.qznUIqGZi1VQYJO46HeGkwA@webmail.df.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120916183914.Horde._TGALdjz9kRQVgCy6ATxxJA@webmail.df.eu>
 <20120917115619.13d3a3cb@pyramind.ukuu.org.uk>
 <20120920161603.Horde.aF7BBcL8999QWyUjk2AmsNA@webmail.df.eu>
 <CAErSpo6+WYE6wnj4CcKVidNHmg-oGH9SBsvg3QP9syC+vo09HQ@mail.gmail.com>
In-Reply-To: <CAErSpo6+WYE6wnj4CcKVidNHmg-oGH9SBsvg3QP9syC+vo09HQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, 679545@bugs.debian.org, jrnieder@gmail.com

Mpfff, there aren't many replies; seems I didn't satisfy what you want  
to have...

At first I want to mention that I just want to help the Debian project  
and started testing Debian Wheezy my old ia64 box.
Since these are my first messages on the kernel lists, I really don't  
feel me in a position to tell you what's right or wrong for the Kernel  
- I guess you have much more Linux Kernel knowledge than me.


> The firmware left the memory BAR at 0x24 cleared (0x00000000), but it
> also left the MEM bit in the command register disabled.  So it seems
> like a Linux bug that we're trying to use that zero address from the
> BAR.  If the firmware left the MEM or IO decode enable bit cleared,
> why would we assume it put anything useful in the corresponding BARs?

Your idea would be a fundamental change in the Kernel; I just want to  
fix the ata_piix problem in Debian Wheezy.

I can't tell you whether the developer of the EFI thought this. Maybe  
it is simply a bug.
If you would evaluate the command registers, which the BIOS or EFI has  
initialized, you would work around some wrong BARs. You might run into  
trouble due to wrong command register values instead.
Are you sure that any BIOS or EFI sets the command registers correctly?

Currently the Linux Kernel sets and clears the IORESOURCE_MEM and  
IORESOURCE_IO bits in the command registers as needed.
Windows reconfigures any PCI device. The settings of the BIOS or EFI  
do not matter at all; the user doesn't experience any BIOS bug at all.





> This still isn't very generic.  It only looks at BAR 5 and only for
> IDE controllers, so it fixes the problem for this device and this
> BIOS, but there's no reason the same problem couldn't happen on other
> devices and other BARs.
>
> My proposal was basically:
>
>     pci_read_config_word(dev, PCI_COMMAND, &cmd);
>     for (i = 0; i < 6; i++) {
>         /* read BAR i here */
>         r = dev->resource[i];
>         if (((r->flags & IORESOURCE_MEM) && (cmd & PCI_COMMAND_MEMORY)) ||
>             ((r->flags & IORESOURCE_IO) && (cmd & PCI_COMMAND_IO))) {
>             /* treat resource as valid */
>         } else {
>             /* treat resource as unassigned; try to assign it later */
>         }
>     }

Both of my two patches hide the BAR5 when we know that BAR5 is not functional.
The first patch makes sure that the PCI device id matches; the second  
one checks whether it is an ide controller in legacy mode. The  
associated ide/piix or ata/ata_piix doesn't need the BAR5 memory  
resource at all.
The other BARs are functional and needed.

I don't know what regression can occur when you hide *any*  
uninitialized BAR of *any* pci device. Some drivers might be screwed  
up when a needed mem resource is absend - after pci_enable_device() or  
pcim_enable_device() returned success.



Ben Hutchings of the Debian project pointed to some interesting detail  
about ide/piix:
"By the way, the reason the old IDE driver worked is that
drivers/ide/setup-pci.c has a fallback for this:

	if (pci_enable_device(dev)) {
		ret = pci_enable_device_io(dev);

It was added almost exactly 10 years ago without any specific comment."


Debian had both ide/piix and ata/ata_piix in the past. When ata_piix  
didn't initialize, ide/piix took over the device. The user didn't  
experience any problem.
The old ide/piix has been removed with recent Debian versions (due to  
problems with shared interrupts). Thus, the ICH4 problem is on the  
table again.


Since you don't want to take my patches, I need some new ideas. The  
patch shouldn't be a fundamental, experimental change with the risk of  
regression because it is intended for a *stable* Debian release.

Suggestions or comments are appreciated.

Stephan


