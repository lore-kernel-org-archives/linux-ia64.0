From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 11 May 2002 00:03:29 +0000
Subject: Re: Circular dependency between asm/system.h and asm/processor.h (Was:
Message-Id: <marc-linux-ia64-105590701905568@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905558@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905558@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 08 May 2002 23:49:10 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> local_irq_restore in asm/system.h needs IA64_PSR_I which is
  Andreas> only defined in asm/processor.h.  linux/tqueue.h defines
  Andreas> the inline function queue_task that uses
  Andreas> spin_unlock_irqrestore, which is defined in terms of
  Andreas> local_irq_restore, so it does not compile because
  Andreas> IA64_PSR_I is undefined.  But asm/processor.h already
  Andreas> depends on asm/system.h, so we cannot just include it
  Andreas> there.

I moved the PSR and DCR bit definitions into kregs.h and include this
file in system.h.  That seems cleaner and will avoid recursive
dependencies.

Thanks,

	--david

