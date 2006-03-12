From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 12 Mar 2006 01:11:24 +0000
Subject: [patch] mark init related functions/variable with __init declaration
Message-Id: <200603120111.k2C1BNg23144@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Speaking of the devil, bunch of functions and variable in mca.c
can be marked with __init variants.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/kernel/mca.c.orig	2006-03-11 17:22:18.324203353 -0800
+++ ./arch/ia64/kernel/mca.c	2006-03-11 17:27:58.232402314 -0800
@@ -133,7 +133,7 @@ static int cpe_poll_enabled = 1;
 
 extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
 
-static int mca_init;
+static int __initdata mca_init;
 
 
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
@@ -392,7 +392,7 @@ ia64_mca_register_cpev (int cpev)
  * Outputs
  *	None
  */
-void
+void __devinit
 ia64_mca_cmc_vector_setup (void)
 {
 	cmcv_reg_t	cmcv;
@@ -1416,7 +1416,7 @@ static struct irqaction mca_cpep_irqacti
  * format most of the fields.
  */
 
-static void
+static void __devinit
 format_mca_init_stack(void *mca_data, unsigned long offset,
 		const char *type, int cpu)
 {

