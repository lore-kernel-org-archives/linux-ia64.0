From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 19 Jan 2005 22:00:42 +0000
Subject: RE: pgprot_writecombine & shub 1.x
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02C33743@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>On Wednesday, January 19, 2005 10:04 am, David Mosberger wrote:
>> Adding new routines for supporting this sounds reasonable, 
>but I think
>> it needs to be added to linux/efi.h, since EFI isn't ia64-specific.
>
>Something like this then?  Works for my test cases.
>
>Add a new EFI memory map checking function called 
>efi_range_is_wc for checking 
>if address ranges can be mapped with the WC (write coalescing) 
>attribute.  
>Useful for fbmem, userspace PCI mapping, and other places where write 
>combining might be beneficial but unavailable.

+	for (i = 0; i < len; i++) {
+		unsigned long paddr = __pa(start + i);
+		if (!(efi_mem_attributes(paddr) & EFI_MEMORY_WC))
+			return 0;
+	}

More EFI ignorance on my part ... do you really have to check
each *byte* of the address range, or is there some larger unit
that you could step by?  It doesn't seem rational that this
attribute could change for anything less than cache line size.

-Tony
