From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 15 Sep 2005 06:34:35 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <1126766075.7372.16.camel@uluru.grenoble.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin,

> +
>  static int
>  default_handler(struct task_struct *task, void *buf, pfm_ovfl_arg_t *arg, struct pt_regs *regs, unsigned long stamp)
>  {
> @@ -165,6 +175,12 @@ default_handler(struct task_struct *task
>  	 * where did the fault happen (includes slot number)
>  	 */
>  	ent->ip = regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3);
> +#ifdef CONFIG_SMP
> +	/* Fix up the ip for code in the spinlock contention path. */
> +	if ((ent->ip >= (unsigned long)ia64_spinlock_contention) &&
> +	    (ent->ip < (unsigned long)ia64_spinlock_contention_end))
> +		ent->ip = regs->b6;
> +#endif

I think SGI already submitted something similar for the 2.4 kernel.
I understand your motivations for doing this. Yet it does not look
so clean and error proof. Keith already mentioned a potential gap.
I also think it is hard to maintain because if for some reasons someone
changes from b6 to b7 there is no way of tracking this from default_handler().
For your purpose, the value of b6 is more interesting than ip. Would that
always be the case for every measurement?

This also opens the door for people submitted other special cases.
This is the reasons why I designed sampling formats to be plug-in
modules such that for special needs, people can simply develop their
own format. I understand that your modification does not deeply alter
the default format and integrates seamlessly with existing applications.
But it seems there ought to be a cleaner way of doing this.

--
-stephane

