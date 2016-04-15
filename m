From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 15 Apr 2016 13:08:29 +0000
Subject: Re: [PATCH] ia64: salinfo: use a waitqueue instead a sema down/up combo
Message-Id: <5710E7CD.4030208@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460466037-4037-1-git-send-email-bigeasy@linutronix.de>
In-Reply-To: <1460466037-4037-1-git-send-email-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 04/14/2016 11:33 PM, Luck, Tony wrote:
>> The only purpose of down_try_lock() followed by up() seems to be to wake
>> up a possible reader. This patch replaces it with a wake-queue. There is
>> no locking around cpumask_empty() and the test is re-done in case there
>> was no hit.
>> With wait_event_interruptible_lock_irq(,&data_saved_lock) we would probably
>> be able to get rid of the `retry` label. However we still can return CPU
>> X which is valid now but later (after the lock dropped) the event may
>> have been removed because the CPU went offline.
> 
> Do you have ia64 h/w to test this - or do you need me to try it out to
> make sure the reality matches the expected behavior?

no ia64 here.

>> And this brings me to the following question: Do you really want to drop all
>> entries for a CPU that goes offline? Wouldn't it make sense to keep that entry
>> even if the CPU is offline now? From what I understand MCA can send such an
>> interrupt / entry due to a memory error. Wouldn't it be important to keep this
>> information until userspace decides to remove it (despite the online state of
>> the CPU)?
> 
> Machine checks and soft offline don't really work well together. As you
> say the machine check may be broadcast, and there is no mechanism for
> soft offline to tell the h/w not to bother this logical cpu with such events.
> On x86 we recently added code to do_machine_check() to quietly return
> if we are called on an "offline" cpu.

Maybe I don't understand this. Please correct me if there is something
wrong.

- CPU2 has an MCA event logged, ->cpu_event is set for this CPU. Now
  CPU2 is going offline, the event is removed. Now the checks the
  buffer and notices that nothing is in there.
  Wouldn't happen if we would remove the CPU_DEAD notifier.

- CPU2 has no events logged, ->cpu_event is not set. CPU2 goes offline
  and MCA sends and logs a message. This message is removed by CPU_DEAD
  notifier.
  Again, wouldn't happen if we would remove the CPU_DEAD notifier.

Now, I wasn't thinking about this but based on your response it seems
to be a valid case:

- CPU2 is offline, ->cpu_event is not set for this CPU. While so an MCA
  event gets sent and logged (there is nothing to ignore this for
  offline CPUs as far as I can tell from looking at the salinfo code).
  There should be a wakeup() (unless the report was not irqsafe which
  is probably NMI context). The wakeup will happen again by the
  CPU_ONLINE notifier.

And there is this:
- CPU2 was offline, ->cpu_event is not set for any CPU. The CPU goes
  online and sets ->cpu_event for every CPU. Userland organizes a
  trailer for all those events but then there are no events logged.

So based on this I don't see a problem why salinfo_cpu_callback()
couldn't be removed. The !irqsafe reports are not lost since there is a
timer which does a wake up once a minute.

> 
> -Tony
> 
Sebastian
