From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 04 Aug 2003 21:15:33 +0000
Subject: Re: [PATCH] New CMC/CPE polling
Message-Id: <marc-linux-ia64-106003174416758@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105969308328993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105969308328993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" wrote:
> 
> >    You might be right on the clearing side, I think moving it down
> > a couple lines and disabling local interrupts would eliminate the
> > potential hole though.  Something like this:
> >
> > ia64_mca_cmc_int_caller(...)
> > {
> > ...
> >     smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0);
> >     local_irq_disable();
> >     ia64_mca_cmc_vector_enable(NULL);
> >     cmc_polling_enabled = 0;
> > ...
> >
> >    Does that address the race you were looking at?  I don't see one
> > on the setting end, could you be more specific?  The spinlock feels
> > like it does the trick to me.  Thanks for the comments,
> 
> My issue is that you check and set cmc_polling_enabled under the
> protection of a lock (cmc_history_lock ... I realise that this is
> mostly protecting the cmc_history[], but it also defends against
> multiple cpus taking a CMCI at the same time and all trying to
> switch over to polling mode).
> 
> But you clear cmc_polling_enabled without the lock.  So the race is
> between enabling the interrupt (on all cpus) and taking the next
> interrupt.  The local_irq_disable() in the above fragment fixes that
> for the current cpu, but for other cpus you can end up in the handler
> with cmc_polling_enabled set to the wrong value.
> 
> One way might be harmless, but I'm not sure which.

Tony,

   I believe it is harmless.  I make use of the spinlock when setting
cmc_polling_enabled to serialize the cpus.  ia64_mca_cmc_int_handler()
can obviously have multiple CPUs in it at the same time.  However,
the polling sequence is naturally serialized, so there will never
be more than one CPU in the block that clears cmc_polling_enabled.
I didn't feel it necessary to pull the spinlock out of the interrupt
handler when it wasn't needed.

   With the modifications above, there is a tiny window where the
other CPUs could take a CMCI while the cmc_polling_enabled flag is in
the wrong state.  IMHO, this doesn't really seem like a problem.
The goal of polling for CMCs is simply to make the system usable, not
to count every CMC that occurs.  Forward progress towards setting
the flag in the right state is ensured by disabling interrupts, so
the window is guaranteed to be very small.  FWIW, this is the same
state we're in between ia64_mca_init() and ia64_mca_late_init().

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab
