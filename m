From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 19 Jan 2006 20:10:57 +0000
Subject: [PATCH 0/5] ia64 ioremap, DMI, EFI system table
Message-Id: <200601191310.57303.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <200601181029.46352.bjorn.helgaas@hp.com> <20060118181116.GA5537@lists.us.dell.com>
In-Reply-To: <20060118181116.GA5537@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Domsch <Matt_Domsch@dell.com>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org

OK, here's a set of patches to (hopefully) clean up this area
a bit:

1  Simplify efi_mem_attribute_range() so I can use it both for
   /dev/mem validation and ioremap() attribute checking.

2  Make ia64 ioremap() check memory attributes, so it works for
   plain memory that only supports write-back access, as well as
   for MMIO space that only supports uncacheable access.

3  DMI ioremaps too much space, which makes it fail on machines
   where the SMBIOS table is near the end of a memory region.

4  Keep EFI table addresses as physical, not virtual.  The SMBIOS
   address was physical on x86 but virtual on ia64, which broke
   dmi_scan_machine().

5  Use smarter ioremap() implementation to remove some cruft in
   acpi_os_{read,write,map}_memory().  This one's just an optional
   cleanup; I don't think it fixes any bugs.
