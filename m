From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 26 Nov 2001 23:41:31 +0000
Subject: Re: [Linux-ia64] where to set rr for uncached region
Message-Id: <marc-linux-ia64-105590698805545@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805542@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805542@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 22 Nov 2001 20:36:47 +0900, nomura@hpc.bs1.fc.nec.co.jp said:

  >> Hello, Current code sets rr for region 6 (kernel uncached region)
  >> in ia64_mmu_init().  However, thinking about application
  >> processors, there are some printk()s before ia64_mmu_init() to be
  >> called.  Since printk() ends up in vt_console_print() and store
  >> to uncached region will happen, I think this cause a problem.

  >> In reality, MCAs always happen on our machine after AP prints
  >> "CPU 1: mapping PAL code ..." to serial console. The processor
  >> log shows that MCA happend in vt_console_print() on CPU1.

  >> I can work around the problem by applying this patch.

  >> I've noticed the problem when EARLY_PRINTK was deleted from
  >> config option.  So I'm curious about whether anyone has not
  >> experienced same kind of problem.

Hmmh, this is a bit of a nasty problem.  We shouldn't be calling any
console drivers until an AP is fully initialized.  But the platform
independent part of Linux currently only delays printing on the
boostrap processor.  Perhaps printk() should be enhanced with a check
to ensure that a processor is ready for calling the console driver.
For example, in __call_console_drivers() we could have something along
the lines of:

	for (con = console_drivers; con; con = con->next) {
		if ((con->flags & CON_ENABLED) && con->write
		    && (cpu_online_map & 1UL << smp_processor_id()))
			con->write(con, &LOG_BUF(start), end - start);
	}

Do you want to try this?

	--david

