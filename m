From: "Alan D. Brunelle" <Alan.Brunelle@hp.com>
Date: Thu, 03 Apr 2008 18:30:36 +0000
Subject: [PATCH] Fix unlock ordering in smp_callin
Message-Id: <47F5224C.3020604@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com

One should normally unlock in the reverse order of the lock calls,
and in this case there certainly is no reason not to.

To better see the results (with locks included), here's the complete
section of corrected code:

        lock_ipi_calllock();
        spin_lock(&vector_lock);
        /* Setup the per cpu irq handling data structures */
        __setup_vector_irq(cpuid);
        cpu_set(cpuid, cpu_online_map);
        per_cpu(cpu_state, cpuid) = CPU_ONLINE;
        spin_unlock(&vector_lock);
        unlock_ipi_calllock();

Signed-off-by: Alan D. Brunelle <alan.brunelle@hp.com>
---
 arch/ia64/kernel/smpboot.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 32ee597..16483be 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -400,9 +400,9 @@ smp_callin (void)
 	/* Setup the per cpu irq handling data structures */
 	__setup_vector_irq(cpuid);
 	cpu_set(cpuid, cpu_online_map);
-	unlock_ipi_calllock();
 	per_cpu(cpu_state, cpuid) = CPU_ONLINE;
 	spin_unlock(&vector_lock);
+	unlock_ipi_calllock();

 	smp_setup_percpu_timer();

-- 
1.5.2.5


