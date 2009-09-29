From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Sep 2009 00:14:07 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909281706420.6996@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 28 Sep 2009, Rick Jones wrote:
> 
> Youch, that is 17% if I've done the math correctly.  This is to deal with
> contended locks more "fairly" correct?

It's worth to note that if there is actual real contention, then a fair 
lock generally has lower throughput than a non-fair one, so that case is 
likely also slowed down, not just the non-contended one.

That said, I think it's been worth it on x86. We had some test-programs to 
show some rather extreme unfairness on x86, especially on big machines. 
With the lock local to one node, that node had a huge advantage in 
re-acquiring the lock, to the point where you had lock imbalances on the 
order of 10,000:1. At some point that becomes a real starvation issue, 
although obviously you'd hope that the kernel never gets even close to 
that much contention on any locks.

[ I also don't think it was anywhere near a 17% hit on x86 in general - 
  although xadd _was_ noticeably slower on some microarchitectures than a 
  regular 'inc' due to being microcoded or something, so it was a hit on 
  _some_ microarchitectures ]

That said, the 8% slowdown sounds like a real problem. Maybe Tony's 
original version (perhaps with a "ld.bias" to get the initial load to try 
to get exclusive ownership) is worth the size expansion. On x86, we have 
atomic 8-bit and 16-bit operations with arbitrary immediates, so there's 
not the silly overhead from the shifting and masking.

		Linus
