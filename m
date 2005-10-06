From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Oct 2005 22:25:00 +0000
Subject: bugfix git pull on ia64 linux tree
Message-Id: <200510062225.j96MP09o009567@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
In-Reply-To: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/mca.c |    5 +++++
 1 files changed, 5 insertions(+)

Bryan Sutula:
  [IA64] Avoid kernel hang during CMC interrupt storm

diff-tree 76e677e25dd3d8af77d0b3810eacaacaf2f93f2f (from c0758146adbe39514e75ac860ce7e49f865c2297)
Author: Bryan Sutula <Bryan.Sutula@hp.com>
Date:   Wed Oct 5 11:02:06 2005 -0600

    [IA64] Avoid kernel hang during CMC interrupt storm
    
    I've noticed a kernel hang during a storm of CMC interrupts, which was
    tracked down to the continual execution of the interrupt handler.
    
    There's code in the CMC handler that's supposed to disable CMC
    interrupts and switch to polling mode when it sees a bunch of CMCs.
    Because disabling CMCs across all CPUs isn't safe in interrupt context,
    the disable is done with a schedule_work().  But with continual CMC
    interrupts, the schedule_work() never gets executed.
    
    The following patch immediately disables CMC interrupts for the current
    CPU.  This then allows (at least) one CPU to ignore CMC interrupts,
    execute the schedule_work() code, and disable CMC interrupts on the rest
    of the CPUs.
    
    Acked-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Bryan Sutula <Bryan.Sutula@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1016,6 +1016,11 @@ ia64_mca_cmc_int_handler(int cmc_irq, vo
 
 			cmc_polling_enabled = 1;
 			spin_unlock(&cmc_history_lock);
+			/* If we're being hit with CMC interrupts, we won't
+			 * ever execute the schedule_work() below.  Need to
+			 * disable CMC interrupts on this processor now.
+			 */
+			ia64_mca_cmc_vector_disable(NULL);
 			schedule_work(&cmc_disable_work);
 
 			/*
