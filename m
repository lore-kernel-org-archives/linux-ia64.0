From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 16 Jun 2004 20:40:20 +0000
Subject: Re: [PATCH] early console registration
Message-Id: <200406161640.20838.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405141425.59867.jbarnes@engr.sgi.com>
In-Reply-To: <200405141425.59867.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, June 16, 2004 4:22 pm, Bjorn Helgaas wrote:
> On Tuesday 15 June 2004 7:12 am, Jesse Barnes wrote:
> > Yeah, that's fine.  In fact, I've tested something similar and sent it to
> > Andrew, but he came back and asked why not just set CPU 0 online early? 
> > And given that CPU 0 is 'online' as soon as the kernel starts executing
> > head.S, it seems like it *should* keep working, and we should probably
> > keep it that way.
>
> It's *not* online as soon as it starts head.S, though -- that's what I
> meant about preserving the original cpu_online semantics.  It currently
> means that at least cpu_init() has been called, so memory allocation,
> per-cpu data, and interrupts should work.

Well, online in the sense that it can execute instructions, but yes, other 
limitations apply, I tried to spell them out in the comments for the 
function.

> If we mark CPU 0 as 'online' earlier, some hypothetical new code could
> test cpu_online(0) and incorrectly assume per-cpu data works.

Yeah, that's possible, but the window is pretty small.

> But AFAIK, there is no such code now, and I don't have any better ideas,
> so maybe we should just go with your ia64-specific patch for now.

Sounds good to me.

Jesse
