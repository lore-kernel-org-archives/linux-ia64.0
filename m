From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 13 Oct 2003 15:24:42 +0000
Subject: Re: Race in salinfo.c?
Message-Id: <marc-linux-ia64-106605905131089@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106603536206819@msgid-missing>
In-Reply-To: <marc-linux-ia64-106603536206819@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 13 October 2003 2:55 am, Keith Owens wrote:
> I need a sanity check on the existing salinfo.c code, it looks like a
> race.
> 
> salinfo_log_wakeup()
> 
>   set_bit(smp_processor_id(), &event->cpu_mask);
>   wake_up_interruptible(&event->queue);
> 
> salinfo_event_read()
> 
>   if (!event->cpu_mask) {
>     ...
>     interruptible_sleep_on(&event->queue);
> 
> 
> 
>       cpu 0                                   cpu 1
> salinfo_log_wakeup                      salinfo_event_read
>                                         event->cpu_mask = 0
> set_bit()
> wake_up_interruptible(), nothing on
> the queue
>                                         interruptible_sleep_on()
> 
> cpu 1 missed the event.  It will only be picked up if another salinfo
> event occurs and calls wake_up_interruptible() a second time.

I think you're right.

