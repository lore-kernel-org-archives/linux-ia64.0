From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 20 Jan 2005 17:30:45 +0000
Subject: Re: [PATCH RFC] 'spinlock/rwlock fixes' V3 [1/1]
Message-Id: <Pine.LNX.4.58.0501200926510.8178@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050116230922.7274f9a2.akpm@osdl.org> <20050117143301.GA10341@elte.hu>
 <20050118014752.GA14709@cse.unsw.EDU.AU> <16877.42598.336096.561224@wombat.chubb.wattle.id.au>
 <20050119080403.GB29037@elte.hu> <16878.9678.73202.771962@wombat.chubb.wattle.id.au>
 <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com>
 <20050120023445.GA3475@taniwha.stupidest.org> <Pine.LNX.4.58.0501200812300.8178@ppc970.osdl.org>
 <20050120162309.GB14002@elte.hu>
In-Reply-To: <20050120162309.GB14002@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Chris Wedgwood <cw@f00f.org>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, Peter Chubb <peterc@gelato.unsw.edu.au>, Tony Luck <tony.luck@intel.com>, Darren Williams <dsw@gelato.unsw.edu.au>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ia64 Linux <linux-ia64@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Jesse Barnes <jbarnes@sgi.com>



On Thu, 20 Jan 2005, Ingo Molnar wrote:
> 
> right. Replace patch #4 with:
>  
>  /**
>   * read_can_lock - would read_trylock() succeed?
>   * @lock: the rwlock in question.
>   */
> -#define read_can_lock(x) (atomic_read((atomic_t *)&(x)->lock) > 0)
> +static inline int read_can_lock(rwlock_t *rw)
> +{
> +	return rw->lock > 0;
> +}

No, it does need the cast to signed, otherwise it will return true for the 
case where somebody holds the write-lock _and_ there's a pending reader 
waiting too (the write-lock will make it zero, the pending reader will 
wrap around and make it negative, but since "lock" is "unsigned", it will 
look like a large value to "read_can_lock".

I also think I'd prefer to do the things as macros, and do the type-safety 
by just renaming the "lock" field like Chris did. We had an issue with gcc 
being very slow recently, and that was due to some inline functions in 
header files: gcc does a lot of work on an inline function regardless of
whether it is used or not, and the spinlock header file is included pretty 
much _everywhere_...

Clearly inline functions are "nicer", but they do come with a cost.

		Linus
