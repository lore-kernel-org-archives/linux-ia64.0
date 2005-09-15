From: Robin Holt <holt@sgi.com>
Date: Thu, 15 Sep 2005 17:23:53 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <20050915172353.GC10755@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 15, 2005 at 08:34:35AM +0200, Stephane Eranian wrote:
> Robin,
> 
> > +
> >  static int
> >  default_handler(struct task_struct *task, void *buf, pfm_ovfl_arg_t *arg, struct pt_regs *regs, unsigned long stamp)
> >  {
> > @@ -165,6 +175,12 @@ default_handler(struct task_struct *task
> >  	 * where did the fault happen (includes slot number)
> >  	 */
> >  	ent->ip = regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3);
> > +#ifdef CONFIG_SMP
> > +	/* Fix up the ip for code in the spinlock contention path. */
> > +	if ((ent->ip >= (unsigned long)ia64_spinlock_contention) &&
> > +	    (ent->ip < (unsigned long)ia64_spinlock_contention_end))
> > +		ent->ip = regs->b6;
> > +#endif
> 
> I think SGI already submitted something similar for the 2.4 kernel.
> I understand your motivations for doing this. Yet it does not look
> so clean and error proof. Keith already mentioned a potential gap.
> I also think it is hard to maintain because if for some reasons someone
> changes from b6 to b7 there is no way of tracking this from default_handler().
> For your purpose, the value of b6 is more interesting than ip. Would that
> always be the case for every measurement?

Can you ever think of a case that monitoring an entire
application including kernel activity would benefit from seeing
ia64_spinlock_contention instead of the function doing the work.  We made
this change to our distro many years ago and have never found a case
where less specific information was good.  We have found knowing which
function was causing spinlock contention to always be more helpful than
just knowing there is contention.

> This also opens the door for people submitted other special cases.

I don't think this change which is arguably getting the information
that the module is providing correct.

> This is the reasons why I designed sampling formats to be plug-in
> modules such that for special needs, people can simply develop their
> own format. I understand that your modification does not deeply alter
> the default format and integrates seamlessly with existing applications.
> But it seems there ought to be a cleaner way of doing this.

If you are suggesting I check in a second format module just for this,
I could do that, but... I can not think of a cleaner way than my most
recent patch provides.  I am open to suggestions.

Thanks,
Robin
