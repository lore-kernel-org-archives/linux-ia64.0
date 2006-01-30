From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 30 Jan 2006 18:53:01 +0000
Subject: Re: boot-time slowdown for measure_migration_cost
Message-Id: <20060130185301.GA4622@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601271403.27065.bjorn.helgaas@hp.com> <20060130172140.GB11793@elte.hu>
In-Reply-To: <20060130172140.GB11793@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Ingo Molnar <mingo@elte.hu>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Ingo Molnar <mingo@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 30, 2006 at 06:21:40PM +0100, Ingo Molnar wrote:
> - double-check that max_cache_size gets set up correctly on your=20
>   architecture - the code searches from ~64K to 2*max_cache_size.

Ia64 gets that from PAL in get_max_cacheline_size() in ia64/kernel/setup.c
A quick printk() in there confirms that we get the right answer (9MB for
me), and that it happens before we compute the migration cost.

> - take the values that are auto-detected and use the migration_cost=3D=20
>   boot parameter - see Documentation/kernel-parameters.txt:
>   ...
>   via this solution you will get zero overhead on subsequent bootups.

But if you are going to go this route, you could drop all this code from
the kernel and have a hard-wired constant, with a user-mode test program
to compute the more accurate value.

> - in kernel/sched.c, decrease ITERATIONS from 2 to 1. This will make the =

>   measurement more noisy though.

Doing this drops the time to compute the value from 15.58s to 10.39s, while
the value of migration_cost changes from 10112 to 9909.

> - in kernel/sched.c, change this line:
>                 size =3D size * 20 / 19;
>   to:
>                 size =3D size * 10 / 9;

Doing this instead of changing ITERATIONS makes the computation take 7.79s
and the computed migration_cost is 9987.

Doing both gets the time down to 5.20s, and the migration_cost=9990.

So the variation in the computed value of migration_cost was at worst
2% with these modifications to the algorithm.  Do you really need to know
the value to this accuracy?  What 2nd order bad effects would occur from
using an off-by-2% value for scheduling decisions?

On the plus side Prarit's results show that this time isn't scaling with
NR_CPUS ... apparently just cache size and number of domains are significant
in the time to compute.

-Tony
