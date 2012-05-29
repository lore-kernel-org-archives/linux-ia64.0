From: Yong Zhang <yong.zhang0@gmail.com>
Date: Tue, 29 May 2012 07:16:02 +0000
Subject: [RFC PATCH 07/10] ia64: smp: remove call to ipi_call_lock_irq()/ipi_call_unlock_irq()
Message-Id: <1338275765-3217-8-git-send-email-yong.zhang0@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1338275765-3217-1-git-send-email-yong.zhang0@gmail.com>
In-Reply-To: <1338275765-3217-1-git-send-email-yong.zhang0@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: ralf@linux-mips.org, sshtylyov@mvista.com, david.daney@cavium.com, nikunj@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, axboe@kernel.dk, mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org, akpm@linux-foundation.org, srivatsa.bhat@linux.vnet.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

From: Yong Zhang <yong.zhang@windriver.com>

1) call_function.lock used in smp_call_function_many() is just to protect
   call_function.queue and &data->refs, cpu_online_mask is outside of the
   lock. And it's not necessary to protect cpu_online_mask,
   because data->cpumask is pre-calculate and even if a cpu is brougt up
   when calling arch_send_call_function_ipi_mask(), it's harmless because
   validation test in generic_smp_call_function_interrupt() will take care
   of it.

2) For cpu down issue, stop_machine() will guarantee that no concurrent
   smp_call_fuction() is processing.

Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/smpboot.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 1113b8a..963d2db 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -382,7 +382,6 @@ smp_callin (void)
 	set_numa_node(cpu_to_node_map[cpuid]);
 	set_numa_mem(local_memory_node(cpu_to_node_map[cpuid]));
 
-	ipi_call_lock_irq();
 	spin_lock(&vector_lock);
 	/* Setup the per cpu irq handling data structures */
 	__setup_vector_irq(cpuid);
@@ -390,7 +389,6 @@ smp_callin (void)
 	set_cpu_online(cpuid, true);
 	per_cpu(cpu_state, cpuid) = CPU_ONLINE;
 	spin_unlock(&vector_lock);
-	ipi_call_unlock_irq();
 
 	smp_setup_percpu_timer();
 
-- 
1.7.5.4

