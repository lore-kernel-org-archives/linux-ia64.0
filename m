From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 19 Jan 2005 09:20:13 +0000
Subject: Re: Horrible regression with -CURRENT from "Don't busy-lock-loop in preemptable spinlocks" patch
Message-Id: <20050119092013.GA2045@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050117055044.GA3514@taniwha.stupidest.org> <20050116230922.7274f9a2.akpm@osdl.org> <20050117143301.GA10341@elte.hu> <20050118014752.GA14709@cse.unsw.EDU.AU> <16877.42598.336096.561224@wombat.chubb.wattle.id.au> <20050119080403.GB29037@elte.hu> <16878.9678.73202.771962@wombat.chubb.wattle.id.au>
In-Reply-To: <16878.9678.73202.771962@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Tony Luck <tony.luck@intel.com>, Darren Williams <dsw@gelato.unsw.edu.au>, Andrew Morton <akpm@osdl.org>, Chris Wedgwood <cw@f00f.org>, torvalds@osdl.org, benh@kernel.crashing.org, linux-kernel@vger.kernel.org, Ia64 Linux <linux-ia64@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>


* Peter Chubb <peterc@gelato.unsw.edu.au> wrote:

> >> Here's a patch that adds the missing read_is_locked() and
> >> write_is_locked() macros for IA64.  When combined with Ingo's
> >> patch, I can boot an SMP kernel with CONFIG_PREEMPT on.
> >> 
> >> However, I feel these macros are misnamed: read_is_locked() returns
> >> true if the lock is held for writing; write_is_locked() returns
> >> true if the lock is held for reading or writing.
> 
> Ingo> well, 'read_is_locked()' means: "will a read_lock() succeed"
> 
> Fail, surely?

yeah ... and with that i proved beyond doubt that the naming is indeed
unintuitive :-)

	Ingo
