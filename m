From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 May 2004 22:58:32 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405041558.32288.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, May 4, 2004 3:51 pm, David Mosberger wrote:
> Yes.  I doubt it would be an issue for inX/outX emulation in the int10
> module.

True.

> I was talking about hard-failure of inX/outX.  If SN2 does that, it's
> broken and I'm not terribly sympathetic (but see below).

But my point was: doesn't in/out hard fail on other ia64 platforms too?  If 
so, then it makes sense to deal with it generically.

>   Jesse> it's a generic way to deal with hard fails on PIO reads,
>   Jesse> which afaik, affects all ia64 platforms.  Correct me if I'm
>   Jesse> wrong here...
>
> Let me try to say it differently: inX/outX must soft-fail.  How you
> achieve that on SN2, I don't really care.  If, for other reasons,
> there happens to be an infrastructure you can hook into to facility
> implementation of soft-fail inX/outX on SN2, that's certainly fine by
> me.  But don't try to use inX/outX soft-fail as a reason to justify
> the infrastructure.  Better?

Sure, that makes sense.  The other part of the implementation was to deal with 
regular MMIO accesses though--userspace drivers want to get signalled when an 
error occurs, would you propose the page fault mechanism to detect that as 
well, or is an MCA handler a better way to go?

Thanks,
Jesse
