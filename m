From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Thu, 11 Jun 2015 04:48:26 +0000
Subject: [PATCH] arch/ia64: Use setup_timer
Message-Id: <20150611044817.GA5753@vaishali-Ideapad-Z570>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>

Use the timer API function setup_timer instead of structure field
assignments to initialize a timer.

A simplified version of the Coccinelle semantic patch that performs
this transformation is as follows:

@change@
expression e1, e2, a;
@@

-init_timer(&e1);
+setup_timer(&e1, a, 0UL);
... when != a = e2
-e1.function = a;

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 arch/ia64/kernel/mca.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index dd5801e..2889412 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -2117,8 +2117,7 @@ ia64_mca_late_init(void)
 	register_hotcpu_notifier(&mca_cpu_notifier);
 
 	/* Setup the CMCI/P vector and handler */
-	init_timer(&cmc_poll_timer);
-	cmc_poll_timer.function = ia64_mca_cmc_poll;
+	setup_timer(&cmc_poll_timer, ia64_mca_cmc_poll, 0UL);
 
 	/* Unmask/enable the vector */
 	cmc_polling_enabled = 0;
@@ -2129,8 +2128,7 @@ ia64_mca_late_init(void)
 #ifdef CONFIG_ACPI
 	/* Setup the CPEI/P vector and handler */
 	cpe_vector = acpi_request_vector(ACPI_INTERRUPT_CPEI);
-	init_timer(&cpe_poll_timer);
-	cpe_poll_timer.function = ia64_mca_cpe_poll;
+	setup_timer(&cpe_poll_timer, ia64_mca_cpe_poll, 0UL);
 
 	{
 		unsigned int irq;
-- 
1.9.1

