From: Andrew Morton <akpm@osdl.org>
Date: Sat, 20 Dec 2003 10:41:59 +0000
Subject: Re: [RFC][PATCH] 2.6.0-test11 sched_clock() broken for "drifty ITC"
Message-Id: <marc-linux-ia64-107191690614174@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107178053026093@msgid-missing>
In-Reply-To: <marc-linux-ia64-107178053026093@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John Hawkes <hawkes@babylon.engr.sgi.com> wrote:
>
> David Mosberger suggests raising this issue on LKML to encourage a search
>  for a more general solution to my ia64 problem.
> 
>  My specific problem is that the generic ia64 sched_clock() is broken for
>  "drifty ITC" (the per-CPU cycle counter clock) platforms, such as the SGI
>  sn.  sched_clock() currently uses its local CPU's ITC and therefore on
>  drifty platforms its values are not synchronized across the CPUs.  This
>  results (in part) in an invalid load_balance() is-the-cache-hot-or-not
>  calculation.

Requiring that sched_clock() be synchronised is difficult for some
platforms.  Clearly, it is better if we can relax that.

> However, David Mosberger rejected this patch, and he seeks instead some
> hypothetical more generic approach to "drifty timebase platforms".  One
> possible generic change would be to relax the semantics of sched_clock() to
> no longer expect that the values be synchronized across all CPUs.

Your patch to kernel/sched.c looks good: low overhead, simple, Ingo likes
it.

Could you please finalise it, cook up the ia64 and numaq implementations
and send it over?


