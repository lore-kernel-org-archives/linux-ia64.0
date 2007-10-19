From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 19 Oct 2007 09:28:16 +0000
Subject: Re: [IA64] Reduce __clear_bit_unlock overhead
Message-Id: <200710191928.16477.nickpiggin@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 19 October 2007 19:14, Zoltan Menyhart wrote:
> You may want to avoid assembly magics:
>
> static __inline__ void
> __clear_bit_unlock(int const nr, volatile void * const addr)
> {
>         volatile __u32 * const m = (volatile __u32 *) addr + (nr >> 5);
>
>         *m &= ~(1 << (nr & 0x1f));
> }
>
> GCC compiles volatile loads with ".acq" and stores with ".rel".

Hmm, more arbitrary volatile semantics :(

Actually I personally would prefer to use a non-volatile pointer,
and do the assembly explicitly. However, that's not for me to
decide. Importantly, the load with acquire is not required and I
agree it should go. Thanks for noticing that.


> Another remark:
> We are adding more variants of existing funtions, e.g.:
>
> clear_bit()
> __clear_bit()
>
> I've got problems with hidden semantics.

Double underscore prepended versions of the bitops are always
non-atomic. This is nothing new.

Functions with "lock" or "unlock" in their names are relatively
clear to be acquire and release. I preferred to stay with the
lock / unlock theme rather than introduce the new acquire and
release barriers into the kernel. Of course they are the same
thing really, but lock/unlock is always associated with locking
and unlocking something.

I don't want people to use the acquire/release semantics of these
things for anything except taking and releasing a lock (in which
case you really don't have to worry much about memory ordering
issues).

> Just reading the source (where they are used), I simply cannot guess
> if a primitive is atomic or not, if it is with some fencing or w/o.
>
> Cannot we have some "speaking names"? E.g.: bit_unlock_Natomic_rel()

I used the double underscore prefix for bit_unlock simply because
it is pretty well associated with the bitops code. I personally do
not like _Natomic postfix though. Also _rel definitely is redundant
because an unlock operation is not exactly an unlock operation if
it doesn't provide the right memory ordering.
