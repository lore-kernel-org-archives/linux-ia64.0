From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 07 May 2008 09:12:58 +0000
Subject: Re: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <4821729A.5020802@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Shaohua Li wrote:
> On Wed, 2008-05-07 at 08:59 +0200, Petr Tesarik wrote:
>> BTW why must be interrupts disabled in this path? Would it be possible
>> to re-enable them for the duration of the synchronization, or does it
>> harm somehow?
> No idea how to fix it. i have the same question why
> do_notify_resume_user in called with interrupt disabled.
> do_notify_resume_user->ia64_do_signal->get_signal_to_deliver which could
> sleep (like try_to_freeze) and this routine calls
> spin_lock_irq()/spin_unlock_irq(), this will enable interrupt.

Yes, I found it too.
It seems that ia64_do_signal should be called with interrupts enabled.

Thanks,
H.Seto
