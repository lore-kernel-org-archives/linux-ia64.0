From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 28 Jul 2005 19:14:53 +0000
Subject: RE: Add prefetch switch stack hook in scheduler function
Message-Id: <200507281914.j6SJErg31398@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20050728090948.GA24222@elte.hu>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
In-Reply-To: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ingo Molnar' <mingo@elte.hu>, Keith Owens <kaos@ocs.com.au>
Cc: David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> i.e. like the patch below. Boot-tested on x86. x86, x64 and ia64 have a 
> real kernel_stack() implementation, the other architectures all return 
> 'next'. (I've also cleaned up a couple of other things in the 
> prefetch-next area, see the changelog below.)
> 
> Ken, would this patch generate a sufficient amount of prefetching on 
> ia64?

Sorry, this is not enough.  Switch stack on ia64 is 528 bytes.  We need to
prefetch 5 lines.  It probably should use prefetch_range().  But on ia64,
prefetch_range stride L1_CACHE_BYTES, where I really want to stride L3 cache
line size.

We also want to prefetch switch stack for current task, since processor
state is saved onto the stack for outgoing process.  And that stack is
almost guaranteed to be cold because switch stack is created below current
stack pointer. 

Can we just go back to prefetch_stack() or prefetch_task() (or use plural
name) and let each arch decide what to do with it?

- Ken

