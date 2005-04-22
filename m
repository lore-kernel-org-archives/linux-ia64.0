From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 22 Apr 2005 06:38:35 +0000
Subject: Re: [ACPI] [RFC/PATCH 3/3] ACPI based I/O APIC hot-plug
Message-Id: <42689BEB.90401@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4267AD21.7040006@jp.fujitsu.com> <1114104131.2784.43.camel@eeyore>
In-Reply-To: <1114104131.2784.43.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Andrew Morton <akpm@osdl.org>, Len Brown <len.brown@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Greg KH <greg@kroah.com>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net

Bjorn Helgaas wrote:
> 
>>+		if ((dev->class >> 8) != PCI_CLASS_SYSTEM_PIC)
>>+			continue;
>>+		if ((dev->class & 0xff) = 0x10 || (dev->class & 0xff) = 0x20)
> 
> 
> What are 0x10 and 0x20?  Looks like they should be #defines in
> include/linux/pci_ids.h.

0x10 and 0x20 are programing interfaces for I/O APIC and I/O xAPIC
respectively. #define for these values looks good. But I don't know
if I can put new #defines into pci_ids.h and how to name them because
I could not find the header file (including pci_ids.h) that #defines
the values for programming interfaces. So I want to add the comments
to explain these values (0x10, 0x20) instead of adding new #defines into
pci_ids.h for now.

Thanks,
Kenji Kaneshige
