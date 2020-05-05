From: Mike Rapoport <rppt@linux.ibm.com>
Date: Tue, 05 May 2020 09:19:46 +0000
Subject: Re: [PATCH v2 17/20] mm: free_area_init: allow defining max_zone_pfn in descending order
Message-Id: <20200505091946.GG342687@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200429121126.17989-1-rppt@kernel.org>
 <20200429121126.17989-18-rppt@kernel.org>
 <20200503174138.GA114085@roeck-us.net>
 <20200503184300.GA154219@roeck-us.net>
 <20200504153901.GM14260@kernel.org>
 <a0b20e15-fddb-aa9c-fd67-f1c8e735b4a4@synopsys.com>
In-Reply-To: <a0b20e15-fddb-aa9c-fd67-f1c8e735b4a4@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Rich Felker <dalias@libc.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, Greg Ungerer <gerg@linux-m68k.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@linux-c6x.org>, Baoquan He <bhe@redhat.com>, Jonathan Corbet <corbet@lwn.net>, linux-sh@vger.kerne

Hi Vineet,

On Tue, May 05, 2020 at 06:23:37AM +0000, Vineet Gupta wrote:
> Hi Mike,
> 
> On 5/4/20 8:39 AM, Mike Rapoport wrote:
> > On Sun, May 03, 2020 at 11:43:00AM -0700, Guenter Roeck wrote:
> >> On Sun, May 03, 2020 at 10:41:38AM -0700, Guenter Roeck wrote:
> >>> Hi,
> >>>
> >>> On Wed, Apr 29, 2020 at 03:11:23PM +0300, Mike Rapoport wrote:
> >>>> From: Mike Rapoport <rppt@linux.ibm.com>
> >>>>
> >>>> Some architectures (e.g. ARC) have the ZONE_HIGHMEM zone below the
> >>>> ZONE_NORMAL. Allowing free_area_init() parse max_zone_pfn array even it is
> >>>> sorted in descending order allows using free_area_init() on such
> >>>> architectures.
> >>>>
> >>>> Add top -> down traversal of max_zone_pfn array in free_area_init() and use
> >>>> the latter in ARC node/zone initialization.
> >>>>
> >>>> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> >>>
> >>> This patch causes my microblazeel qemu boot test in linux-next to fail.
> >>> Reverting it fixes the problem.
> >>>
> >> The same problem is seen with s390 emulations.
> > 
> > Yeah, this patch breaks some others as well :(
> > 
> > My assumption that max_zone_pfn defines architectural limit for maximal
> > PFN that can belong to a zone was over-optimistic. Several arches
> > actually do that, but others do
> > 
> > 	max_zone_pfn[ZONE_DMA] = MAX_DMA_PFN;
> > 	max_zone_pfn[ZONE_NORMAL] = max_pfn;
> > 
> > where MAX_DMA_PFN is build-time constrain and max_pfn is run time limit
> > for the current system.
> > 
> > So, when max_pfn is lower than MAX_DMA_PFN, the free_init_area() will
> > consider max_zone_pfn as descending and will wrongly calculate zone
> > extents.
> > 
> > That said, instead of trying to create a generic way to special case
> > ARC, I suggest to simply use the below patch instead.
> 
> Even for ARC it will be a bit more complicated. Highmem on ARC can be setup in 2
> ways such that it is descending in one case, and ascending in other (w.r.t
> "normal" mem) :-(

Yeah, and this makes ARC really special :)

> First some basic info about an ARC MMU based system
> 
> ARC logical address space (various addresses embedded in binaries)
>  - translated (0 to 0x6FFF_FFFF)  - for userspace
>  - untranslated (0x8000_0000 to 0xFFFF_FFFF) - kernel
> 
> ARC Physical address space is typically from 0x8000_0000 to 0xF000_0000.
> Above translated space maps here via MMU. Untranslated is implicitly mapped (no
> MMU involved).
> 
> The physical address in turn maps to a Bus address / memory (done at the
> inter-connect/NoC). Typically Physical 0x8000_0000 map to DDR 0
> 
> Now,
> - HIGHMEM w/o PAE40 adds Physical address space 0 to 0x7FFF_FFFF.
> - HIGHMEM with PAE40 uses physical address space from 0x1_0000_0000 upwards.
> 
> But then you could also have a system which has both of above so the bimodal up/dn
> won't work.

From the code I've got the impression that it is either one of them. I.e
the physical memory is either at

0x8000_0000 - <end of DDR 0 bank>
0x0000_0000 - <end of DDR 1 bank>

or

0x0_8000_0000 - <end of DDR 0 bank>
0x1_0000_0000 - <end of DDR 1 bank>

Is this possible to have a system with three live ranges? Like

0x0_0000_0000 - <end of DDR 1 bank>
0x0_8000_0000 - <end of DDR 0 bank>
0x1_0000_0000 - <end of DDR 2 bank>

> While I appreciate the effort to reduce complexity, it seems the
> current way of
> setting things up allows for more flexibility in specifying the system memory map.
>
> PS: I haven't looked at your series too carefully, the mention of ARC caught my
> attention :-) I guess I need to read it more carefully to understand.
 
