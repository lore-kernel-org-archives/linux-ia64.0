From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 16:28:36 +0000
Subject: Re: [PATCH RFC] 'spinlock/rwlock fixes' V3 [1/1]
Message-Id: <20050120162836.GA14726@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050116230922.7274f9a2.akpm@osdl.org> <20050117143301.GA10341@elte.hu> <20050118014752.GA14709@cse.unsw.EDU.AU> <16877.42598.336096.561224@wombat.chubb.wattle.id.au> <20050119080403.GB29037@elte.hu> <16878.9678.73202.771962@wombat.chubb.wattle.id.au> <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <Pine.LNX.4.58.0501200812300.8178@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0501200812300.8178@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Chris Wedgwood <cw@f00f.org>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, Peter Chubb <peterc@gelato.unsw.edu.au>, Tony Luck <tony.luck@intel.com>, Darren Williams <dsw@gelato.unsw.edu.au>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ia64 Linux <linux-ia64@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Jesse Barnes <jbarnes@sgi.com>


* Linus Torvalds <torvalds@osdl.org> wrote:

> And it probably should be in <asm-i386/rwlock.h>, since that is where
> the actual implementation is, and <asm-i386/spinlock.h> doesn't really
> have any clue what the rules are, and shouldn't act like it has.

historically spinlock.h had the full implementation of both spinlock
variants: spinlocks and rwlocks. (hey, you implemented it first and put
it there! :-) Then came Ben's rwsems that wanted pieces of rw-spinlocks,
so rwlock.h was created with the shared bits.

one thing i was thinking about was to move most but the assembly to
asm-generic/spinlock.h. Almost every architecture shares the spinlock
type definitions and shares most of the non-assembly functions.

	Ingo
