From: Jesse Barnes <jesse.barnes@intel.com>
Date: Tue, 26 Sep 2006 15:48:53 +0000
Subject: Re: [PATCH 2.6.18] IA64: Add pci_fixup_video into IA64 kernel for embedded VGA
Message-Id: <200609260848.53556.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <XNM1$9$0$4$$3$3$7$A$9002681U4518d9f9@hitachi.com> <200609260909.12876.bjorn.helgaas@hp.com>
In-Reply-To: <200609260909.12876.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: eiichiro.oiwa.nm@hitachi.com, akpm@osdl.org, tony.luck@intel.com, greg@kroah.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tuesday, September 26, 2006 8:09 am, Bjorn Helgaas wrote:
> On Tuesday 26 September 2006 01:42, eiichiro.oiwa.nm@hitachi.com wrote:
> > To be compatible with Xorg's handling of PCI, we need pci_fixup_video
> > on IA64 platform like x86 platform. There are also machines, which
> > have VGA embedded into main board, among IA64 platform. Embedded VGA
> > generally don't have PCI ROM, and there are VGA ROM image in System
> > BIOS. Therefore, these machines need pci_fixup_video for the sysfs
> > rom. pci_fixup_video already exists in x86 Linux kernel. However since
> > this function doesn't exist in IA64 kernel, we could not run X server
> > on IA64 box has embedded-VGA.
> >
> > I tested pci_fixup_video on IA64 box has embedded-VGA. I confirmed we
> > can read VGA BIOS from the sysfs rom regardless of embedded-VGA.
>
> What other architectures will need this?  There's nothing ia64-specific
> in the patch below.  Can it be put somewhere more generic?

It could go into drivers/pci, but setting the flag implies that the ROM is 
at 0xc0000, so it does have some arch dependencies (though at least x86, 
x86_64 and ia64 have machines that do this).

Jesse
