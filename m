From: Tim Schmielau <tim@physik3.uni-rostock.de>
Date: Mon, 24 Mar 2003 12:10:55 +0000
Subject: [Linux-ia64] Re: [PATCH] fix nanosleep() granularity bumps
Message-Id: <marc-linux-ia64-105590723705298@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705296@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705296@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Tue, Mar 18, 2003 at 10:05:56AM +0100, Tim Schmielau wrote:
[...]
> Suggest the attached patch as a fix instead - easier to understand I
> think and works for every possible start value. This is what I made for
> Andrea Arcangeli many years ago...
>
> diff -ur linux-2.5.65/kernel/timer.c linux-2.5.65-new/kernel/timer.c
> --- linux-2.5.65/kernel/timer.c	2003-03-17 22:44:41.000000000 +0100
> +++ linux-2.5.65-new/kernel/timer.c	2003-03-24 12:57:31.000000000 +0100
> @@ -1182,11 +1182,14 @@
>  		INIT_LIST_HEAD(base->tv1.vec + j);
>
>  	base->timer_jiffies = INITIAL_JIFFIES;
> -	base->tv1.index = INITIAL_JIFFIES & TVR_MASK;
> -	base->tv2.index = (INITIAL_JIFFIES >> TVR_BITS) & TVN_MASK;
> -	base->tv3.index = (INITIAL_JIFFIES >> (TVR_BITS+TVN_BITS)) & TVN_MASK;
> -	base->tv4.index = (INITIAL_JIFFIES >> (TVR_BITS+2*TVN_BITS)) & TVN_MASK;
> -	base->tv5.index = (INITIAL_JIFFIES >> (TVR_BITS+3*TVN_BITS)) & TVN_MASK;
> +	base->tv1.index = (1 + (INITIAL_JIFFIES - 1)) & TVR_MASK;
> +	base->tv2.index = (1 + ((INITIAL_JIFFIES - 1) >> TVR_BITS)) & TVN_MASK;
> +	base->tv3.index = (1 + ((INITIAL_JIFFIES - 1)
> +				>> (TVR_BITS + TVN_BITS))) & TVN_MASK;
> +	base->tv4.index = (1 + ((INITIAL_JIFFIES - 1)
> +				>> (TVR_BITS + 2 * TVN_BITS))) & TVN_MASK;
> +	base->tv5.index = (1 + ((INITIAL_JIFFIES - 1)
> +				>> (TVR_BITS + 3 * TVN_BITS))) & TVN_MASK;
>  }
>
>  static int __devinit timer_cpu_notify(struct notifier_block *self,

Too late - the whole tv[1-5].index duplication is gone already after a
cleanup done by George Anzinger.

Tim


