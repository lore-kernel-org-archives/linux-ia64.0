From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 14 Aug 2004 03:23:47 +0000
Subject: Re: [PATCH] add scheduler domains for ia64
Message-Id: <411D85C3.4030808@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131108.40502.jbarnes@engr.sgi.com>
In-Reply-To: <200408131108.40502.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, John Hawkes <hawkes@sgi.com>, Ingo Molnar <mingo@elte.hu>

Jesse Barnes wrote:
> Nick, how does this look?  It adds scheduler domain code for ia64 and replaces 
> the patch in Andrew's tree.  It also adds SD_NODE_INIT macros to each arch 
> that has ARCH_HAS_SCHED_DOMAIN so that the balance values are more easily 
> tweaked.  Since the cpu span of the nodes on ia64 is smaller than the whole 
> system, I also removed a WARN_ON in active_load_balance, but I'm not sure if 
> that's correct.

Hi Jesse,
Andrew's latest tree should have a number of improvements and changes
to the sched domains code which you will need to synch up to.

One issue you may have is that Ingo removed the ability to have arch
code override the domain structure due to it being too hazardous for
architectures to use in this form (which I don't entirely disagree with).

Now I guess your patch could go into the generic code because it is
pretty general - however are you guys going to want to do anything
more fancy with these things?

Nick
