From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 11 Jan 2008 02:02:08 +0000
Subject: Re: [patch 1/3] IA64: Slim down __clear_bit_unlock
Message-Id: <200801111302.09048.nickpiggin@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
In-Reply-To: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 04 January 2008 00:36, Zoltan Menyhart wrote:
> Please have a look at the patch below.

OK, I just had a couple of comments...

> Taking this opportunity, in addition:
> - I removed the useless "volatile" stuff from the non-atomic versions
>   of the bit operations.

This is a relatively big thing to be doing. I actually want to
remove all volatiles (except maybe in special accessor functions)
from the kernel, so great :) However it needs to be in a separate
patch, and it needs to be done for all architectures and
asm-generic to spread out the burden of testing. You should also
cc lkml and Linus on that one.

Make it on top of the __clear_bit_unlock work, so the ia64 specific
patch doesn't get held up.


> - I removed the unnecessary barrier() from __clear_bit_unlock().
>   ia64_st4_rel_nta() makes sure all the modifications are globally
>   seen before the bit is seen to be off.

Fine. I guess it doesn't need a comment because you ia64 guys know
this intimately.

> - I made __clear_bit() modeled after __set_bit() and __change_bit().
> - I corrected some comments sating that a memory barrier is provided,
>   yet in reality, it is the acquisition side of the memory barrier only.
> - I corrected some comments, e.g. test_and_clear_bit() was peaking
>   about "bit to set".
>
> Signed-off-by: Zoltan Menyhart, <Zoltan.Menyhart@bull.net>

I guess removing the acquire barrier from close to the release barrier
is a good idea. I won't ask for performance numbers because I guess
they are too hard to get a meaningful number for such a small and
obviously better change. It would just be good to know that code size
ends up being as small or smaller.

Anyway, I don't want to actually say ack to the ia64 parts without
having done any compilation or testing myself, but I would like
especially the volatile change to be moved. I guess Tony does too :)

Thanks,
Nick
