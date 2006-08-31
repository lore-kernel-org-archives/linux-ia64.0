From: Jack Steiner <steiner@sgi.com>
Date: Thu, 31 Aug 2006 16:35:57 +0000
Subject: [PATCH] - SN fix for cpu hotplug/kexec
Message-Id: <20060831163557.GA31856@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The sn_cpu_init() is required for cpu initialization on SN platforms.
Change __init to __cpuinit so that the function is not freed with init code/data.


	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2006-08-31 11:14:49.000000000 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2006-08-31 11:22:20.970284690 -0500
@@ -565,7 +565,7 @@ static void __init sn_init_pdas(char **c
  * Also sets up a few fields in the nodepda.  Also known as
  * platform_cpu_init() by the ia64 machvec code.
  */
-void __init sn_cpu_init(void)
+void __cpuinit sn_cpu_init(void)
 {
 	int cpuid;
 	int cpuphyid;
