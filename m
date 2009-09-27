From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 27 Sep 2009 00:00:52 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909261636570.3303@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Sat, 26 Sep 2009, Matthew Wilcox wrote:

> On Sat, Sep 26, 2009 at 01:39:12PM -0700, Linus Torvalds wrote:
> > Ok, so x86 has obviously done ticket locks for a while now, and I think 
> > it's good that ia64 does too, but I wonder why you made the ticket lock be 
> > a full 64-bit thing?
> 
> This got brought up earlier, and there isn't a fetchadd4, only a fetchadd8.

Hmm. There's a fetchadd4, but it has horrible semantics (very limited 
constants).

You'd want a fetchadd4 that updates the high bits, and have the atomic 
counter in the high 16 bits, and the "current owner" in the low bits. And 
fetchadd4 can't do that, due to its idiotic "only does a few constants" 
thing.

BTW, I also think that the memory ordering is not sufficient in the 
current ia64 ticket locks. It does just a simple

        do {
                cpu_relax();
        } while (ACCESS_ONCE(*p) != turn);

to wait to get the spinlock, and even if the 'fetchadd' it did earlier was 
done with 'acq', the reads in ACCESS_ONCE() are just normal reads, so the 
code that is protected by that spinlock could easily have other reads or 
writes that escape to _before_ the ACCESS_ONCE().

Of course, with an in-order implementation, I guess it will never happen 
in practice, so what do I know. But I do suspect that at least in theory 
that thing is literally buggy as-is.

However, I will ignore that issue, and look at the "4 bytes versus 8 
bytes for the lock" thing. And I think fetchadd4 is still usable, despite 
it's limitations. We make the rule be:

 - the low 15 bits are the "I want to own counter"

   This allows 32768 different CPU's.

 - the high 15 bits are the "this is the current owner" counter

 - the 2 bits in the middle are "don't care" bits, and in particular, we 
   will do non-atomic stores to the upper 16 bits that always clear bit#16 
   in the 32-bit word. Overflow etc may still set it, but we don't care, 
   because the overflow count is still limited to 32767, which means that 
   it's enough that we clear bit #16 more often than that, and we know 
   that the fetchadd will never overflow into the high 15 bits.

and now you have:

 - spinlock:

	fetchadd4.acq r1=[p],1
	target = (r1 & 32767);
	if (target = (r1>>17))
		return; /* The 'acq' was enough */

	while ((ACCESS_ONCE(*p) >> 17) != target)
		cpu_relax();
	/* We need an smp_mb() because the 'acq' was long ago */
	smb_mb();

 - spinunlock

	/*
	 * High bits of the lock - we don't care about atomicity
	 * here, the 'fetchadd4' can't change the bits we care
	 * about.
	 */
	unsigned short *mem = 1+(unsigned short)lock;

	/*
	 * Make sure to clear bit #16 (the ~1 part) when we
	 * store the new value, add add one to bits 17..31 in
	 * the full 4-byte word (it's "*mem+2") to set the
	 * new ticket owner.
	 */
	unsigned short value = (*mem + 2) & ~1;

	/*
	 * Do the final unlock as a 16-bit store with release
	 * semantics
	 */
	st2.rel.nta value,[mem]

and that should work.

Of course, there may be some reason I don't know about why this is a 
violation of the Itanium memory ordering semantics (accessing that thing 
with two different memory access sizes, or maybe 'st2' doesn't have a 
'rel' thing that works or whatever).

Anyway, somebody who knows the Itanium memory ordering should really look 
at this, and even if you don't want to try to do a 4-byte spinlock, at 
least somebody should check the memory ordering with that whole read-loop 
for waiting. I really do believe that you need a memory barrier to make 
sure that the new ticket spinlocks actually work, because the 'fetchadd4' 
you use now doesn't seem to do that whole 'acquire' ordering, and even if 
it does, I don't think it helps for the case where you then have to do 
loads and wait for the value to change.

Hmm?

		Linus
