From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 12 Jan 2005 23:50:05 +0000
Subject: Re: page table lock patch V15 [0/7]: overview
Message-Id: <41E5B7AD.40304@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>	<Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>	<Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>	<Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com>	<m1652ddljp.fsf@muc.de>	<Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com>	<41E4BCBE.2010001@yahoo.com.au>	<20050112014235.7095dcf4.akpm@osdl.org>	<Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>	<20050112104326.69b99298.akpm@osdl.org>	<41E5AFE6.6000509@yahoo.com.au> <20050112153033.6e2e4c6e.akpm@osdl.org>
In-Reply-To: <20050112153033.6e2e4c6e.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, torvalds@osdl.org, ak@muc.de, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>So my patches cost about 7% in lmbench fork benchmark.
> 
> 
> OK, well that's the sort of thing we need to understand fully.  What sort
> of CPU was that on?
> 

That was on a P4, although I've seen pretty similar results on ia64 and
other x86 CPUs.

Note that this was with my ptl removal patches. I can't see why Christoph's
would have _any_ extra overhead as they are, but it looks to me like they're
lacking in atomic ops. So I'd expect something similar for Christoph's when
they're properly atomic.

> Look, -7% on a 2-way versus +700% on a many-way might well be a tradeoff we
> agree to take.  But we need to fully understand all the costs and benefits.
> 

I think copy_page_range is the one to keep an eye on.

