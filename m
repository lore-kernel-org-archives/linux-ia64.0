From: Erich Focht <efocht@ess.nec.de>
Date: Fri, 12 Jul 2002 16:47:58 +0000
Subject: [Linux-ia64] Re: switch_mm race condition with Ingo's scheduler
Message-Id: <marc-linux-ia64-105590701905769@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Also, I think it's sufficient to
> call delayed_flush_tlb() in get_new_mmu_context(), as we just need to
> make sure that the TLB does get flushed before.  Or did this not work
> for some reason?

But then other processors would continue using the old TLBs maybe of
tasks which died. The problem is that we need to do a TLB flush on all
CPUs when wrapping around the context. Otherwise we might reuse the context
number of a recently exited process and on other CPUs some of its TLB entries
may survive until the new task switches CPUs. Hard to debug, probably...

Regards,
Erich



