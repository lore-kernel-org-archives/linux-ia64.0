From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 17:38:23 +0000
Subject: Re: [PATCH RFC] 'spinlock/rwlock fixes' V3 [1/1]
Message-Id: <20050120173823.GA21223@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050118014752.GA14709@cse.unsw.EDU.AU> <16877.42598.336096.561224@wombat.chubb.wattle.id.au> <20050119080403.GB29037@elte.hu> <16878.9678.73202.771962@wombat.chubb.wattle.id.au> <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <Pine.LNX.4.58.0501200812300.8178@ppc970.osdl.org> <20050120162309.GB14002@elte.hu> <Pine.LNX.4.58.0501200926510.8178@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0501200926510.8178@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Chris Wedgwood <cw@f00f.org>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, Peter Chubb <peterc@gelato.unsw.edu.au>, Tony Luck <tony.luck@intel.com>, Darren Williams <dsw@gelato.unsw.edu.au>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ia64 Linux <linux-ia64@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Jesse Barnes <jbarnes@sgi.com>


* Linus Torvalds <torvalds@osdl.org> wrote:

> > +static inline int read_can_lock(rwlock_t *rw)
> > +{
> > +	return rw->lock > 0;
> > +}
> 
> No, it does need the cast to signed, otherwise it will return true for
> the case where somebody holds the write-lock _and_ there's a pending
> reader waiting too (the write-lock will make it zero, the pending
> reader will wrap around and make it negative, but since "lock" is
> "unsigned", it will look like a large value to "read_can_lock".

indeed. Another solution would be to make the type signed - patch below. 
(like ppc64 does)

> I also think I'd prefer to do the things as macros, and do the
> type-safety by just renaming the "lock" field like Chris did. [...]

(i sent the original lock/slock renaming patch yesterday, and i think
Chris simply reworked&resent that one.)

	Ingo

--- linux/include/asm-i386/spinlock.h.orig
+++ linux/include/asm-i386/spinlock.h
@@ -179,7 +179,7 @@ static inline void _raw_spin_lock_flags 
  * read-locks.
  */
 typedef struct {
-	volatile unsigned int lock;
+	volatile signed int lock;
 #ifdef CONFIG_DEBUG_SPINLOCK
 	unsigned magic;
 #endif
