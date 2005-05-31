From: Jack Steiner <steiner@sgi.com>
Date: Tue, 31 May 2005 18:15:17 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050531181517.GA16283@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 30, 2005 at 09:18:22AM +0900, KAMEZAWA Hiroyuki wrote:
> Hi Bob,
> >Another point to consider...
> >
> >Both RH & SuSE release a single kernel binary image that is used on all
> >platforms. IA64 discovers the platform type (Dig, SGI, HP, ...) during
> >boot & sets up platform callouts to platform specific functions. We
> >will need to select values for both CONFIG_SECTION_BITS &
> >CONFIG_PHYSICAL_MEMORY_BITS that work on all IA64 platforms (or make these
> >values configurable at runtime)
> >
> After reading e-mails,
> 	physical address size -- 50bits
> 	section size	      -- 32bits

A significant number of SGI systems contain 2GB memory chunks (4x512MB
DIMMS configured as a 2GB memory bank). I think these system would prefer
a section size of 31bits. Right?

I'm concerned that there may not be value of "section size" & "physical address size"
that is optimal across all of the various IA64 platforms.

(Functionally, everything appears to work fine. I'm in the process of running a
few benchmarks on a 64p system. More later....).


> will be good as a default.
> This can work on any ia64 platforms && Full-sized Hugetlb can be used 
> without any tuning.
> 
> If people want to hot-remove smaller memory sections, he should adjust the 
> params.
> 
> -- Kame

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


