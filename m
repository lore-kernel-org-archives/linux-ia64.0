From: Erich Focht <efocht@ess.nec.de>
Date: Fri, 12 Jul 2002 17:26:07 +0000
Subject: [Linux-ia64] Re: switch_mm race condition with Ingo's scheduler
Message-Id: <marc-linux-ia64-105590701905771@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> But the only time you might reuse an old context number is when you
> allocate one.  Yes, you will have old entries hanging around in the
> TLB for a while, but you _know_ that the corresponding tasks already
> died and you also know that you'll flush the TLB before re-using one
> of those context numbers.

Context numbers are global, used by all CPUs in common. Suppose
task 123 is newly created and we want a context number for it. Unfortunately
it's time to wrap around context numbers and we reuse the context number
of task 100 which died a short while ago and left over TLB entries on all
CPUs of the machine.

get_new_mmu_context is called on the CPU where task 123 is scheduled first.
We can flush TLB there. But on the other CPUs the stale entries of task 100
survive. If no new context is needed before task 123 gets migrated to
another CPU, it might reuse TLB entries of task 100, which are wrong.
I'm not worried about taking an old context number but of using old TLB
entries when my newly created task with reused context number switches
CPUs. flush_tlb_all() was flushing all TLB entries by sending an IPI but
this can lead to a deadlock... Do I misunderstand something?

Regards,
Erich
 

