From: "Sourav Sen" <souravs@india.hp.com>
Date: Thu, 06 May 2004 16:37:35 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <004f01c43386$c3301900$39624c0f@india.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <200405060908.39311.bjorn.helgaas@hp.com>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "HELGAAS,BJORN (HP-Ft. Collins)" <bjorn_helgaas@am.exch.hp.com>, 'Sourav Sen' <souravs@india.hp.com>
Cc: 'Matt Domsch' <Matt_Domsch@dell.com>, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com

+ -----Original Message-----
+ From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com]
+ Sent: Thursday, May 06, 2004 8:39 PM
+ To: Sourav Sen
+ Cc: 'Matt Domsch'; matthew.e.tolentino@intel.com;
+ linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org;
+ tony.luck@intel.com
+ Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
+ 
+ 
+ On Thursday 06 May 2004 7:20 am, Sourav Sen wrote:
+ > + 1) Why does userspace / humans need to know this?  For 
+ > + debugging firmware?
+ > 	
+ > 	Maybe. But the point I had in mind is, say for example
+ > memory diagnostics applications/exercisers which reads (Blind
+ > reads, without caring about contents) memory
+ > to uncover errors (single bit errors)  can use
+ > this to know the usable ranges and map them thru /dev/mem and
+ > read those ranges.
+ 
+ For this application, the EFI memory map isn't what you want.
+ It's a pretty good approximation today, but the day when we'll
+ be able to hot-add memory is fast approaching, and the EFI map
+ won't mention anything added after boot.  We'll discover all
+ that via ACPI (on ia64).
+ 

	Why not also update the efi memory table on a hotplug :-)
(Now also it gets modified a little on a call to efi_memmap_walk()).
Otherwise clients of efi_memmap_walk() will also get stale 
information after a hotplug, isn't it (assuming they want to
know about available physical ranges)?

	Also, kernel may not exactly use all the memory added via
hotplug and there may be some truncation (just as efi_memmap_walk()
does today). And it isn't help us if we get to know about those
extents. Additionally we get to know about various mmio ranges and
other ranges thru that table -- may be useful opportunistically.

--Sourav
