From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 13:04:01 +0000
Subject: Re: [PATCH RFC] 'spinlock/rwlock fixes' V3 [1/1]
Message-Id: <20050120130401.GA8061@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050118014752.GA14709@cse.unsw.EDU.AU> <16877.42598.336096.561224@wombat.chubb.wattle.id.au> <20050119080403.GB29037@elte.hu> <16878.9678.73202.771962@wombat.chubb.wattle.id.au> <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org> <16879.29449.734172.893834@wombat.chubb.wattle.id.au>
In-Reply-To: <16879.29449.734172.893834@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, dsw@gelato.unsw.edu.au, torvalds@osdl.org, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com


* Peter Chubb <peterc@gelato.unsw.edu.au> wrote:

> I suggest reversing the sense of the macros, and having
> read_can_lock() and write_can_lock()
> 
> Meaning:
> 	read_can_lock() --- a read_lock() would have succeeded
> 	write_can_lock() --- a write_lock() would have succeeded.

i solved the problem differently in my patch sent to lkml today: i
introduced read_trylock_test()/etc. variants which mirror the semantics
of the trylock primitives and solve the needs of the PREEMPT branch
within kernel/spinlock.c.

	Ingo
