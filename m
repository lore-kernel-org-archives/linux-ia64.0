From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2003 20:43:35 +0000
Subject: RE: [PATCH] New CMC/CPE polling
Message-Id: <marc-linux-ia64-106003003014980@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105969308328993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105969308328993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>    You might be right on the clearing side, I think moving it down
> a couple lines and disabling local interrupts would eliminate the
> potential hole though.  Something like this:
> 
> ia64_mca_cmc_int_caller(...)
> {
> ...
>     smp_call_function(ia64_mca_cmc_vector_enable, NULL, 1, 0);
>     local_irq_disable();
>     ia64_mca_cmc_vector_enable(NULL);
>     cmc_polling_enabled = 0;
> ...
> 
>    Does that address the race you were looking at?  I don't see one
> on the setting end, could you be more specific?  The spinlock feels
> like it does the trick to me.  Thanks for the comments,

My issue is that you check and set cmc_polling_enabled under the
protection of a lock (cmc_history_lock ... I realise that this is
mostly protecting the cmc_history[], but it also defends against
multiple cpus taking a CMCI at the same time and all trying to
switch over to polling mode).

But you clear cmc_polling_enabled without the lock.  So the race is
between enabling the interrupt (on all cpus) and taking the next
interrupt.  The local_irq_disable() in the above fragment fixes that
for the current cpu, but for other cpus you can end up in the handler
with cmc_polling_enabled set to the wrong value.

One way might be harmless, but I'm not sure which.

-Tony
