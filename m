From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 01 Sep 2004 23:09:25 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64
Message-Id: <1094080164.4025.17.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
	 <20040815130919.44769735.davem@redhat.com>
	 <Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com>
	 <20040815165827.0c0c8844.davem@redhat.com>
	 <Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com>
	 <20040815185644.24ecb247.davem@redhat.com>
	 <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com>
	 <20040816143903.GY11200@holomorphy.com>
	 <B6E8046E1E28D34EB815A11AC8CA3129027B679F@mtv-atc-605e--n.corp.sgi.com>
	 <B6E8046E1E28D34EB815A11AC8CA3129027B67A9@mtv-atc-605e--n.corp.sgi.com>
	 <B6E8046E1E28D34EB815A11AC8CA3129027B67B4@mtv-atc-605e--n.corp.sgi.com>
	 <Pine.LNX.4.58.0408271616001.14712@schroedinger.engr.sgi.com>
	 <1094012689.6538.330.camel@gaston>
	 <Pine.LNX.4.58.0409010938200.9907@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0409010938200.9907@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, "David S. Miller" <davem@redhat.com>, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>, vrajesh@umich.edu, hugh@veritas.com

On Thu, 2004-09-02 at 02:43, Christoph Lameter wrote:

> This would limit the time that the page_table_lock is held to a minimum
> and may still offer some of the performance improvements.
> 
> Would that be acceptable?

Not sure... You probably want to have the set_pte and the later flush_*
in the same lock to maintain expected semantics with those platforms...

It's not that a simple issue. I have ways to do sort-of lock-less by
using my PAGE_BUSY lock bit in the PTE instead on ppc64 and I think
doing that properly would result in almost no overhead over what we have
now, so I'm still interested. ppc32 would have to take a global
spinlock, but that's fine as we aren't looking for scalability on this
arch.

So while I like your idea, I think it needs a bit more thinking & work
on some platforms. David wrote about potential issues on sparc64, and I
wonder if it would be worth re-thinking some of the pte invalidation
semantics a bit (pushing more logic into set-pte, that is making it
higher level, rather than having the common code split changing of PTEs
and invalidations, with eventually some beign/end semantics for batches)

BTW. We should get David's patch in first thing before tackling with
this complicated issue (the one adding mm & addr to set_pte & friends).

Ben.


