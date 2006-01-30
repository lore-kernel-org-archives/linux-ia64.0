From: Matt Domsch <Matt_Domsch@dell.com>
Date: Mon, 30 Jan 2006 17:11:31 +0000
Subject: Re: [Openipmi-developer] [PATCH 0/5] ia64 ioremap, DMI, EFI system table
Message-Id: <20060130171131.GA24947@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <200601181029.46352.bjorn.helgaas@hp.com> <20060118181116.GA5537@lists.us.dell.com> <200601191310.57303.bjorn.helgaas@hp.com>
In-Reply-To: <200601191310.57303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org

On Thu, Jan 19, 2006 at 01:10:57PM -0700, Bjorn Helgaas wrote:
> OK, here's a set of patches to (hopefully) clean up this area
> a bit:
> 
> 1  Simplify efi_mem_attribute_range() so I can use it both for
>    /dev/mem validation and ioremap() attribute checking.
> 
> 2  Make ia64 ioremap() check memory attributes, so it works for
>    plain memory that only supports write-back access, as well as
>    for MMIO space that only supports uncacheable access.
> 
> 3  DMI ioremaps too much space, which makes it fail on machines
>    where the SMBIOS table is near the end of a memory region.
> 
> 4  Keep EFI table addresses as physical, not virtual.  The SMBIOS
>    address was physical on x86 but virtual on ia64, which broke
>    dmi_scan_machine().
> 
> 5  Use smarter ioremap() implementation to remove some cruft in
>    acpi_os_{read,write,map}_memory().  This one's just an optional
>    cleanup; I don't think it fixes any bugs.


This set of patches works for me on my IA64 Tiger4 (Dell PowerEdge
7250) in kernel 2.6.16-rc1-mm4.  modprobe ipmi_si successfully
automatically finds the IPMI controller now.

Thanks Bjorn for doing a more complete cleanup in support of this!

Thanks,
Matt

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
