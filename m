From: Erich Focht <focht@ess.nec.de>
Date: Thu, 31 Jan 2002 10:45:00 +0000
Subject: [Linux-ia64] Re: switch_mm race condition with Ingo's scheduler
Message-Id: <marc-linux-ia64-105590698805973@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Is it really necessary to flush all TLBs when doing a context switch on
> one?

I think the global TLB flush is not necessary at all when the mmu_context
counter wraps over (in wrap_mmu_context). Please tell me if I'm wrong...

Commented that out and got rid of the lockups with Ingo's scheduler.

Regards,
Erich


