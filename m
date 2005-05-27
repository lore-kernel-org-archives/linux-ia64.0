From: Bob Picco <bob.picco@hp.com>
Date: Fri, 27 May 2005 10:35:48 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050527103548.GA8779@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Thu May 26 2005, 06:03:29PM EDT]
> >Well worse case it would consume 2^(1(50-32)+3) (2 Mb).  I would hope that 
> >it's not configured for 28 SECTION_SIZE_BITS and 50 physical. This would
> >be excessive 2^((50-28)+3 = 32Mb and not advised.
> 
> While you can tune a custom kernel for a particular system configuration,
> we might have to use the 50/28 configuration for the generic "defconfig"
> case ... that kernel should be bootable anywhere.   SGI needs (or will
> need) the "50" for total physical size, and other platforms may need the
> "28" (is that even small enough?  We currently have "granule" sizes of
> 16M and 64M to cope with odd holes in the physical address space ... so
> perhaps the section size might need to be even smaller: 24 or 26?  How did
> you come up with 28 as the low bound for SECTION_BITS?)
It seems to be least costly in terms of consuming reserved pages. Of course
reducing it decreases consuming reserved pages but at the cost of increasing
the mem_section size.  Should 50 have to be the defconfig value, then I'd
recommend 30 for SECTION_SIZE_BITS.  So memory wise 8Mb -> 2^((50-30)+3) 
for mem_section.  Smaller than 30 SECTION_BITS for 50 bit physical
consumes too much memory for mem_section. 

Well this correction below will eliminate a Kconfig patch mishap.  I booted on
a 4Mbg rx2600 with memQ2Mb.  No problems but reserved pages and detected RAM 
is slightly disconcerting.  Investigating this further.
> 
> -Tony
bob

Index: linux-2.6.12-rc4-mm2-broken/arch/ia64/Kconfig
=================================--- linux-2.6.12-rc4-mm2-broken.orig/arch/ia64/Kconfig	2005-05-25 12:28:37.000000000 -0400
+++ linux-2.6.12-rc4-mm2-broken/arch/ia64/Kconfig	2005-05-26 19:20:57.000000000 -0400
@@ -321,7 +321,7 @@ config HAVE_ARCH_EARLY_PFN_TO_NID
 	depends on NEED_MULTIPLE_NODES
 
 config SECTION_BITS
-	int
+	int "SECTION_BITS (28-32)" if !HUGETLB_PAGE
 	depends on SPARSEMEM
 	range 28 32	if !HUGETLB_PAGE
 	default "32"	if HUGETLB_PAGE
@@ -330,7 +330,7 @@ config SECTION_BITS
 	  Size of memory section in bits.
 
 config PHYSICAL_MEMORY_BITS
-	int
+	int "PHYSICAL_MEMORY_BITS (44-50)"
 	depends on SPARSEMEM
 	range 44 50
 	default 44

