From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 20 Jan 2005 15:51:08 +0000
Subject: Re: [PATCH RFC] 'spinlock/rwlock fixes' V3 [1/1]
Message-Id: <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050116230922.7274f9a2.akpm@osdl.org> <20050117143301.GA10341@elte.hu>
 <20050118014752.GA14709@cse.unsw.EDU.AU> <16877.42598.336096.561224@wombat.chubb.wattle.id.au>
 <20050119080403.GB29037@elte.hu> <16878.9678.73202.771962@wombat.chubb.wattle.id.au>
 <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com>
 <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org>
 <20050120031854.GA8538@taniwha.stupidest.org> <16879.29449.734172.893834@wombat.chubb.wattle.id.au>
In-Reply-To: <16879.29449.734172.893834@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com



On Thu, 20 Jan 2005, Peter Chubb wrote:
> 
> I suggest reversing the sense of the macros, and having read_can_lock()
> and write_can_lock()
> 
> Meaning:
> 	read_can_lock() --- a read_lock() would have succeeded
> 	write_can_lock() --- a write_lock() would have succeeded.

Yes. This has the advantage of being readable, and the "sense" of the test 
always being obvious.

We have a sense problem with the "trylock()" cases - some return "it was
locked" (semaphores), and some return "I succeeded" (spinlocks), so not
only is the sense not immediately obvious from the usage, it's actually
_different_ for semaphores and for spinlocks.

So I like "read_can_lock()", since it's also obvious what it returns.

(And yes, we should fix the semaphore trylock return code, dammit.)

		Linus
