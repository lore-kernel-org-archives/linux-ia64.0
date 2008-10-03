From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 03 Oct 2008 15:41:42 +0000
Subject: Re: [PATCH 2/2]Add Variable Page Size and IA64 Support in Intel IOMMU: IA64 Specific Part
Message-Id: <200810030941.42800.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081001165750.GA21272@linux-os.sc.intel.com> <200810020951.08408.bjorn.helgaas@hp.com> <A6AD88C3F2289247BE726C37303E1EB88408AA3E@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB88408AA3E@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Thursday 02 October 2008 11:46:04 am Yu, Fenghua wrote:
> >> --- a/arch/ia64/include/asm/cacheflush.h
> >> +++ b/arch/ia64/include/asm/cacheflush.h
> >> @@ -34,6 +34,8 @@ do {                                                \
> >>  #define flush_dcache_mmap_unlock(mapping)    do { } while (0)
> >>
> >>  extern void flush_icache_range (unsigned long start, unsigned long end);
> >> +extern void clflush_cache_range(void *addr, int size);
> >
> >This patch adds clflush_cache_range(), but it's not used anywhere.
> Clflush_cache_range() is used in __iommu_flush_cache() in include/linux/intel-iommu.h.

Oh, OK.  I didn't look hard enough to find __iommu_flush_cache()
(currently in drivers/pci/intel-iommu.c).

Architecturally, I'm surprised that ia64 would need to actually do a
cache flush.  I would think the VT-d hardware would do coherent accesses
which would make the cache flush unnecessary.

Bjorn
