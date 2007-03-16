From: Jesse Barnes <jesse.barnes@intel.com>
Date: Fri, 16 Mar 2007 18:42:39 +0000
Subject: Re: [PATCH 2.6.18] PCI: Turn pci_fixup_video into generic for embedded VGA
Message-Id: <200703161142.39854.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <XNM1$9$0$4$$3$3$7$A$9002686U451b55cd@hitachi.com> <200609280936.02098.jesse.barnes@intel.com> <200703161120.46123.bjorn.helgaas@hp.com>
In-Reply-To: <200703161120.46123.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: eiichiro.oiwa.nm@hitachi.com, akpm@osdl.org, tony.luck@intel.com, greg@kroah.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Friday, March 16, 2007 10:20 am Bjorn Helgaas wrote:
> Are there really ia64 machines where we need to use the option ROM
> copy at 0xC0000?  If so, is this documented somewhere?  I couldn't
> find any mention in DIG64, EFI, or internal HP architecture specs.
>
> If we do need to use it, ia64 has a bit of a problem because on some
> boxes, the 0xC0000 memory supports only cacheable access, the VGA
> frame buffer at 0xA0000 supports only uncacheable access, and the
> usual ia64 ioremap mapping is a 16MB page that covers both.

Apparently Eichiro's machine needs it, and of course there are i386 and 
x86_64 machines that need it to, so it makes sense that it be generic.

Jesse
