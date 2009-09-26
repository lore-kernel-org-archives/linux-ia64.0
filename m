From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 26 Sep 2009 20:39:12 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909261330000.3303@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Sat, 26 Sep 2009, Luck, Tony wrote:
> 
> please pull from:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release
> 
> This will update the files shown below.
> 
> Tony Luck (1):
>       [IA64] implement ticket locks for Itanium

Ok, so x86 has obviously done ticket locks for a while now, and I think 
it's good that ia64 does too, but I wonder why you made the ticket lock be 
a full 64-bit thing?

A plain 32-bit lock with a 16-bit shift should be plenty good enough, and 
those spinlocks are embedded into a lot of structures where size might 
matter. In fact, on x86, we do a 16-bit lock with a 8-bit shift for the 
case where NR_CPU's is less than 256 (but part of that is that we can use 
byte ops easily and access the high byte etc - it's not all about just the 
size of the spinlock).

Also, your basic spinlock seems to be pessimised a bit:

	+	int	*p = (int *)&lock->lock, turn, now_serving;
	+
	+	now_serving = *p;
	+	turn = ia64_fetchadd(1, p+1, acq);
	+
	+	if (turn = now_serving)
	+		return;
	+
	+	do {
	+		cpu_relax();
	+	} while (ACCESS_ONCE(*p) != turn);

which has a couple of issues, foremost being the one that you force a 
regular read first. Now, if the cacheline is already exclusive in your 
local caches, that should be fine, but if it's not in your cache, then 
you'll first fetch the cacheline for reading and possibly shared, and then 
immediately afterwards you'll do that "fetchadd()" thing that turns it 
dirty and exclusive.

It's likely _better_ to do the first access with a dirtying access, which 
can bring in the cache-line for exclusive ownership immediately. Of 
course, that depends on the exact details of ia64 cache coherency 
protocol, but in general, I'd have expected

	int *p = ((int *)&lock->lock, turn;

	turn = ia64_fetchadd(1, p+1, acq);
	while (ACCESS_ONCE(*p) != turn)
		cpu_relax();

to actually be not only shorter, but better due to cache access patterns 
too (ie do the read only _after_ you've done the write).

But I dunno. I'll pull the thing as-is, but I thought I'd point out that 
this looks non-optimal.

		Linus
