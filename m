From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Thu, 17 Jul 2003 17:43:19 +0000
Subject: RE: [PATCH] remove pa->va->pa conversion for efi.acpi
Message-Id: <marc-linux-ia64-105846382809995@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105797540229907@msgid-missing>
In-Reply-To: <marc-linux-ia64-105797540229907@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

> I'm OK with the change in principle, but the patch as sent is
> unacceptable because it leaves "acpi" and "acpi20" declared 
> as "void *"
> (in struct efi").  If you want them to by physical addresses, this
> should be changed to "unsigned long" (or perhaps u32 for acpi and u64
> for acpi20?).  It would be good to rename the members as well (e.g.,
> acpi_phys_addr/acpi20_phys_addr) to make sure that old code will
> break at compile-time, not at run-time.

Sounds good.  I've changed these to unsigned long and added the phys_addr to the names...

> Does ACPI really guarantee that the table is never stored at physical
> address 0?  If not, then leaving it as a virtual address might be
> safer.  (Yes, I know it's very unlikely for today's system, but at
> least on ia64, pfn 0 is normal RAM so it seems at least in principle
> possible to store the ACPI table there).
> 

No guarantee that I could find...I suppose this is technically possible. :)  However, considering the ACPI routines expect a physical address and thus immediately map it to get the descriptor (either directly with virt_to_phys or via ioremap), this seems redundant.  Given the mapping scheme employed, is this still risky?  I'd like to reuse the same code path for ia32, but don't want to break ia64.     

thanks,
matt   
