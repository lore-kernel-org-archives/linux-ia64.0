From: Jack Steiner <steiner@sgi.com>
Date: Fri, 27 May 2005 22:04:47 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050527220447.GA25905@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 27, 2005 at 09:23:24AM -0700, David Mosberger wrote:
> >>>>> On Fri, 27 May 2005 06:35:48 -0400, Bob Picco <bob.picco@hp.com> said:
> 
>   Bob> luck wrote:	[Thu May 26 2005, 06:03:29PM EDT]
>   >> >Well worse case it would consume 2^(1(50-32)+3) (2 Mb).  I would hope that 
>   >> >it's not configured for 28 SECTION_SIZE_BITS and 50 physical. This would
>   >> >be excessive 2^((50-28)+3 = 32Mb and not advised.
> 
>   >> While you can tune a custom kernel for a particular system configuration,
>   >> we might have to use the 50/28 configuration for the generic "defconfig"
>   >> case ... that kernel should be bootable anywhere.   SGI needs (or will
>   >> need) the "50" for total physical size, and other platforms may need the
>   >> "28" (is that even small enough?  We currently have "granule" sizes of
>   >> 16M and 64M to cope with odd holes in the physical address space ... so
>   >> perhaps the section size might need to be even smaller: 24 or 26?  How did
>   >> you come up with 28 as the low bound for SECTION_BITS?)
> 
>   Bob> It seems to be least costly in terms of consuming reserved
>   Bob> pages. Of course reducing it decreases consuming reserved pages
>   Bob> but at the cost of increasing the mem_section size.  Should 50
>   Bob> have to be the defconfig value, then I'd recommend 30 for
>   Bob> SECTION_SIZE_BITS.  So memory wise 8Mb -> 2^((50-30)+3) for
>   Bob> mem_section.  Smaller than 30 SECTION_BITS for 50 bit physical
>   Bob> consumes too much memory for mem_section.
> 
> This discussion just demonstrates what a pain such config parameters
> are.  Such stuff need to be
> self-adjusting/self-tuning/able-to-cover-any-configuration.  Virtual
> mem-map seems to qualify much better here.
> 
> 	--david

Another point to consider...

Both RH & SuSE release a single kernel binary image that is used on all
platforms. IA64 discovers the platform type (Dig, SGI, HP, ...) during
boot & sets up platform callouts to platform specific functions. We
will need to select values for both CONFIG_SECTION_BITS &
CONFIG_PHYSICAL_MEMORY_BITS that work on all IA64 platforms (or make these
values configurable at runtime)

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


