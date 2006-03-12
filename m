From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 16:52:20 +0000
Subject: [patch 1/6] add __init declaration to mca functions
Message-Id: <200603121652.k2CGqIg10015@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mark init related variable and functions with appropriate
__init* declaration to mca functions.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/kernel/mca.c.orig	2006-03-12 01:23:18.000000000 -0800
+++ ./arch/ia64/kernel/mca.c	2006-03-12 09:01:44.713161302 -0800
@@ -133,7 +133,7 @@ static int cpe_poll_enabled = 1;
 
 extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
 
-static int mca_init;
+static int mca_init __initdata;
 
 
 static void inline
@@ -184,7 +184,7 @@ static ia64_state_log_t ia64_state_log[I
  * Inputs   :   info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
  * Outputs	:	None
  */
-static void
+static void __init
 ia64_log_init(int sal_info_type)
 {
 	u64	max_size = 0;
@@ -359,7 +359,7 @@ ia64_mca_cpe_int_handler (int cpe_irq, v
  *  Outputs
  *      None
  */
-static void
+static void __init
 ia64_mca_register_cpev (int cpev)
 {
 	/* Register the CPE interrupt vector with SAL */
@@ -392,7 +392,7 @@ ia64_mca_register_cpev (int cpev)
  * Outputs
  *	None
  */
-void
+void __cpuinit
 ia64_mca_cmc_vector_setup (void)
 {
 	cmcv_reg_t	cmcv;
@@ -1416,7 +1416,7 @@ static struct irqaction mca_cpep_irqacti
  * format most of the fields.
  */
 
-static void
+static void __cpuinit
 format_mca_init_stack(void *mca_data, unsigned long offset,
 		const char *type, int cpu)
 {
@@ -1440,7 +1440,7 @@ format_mca_init_stack(void *mca_data, un
 
 /* Do per-CPU MCA-related initialization.  */
 
-void __devinit
+void __cpuinit
 ia64_mca_cpu_init(void *cpu_data)
 {
 	void *pal_vaddr;



