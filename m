From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 17:53:13 +0000
Subject: Re: [patch 1/3] spinlock fix #1, *_can_lock() primitives
Message-Id: <20050120175313.GA22782@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org> <16879.29449.734172.893834@wombat.chubb.wattle.id.au> <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org> <20050120160839.GA13067@elte.hu> <Pine.LNX.4.58.0501200823010.8178@ppc970.osdl.org> <20050120164038.GA15874@elte.hu> <Pine.LNX.4.58.0501200947440.8178@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0501200947440.8178@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com


* Linus Torvalds <torvalds@osdl.org> wrote:

> On Thu, 20 Jan 2005, Ingo Molnar wrote:
> > 
> > You are right about UP, and the patch below adds the UP variants. It's
> > analogous to the existing wrapping concept that UP 'spinlocks' are
> > always unlocked on UP. (spin_can_lock() is already properly defined on
> > UP too.)
> 
> Looking closer, it _looks_ like the spinlock debug case never had a
> "spin_is_locked()" define at all. Or am I blind? Maybe UP doesn't
> want/need it after all?

i remember frequently breaking the UP build wrt. spin_is_locked() when
redoing all the spinlock primitives for PREEMPT_RT.

looking closer, here's the debug variant it appears:

 /* without debugging, spin_is_locked on UP always says
  * FALSE. --> printk if already locked. */
 #define spin_is_locked(x) \
	({ \
	 	CHECK_LOCK(x); \
		if ((x)->lock&&(x)->babble) { \
			(x)->babble--; \
			printk("%s:%d: spin_is_locked(%s:%p) already locked by %s/%d\n", \
					__FILE__,__LINE__, (x)->module, \
					(x), (x)->owner, (x)->oline); \
		} \
		0; \
	})

(the comment is misleading a bit, this _is_ the debug branch. The
nondebug branch has a spin_is_locked() definition too.)

	Ingo
