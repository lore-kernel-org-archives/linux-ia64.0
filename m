From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 09 Dec 2005 16:42:22 +0000
Subject: SAL calling conventions + locking
Message-Id: <4399B3EE.6050408@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The SAL specification does say that the SAL procedures should be called
with interrupts enabled if we call them in virtual mode.

Here is the simplified CPEI handler control flow:

ia64_mca_cpe_int_handler():

	/* SAL spec states this should run w/ interrupts enabled */
	local_irq_enable();
	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE):

		ia64_log_get():

			IA64_LOG_LOCK():

				spin_lock_irqsave():

			ia64_sal_get_state_info();
			IA64_LOG_UNLOCK()

		salinfo_log_wakeup()
		if (rh->severity = sal_log_severity_corrected)
			ia64_sal_clear_state_info();

Despite the note "SAL spec ... w/ interrupts enabled" the interrupts
are disabled before "ia64_sal_get_state_info()" is invoked.

Can someone please tell me:
- why the spec. requires to call the SAL with interrupts enabled,
- why Linux calls the SAL with interrupts disabled,
- what happens if the SAL is called with interrupts disabled?

The second issue is:
The lock of the log is released before "salinfo_log_wakeup()" could record
the existence of the current log. Two more logs can arrive and overwrite
the current log without even indicting the loss of the information.
(E.g. CPEI-s with interrupt redirection, CMCI-s on multiple CPUs.)
Should not we keep the log lock at least while "salinfo_log_wakeup()"
executes?

Thanks.

Zoltan Menyhart
