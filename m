From: Hirofumi Fujita <h-fujita@ebina.hitachi.co.jp>
Date: Mon, 20 Nov 2000 11:07:25 +0000
Subject: [Linux-ia64] kernel test10 CMCV definition
Message-Id: <marc-linux-ia64-105590678205752@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

In test10 kernel, the definition of CMC vector register looks
different from Intel's documnet (The Itanium Architecture Software
Developer's Manual Vol. 2 rev. 1.1: System Architecture).

The order of bit fields are wrong ?

Hirofumi Fujita
Hitachi, Ltd.

--- linux-2.4.0-test10-ia64-001115/include/asm-ia64/mca.h.org	Thu Nov 16 17:46:36 2000
+++ linux-2.4.0-test10-ia64-001115/include/asm-ia64/mca.h	Mon Nov 20 17:23:24 2000
@@ -46,11 +46,11 @@
 	u64	cmcv_regval;
 	struct	{
 		u64  	cmcr_vector		: 8;
-		u64	cmcr_ignored1		: 47;
-		u64	cmcr_mask		: 1;
-		u64	cmcr_reserved1		: 3;
-		u64	cmcr_ignored2		: 1;
-		u64	cmcr_reserved2		: 4;
+		u64	cmcr_reserved1		: 4;
+		u64	cmcr_ignored1		: 1;
+		u64	cmcr_reserved2		: 3;
+		u64	cmcr_mask		: 1;
+		u64	cmcr_ignored2		: 47;
 	} cmcv_reg_s;
 
 } cmcv_reg_t;

