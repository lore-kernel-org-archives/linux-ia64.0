From: nomura@hpc.bs1.fc.nec.co.jp
Date: Thu, 29 Nov 2001 07:34:21 +0000
Subject: Re: [Linux-ia64] where to set rr for uncached region
Message-Id: <marc-linux-ia64-105590698805560@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805542@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805542@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Thank you for your suggestion. It's a better approach.
Though putting the check in __call_console_drivers() does fix the problem,
it's not satisfactory. Because, until cpu_online_map is set up, log_buf is
flushed without printing.

So I put the check in release_console_sem().
How about this fix?

From: David Mosberger <davidm@hpl.hp.com>
Subject: Re: [Linux-ia64] where to set rr for uncached region
Date: Mon, 26 Nov 2001 15:41:31 -0800

> Hmmh, this is a bit of a nasty problem.  We shouldn't be calling any
> console drivers until an AP is fully initialized.  But the platform
> independent part of Linux currently only delays printing on the
> boostrap processor.  Perhaps printk() should be enhanced with a check
> to ensure that a processor is ready for calling the console driver.
> For example, in __call_console_drivers() we could have something along
> the lines of:
> 
> 	for (con = console_drivers; con; con = con->next) {
> 		if ((con->flags & CON_ENABLED) && con->write
> 		    && (cpu_online_map & 1UL << smp_processor_id()))
> 			con->write(con, &LOG_BUF(start), end - start);
> 	}
> 
> Do you want to try this?

Index: kernel/printk.c
=================================RCS file: /home/cvsadm/cvsroot/linux/kernel/printk.c,v
retrieving revision 1.1.1.8.2.1
diff -u -r1.1.1.8.2.1 printk.c
--- kernel/printk.c	2001/11/27 08:28:04	1.1.1.8.2.1
+++ kernel/printk.c	2001/11/29 06:20:35
@@ -505,6 +505,10 @@
 	for ( ; ; ) {
 		spin_lock_irqsave(&logbuf_lock, flags);
 		must_wake_klogd |= log_start - log_end;
+#ifndef CONFIG_IA64_EARLY_PRINTK
+		if (!(cpu_online_map & 1UL << smp_processor_id()))
+			break;
+#endif
 		if (con_start = log_end)
 			break;			/* Nothing to print */
 		_con_start = con_start;


Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.

