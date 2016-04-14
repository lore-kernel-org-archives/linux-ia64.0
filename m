From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 14 Apr 2016 21:33:51 +0000
Subject: RE: [PATCH] ia64: salinfo: use a waitqueue instead a sema down/up combo
Message-Id: <3908561D78D1C84285E8C5FCA982C28F3A0A605E@ORSMSX114.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460466037-4037-1-git-send-email-bigeasy@linutronix.de>
In-Reply-To: <1460466037-4037-1-git-send-email-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The only purpose of down_try_lock() followed by up() seems to be to wake
> up a possible reader. This patch replaces it with a wake-queue. There is
> no locking around cpumask_empty() and the test is re-done in case there
> was no hit.
> With wait_event_interruptible_lock_irq(,&data_saved_lock) we would probably
> be able to get rid of the `retry` label. However we still can return CPU
> X which is valid now but later (after the lock dropped) the event may
> have been removed because the CPU went offline.

Do you have ia64 h/w to test this - or do you need me to try it out to
make sure the reality matches the expected behavior?


> And this brings me to the following question: Do you really want to drop all
> entries for a CPU that goes offline? Wouldn't it make sense to keep that entry
> even if the CPU is offline now? From what I understand MCA can send such an
> interrupt / entry due to a memory error. Wouldn't it be important to keep this
> information until userspace decides to remove it (despite the online state of
> the CPU)?

Machine checks and soft offline don't really work well together. As you
say the machine check may be broadcast, and there is no mechanism for
soft offline to tell the h/w not to bother this logical cpu with such events.
On x86 we recently added code to do_machine_check() to quietly return
if we are called on an "offline" cpu.

-Tony
