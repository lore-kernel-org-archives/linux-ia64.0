From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Tue, 15 Apr 2003 10:59:42 +0000
Subject: [Linux-ia64] [PATCH] iosapic fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Tue_Apr_15_19:59:42_2003_641)--"
Message-Id: <marc-linux-ia64-105590723705504@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

----Next_Part(Tue_Apr_15_19:59:42_2003_641)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

This patch fixes waste of interrupt vector pool by not
allocating an interrupt vector to a GSI which has no corresponding
IO SAPIC.

Tested on NEC TX7 and BigSur.

Thanks,
---
Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>

----Next_Part(Tue_Apr_15_19:59:42_2003_641)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="iosapic.c.diff"

--- linux/arch/ia64/kernel/iosapic.c.orig	Tue Apr 15 19:41:22 2003
+++ linux/arch/ia64/kernel/iosapic.c	Tue Apr 15 19:39:19 2003
@@ -709,6 +709,9 @@
 
 		vector = gsi_to_vector(gsi);
 		if (vector < 0) {
+			if (find_iosapic(gsi) < 0)
+				continue;
+
 			/* allocate a vector for this interrupt line */
 			if (pcat_compat && (gsi < 16))
 				vector = isa_irq_to_vector(gsi);

----Next_Part(Tue_Apr_15_19:59:42_2003_641)----

