From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 01 Sep 2004 05:22:24 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64
Message-Id: <20040831222224.736208b4.davem@davemloft.net>
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
In-Reply-To: <1094012689.6538.330.camel@gaston>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: clameter@sgi.com, akpm@osdl.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Wed, 01 Sep 2004 14:24:50 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> The removal of the page table lock has other more subtle side effects
> on ppc64 (and ppc32 too) that aren't trivial to solve. Typically, due
> to the way we use the hash table as a TLB cache.

True on sparc64 as well where the page table lock is what
synchronizes TLB context allocation for a process.
While the lock is held, we know that the TLB context cannot
change and this allows all kinds of TLB flush optimizations.

We also have the pseudo-invariant that flush_tlb_page() is
always called with the page table lock held.
