From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Sat, 14 Aug 2004 20:52:01 +0000
Subject: Re: [PATCH] add scheduler domains for ia64
Message-Id: <200408141352.01486.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131108.40502.jbarnes@engr.sgi.com> <411D85C3.4030808@yahoo.com.au>
In-Reply-To: <411D85C3.4030808@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, John Hawkes <hawkes@sgi.com>, Ingo Molnar <mingo@elte.hu>

On Friday, August 13, 2004 8:23 pm, Nick Piggin wrote:
> Andrew's latest tree should have a number of improvements and changes
> to the sched domains code which you will need to synch up to.

Yeah, I forgot about those.  I'll respin against your consolidation stuff.

> One issue you may have is that Ingo removed the ability to have arch
> code override the domain structure due to it being too hazardous for
> architectures to use in this form (which I don't entirely disagree with).
>
> Now I guess your patch could go into the generic code because it is
> pretty general - however are you guys going to want to do anything
> more fancy with these things?

Maybe, we haven't figured out the best way to schedule on a 512p yet, but most 
or all of this code is generic.  In order for things to work at all though, 
we'll need to change some of the SD_NODE_INIT values, maybe we can keep that 
as per-arch?

Thanks,
Jesse
