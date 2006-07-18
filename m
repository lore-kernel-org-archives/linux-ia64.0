From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 18 Jul 2006 02:54:58 +0000
Subject: Re: [PATCH] oops_in_progress on MCA/INIT
Message-Id: <44BC4D82.8080706@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200607111912.k6BJCrIP1986049@efs.americas.sgi.com>
In-Reply-To: <200607111912.k6BJCrIP1986049@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> Keith Owens wrote:
>> The existing 'oops_in_progress' code is working pretty well.  It does
>> leave nasty bits behind if the MCA is recoverable, but that problem is
>> not bad enough to justify a completely separate print mechanism plus
>> changes to external programs.  Instead we should fix the unwanted side
>> effects of oops_in_progress.
> 
> One problem is that oops_in_progress gets set in MCA/INIT but
> does not get cleared if the MCA is recovered (or after the INIT
> stack trace prints).  The result is that subsequent messages do
> not get to /var/log/messages, due to release_console_sem() not 
> waking up klogd.  Thanks to Keith Owens for his analysis of 
> this problem.
> 
> This patch does not address the larger issue of printing from
> MCA/INIT context.

Still there are larger issues...

Here are related codes in kernel/printk.c(2.6.17):

  418 static void zap_locks(void)
  419 {
  420         static unsigned long oops_timestamp;
  421
  422         if (time_after_eq(jiffies, oops_timestamp) &&
  423                         !time_after(jiffies, oops_timestamp + 30 * HZ))
  424                 return;
  425
  426         oops_timestamp = jiffies;
  427
  428         /* If a crash is occurring, make sure we can't deadlock */
  429         spin_lock_init(&logbuf_lock);
  430         /* And make sure that we print immediately */
  431         init_MUTEX(&console_sem);
  432 }

  490 asmlinkage int vprintk(const char *fmt, va_list args)
  491 {
  492         unsigned long flags;
  493         int printed_len;
  494         char *p;
  495         static char printk_buf[1024];
  496         static int log_level_unknown = 1;
  497
  498         preempt_disable();
  499         if (unlikely(oops_in_progress) && printk_cpu = smp_processor_id())
  500                 /* If a crash is occurring during printk() on this CPU,
  501                  * make sure we can't deadlock */
  502                 zap_locks();
  503
  504         /* This stops the holder of console_sem just where we want him */
  505         spin_lock_irqsave(&logbuf_lock, flags);
  506         printk_cpu = smp_processor_id();

It seems that there are at least two problems not solved yet.

  - zap_lock initializes console_sem. It doesn't wake up waiters.
  - it allows existence of two holders of logbuf_lock if interrupted
    original holder restarts after spin_lock_init(logbuf_lock).
    You'll see mixed message like: inrterecruovepteredd

These larger issues are more critical and need to be solved before
returning from MCA/INIT handlers saying "recovered".
And these issues are no matter if the kernel is really progressing oops.


H.Seto

