From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 20 Jan 2005 16:18:42 +0000
Subject: Re: [PATCH RFC] 'spinlock/rwlock fixes' V3 [1/1]
Message-Id: <Pine.LNX.4.58.0501200812300.8178@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050117055044.GA3514@taniwha.stupidest.org>
 <20050116230922.7274f9a2.akpm@osdl.org> <20050117143301.GA10341@elte.hu>
 <20050118014752.GA14709@cse.unsw.EDU.AU> <16877.42598.336096.561224@wombat.chubb.wattle.id.au>
 <20050119080403.GB29037@elte.hu> <16878.9678.73202.771962@wombat.chubb.wattle.id.au>
 <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com>
 <20050120023445.GA3475@taniwha.stupidest.org>
In-Reply-To: <20050120023445.GA3475@taniwha.stupidest.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Wedgwood <cw@f00f.org>
Cc: Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Peter Chubb <peterc@gelato.unsw.edu.au>, Tony Luck <tony.luck@intel.com>, Darren Williams <dsw@gelato.unsw.edu.au>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ia64 Linux <linux-ia64@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Jesse Barnes <jbarnes@sgi.com>



On Wed, 19 Jan 2005, Chris Wedgwood wrote:
> 
>   * i386, ia64: rename rwlock_is_locked to rwlock_write_locked as this
>     is IMO a better name

I actually much prefer the "read_can_lock()" suggestion by Peter.

Also, why this:

	+#define rwlock_read_locked(x) (atomic_read((atomic_t *)&(x)->lock) <= 0)

what the _heck_ is that "atomic_read((atomic_t *)&(x)->lock)", and why is 
it not just a "(int)(x)->lock" instead?

So I think it would be much better as

	#define read_can_lock(x) ((int)(x)->lock > 0)

which seems simple and straightforward.

And it probably should be in <asm-i386/rwlock.h>, since that is where the 
actual implementation is, and <asm-i386/spinlock.h> doesn't really have 
any clue what the rules are, and shouldn't act like it has.

		Linus
