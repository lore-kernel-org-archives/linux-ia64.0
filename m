From: Greg KH <greg@kroah.com>
Date: Fri, 22 Apr 2005 15:15:17 +0000
Subject: Re: [ACPI] [RFC/PATCH 3/3] ACPI based I/O APIC hot-plug
Message-Id: <20050422151517.GA29039@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4267AD21.7040006@jp.fujitsu.com> <1114104131.2784.43.camel@eeyore> <42689BEB.90401@jp.fujitsu.com> <1114181881.4902.4.camel@eeyore>
In-Reply-To: <1114181881.4902.4.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
Cc: Kenji Kaneshige <kaneshige.kenji-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pcihpd-discuss-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

On Fri, Apr 22, 2005 at 08:58:01AM -0600, Bjorn Helgaas wrote:
> On Fri, 2005-04-22 at 15:38 +0900, Kenji Kaneshige wrote:
> > Bjorn Helgaas wrote:
> > > 
> > >>+		if ((dev->class >> 8) != PCI_CLASS_SYSTEM_PIC)
> > >>+			continue;
> > >>+		if ((dev->class & 0xff) = 0x10 || (dev->class & 0xff) = 0x20)
> > > 
> > > 
> > > What are 0x10 and 0x20?  Looks like they should be #defines in
> > > include/linux/pci_ids.h.
> > 
> > 0x10 and 0x20 are programing interfaces for I/O APIC and I/O xAPIC
> > respectively. #define for these values looks good. But I don't know
> > if I can put new #defines into pci_ids.h and how to name them because
> > I could not find the header file (including pci_ids.h) that #defines
> > the values for programming interfaces. So I want to add the comments
> > to explain these values (0x10, 0x20) instead of adding new #defines into
> > pci_ids.h for now.
> 
> I think your patch should just add the values to pci_ids.h.  If
> somebody doesn't like that, he or she will complain and you can fall
> back to just using 0x10 and 0x20.  But I suspect it will be fine.

Yes, I have no problem with that.

thanks,

greg k-h
