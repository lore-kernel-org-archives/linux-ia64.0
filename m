From: Keith Owens <kaos@sgi.com>
Date: Thu, 06 Feb 2003 12:02:27 +0000
Subject: [Linux-ia64] SAL_MC_RENDEZ logic
Message-Id: <marc-linux-ia64-105590709805820@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.20-ia64-021210/arch/ia64/kernel/mca.c::ia64_mca_rendez_int_handler

        /* Register with the SAL monarch that the slave has
         * reached SAL
         */
        ia64_sal_mc_rendez();

        /* Wait for the wakeup IPI from the monarch
         * This waiting is done by polling on the wakeup-interrupt
         * vector bit in the processor's IRRs
         */
        ia64_mca_wakeup_ipi_wait();

The documentation for SAL_MC_RENDEZ (24535901.pdf) says that SAL itself
spins, looking for the wakeup ipi.  Why is the kernel code doing the
same work?  Either SAL_MC_RENDEZ does not spin (and the SAL docs are
wrong) or the kernel code in ia64_mca_wakeup_ipi_wait is redundant.

Why do I care?  I am trying to get kdb/lcrash data after MCA.


