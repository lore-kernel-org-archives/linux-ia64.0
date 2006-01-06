From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 06 Jan 2006 18:25:46 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <20060106182546.GX12131@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Arjan van de Ven <arjan@infradead.org>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

On Fri, Jan 06, 2006 at 09:45:20AM -0800, Luck, Tony wrote:
> >Why can't we keep the default below 64?  Surely the 0.1% of the market
> >which needs more than 64 cpus can recompile their kernel ...
> 
> I suppose that depends on your expectations from defconfig.  In my
> mind its the one that builds into a kernel that will boot and run
> on just about any box.  People who want to get a bit of extra performance
> will do the re-compilation to strip out the bits that they don't want
> and tune down limits that are set higher than they need.  I only
> ever boot a defconfig kernel to check that it still works, my systems
> all run tiger_defconfig/zx1_defconfig based most of the time.  But
> perhaps I'm the weird one?
>...

defconfig's are usually not intended for running on all supported 
machines, they are more a base for compile-tests and a starting point 
for building an own configuration.

If you intend to use the ia64 defconfig in a different way I don't 
see any strong point against it.

But if you seriously want a defconfig "that builds into a kernel that 
will boot and run on just about any box", please change your defconfig 
to ITANIUM=y,MCKINLEY=n. "People who want to get a bit of extra 
performance" can still change their configuration to omit support for 
the original Itanium.

> -Tony

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

