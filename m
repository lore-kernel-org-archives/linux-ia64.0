From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 11 Apr 2000 06:22:50 +0000
Subject: [Linux-ia64] updated kernel diff on kernel.org
Message-Id: <marc-linux-ia64-105590678205014@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, the latest kernel diff is now available as
linux-2.3.51-ia64-000410.diff.gz from:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

This is basically Friday's patch with the following additions:

	- Don's IA-32 updates (Don, please take a look at this
	  diff as there were a few changes: I put the trap handler
	  in ia32/ia32_traps.c and made some other small changes;
	  e.g., send SIGTRAP via send_sig_info instead of
	  force_sig_info).

	- Fix for SMP problem that Chuck found in the softirq handling
	  code (Chuck, you may want to review this as I implemented
	  this a bit differently and have not had a chance to test it
	  on SMP).

	- The IA64_UL() change that fixes Jes's grief with the
	  FPSR_DEFAULT macro

That should be it.  The irq debug printk's are still there, I'm
afraid.  They'll stay there as long as the IDE secondary channel
continues to disfunction.

Note: I suspect there is another signal-delivery related bug as
building gcc with profiling enabled still fails for me.  Stay tuned...

	--david


