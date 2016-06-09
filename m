From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 09 Jun 2016 13:10:35 +0000
Subject: Re: [PREEMPT-RT] [PATCH] ia64: salinfo: use a waitqueue instead a sema down/up combo
Message-Id: <275e729f-10a6-fdf2-3dfe-d19de4f5b8f0@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 04/15/2016 03:08 PM, Sebastian Andrzej Siewior wrote:
> On 04/14/2016 11:33 PM, Luck, Tony wrote:
>>> The only purpose of down_try_lock() followed by up() seems to be to wake
>>> up a possible reader. This patch replaces it with a wake-queue. There is
>>> no locking around cpumask_empty() and the test is re-done in case there
>>> was no hit.
>>> With wait_event_interruptible_lock_irq(,&data_saved_lock) we would probably
>>> be able to get rid of the `retry` label. However we still can return CPU
>>> X which is valid now but later (after the lock dropped) the event may
>>> have been removed because the CPU went offline.
>>
>> Do you have ia64 h/w to test this - or do you need me to try it out to
>> make sure the reality matches the expected behavior?
> 
> no ia64 here.

Tony?

Sebastian

