From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 16:59:37 +0000
Subject: Re: [patch 1/3] spinlock fix #1, *_can_lock() primitives
Message-Id: <20050120165937.GA17262@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org> <16879.29449.734172.893834@wombat.chubb.wattle.id.au> <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org> <20050120160839.GA13067@elte.hu> <Pine.LNX.4.58.0501200823010.8178@ppc970.osdl.org> <20050120164428.GA16342@elte.hu>
In-Reply-To: <20050120164428.GA16342@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com


* Ingo Molnar <mingo@elte.hu> wrote:

> * Linus Torvalds <torvalds@osdl.org> wrote:
> 
> > I can do ppc64 myself, can others fix the other architectures (Ingo,
> > shouldn't the UP case have the read/write_can_lock() cases too? And
> > wouldn't you agree that it makes more sense to have the rwlock test
> > variants in asm/rwlock.h?):
> 
> this one adds it to x64. (untested at the moment) [...]

with this patch the x64 SMP+PREEMPT kernel builds & boots fine on an UP
x64 box. (this is not a full test but better than nothing.) [the other 8
spinlock patches were all applied as well.]

	Ingo
