From: Mike Rapoport <rppt@kernel.org>
Date: Fri, 04 Jun 2021 14:49:41 +0000
Subject: Re: [PATCH v2 3/9] arc: remove support for DISCONTIGMEM
Message-Id: <YLo9hb3yTeh3LBMg@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210604064916.26580-1-rppt@kernel.org>
 <20210604064916.26580-4-rppt@kernel.org>
 <f1616f95-f99c-c387-4ed4-88961457a7c6@synopsys.com>
In-Reply-To: <f1616f95-f99c-c387-4ed4-88961457a7c6@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Richard Henderson <rth@twiddle.net>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>

On Fri, Jun 04, 2021 at 02:07:39PM +0000, Vineet Gupta wrote:
> On 6/3/21 11:49 PM, Mike Rapoport wrote:
> > From: Mike Rapoport <rppt@linux.ibm.com>
> >
> > DISCONTIGMEM was replaced by FLATMEM with freeing of the unused memory map
> > in v5.11.
> >
> > Remove the support for DISCONTIGMEM entirely.
> >
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> 
> Looks non intrusive, but I'd still like to give this a spin on hardware 
> - considering highmem on ARC has tendency to go sideways ;-)
> Can you please share a branch !

Sure:

https://git.kernel.org/pub/scm/linux/kernel/git/rppt/linux.git/log/?h=memory-models/rm-discontig/v2
 
> Acked-by: Vineet Gupta <vgupta@synopsys.com>

Thanks!
 
> Thx,
> -Vineet
> 
> > ---
> >   arch/arc/Kconfig              | 13 ------------
> >   arch/arc/include/asm/mmzone.h | 40 -----------------------------------
> >   arch/arc/mm/init.c            |  8 -------
> >   3 files changed, 61 deletions(-)
> >   delete mode 100644 arch/arc/include/asm/mmzone.h
> >
> > diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
> > index 2d98501c0897..d8f51eb8963b 100644
> > --- a/arch/arc/Kconfig
> > +++ b/arch/arc/Kconfig
> > @@ -62,10 +62,6 @@ config SCHED_OMIT_FRAME_POINTER
> >   config GENERIC_CSUM
> >   	def_bool y
> >   
> > -config ARCH_DISCONTIGMEM_ENABLE
> > -	def_bool n
> > -	depends on BROKEN
> > -
> >   config ARCH_FLATMEM_ENABLE
> >   	def_bool y
> >   
> > @@ -344,15 +340,6 @@ config ARC_HUGEPAGE_16M
> >   
> >   endchoice
> >   
> > -config NODES_SHIFT
> > -	int "Maximum NUMA Nodes (as a power of 2)"
> > -	default "0" if !DISCONTIGMEM
> > -	default "1" if DISCONTIGMEM
> > -	depends on NEED_MULTIPLE_NODES
> > -	help
> > -	  Accessing memory beyond 1GB (with or w/o PAE) requires 2 memory
> > -	  zones.
> > -
> >   config ARC_COMPACT_IRQ_LEVELS
> >   	depends on ISA_ARCOMPACT
> >   	bool "Setup Timer IRQ as high Priority"
> > diff --git a/arch/arc/include/asm/mmzone.h b/arch/arc/include/asm/mmzone.h
> > deleted file mode 100644
> > index b86b9d1e54dc..000000000000
> > --- a/arch/arc/include/asm/mmzone.h
> > +++ /dev/null
> > @@ -1,40 +0,0 @@
> > -/* SPDX-License-Identifier: GPL-2.0-only */
> > -/*
> > - * Copyright (C) 2016 Synopsys, Inc. (www.synopsys.com)
> > - */
> > -
> > -#ifndef _ASM_ARC_MMZONE_H
> > -#define _ASM_ARC_MMZONE_H
> > -
> > -#ifdef CONFIG_DISCONTIGMEM
> > -
> > -extern struct pglist_data node_data[];
> > -#define NODE_DATA(nid) (&node_data[nid])
> > -
> > -static inline int pfn_to_nid(unsigned long pfn)
> > -{
> > -	int is_end_low = 1;
> > -
> > -	if (IS_ENABLED(CONFIG_ARC_HAS_PAE40))
> > -		is_end_low = pfn <= virt_to_pfn(0xFFFFFFFFUL);
> > -
> > -	/*
> > -	 * node 0: lowmem:             0x8000_0000   to 0xFFFF_FFFF
> > -	 * node 1: HIGHMEM w/o  PAE40: 0x0           to 0x7FFF_FFFF
> > -	 *         HIGHMEM with PAE40: 0x1_0000_0000 to ...
> > -	 */
> > -	if (pfn >= ARCH_PFN_OFFSET && is_end_low)
> > -		return 0;
> > -
> > -	return 1;
> > -}
> > -
> > -static inline int pfn_valid(unsigned long pfn)
> > -{
> > -	int nid = pfn_to_nid(pfn);
> > -
> > -	return (pfn <= node_end_pfn(nid));
> > -}
> > -#endif /* CONFIG_DISCONTIGMEM  */
> > -
> > -#endif
> > diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
> > index 397a201adfe3..abfeef7bf6f8 100644
> > --- a/arch/arc/mm/init.c
> > +++ b/arch/arc/mm/init.c
> > @@ -32,11 +32,6 @@ unsigned long arch_pfn_offset;
> >   EXPORT_SYMBOL(arch_pfn_offset);
> >   #endif
> >   
> > -#ifdef CONFIG_DISCONTIGMEM
> > -struct pglist_data node_data[MAX_NUMNODES] __read_mostly;
> > -EXPORT_SYMBOL(node_data);
> > -#endif
> > -
> >   long __init arc_get_mem_sz(void)
> >   {
> >   	return low_mem_sz;
> > @@ -147,9 +142,6 @@ void __init setup_arch_memory(void)
> >   	 * to the hole is freed and ARC specific version of pfn_valid()
> >   	 * handles the hole in the memory map.
> >   	 */
> > -#ifdef CONFIG_DISCONTIGMEM
> > -	node_set_online(1);
> > -#endif
> >   
> >   	min_high_pfn = PFN_DOWN(high_mem_start);
> >   	max_high_pfn = PFN_DOWN(high_mem_start + high_mem_sz);
> 

-- 
Sincerely yours,
Mike.
