From: Grant Grundler <iod00d@hp.com>
Date: Thu, 18 Nov 2004 23:01:18 +0000
Subject: [PATCH] 2.6.10-rc1 pfmon broken by bad merge?
Message-Id: <20041118230118.GC15892@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Just pulled/rebuilt from the bk linux-ia64-release-2.6.10 tree
and it failed to build with :
arch/ia64/kernel/perfmon.c: In function `pfm_handle_work':
arch/ia64/kernel/perfmon.c:5068: error: parse error before '/' token

Following trivial patch fixes what looks like a merge bug.

Signed-off-by: Grant Grundler <iod00d@hp.com>

grant

=== arch/ia64/kernel/perfmon.c 1.100 vs edited ==--- 1.100/arch/ia64/kernel/perfmon.c	2004-11-18 10:43:37 -08:00
+++ edited/arch/ia64/kernel/perfmon.c	2004-11-18 14:58:03 -08:00
@@ -5065,7 +5065,7 @@
 	  * when returning to user level (PUStk=1), in which case
 	  * there is no risk of kernel stack overflow due to deep
 	  * interrupt nesting.
-	  */                                                                         */
+	  */
 	BUG_ON(flags & IA64_PSR_I);
 	local_irq_enable();
 
