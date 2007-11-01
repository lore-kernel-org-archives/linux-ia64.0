From: Badari Pulavarty <pbadari@us.ibm.com>
Date: Thu, 01 Nov 2007 15:25:00 +0000
Subject: Re: [PATCH] Add IORESOUCE_BUSY flag for System RAM (Re: [Question]
Message-Id: <1193934490.26106.0.camel@dyn9047017100.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071003015242.GC12049@parisc-linux.org>
	 <20071003135702.bdcf3f1b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20071101181700.6D9A.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20071101181700.6D9A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, lkml <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>

On Thu, 2007-11-01 at 18:21 +0900, Yasunori Goto wrote:
> Hello.
> 
> I was asked from Kame-san to write this patch.
> 
> Please apply.
> 
> ---------
> i386 and x86-64 registers System RAM as IORESOURCE_MEM | IORESOURCE_BUSY.
> 
> But ia64 registers it as IORESOURCE_MEM only.
> In addition, memory hotplug code registers new memory as IORESOURCE_MEM too.
> 
> This patch adds IORESOURCE_BUSY for them to avoid potential overlap mapping
> by PCI device.
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> ---
>  arch/ia64/kernel/efi.c |    6 ++----
>  mm/memory_hotplug.c    |    2 +-
>  2 files changed, 3 insertions(+), 5 deletions(-)
> 
> Index: current/arch/ia64/kernel/efi.c
> =================================> --- current.orig/arch/ia64/kernel/efi.c	2007-11-01 15:24:05.000000000 +0900
> +++ current/arch/ia64/kernel/efi.c	2007-11-01 15:24:18.000000000 +0900
> @@ -1111,7 +1111,7 @@ efi_initialize_iomem_resources(struct re
>  		if (md->num_pages = 0) /* should not happen */
>  			continue;
> 
> -		flags = IORESOURCE_MEM;
> +		flags = IORESOURCE_MEM | IORESOURCE_BUSY;
>  		switch (md->type) {
> 
>  			case EFI_MEMORY_MAPPED_IO:
> @@ -1133,12 +1133,11 @@ efi_initialize_iomem_resources(struct re
> 
>  			case EFI_ACPI_MEMORY_NVS:
>  				name = "ACPI Non-volatile Storage";
> -				flags |= IORESOURCE_BUSY;
>  				break;
> 
>  			case EFI_UNUSABLE_MEMORY:
>  				name = "reserved";
> -				flags |= IORESOURCE_BUSY | IORESOURCE_DISABLED;
> +				flags |= IORESOURCE_DISABLED;
>  				break;
> 
>  			case EFI_RESERVED_TYPE:
> @@ -1147,7 +1146,6 @@ efi_initialize_iomem_resources(struct re
>  			case EFI_ACPI_RECLAIM_MEMORY:
>  			default:
>  				name = "reserved";
> -				flags |= IORESOURCE_BUSY;
>  				break;
>  		}
> 
> Index: current/mm/memory_hotplug.c
> =================================> --- current.orig/mm/memory_hotplug.c	2007-11-01 15:24:16.000000000 +0900
> +++ current/mm/memory_hotplug.c	2007-11-01 15:41:27.000000000 +0900
> @@ -39,7 +39,7 @@ static struct resource *register_memory_
>  	res->name = "System RAM";
>  	res->start = start;
>  	res->end = start + size - 1;
> -	res->flags = IORESOURCE_MEM;
> +	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
>  	if (request_resource(&iomem_resource, res) < 0) {
>  		printk("System RAM resource %llx - %llx cannot be added\n",
>  		(unsigned long long)res->start, (unsigned long long)res->end);
> 


Not quite.. You need following patch on top of this to make
hotplug memory remove work on ia64/x86-64.

Thanks,
Badari

Once you mark memory resource BUSY, walk_memory_resource() won't be able
to find it. 

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
---
 kernel/resource.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.24-rc1/kernel/resource.c
=================================--- linux-2.6.24-rc1.orig/kernel/resource.c	2007-10-23 20:50:57.000000000 -0700
+++ linux-2.6.24-rc1/kernel/resource.c	2007-11-01 08:19:59.000000000 -0700
@@ -277,7 +277,7 @@ walk_memory_resource(unsigned long start
 	int ret = -1;
 	res.start = (u64) start_pfn << PAGE_SHIFT;
 	res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
-	res.flags = IORESOURCE_MEM;
+	res.flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) && (find_next_system_ram(&res) >= 0)) {
 		pfn = (unsigned long)(res.start >> PAGE_SHIFT);


