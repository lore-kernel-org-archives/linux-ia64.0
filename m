From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 08 Feb 2006 22:49:04 +0000
Subject: Re: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <20060208224904.GT3524@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060208213825.GQ3524@stusta.de> <200602082224.k18MOpg24612@unix-os.sc.intel.com>
In-Reply-To: <200602082224.k18MOpg24612@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Jes Sorensen <jes@sgi.com>, 'Keith Owens' <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Feb 08, 2006 at 02:24:51PM -0800, Chen, Kenneth W wrote:
> Adrian Bunk wrote on Wednesday, February 08, 2006 1:38 PM
> > > Not really, it helps a bit by selecting some things we know we need
> > > for all GENERIC builds. True we can't make it bullet proof, but whats
> > > there is better than removing it.
> > 
> > Like the bug of allowing the illegal configuration NUMA=y, FLATMEM=y?
> 
> 
> You can't even compile a kernel with that combination ...
> Just about every arch except ia64 turns off ARCH_FLATMEM_ENABLE if NUMA=y.
> ia64 can just do the same thing.  Instead of mucking around with select,
> fix the bug at its source. The real culprit is in mm/Kconfig, it shouldn't
> enable ARCH_FLATMEM_ENABLE if NUMA=y.


No, the bug is exactly the part of arch/ia64/Kconfig you are patching, 
because mm/Kconfig simply relies on architectures setting the right 
dependencies for ARCH_FLATMEM_ENABLE.


> Fix ARCH_FLATMEM_ENABLE dependency in ia64 arch.
> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> --- ./arch/ia64/Kconfig.orig	2006-02-08 14:57:40.597354431 -0800
> +++ ./arch/ia64/Kconfig	2006-02-08 15:04:15.552427718 -0800
> @@ -298,7 +298,8 @@ config ARCH_DISCONTIGMEM_ENABLE
>   	  See <file:Documentation/vm/numa> for more.
>  
>  config ARCH_FLATMEM_ENABLE
> -	def_bool y
> +	depends on !NUMA
> +	def_bool y if !NUMA
>...

Only one of the two NUMA dependencies is required.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

