From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 03 Sep 2008 22:54:43 +0000
Subject: Re: [PATCH] Correct printk %pF to work on all architectures
Message-Id: <alpine.LFD.1.10.0809031546310.3515@nehalem.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220473137.3254.29.camel@localhost.localdomain>  <alpine.LFD.1.10.0809031419560.3515@nehalem.linux-foundation.org> <1220481754.3254.42.camel@localhost.localdomain>
In-Reply-To: <1220481754.3254.42.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-arch@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org



On Wed, 3 Sep 2008, James Bottomley wrote:
> 
> Is that finally final?  because the last time I tried to do the above
> for a voyager override I was told weak functions were the preferred
> method ...

Weak functions are fine IF THEY DO SOMETHING REAL AND SHOULD BE FUNCTIONS 
IN THE FIRST PLACE!

IOW, if the default behaviour is actually something that should be a 
function, then a weak function is the simplest and most appropriate way of 
doing thigns.

But if the default behaviour is to not do anything at all, then a weak 
function simply doesn't work - because it will always generate that stupid 
and useless function call. And then you have to have per-architecture 
inline functions.

And in order to avoid having all 99 architectures that don't care at all 
add an empty inline function, then you essentially have to use a #define 
to allow us to detect at compile-time that no function existed.

> Anyway, it's easy to do (if a slightly larger diff) ... I have to move
> the prototype from include/kernel.h to include/module.h because I need
> an assured asm/xxx include before it to get the override.

I don't really see what this has to do with module.h, though.

Why do this in <linux/module.h>?  Why not just do it in lib/vsptintf.c 
which is the only place that cares? None of this needs to pollute the 
generic header files that simply don't care.

			Linus
