From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 20 Aug 2004 14:57:30 +0000
Subject: Re: [PATCH] add scheduler domains for ia64
Message-Id: <200408201057.30813.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131108.40502.jbarnes@engr.sgi.com> <200408192222.35512.jbarnes@engr.sgi.com> <20040819232855.5d919155.akpm@osdl.org>
In-Reply-To: <20040819232855.5d919155.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, hawkes@sgi.com, mingo@elte.hu

On Friday, August 20, 2004 2:28 am, Andrew Morton wrote:
> Jesse Barnes <jbarnes@engr.sgi.com> wrote:
> > Yep, it's been working ok so far.  There's still more we can do, but this
> > is a good start I think.  Andrew, this version applies on top of
> > 2.6.8.1-mm2 but overwrites most of the earlier node-span patch by moving
> > bits from arch/ia64 to kernel/sched.c, so let me know if you want the
> > patch in a different format.
>
> Is OK.  I wiggled it into the logical place so we'll end up with a sane
> patch series.
>
> Watch the warnings please...
>
>
>
> kernel/sched.c:3732: warning: `sched_domain_node_span' defined but not used

Oops, sorry about that!  I meant to test with CONFIG_NUMA=n but fell asleep.  
I'll be more careful in the future.

Jesse