That would be cool :)

> > 
> > diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
> > index 41eb9be1653c..386959bac3d2 100644
> > --- a/arch/arc/mm/init.c
> > +++ b/arch/arc/mm/init.c
> > @@ -77,6 +77,11 @@ void __init early_init_dt_add_memory_arch(u64 base, u64 size)
> >  		base, TO_MB(size), !in_use ? "Not used":"");
> >  }
> >  
> > +bool arch_has_descending_max_zone_pfns(void)
> > +{
> > +	return true;
> > +}
> > +
> >  /*
> >   * First memory setup routine called from setup_arch()
> >   * 1. setup swapper's mm @init_mm
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index b990e9734474..114f0e027144 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7307,6 +7307,15 @@ static void check_for_memory(pg_data_t *pgdat, int nid)
> >  	}
> >  }
> >  
> > +/*
> > + * Some architecturs, e.g. ARC may have ZONE_HIGHMEM below ZONE_NORMAL. For
> > + * such cases we allow max_zone_pfn sorted in the descending order
> > + */
> > +bool __weak arch_has_descending_max_zone_pfns(void)
> > +{
> > +	return false;
> > +}
> > +
> >  /**
> >   * free_area_init - Initialise all pg_data_t and zone data
> >   * @max_zone_pfn: an array of max PFNs for each zone
> > @@ -7324,7 +7333,7 @@ void __init free_area_init(unsigned long *max_zone_pfn)
> >  {
> >  	unsigned long start_pfn, end_pfn;
> >  	int i, nid, zone;
> > -	bool descending = false;
> > +	bool descending;
> >  
> >  	/* Record where the zone boundaries are */
> >  	memset(arch_zone_lowest_possible_pfn, 0,
> > @@ -7333,14 +7342,7 @@ void __init free_area_init(unsigned long *max_zone_pfn)
> >  				sizeof(arch_zone_highest_possible_pfn));
> >  
> >  	start_pfn = find_min_pfn_with_active_regions();
> > -
> > -	/*
> > -	 * Some architecturs, e.g. ARC may have ZONE_HIGHMEM below
> > -	 * ZONE_NORMAL. For such cases we allow max_zone_pfn sorted in the
> > -	 * descending order
> > -	 */
> > -	if (MAX_NR_ZONES > 1 && max_zone_pfn[0] > max_zone_pfn[1])
> > -		descending = true;
> > +	descending = arch_has_descending_max_zone_pfns();
> >  
> >  	for (i = 0; i < MAX_NR_ZONES; i++) {
> >  		if (descending)
> > 

-- 
Sincerely yours,
Mike.
