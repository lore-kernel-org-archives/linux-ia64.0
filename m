From: Keith Owens <kaos@sgi.com>
Date: Mon, 13 Oct 2003 08:55:38 +0000
Subject: Race in salinfo.c?
Message-Id: <marc-linux-ia64-106603536206819@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I need a sanity check on the existing salinfo.c code, it looks like a
race.

salinfo_log_wakeup()

  set_bit(smp_processor_id(), &event->cpu_mask);
  wake_up_interruptible(&event->queue);

salinfo_event_read()

  if (!event->cpu_mask) {
    ...
    interruptible_sleep_on(&event->queue);



      cpu 0                                   cpu 1
salinfo_log_wakeup                      salinfo_event_read
                                        event->cpu_mask = 0
set_bit()
wake_up_interruptible(), nothing on
the queue
                                        interruptible_sleep_on()

cpu 1 missed the event.  It will only be picked up if another salinfo
event occurs and calls wake_up_interruptible() a second time.

If that race exists (I cannot see anything that prevents it), the only
solution is to grab BKL around accesses of event->cpu_mask.  It has to
be BKL, we have no atomic operation that does 

  drop_lock();
  interruptible_sleep_on();
  acquire_lock();

I am already doing other work on salinfo.c.  If this race is real then
I will do a patch to close it.

