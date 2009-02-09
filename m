From: Alex Chiang <achiang@hp.com>
Date: Mon, 09 Feb 2009 18:16:57 +0000
Subject: [PATCH v2 2/2] ia64: Remove redundant cpu_clear() in __cpu_disable
Message-Id: <20090209181657.GF19064@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090209181338.GD19064@ldl.fc.hp.com>
In-Reply-To: <20090209181338.GD19064@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, stable@kernel.org, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

The second call to cpu_clear() is redundant, as we've already removed
the CPU from cpu_online_map before calling migrate_platform_irqs().

Cc: stable@kernel.org
Signed-off-by: Alex Chiang <achiang@hp.com>
---
 arch/ia64/kernel/smpboot.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 2ec5bbf..5229054 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -740,11 +740,10 @@ int __cpu_disable(void)
 
 	if (migrate_platform_irqs(cpu)) {
 		cpu_set(cpu, cpu_online_map);
-		return (-EBUSY);
+		return -EBUSY;
 	}
 
 	remove_siblinginfo(cpu);
-	cpu_clear(cpu, cpu_online_map);
 	fixup_irqs();
 	local_flush_tlb_all();
 	cpu_clear(cpu, cpu_callin_map);
-- 
1.6.0.1.161.g7f314

