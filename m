From: Jack Steiner <steiner@sgi.com>
Date: Thu, 29 Jan 2004 01:13:42 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <20040129011341.GA25261@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 29, 2004 at 10:57:49AM +1100, Peter Chubb wrote:
> >>>>> "Jack" = Jack Steiner <steiner@SGI.com> writes:
> 
> Jack> On Wed, Jan 28, 2004 at 09:17:59PM +0000, Christoph Hellwig
> Jack> wrote:
> >> On Wed, Jan 28, 2004 at 02:59:12PM -0600, Jack Steiner wrote: >
> >> +#ifdef CONFIG_NUMA > + cpus_clear(mm->cpu_vm_mask); > +#endif
> >> 
> >> I really hate this ifdefs all over the place.  Does this really
> >> hurt that much on non-NUMA systems?  Also SN2 seems to use this
> >> code always so CONFIG_NUMA looks like the wrong ifdef to me.
> 
> Jack> Are you suggesting that we remove the #ifdef OR hide the code in
> Jack> a function that, depending on config options, may or may not do
> Jack> anything?

I dont have a strong opinion. Either is acceptible to me.
David suggested removing the #ifdef iff we can move cpu_vm_mask
closer to the mm_context_t. I'll pursue this....


> 
> Jack> The code is needed on kernels built for SN2. That includes both
> Jack> CONFIG_IA64_GENERIC & CONFIG_IA64_SGI_SN2. I agree that
> Jack> CONFIG_NUMA is not a great choice but nothing else seemed
> Jack> appropriate.
> 
> As CONFIG_IA64_GENERIC is a superset of CONFIG_IA64_SGI_SN2
> why not make CONFIG_IA64_GENERIC turn on CONFIG_IA64_SGI_SN2   and
> then only test for the latter.

This wont work with the current usage of the CONFIG options. For 
example:
	# if defined (CONFIG_IA64_HP_SIM)
	#  include <asm/machvec_hpsim.h>
	# elif defined (CONFIG_IA64_DIG)
	#  include <asm/machvec_dig.h>
	# elif defined (CONFIG_IA64_HP_ZX1)
	#  include <asm/machvec_hpzx1.h>
	# elif defined (CONFIG_IA64_SGI_SN2)
	#  include <asm/machvec_sn2.h>
	# elif defined (CONFIG_IA64_GENERIC)
	....

(It sounded like a good idea though. Most but not all places that check
CONFIG_IA64_SGI_SN2 also check for CONFIG_IA64_GENERIC).


> 
> And yes, using a function that disappears or does nothing on platforms
> for which it is inappropriate is a better approach than littering
> #ifdefs though the code.
> 
> --
> Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
> The technical we do immediately,  the political takes *forever*

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


