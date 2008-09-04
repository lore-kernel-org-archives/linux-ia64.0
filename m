From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 04 Sep 2008 00:01:52 +0000
Subject: Re: [PATCH] Correct printk %pF to work on all architectures
Message-Id: <alpine.LFD.1.10.0809031636320.3515@nehalem.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220473137.3254.29.camel@localhost.localdomain>  <alpine.LFD.1.10.0809031419560.3515@nehalem.linux-foundation.org>  <1220481754.3254.42.camel@localhost.localdomain>  <alpine.LFD.1.10.0809031546310.3515@nehalem.linux-foundation.org>
 <1220482853.3254.47.camel@localhost.localdomain>  <alpine.LFD.1.10.0809031602270.3515@nehalem.linux-foundation.org> <1220484812.3254.59.camel@localhost.localdomain>
In-Reply-To: <1220484812.3254.59.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-arch@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org



On Wed, 3 Sep 2008, James Bottomley wrote:
> 
> Oh ... because Arjan has a patch to export
> dereference_function_descriptor.  I suppose I could make him do the
> heavy lifting, but it seemed sensible to make it easy for him (and me)
> by putting it in a header.
> 
> http://marc.info/?l=linux-kernel&m1976793429869

Ahh.

NOW it all starts to make sense.

Or perhaps not sense, but I at least understand why people want to move it 
around. The kernel.h location kind of goes together with that 
core_kernel_text() thing, although it seems to be more of a "random 
collection of routines" thing than anything else (but hey, that's the very 
definition of "kernel.h" for you).

The module.h location still seems to be more of a "oh, both 
kernel/extable.c and lib/vsprintf.c already included <linux/module.h>" and 
it's a bit sad, since it really has nothing at all to do with modules.

Grr. It does seem like we don't have any kind of "abi" header file. 
<linux/kernel.h> and <asm/processor.h> has various random things.

So yea, there doesn't seem to be any _obvious_ place that makes sense.

		Linus

Not-very-strong-opinion: How about <asm/sections.h>? That does seem to be 
where we already hide things like "in_kernel_text()" at least on powerpc. 
In fact, since we already always have a generic version, the patch would 
actually be something like

 - in <asm-generic/sections.h>, just do

	#define dereference_function_descriptor(p) (p)

 - in architectures that want to override it

	#undef dereference_function_descriptor

   followed by 

	static inline void *dereference_function_descriptor(..) ..
	or
	#define dereference_function_descriptor my_fn_dereference

   since they all include the generic one as a base

Hmm? I do admit that "<asm/sections.h>" doesn't really strike me as a very 
natural name for this, but kernel/extable.c does already include it for 
other reasons, and it's at least no worse than module.h.
