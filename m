From: Erich Focht <focht@ess.nec.de>
Date: Mon, 21 Jan 2002 18:24:08 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805899@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Please ignore my previous email. The interrupt can of course come from
within the context_switch() part in schedule(), where psr.i is set.

Unfortunately the context switch in Ingo's scheduler happens with the
runqueue lock held, which can lead to a deadlock eg. if the timer
interrupt is called inside and sched_tick spinlocks on the runqueue lock
held by schedule(). On IA64 (HZ24) this probably happens much more
frequently than on IA32 (HZ0).

Regards,
Erich


On Sat, 19 Jan 2002, David Mosberger wrote:

> psr.i *does* disable all interrupts, including NMI.  Device interrupts
> are generally referred to as "external interrupts" in the ia64
> manuals.  If you read the manual, you'll find there is no ambiguity
> about this at all.  For example, see Table 5-8: External Interrupt
> Control Registers; it lists ITV...
> 
> 	--david


