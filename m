From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 26 May 2003 21:21:18 +0000
Subject: [Linux-ia64] i2000 won't boot for me with current 2.5.69-bk
Message-Id: <marc-linux-ia64-105590723706035@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've tracked down the problem to something in mca.c:  the second call
to get SAL error logs causes a partial reboot instead of returning
error logs.  I instrumented bits of mca.c to see what was going on
(hope the printk output is self-explanatory). This is on a
uniprocessor i2000.

calling initcall 0xa00000010070fbe8  ( __initcall_ia64_mca_check_errors )
ia64_mca_log_sal_error_record
ia64_log_get()
ia64_log_get -- log_lock
ia64_log_get -- sal_get_state_info
SAL_CALL(isrv, SAL_GET_STATE_INFO, ...)
sal_get_state_info returned 0
log_get returned null
calling initcall 0xa00000010070fbf0 ( __initcall_ia64_mca_late_init )
init_timer(cmc_poll_timer)
init_tiemr(cpe_poll_timer)
acpi_request_vector(ACPI_INTERRUPT_CPE1) (obviously couldn't get it...)
ia64_mca_cpe_poll
set start_count
smp call ia64_mca_cpe_int_caller
local call ia64_mca_cpe_int_caller
ia64_mca_cpe_int_handler
ia64_mca_log_sal_error_record
ia64_log_get()
ia64_log_get -- log_lock
ia64_log_get -- sal_get_state_info
SAL_CALL(isrv, SAL_GET_STATE_INFO, ...)

(Monitor goes blank, I hear the floppy drive seek, and machine becomes
totally unresponsive and needs to be power cycled to continue)

Does anyone have any ideas?

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.

