From: Fenghua Yu <fenghua.yu@intel.com>
Date: Mon, 13 Jul 2009 20:09:43 +0000
Subject: [PATCH] linux-next arch/ia64/kernel/setup.c: Fix setup_per_cpu_areas() compilation error
Message-Id: <20090713200942.GA19606@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <A6AD88C3F2289247BE726C37303E1EB8B06CB5E9@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB8B06CB5E9@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Rothwell <sfr@canb.auug.org.au>, Tejun Heo <tj@kernel.org>
Cc: linux-next@vger.kernel.org, linux-ia64@vger.kernel.org

Fix ia64 build setup_per_cpu_areas() redifinition issue in UP configuration

When compiling ia64 kernel in UP configuration, the following compilation errors
are reported:

arch/ia64/kernel/setup.c:860: error: redefinition of 'setup_per_cpu_areas'
include/linux/percpu.h:185: error: previous definition of 'setup_per_cpu_areas' was here

The patch fixes the issue in arch/ia64/kernel/setup.c

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---

The commit e74e396204bfcb67570ba4517b08f5918e69afea in linux-next causes this
build issue.  

 setup.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 1b23ec1..1de86c9 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -855,11 +855,17 @@ identify_cpu (struct cpuinfo_ia64 *c)
 	c->unimpl_pa_mask = ~((1L<<63) | ((1L << phys_addr_size) - 1));
 }
 
+/*
+ * In UP configuration, setup_per_cpu_areas() is defined in
+ * include/linux/percpu.h
+ */
+#ifdef CONFIG_SMP
 void __init
 setup_per_cpu_areas (void)
 {
 	/* start_kernel() requires this... */
 }
+#endif
 
 /*
  * Do the following calculations:
