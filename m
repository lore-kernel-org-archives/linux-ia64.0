From: Jiri Kosina <jkosina@suse.cz>
Date: Wed, 08 Feb 2012 14:32:13 +0000
Subject: [PATCH] [IA64] disable interrupts when exiting from ia64_mca_cmc_int_handler()
Message-Id: <alpine.LNX.2.00.1202081530510.24127@pobox.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-kernel@vger.kernel.org, Raymund Will <rw@suse.de>, linux-ia64@vger.kernel.org

SAL specification mandates that ia64_mca_log_sal_error_record() gets 
called with interrupts enabled, and that's why ia64_mca_cmc_int_handler() 
is enabling them. It however forgets to re-disable them when exiting, 
which triggers WARN_ON() in generic IRQ handler.

Disable the interrupts again before exiting. This is analogous to 
a3967685745 ("[IA64] disable interrupts at end of 
ia64_mca_cpe_int_handler()").

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 arch/ia64/kernel/mca.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 84fb405..8192009 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1447,6 +1447,8 @@ out:
 	/* Get the CMC error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC);
 
+	local_irq_disable();
+
 	return IRQ_HANDLED;
 }
 
-- 
Jiri Kosina
SUSE Labs
