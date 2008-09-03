From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 03 Sep 2008 23:00:53 +0000
Subject: Re: [PATCH] Correct printk %pF to work on all architectures
Message-Id: <1220482853.3254.47.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220473137.3254.29.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031419560.3515@nehalem.linux-foundation.org>
	 <1220481754.3254.42.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0809031546310.3515@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0809031546310.3515@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org

On Wed, 2008-09-03 at 15:54 -0700, Linus Torvalds wrote:
> > Anyway, it's easy to do (if a slightly larger diff) ... I have to move
> > the prototype from include/kernel.h to include/module.h because I need
> > an assured asm/xxx include before it to get the override.
> 
> I don't really see what this has to do with module.h, though.
> 
> Why do this in <linux/module.h>?  Why not just do it in lib/vsptintf.c 
> which is the only place that cares? None of this needs to pollute the 
> generic header files that simply don't care.

You want me to pull the elf header files into lib/vsprintf.c and have
something like

static inline void *dereference_function_descritpor(void *ptr)
{
#if defined(CONFIG_IA64) || defined(CONFIG_PPC64)
	void *p;
	if (!probe_kernel_address(ptr, p))
		ptr = p;
#elif defined(CONFIG_PARISC) && defined(CONFIG_64BITS)
	Elf64_Fptr *desc = ptr;
	void *p;
	if (!probe_kernel_address(&desc->addr, p))
		ptr = p;
#endif
	...

?

Because it just looks rather tacky ...

James


