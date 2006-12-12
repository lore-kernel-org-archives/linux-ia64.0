From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 12 Dec 2006 15:47:46 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <20061212154746.GI21070@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 12, 2006 at 04:01:00PM +0100, Zoltan Menyhart wrote:
> Let's assume the bit test & set is already set, why is then the
> cmpxchg_acq() executed? Cannot we just return, e.g. like this?
> 
>        do {
>                old = *m;
> 		if (old & bit)
> 			return 1;
>                new = old | bit;
>        } while (cmpxchg_acq(m, old, new) != old);

The original code and your rewrite both access memory twice in the loop.
Why don't we do it with one memory reference per loop instead?

{
	CMPXCHG_BUGCHECK_DECL

	u32 *m = (u32 *)addr + (nr >> 5);
	u32 bit = 1 << (nr & 31);

	u32 old = *m;
	while (!(old & bit)) {
		u32 new = old | bit;
		u32 prev = cmpxchg_acq(m, old, new);
		CMPXCHG_BUGCHECK(m);
		if (prev = old)
			return 1;
		old = prev;
	}

	return 0;
}

Looking at the disassembly of grab_block() in fs/ext2/balloc.c, I don't
see much difference.  The ld4.acq turns into a regular ld4 (because
'm' is no longer tagged as volatile), and is hoisted out of the loop.
Interestingly, gcc chooses to reorder the tests, and make the loop four
bundles long instead of three, but will 'goto repeat' in two bundles
instead of four.  Using likely()/unlikely() doesn't persuade gcc to
change the order of the two branches, so I assume it actually is better
to do it this way.
