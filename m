From: Keith Owens <kaos@sgi.com>
Date: Thu, 16 Oct 2003 06:58:44 +0000
Subject: Re: Race in salinfo.c?
Message-Id: <marc-linux-ia64-106628768406629@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106603536206819@msgid-missing>
In-Reply-To: <marc-linux-ia64-106603536206819@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 13 Oct 2003 09:24:42 -0600, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>On Monday 13 October 2003 2:55 am, Keith Owens wrote:
>> I need a sanity check on the existing salinfo.c code, it looks like a
>> race.
>> 
>> salinfo_log_wakeup()
>> 
>>   set_bit(smp_processor_id(), &event->cpu_mask);
>>   wake_up_interruptible(&event->queue);
>> 
>> salinfo_event_read()
>> 
>>   if (!event->cpu_mask) {
>>     ...
>>     interruptible_sleep_on(&event->queue);

>I think you're right.

More salinfo problems.  2.4.23-pre6 cset-1.1069.1.78-to-1.1103 has 
salinfo_save_record which does spin_lock_irqsave(&data_lock).
salinfo_log_open() only does spin_lock(&data_lock).  This sequence will
deadlock

sys_open()->salinfo_log_open()
  salinfo_log_open()->spin_lock(&data_lock)
  cpe or cmc interrupt->salinfo_log_wakeup()
    salinfo_log_wakeup()->salinfo_save_record()
      salinfo_save_record()->spin_lock_irqsave(&data_lock)
      Deadlock.

Besides that deadlock (which can be fixed by always using
spin_lock_irqsave on data_lock), there is still the race I described
above.  Making {set bit, wakeup} atomic wrt. {test bits, sleep}
requires BKL.  Taking BKL in salinfo_log_wakeup() can deadlock when
salinfo_log_wakeup() is called from an interrupt.

cmc and cpe records are processed in interrupt context but with
interrupts enabled.  So a cmc event can interrupt cpe and vice versa.

Most of the problem is caused by the different contexts that the
salinfo code is called from.  Sometimes it is in interrupt, sometimes
it is not.  salinfo_log_wakeup() is called in both user and interrupt
context, which affects all the downstream routines.

What about changing all salinfo.c code to always run in user context,
with interrupts enabled?  That removes all the deadlocks and lets us
use BKL to fix the race above.  It also lets us use vmalloc instead of
kmalloc, every little helps.  smp_call_function_single() gets replaced
with set_cpus_allowed() so reading the record from another cpu runs in
user, not interrupt, context.

The interface between mca.c and salinfo.c would become a tasklet.
mca.c calls salinfo_log_wakeup_schedule() which saves the buffer
address and size and schedules salinfo_log_wakeup().  The tasklet
scheduler ensures that the salinfo code only runs one instance at a
time.

