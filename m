From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 20 Oct 2004 00:02:04 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <4175AAFC.5060903@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:
> Some have noticed that the overlapping sched domains code doesn't quite work 
> as intended (it results in disjoint domains on some machines), and that a top 
> level, machine spanning domain is needed.  This patch from John Hawkes adds 
> it to the ia64 code.  This allows processes to run on all CPUs in large 
> systems, though balancing is limited.  It should go to Linus soon now 
> otherwise large systems will only have ~16p (depending on topology) usable by 
> the scheduler.  I sanity checked it on a small system after rediffing John's 
> original, and he's done some testing on very large systems.
> 
> Nick, can you buy off on the sched.c change?  Alternatively, do you want to 
> send that fix separately John?

No, that looks good. It is a pretty trivial change so I think its harmless
to go in with this patch.

I'd consider increasing balancing rates for the SD_NODE_INIT domains after
this patch goes in too.

